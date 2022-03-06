import Foundation
import SwiftUI

/// Enumerated State to be used in StateContainer.
public protocol EnumState: Equatable {}

extension EnumState {
    private var reflectedCase: Mirror.Child? {
        let reflection = Mirror(reflecting: self)
        guard
            reflection.displayStyle == .enum,
            let reflectedCase = reflection.children.first else {
            return nil
        }
        
        return reflectedCase
    }
    
    /// The name of the base enum case.
    /// - Warning: Every access of this property will cause reflection, access should be minimal. It's best to cache the value
    /// if it will be needed several times in scope.
    ///
    /// Access of this once per state change is considered minimal and should not be cause for alarm.
    public var name: String {
        reflectedCase?.label ?? "\(self)"
    }
    
    /**
     Compares two EnumStates and checks if their base case is different
     ```swift
     enum Example: EnumState {
        case foo(Bool)
     }
     
     let first = Example.foo(false)
     let second = Example.foo(true)
     
     // The two states are not equal.
     print(first == second) // false
     
     // The two states have the same base case and are not distinct.
     print(first.isDistinct(from: second)) // false
     ```
     */
    public func isDistinct(from state: Self) -> Bool {
        return name != state.name
    }
}
