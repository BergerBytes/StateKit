import Foundation

/// State provided by a ViewStore to be delivered to a StatefulView
public protocol ViewState: StoreState {}

/// State provided by a Store
public protocol StoreState: Equatable where State: EnumState {
    associatedtype State
    var current: State { get set }
}

extension StoreState {
    /// Mutation composition helper to allow for multiple mutations to the state tree to execute as a single change.
    public mutating func update(_ update: (inout Self) -> Void) {
        var data = self
        update(&data)
        self = data
    }
}
