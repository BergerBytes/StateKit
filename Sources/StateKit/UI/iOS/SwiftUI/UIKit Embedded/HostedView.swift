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

#if canImport(SwiftUI)

    import Combine
    import Foundation
    import SwiftUI

    public protocol HostedView: View {
        associatedtype StateType: StateContainer
        var state: StateType { get set }

        associatedtype Effect: SideEffect
        var effects: AnyPublisher<Effect, Never> { get }

        associatedtype Delegate
        var delegate: Delegate? { get set }

        init(state: StateType, effects: AnyPublisher<Effect, Never>)
        init(state: StateType, effects: AnyPublisher<Effect, Never>, delegate: Delegate?)
    }

    public extension HostedView {
        init(state: StateType, effects: AnyPublisher<Effect, Never>, delegate: Delegate?) {
            self.init(state: state, effects: effects)
            self.delegate = delegate
        }
    }

#endif
