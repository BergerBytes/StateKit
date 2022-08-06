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

    import UIKit

    open class ViewController<State: ViewState, Store: ViewControllerStore<State>, Delegate>: UIViewController, StatefulView {
        private var viewStore: Store
        public var delegate: Delegate?

        /// The last rendered state.
        /// - Note: The state provided in ``render(state:from:)`` should still be used as the main way a view is updated; This property should
        /// mainly be used data source patterned subviews, i.e. collection views.
        public var state: State

        public required init(viewStore: Store) {
            self.viewStore = viewStore
            state = viewStore.state

            super.init(nibName: nil, bundle: nil)

            precondition(self.viewStore is Delegate, "ViewStore does not conform to Delegate type: \(type(of: Delegate.self))")

            delegate = self.viewStore as? Delegate
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("ViewController does not support init?(coder:)")
        }

        override open func viewDidLoad() {
            super.viewDidLoad()

            view.backgroundColor = .white

            // Subscription should happen after the subclass has completed any ViewDidLoad work.
            // Queue the subscription to ensure it happens after the current stack completes.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                try! self.viewStore += self
                self.viewStore.viewControllerDidLoad()
            }
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

        open func render(state: State, from _: State.State?) {
            self.state = state
        }
    }

#endif
