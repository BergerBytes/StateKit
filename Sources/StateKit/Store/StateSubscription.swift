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

@available(*, deprecated)
public class StateSubscription<State> {
    private(set) var closure: ((State) -> Void)?

    public init(_ closure: @escaping (State) -> Void) {
        self.closure = closure
    }

    public func fire(_ state: State) {
        closure?(state)
    }

    public func stop() {
        closure = nil
    }

    deinit {
        stop()
    }
}

protocol StoreSubscriptionContainer {
    associatedtype State: StateContainer
    associatedtype Effect: SideEffect

    func fire(_ state: State, _ sideEffect: Effect)
    func fire(_ state: State)

    func stop()
}

public class NoDataStoreSubscription<State: StateContainer, Effect: SideEffect>: StoreSubscription<State, Effect> {
    public init(_ closure: @escaping () -> Void) {
        super.init { _, _  in closure() }
    }
}

public class StateOnlyStoreSubscription<State: StateContainer>: StoreSubscription<State, NoSideEffects> {
    private(set) var stateClosure: ((State) -> Void)?

    public init(_ closure: @escaping (State) -> Void) {
        stateClosure = closure
        super.init { _, _  in }
    }

    override public func fire(_ state: State) {
        stateClosure?(state)
    }
}

public class StoreSubscription<State: StateContainer, Effect: SideEffect> {
    private(set) var closure: ((State, Effect?) -> Void)?

    public init(_ closure: @escaping (State, Effect?) -> Void) {
        self.closure = closure
    }

    open func fire(_ state: State, _ sideEffect: Effect) {
        closure?(state, sideEffect)
    }

    open func fire(_ state: State) {
        closure?(state, nil)
    }

    public func stop() {
        closure = nil
    }

    deinit {
        stop()
    }
}
