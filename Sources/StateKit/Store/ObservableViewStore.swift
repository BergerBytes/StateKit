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

import Debug
import Foundation

@MainActor
open class ObservableViewStore<State: StateContainer>: ObservableObject {
    private var subscriptions: NSHashTable<StateSubscription<State>> = .weakObjects()
    public var otherStoresSubscriptions: [String: AnyObject] = .init()

    /// String identifying a unique store. Override if needed to differentiate stores of the same type. Default: `String(describing: self)`
    open var storeIdentifier: String {
        String(describing: self)
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
        String(describing: self)
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
