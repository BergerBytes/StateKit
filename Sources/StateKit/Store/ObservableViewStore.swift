//  Copyright © 2022 BergerBytes LLC. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED  AS IS AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import Combine
import DevKit
import Foundation

public protocol ObservableViewStoreType: ObservableObject, StoreType { }

open class ObservableViewStore<State: StateContainer, Effect: SideEffect>: ObservableObject, ObservableViewStoreType {
    private var subscriptions: NSHashTable<StoreSubscription<State, Effect>> = .weakObjects()
    public var otherStoresSubscriptions: [String: AnyObject] = .init()
    private var views = Set<AnyStatefulView<State, Effect>>()

    /// String identifying a unique store. Override if needed to differentiate stores of the same type. Default: `String(describing: self)`
    open var storeIdentifier: String {
        String(describing: self)
    }

    @Published public var state: State
    private let effectPublisher = EffectPublisher<Effect>()

    public init(initialState: State) {
        state = initialState
    }

    /// Force push the current state object to all subscribers.
    /// This should be not be needed for most use cases and should only be called by Store subclasses.
    public func forcePushState() {
        objectWillChange.send()
    }

    public func emit(_ effect: Effect) {
        effectPublisher.send(effect)
    }

    public func eraseToAnyPublisher() -> AnyEffectPublisher<Effect> {
        effectPublisher.eraseToAnyPublisher()
    }

    // MARK: - Subscription

    /// Subscribe's to the store's State and SideEffect updates.
    ///
    /// Helper method to subscribe to other stores that automatically retains the subscription tokens
    /// so children stores can easily subscribe to other store changes without hassle.
    /// - Parameters:
    ///   - store: The store to subscribe to.
    ///   - handler: The update handle to receive State and SideEffect updates.
    open func subscribe<State, Effect>(to store: Store<State, Effect>, handler: @escaping (State, Effect?) -> Void) {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Log.warning(in: .stateKit, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }

        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }

    /// Subscribe to the store's State updates when the store contains no side effects.
    /// - Parameters:
    ///   - store: The store to subscribe to.
    ///   - handler: The update handle to receive State updates.
    open func subscribe<Store: StoreType>(to store: Store, handler: @escaping (Store.State) -> Void) where Store: NoEffectsStoreType {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Log.warning(in: .stateKit, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }

        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }

    /// Subscribe to the store's updates without getting the State or SideEffect back.
    /// - Parameter store: The store to subscribe to.
    open func unsubscribe(from store: Store<some StateContainer, some SideEffect>) {
        if otherStoresSubscriptions[store.storeIdentifier] == nil {
            Log.error("Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[store.storeIdentifier] = nil
    }

    open func subscribe(to store: Store<some StateContainer, some SideEffect>, handler: @escaping () -> Void) {
        if otherStoresSubscriptions[store.storeIdentifier] != nil {
            Log.warning(in: .stateKit, "Subscribing to an already subscribed store. This will replace the previous subscription. \(storeIdentifier)")
        }

        otherStoresSubscriptions[store.storeIdentifier] = store.subscribe(handler)
    }

    open func unsubscribe(from storeIdentifier: String) {
        if otherStoresSubscriptions[storeIdentifier] == nil {
            Log.error(in: .stateKit, "Trying to unsubscribe from a not subscribed store. \(storeIdentifier)")
        }

        otherStoresSubscriptions[storeIdentifier] = nil
    }

    open func subscribe(_ closure: @escaping (State, Effect?) -> Void) -> StoreSubscription<State, Effect> {
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
