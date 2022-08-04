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

/// An update from a store consisting of a State and optional side effect.
public struct StoreUpdate<State: StateContainer, Effect: SideEffect> {
    public let state: State
    public let sideEffect: Effect?
}

protocol StoreSubscriptionContainer {
    associatedtype State: StateContainer
    associatedtype Effect: SideEffect
    
    func fire(_ update: StoreUpdate<State, Effect>)
    func fire(_ state: State, _ sideEffect: Effect)
    func fire(_ state: State)
    
    func stop()
}

public class NoDataStoreSubscription<State: StateContainer, Effect: SideEffect>: StoreSubscription<State, Effect> {
    public init(_ closure: @escaping () -> Void) {
        super.init( { _ in closure() })
    }
}

public class StateOnlyStoreSubscription<State: StateContainer>: StoreSubscription<State, NoSideEffects> {
    private(set) var stateClosure: ((State) -> Void)?

    public init(_ closure: @escaping (State) -> Void) {
        self.stateClosure = closure
        super.init({ _ in })
    }
    
    public override func fire(_ state: State) {
        stateClosure?(state)
    }
 
    public override func fire(_ update: StoreUpdate<State, NoSideEffects>) {
        Debug.assertionFailure("Tried to send a side effect for a store defined as NoSideEffects")
        stateClosure?(update.state)
    }
    
    public override func fire(_ state: State, _ sideEffect: NoSideEffects) {
        Debug.assertionFailure("Tried to send a side effect for a store defined as NoSideEffects")
        stateClosure?(state)
    }
}

public class StoreSubscription<State: StateContainer, Effect: SideEffect> {
    private(set) var closure: ((StoreUpdate<State, Effect>) -> Void)?
    
    public init(_ closure: @escaping (StoreUpdate<State, Effect>) -> Void) {
        self.closure = closure
    }
    
    open func fire(_ update: StoreUpdate<State, Effect>) {
        closure?(update)
    }
    
    open func fire(_ state: State, _ sideEffect: Effect) {
        closure?(.init(state: state, sideEffect: sideEffect))
    }
    
    open func fire(_ state: State) {
        closure?(.init(state: state, sideEffect: nil))
    }
    
    public func stop() {
        closure = nil
    }
    
    deinit {
        stop()
    }
}
