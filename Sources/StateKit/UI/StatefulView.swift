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

// MARK: - StatefulView

/// A view to receive and render a state
public protocol StatefulView: AnyObject {
    associatedtype State: ViewState

    /// Render should be used to update the view with the new state.
    /// If the state has changed it's base case, distinctState will be provided to help transition between states.
    func render(state: State, from distinctState: State.State?)
    var renderPolicy: RenderPolicy { get }
}

// MARK: - AnyStatefulView

/// Weak container and type erasure for StatefulViews
class AnyStatefulView<State: ViewState>: StatefulView {
    private let _render: (State, State.State?) -> Void
    private let _renderPolicy: () -> RenderPolicy
    let identifier: String

    init<View: StatefulView>(_ statefulView: View) where View.State == State {
        _render = { [weak statefulView] newState, oldState in
            statefulView?.render(state: newState, from: oldState)
        }

        _renderPolicy = { [weak statefulView] in
            statefulView?.renderPolicy ?? .notPossible(.viewDeallocated)
        }

        identifier = String(describing: statefulView)
    }

    func render(state: State, from distinctState: State.State?) {
        guard renderPolicy.isPossible else {
            Debug.log(level: .error, "view [\(identifier)] cannot be rendered. \(renderPolicy)")
            return
        }
        _render(state, distinctState)
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
