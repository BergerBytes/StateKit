import Debug
import Foundation

public protocol ObservableViewStoreType: ObservableObject, StoreType {
    associatedtype Delegate
}

open class ObservableViewStore<State: StateContainer, Effect: SideEffect, Delegate>: ObservableObject, ObservableViewStoreType {
    private var subscriptions: NSHashTable<StoreSubscription<State, Effect>> = NSHashTable<StoreSubscription<State, Effect>>.weakObjects()
    public var otherStoresSubscriptions: [String : AnyObject] = [String: AnyObject]()
    private var views = Set<AnyStatefulView<State, Effect>>()

    /// String identifying a unique store. Override if needed to differentiate stores of the same type. Default: `String(describing: self)`
    open var storeIdentifier: String {
        return String(describing: self)
    }
    
    @Published public var state: State

    public init(initialState: State) {
        state = initialState
    }
    
    // MARK: - Subscription
    
    /// Subscribe's to the store's State and SideEffect updates.
    ///
    /// Helper method to subscribe to other stores that automatically retains the subscription tokens
    /// so children stores can easily subscribe to other store changes without hassle.
    /// - Parameters:
    ///   - store: The store to subscribe to.
    ///   - handler: The update handle to receive State and SideEffect updates.
    open func subscribe<State, Effect>(to store: Store<State, Effect>, handler: @escaping (StoreUpdate<State, Effect>) -> Void) {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Debug.log(level: .warning, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }
        
        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }
    
    /// Subscribe to the store's State updates when the store contains no side effects.
    /// - Parameters:
    ///   - store: The store to subscribe to.
    ///   - handler: The update handle to receive State updates.
    open func subscribe<Store: StoreType>(to store: Store, handler: @escaping (Store.State) -> Void) where Store: NoEffectsStoreType {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Debug.log(level: .warning, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }
        
        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }
    
    /// Subscribe to the store's updates without getting the State or SideEffect back.
    /// - Parameter store: The store to subscribe to.
    open func unsubscribe<State, Effect>(from store: Store<State, Effect>) {
        if otherStoresSubscriptions[store.storeIdentifier] == nil {
            Debug.log(level: .error, "Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[store.storeIdentifier] = nil
    }
    
    open func subscribe<State, Effect>(to store: Store<State, Effect>, handler: @escaping () -> Void) {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Debug.log(level: .warning, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }
        
        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }
    
    open func unsubscribe(from storeIdentifier: String) {
        if otherStoresSubscriptions[storeIdentifier] == nil {
            Debug.log(level: .error, "Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[storeIdentifier] = nil
    }
    
    open func subscribe(_ closure: @escaping (StoreUpdate<State, Effect>) -> Void) -> StoreSubscription<State, Effect> {
        let subscription = StoreSubscription(closure)
        subscriptions.add(subscription)
        subscription.fire(state)
        return subscription
    }
    
    open func subscribe(_ closure: @escaping () -> Void) -> NoDataStoreSubscription<State, Effect> {
        let subscription = NoDataStoreSubscription<State, Effect>(closure)
        subscriptions.add(subscription)
        subscription.fire(state)
        return subscription
    }
}

extension ObservableViewStore: NoEffectsStoreType where Effect == NoSideEffects {
    public func subscribe(_ closure: @escaping (State) -> Void) -> StateOnlyStoreSubscription<State> {
        let subscription = StateOnlyStoreSubscription<State>(closure)
        subscriptions.add(subscription)
        subscription.fire(state)
        return subscription
    }
}
