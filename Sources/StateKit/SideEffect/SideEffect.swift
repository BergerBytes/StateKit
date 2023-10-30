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

import Combine
import Foundation

public protocol SideEffect { }
public enum NoSideEffects: SideEffect { }

public typealias NoSideEffectPublisher = AnyEffectPublisher<NoSideEffects>

class EffectPublisher<Effect: SideEffect>: Publisher {
    public typealias Output = Effect
    public typealias Failure = Never

    private var effectSubscribers = NSHashTable<EffectSubscription<Effect>>.weakObjects()

    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Effect == S.Input {
        // Creating our custom subscription instance:
        let subscription = EffectSubscription<Effect>()
        subscription.target = .init(subscriber)

        // Attaching our subscription to the subscriber:
        subscriber.receive(subscription: subscription)

        effectSubscribers.add(subscription)
    }

    func send(_ effect: Effect) {
        effectSubscribers.allObjects.forEach { subscriber in
            subscriber.send(effect)
        }
    }

    func eraseToAnyPublisher() -> AnyEffectPublisher<Effect> {
        .init(self)
    }
}

public struct AnyEffectPublisher<Effect: SideEffect>: Publisher {
    public typealias Output = Effect
    public typealias Failure = Never

    private weak var publisher: EffectPublisher<Effect>?

    init(_ publisher: EffectPublisher<Effect>?) {
        self.publisher = publisher
    }

    public static func empty<Effect>() -> AnyEffectPublisher<Effect> {
        .init(nil)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Effect == S.Input {
        publisher?
            .receive(on: RunLoop.main)
            .receive(subscriber: subscriber)
    }
}
