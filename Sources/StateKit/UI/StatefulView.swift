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
    func render(state: State, from distinctState: State.State?, sideEffect: Effect?)
}

// MARK: - AnyStatefulView

/// Weak container and type erasure for StatefulViews
class AnyStatefulView<State: StateContainer, Effect: SideEffect> {
    private let _render: (State, State.State?, Effect?) -> Void
    private let _renderPolicy: () -> RenderPolicy
    let identifier: String

    init<View: StatefulView>(_ statefulView: View) where View.State == State, View.Effect == Effect {
        _render = { [weak statefulView] newState, oldState, sideEffect in
            statefulView?.render(state: newState, from: oldState, sideEffect: sideEffect)
        }

        _renderPolicy = { [weak statefulView] in
            statefulView?.renderPolicy ?? .notPossible(.viewDeallocated)
        }

        identifier = String(describing: statefulView)
    }

    func render(state: State, from distinctState: State.State?, sideEffect: Effect?) {
        guard renderPolicy.isPossible else {
            Log.error(in: .stateKit, "view [\(identifier)] cannot be rendered. \(renderPolicy)")
            return
        }
        _render(state, distinctState, sideEffect)
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
