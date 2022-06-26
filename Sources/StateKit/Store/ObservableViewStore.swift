import Debug
import Foundation

@MainActor
open class ObservableViewStore<State: StateContainer>: ObservableObject {
    private var subscriptions: NSHashTable<StateSubscription<State>> = NSHashTable<StateSubscription<State>>.weakObjects()
    public var otherStoresSubscriptions: [String : AnyObject] = [String: AnyObject]()
    
    /// String identifying a unique store. Override if needed to differentiate stores of the same type. Default: `String(describing: self)`
    open var storeIdentifier: String {
        return String(describing: self)
    }
    
    @Published public var state: State

    public init(initialState: State) {
        state = initialState
    }
    
    // MARK: - Subscription
    
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
    
    open func unsubscribe(from storeIdentifier: String) {
        if otherStoresSubscriptions[storeIdentifier] == nil {
            Debug.log(level: .error, "Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[storeIdentifier] = nil
    }
    
    open func subscribe(_ closure: @escaping (State) -> Void) -> StateSubscription<State> {
        let subscription = StateSubscription(closure)
        subscriptions.add(subscription)
        subscription.fire(state)
        return subscription
    }
}

@MainActor
open class NSObservableViewStore<State: StateContainer>: NSObject, ObservableObject {
    private var subscriptions = NSHashTable<StateSubscription<State>>.weakObjects()
    public var otherStoresSubscriptions = [String: AnyObject]()
    
    /// String identifying a unique store. Override if needed to differentiate stores of the same type. Default: `String(describing: self)`
    open var storeIdentifier: String {
        return String(describing: self)
    }
    
    @Published public var state: State

    public init(initialState: State) {
        state = initialState
    }
    
    // MARK: - Subscription
    
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
    
    open func unsubscribe(from storeIdentifier: String) {
        if otherStoresSubscriptions[storeIdentifier] == nil {
            Debug.log(level: .error, "Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[storeIdentifier] = nil
    }
    
    open func subscribe(_ closure: @escaping (State) -> Void) -> StateSubscription<State> {
        let subscription = StateSubscription(closure)
        subscriptions.add(subscription)
        subscription.fire(state)
        return subscription
    }
}
