// ___COPYRIGHT___

import StateKit

struct ___VARIABLE_productName:identifier___StateContainer: StateContainer {
    enum State: EnumState {
        case idle
        case error(EquatableError)
    }
    
    var current: State
}

// MARK: - Queries

extension ___VARIABLE_productName:identifier___StateContainer {
    var error: Error? {
        switch current {
        case let .error(equatableError):
            return equatableError.error
            
        case .idle:
            return nil
        }
    }
}

// MARK: - Transactions

extension ___VARIABLE_productName:identifier___StateContainer {
    mutating func toIdle() {
        update { $0.current = .idle }
    }
    
    mutating func to(error: Error) {
        update { $0.current = .error(.init(error)) }
    }
}
