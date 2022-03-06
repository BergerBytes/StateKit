// ___COPYRIGHT___

import StateKit

/// The state container for ``___VARIABLE_productName:identifier___Store``
struct ___VARIABLE_productName:identifier___StoreState: StateContainer {
    enum State: EnumState {
        case main
        case error(EquatableError)
    }
    
    var current: State
}

// MARK: - Queries

extension ___VARIABLE_productName:identifier___StoreState {
    var error: Error? {
        switch current {
        case let .error(equatableError):
            return equatableError.error
            
        case .main:
            return nil
        }
    }
}

// MARK: - Transactions

extension ___VARIABLE_productName:identifier___StoreState {
    mutating func toMain() {
        update { $0.current = .main }
    }
    
    mutating func to(error: Error) {
        update { $0.current = .error(.init(error)) }
    }
}
