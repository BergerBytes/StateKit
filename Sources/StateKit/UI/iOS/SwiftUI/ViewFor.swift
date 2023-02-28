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
    import DevKit
    import SwiftUI
#endif

#if canImport(SwiftUI)
    @available(iOS 14.0, macOS 11.0, *)
    public struct ViewFor<Store: ObservableViewStoreType, Content: View>: View {
        public typealias State = Store.State
        public typealias Effect = Store.Effect

        @StateObject var store: Store
        @ViewBuilder var view: (Store) -> Content

        internal init(store: @escaping @autoclosure () -> Store, view: @escaping (Store) -> Content) {
            _store = StateObject(wrappedValue: store())
            self.view = view
        }

        public var body: some View {
            view(store)
        }
    }

    @available(iOS 14.0, macOS 11.0, *)
    public extension ViewFor {
        init(_ store: @escaping @autoclosure () -> Store, view: @escaping (Store) -> Content) {
            self.init(store: store(), view: view)
        }
    }
#endif
