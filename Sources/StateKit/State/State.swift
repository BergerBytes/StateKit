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

/// State provided by a ViewStore to be delivered to a StatefulView
public protocol ViewState: StateContainer { }

/// State provided by a Store
public protocol StateContainer: Equatable where State: EnumState {
    associatedtype State
    var current: State { get set }
}

public extension StateContainer {
    /// Mutation composition helper to allow for multiple mutations to the state tree to execute as a single change.
    mutating func update<T>(_ update: (inout Self) -> T) -> T? {
        var data = self
        let value = update(&data)

        if data == self {
            return value
        }

        self = data
        return value
    }
    
    /// Mutation composition helper to allow for multiple mutations to the state tree to execute as a single change.
    mutating func update(_ update: (inout Self) -> Void) {
        var data = self
        update(&data)
        
        if data == self {
            return
        }
        
        self = data
    }
}
