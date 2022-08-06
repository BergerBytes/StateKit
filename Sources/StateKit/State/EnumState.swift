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

import Foundation
import SwiftUI

/// Enumerated State to be used in StateContainer.
public protocol EnumState: Equatable { }

public extension EnumState {
    private var reflectedCase: Mirror.Child? {
        let reflection = Mirror(reflecting: self)
        guard
            reflection.displayStyle == .enum,
            let reflectedCase = reflection.children.first
        else {
            return nil
        }

        return reflectedCase
    }

    /// The name of the base enum case.
    /// - Warning: Every access of this property will cause reflection, access should be minimal. It's best to cache the value
    /// if it will be needed several times in scope.
    ///
    /// Access of this once per state change is considered minimal and should not be cause for alarm.
    var name: String {
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
    func isDistinct(from state: Self) -> Bool {
        name != state.name
    }
}
