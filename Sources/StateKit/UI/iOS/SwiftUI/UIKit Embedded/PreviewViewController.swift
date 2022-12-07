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

#if canImport(UIKit)

    import Foundation
    import SwiftUI

    /// SwiftUI view used to preview a UIViewController on the swiftUI canvas.
    /// Helpful for previewing HostingControllers
    /// ```swift
    /// typealias SomeViewController = HostingController<SomeViewState, SomeViewStore, SomeView>
    ///
    /// struct SomeView_Previews: PreviewProvider {
    ///     static var previews: some View {
    ///         PreviewViewController {
    ///             SomeViewController(viewStore: .init())
    ///         }
    ///     }
    /// }
    /// ```
    public struct PreviewViewController: View {
        private let builder: () -> UIViewController

        public init(builder: @escaping () -> UIViewController) {
            self.builder = builder
        }

        public var body: some View {
            PreviewViewRepresentable(builder: builder)
                .edgesIgnoringSafeArea(.all)
        }

        private struct PreviewViewRepresentable: UIViewControllerRepresentable {
            private let builder: () -> UIViewController

            init(builder: @escaping () -> UIViewController) {
                self.builder = builder
            }

            func makeUIViewController(context _: Context) -> UIViewController {
                builder()
            }

            func updateUIViewController(_: UIViewController, context _: Context) { }
        }
    }

#endif
