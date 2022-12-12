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

import DevKit
import Foundation

// MARK: - StatefulView

/// A view to receive and render a state
public protocol StatefulView: AnyObject {
    associatedtype State: StateContainer
    associatedtype Effect: SideEffect

    var renderPolicy: RenderPolicy { get }

    /// Render should be used to update the view with the new state.
    /// If the state has changed it's base case, distinctState will be provided to help transition between states.
    func render(state: State, from distinctState: State.State?, effect: Effect?)
}

/// A HostingViewController type
public protocol HostingStatefulView<Effect>: StatefulView {
    func receive(effect: Effect)
}

// MARK: - AnyStatefulView

/// Weak container and type erasure for StatefulViews
class AnyStatefulView<State: StateContainer, Effect: SideEffect> {
    private let _render: (State, State.State?, Effect?) -> Void
    private let _emit: ((Effect) -> Void)?
    private let _renderPolicy: () -> RenderPolicy
    let identifier: String

    private(set) lazy var emitEffects: Bool = _emit != nil

    init<View: StatefulView>(_ statefulView: View) where View.State == State, View.Effect == Effect {
        _render = { [weak statefulView] newState, oldState, effect in
            statefulView?.render(state: newState, from: oldState, effect: effect)
        }

        _renderPolicy = { [weak statefulView] in
            statefulView?.renderPolicy ?? .notPossible(.viewDeallocated)
        }

        switch statefulView {
        case let view as any HostingStatefulView<Effect>:
            _emit = { [weak view] effect in
                view?.receive(effect: effect)
            }

        default:
            _emit = nil
        }

        identifier = String(describing: statefulView)
    }

    func emit(effect: Effect) {
        Assert.isNotNil(_emit, in: .stateKit, message: "emit was called while _emit is nil.")
        _emit?(effect)
    }

    func render(state: State, from distinctState: State.State?, effect: Effect?) {
        guard renderPolicy.isPossible else {
            Log.error(in: .stateKit, "view [\(identifier)] cannot be rendered. \(renderPolicy)")
            return
        }

        if
            let effect,
            let _emit
        {
            _emit(effect)
            return
        }

        _render(state, distinctState, effect)
    }

    var renderPolicy: RenderPolicy {
        _renderPolicy()
    }
}

// MARK: - AnyStatefulView: Hashable

extension AnyStatefulView: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier.hash)
    }

    static func == (lhs: AnyStatefulView, rhs: AnyStatefulView) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
