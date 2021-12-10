import Foundation

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

