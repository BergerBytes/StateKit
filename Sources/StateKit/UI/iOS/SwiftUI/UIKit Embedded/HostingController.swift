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

#if os(iOS)

    import Foundation
    import SwiftUI

    @available(iOS 13.0, *)
    open class HostingController<Store: ViewControllerStoreType, Content: StateView>: UIHostingController<Content>, StatefulView where Content.StateType == Store.State {
        public typealias State = Store.State
        public typealias Effect = Store.Effect

        private let viewStore: Store
        private let delegate: Content.Delegate
        public private(set) var renderPolicy: RenderPolicy

        public required init(viewStore: Store) {
            self.viewStore = viewStore
            renderPolicy = .notPossible(.viewNotReady)

            precondition(viewStore is Content.Delegate, "ViewStore does not conform to Delegate type: \(type(of: Content.Delegate.self))")

            delegate = viewStore as! Content.Delegate

            super.init(rootView: Content(state: viewStore.state, delegate: viewStore as? Content.Delegate))

            // SwiftUI does not need time to "load a view" like a UIViewController since the view is declarative.
            // The rendering can happen right away.
            renderPolicy = .possible
            try! self.viewStore.subscribe(from: self)
            self.viewStore.viewControllerDidLoad()
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("HostingController does not support init?(coder:)")
        }

        override open func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            viewStore.viewControllerWillAppear()
        }

        override open func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            viewStore.viewControllerDidAppear()
        }

        override open func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            viewStore.viewControllerWillDisappear()
        }

        override open func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            viewStore.viewControllerDidDisappear()
        }

        public func render(state: State, from _: State.State?, sideEffect _: Effect?) {
            rootView = Content(state: state, delegate: delegate)
        }
    }

#endif
