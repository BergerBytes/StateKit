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
