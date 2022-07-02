import Foundation
import Debug

/// Specialized ViewStore with ViewController lifecycle events.
/// Used with ``ViewController``
open class NSViewControllerStore<State: ViewState>: NSViewStore<State> {
    open func viewControllerDidLoad() {}
    open func viewControllerWillAppear() {}
    open func viewControllerDidAppear() {}
    open func viewControllerWillDisappear() {}
    open func viewControllerDidDisappear() {}
}

/// A state store designed to provide a view state to a ViewController and additional stateful views.
open class NSViewStore<State: ViewState>: NSStore<State> {
    private var views = Set<AnyStatefulView<State>>()
    
    open override var state: State {
        didSet(oldState) {
            // Update every tracked stateful view with the updated state.
            stateTransactionQueue.async { [weak self, state, oldState, views] in
                views.forEach {
                    self?.stateDidChange(oldState: oldState, newState: state, view: $0)
                }
            }
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
    
    public override func forcePushState() {
        // Update every tracked stateful view with the updated state.
        stateTransactionQueue.async { [weak self, state, views] in
            views.forEach {
                self?.stateDidChange(oldState: state, newState: state, view: $0, force: true)
            }
        }
    }
}

// MARK: - Subscription

extension NSViewStore {
    public func subscribe<View: StatefulView>(from view: View) throws where View.State == State {
        let anyView = AnyStatefulView(view)
        if views.insert(anyView).inserted {
            stateDidChange(oldState: state, newState: state, view: anyView, force: true)
        } else {
            throw ViewStore<State>.SubscriptionError.viewIsAlreadySubscribed
        }
    }
    
    public func unsubscribe<View: StatefulView>(from view: View) throws where View.State == State {
        if views.remove(AnyStatefulView(view)) == nil {
            throw ViewStore<State>.SubscriptionError.viewIsNotSubscribed
        }
    }
}

public func += <State, View: StatefulView>(left: NSViewStore<State>, right: View) throws where View.State == State {
    try left.subscribe(from: right)
}

public func -= <State, View: StatefulView>(left: NSViewStore<State>, right: View) throws where View.State == State {
    try left.unsubscribe(from: right)
}
