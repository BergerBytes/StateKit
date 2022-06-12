#if os(iOS)

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
@available(iOS 13.0, *)
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
        
        func makeUIViewController(context: Context) -> UIViewController {
             builder()
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    }
}

#endif
