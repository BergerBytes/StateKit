import Debug
import Foundation

// MARK: - StatefulView

/// A view to receive and render a state
public protocol StatefulView: AnyObject {
    associatedtype State: StateContainer
    associatedtype Effect: SideEffect

    /// Render should be used to update the view with the new state.
    /// If the state has changed it's base case, distinctState will be provided to help transition between states.
    func render(state: State, from distinctState: State.State?, sideEffect: Effect?)
    var renderPolicy: RenderPolicy { get }
}

// MARK: - AnyStatefulView

/// Weak container and type erasure for StatefulViews
class AnyStatefulView<State: StateContainer, Effect: SideEffect>: StatefulView {
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
            Debug.log(level: .error, "view [\(identifier)] cannot be rendered. \(renderPolicy)")
            return
        }
        _render(state, distinctState, sideEffect)
    }

    var renderPolicy: RenderPolicy {
        return _renderPolicy()
    }
}

// MARK: - AnyStatefulView: Hashable

extension AnyStatefulView: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier.hash)
    }

    static func == (lhs: AnyStatefulView, rhs: AnyStatefulView) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
