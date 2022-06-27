import Foundation
import Debug

/// Specialized ViewStore with ViewController lifecycle events.
/// Used with ``ViewController``
open class ViewControllerStore<State: ViewState>: ViewStore<State> {
    open func viewControllerDidLoad() {}
    open func viewControllerWillAppear() {}
    open func viewControllerDidAppear() {}
    open func viewControllerWillDisappear() {}
    open func viewControllerDidDisappear() {}
}

/// A state store designed to provide a view state to a ViewController and additional stateful views.
open class ViewStore<State: ViewState> {
    public var otherStoresSubscriptions = [String: AnyObject]()
    private var views = Set<AnyStatefulView<State>>()
    internal lazy var stateTransactionQueue = DispatchQueue(
        label: "\(type(of: self)).\(storeIdentifier).StateTransactionQueue.\(UUID().uuidString)"
    )
    
    // The current state of the store.
    // This should be protected and changed only by subclasses.
    public var state: State {
        didSet(oldState) {
            stateTransactionQueue.async { [weak self, state, oldState] in
                self?.stateDidChange(oldState: oldState, newState: state)
            }
        }
    }
    
    /// String identifying a unique store. Override if needed to differentiate stores of the same type. Default: `String(describing: self)`
    open var storeIdentifier: String {
        return String(describing: self)
    }

    public init(initialState: State) {
        state = initialState
    }
    
    private func stateDidChange(oldState: State, newState: State) {
        views.forEach { [weak self] in
            self?.stateDidChange(oldState: oldState, newState: state, view: $0)
        }
    }
    
    private func stateDidChange(oldState: State, newState: State, view: AnyStatefulView<State>, force: Bool = false) {
        let handleChange = { [weak self, oldState, newState, view, force] in
            switch view.renderPolicy {
            case .possible:
                self?.handlePossibleRender(newState: newState, oldState: oldState, view: view, force: force)
            case .notPossible(let renderError):
                self?.handleNotPossibleRender(error: renderError, view: view)
            }
        }
        
        if Thread.current == stateTransactionQueue || !Thread.isMainThread {
            DispatchQueue.main.sync(execute: handleChange)
        } else {
            handleChange()
        }
    }
    
    private func handlePossibleRender(newState: State, oldState: State, view: AnyStatefulView<State>, force: Bool) {
        if force == false && newState == oldState {
            Debug.log(level: .stateKit, "[\(debugDescription)] Skip forwarding same state: \(newState.current.name)")
            return
        }

        if oldState.current.name != newState.current.name {
            Debug.log(level: .stateKit, "[\(debugDescription)] State did change from: \(oldState.current.name) to: \(newState.current.name)")
        } else {
            Debug.log(level: .stateKit, "[\(debugDescription)] State data changed. \(newState.current.name)")
        }
        
        let renderBlock = { [view, newState, oldState] in
            view.render(state: newState,
                        from: newState.current.isDistinct(from: oldState.current)
                            ? oldState.current
                            : nil)
        }
        
        DispatchQueue.main.async(execute: renderBlock)
    }
    
    private func handleNotPossibleRender(error: RenderPolicy.RenderError, view: AnyStatefulView<State>) {
        switch error {
        case .viewNotReady:
            Debug.log(level: .error, "[\(view)] view not ready to be rendered")
            
        case .viewDeallocated:
            Debug.log(level: .warning, "[\(view.identifier)] view deallocated")
            views.remove(view)
        }
    }
    
    public func forcePushState() {
        // Update every tracked stateful view with the updated state.
        stateTransactionQueue.async { [weak self, state, views] in
            views.forEach {
                self?.stateDidChange(oldState: state, newState: state, view: $0, force: true)
            }
        }
    }
}

// MARK: - Subscription

extension ViewStore {
    enum SubscriptionError: Error {
        /// The view is already subscribed to this view store.
        case viewIsAlreadySubscribed
        
        /// The view is not subscribed to this view store.
        case viewIsNotSubscribed
    }
    
    // Helper method to subscribe to other stores that automatically retains the subscription tokens
    // so children stores can easily subscribe to other store changes without hassle.
    open func subscribe<T>(to store: Store<T>, handler: @escaping (T) -> Void) {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Debug.log(level: .warning, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }
        
        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }
    
    open func unsubscribe<T>(from store: Store<T>) {
        if otherStoresSubscriptions[store.storeIdentifier] == nil {
            Debug.log(level: .error, "Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[store.storeIdentifier] = nil
    }
    
    public func subscribe<View: StatefulView>(from view: View) throws where View.State == State {
        let anyView = AnyStatefulView(view)
        if views.insert(anyView).inserted {
            stateDidChange(oldState: state, newState: state, view: anyView, force: true)
        } else {
            throw SubscriptionError.viewIsAlreadySubscribed
        }
    }
    
    public func unsubscribe<View: StatefulView>(from view: View) throws where View.State == State {
        if views.remove(AnyStatefulView(view)) == nil {
            throw SubscriptionError.viewIsNotSubscribed
        }
    }
}

public func += <State, View: StatefulView>(left: ViewStore<State>, right: View) throws where View.State == State {
    try left.subscribe(from: right)
}

public func -= <State, View: StatefulView>(left: ViewStore<State>, right: View) throws where View.State == State {
    try left.unsubscribe(from: right)
}

// MARK: - CustomDebugStringConvertible

extension ViewStore: CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(describing: type(of: self))
    }
}
