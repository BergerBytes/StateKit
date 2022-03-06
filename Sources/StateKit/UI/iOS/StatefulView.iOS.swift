#if os(iOS)
import UIKit
import Foundation

// MARK: - StatefulView: UIViewController

extension StatefulView where Self: UIViewController {
    public var renderPolicy: RenderPolicy {
        isViewLoaded ? .possible : .notPossible(.viewNotReady)
    }
}

// MARK: - StatefulView: UIView

extension StatefulView where Self: UIView {
    public var renderPolicy: RenderPolicy {
        superview != nil ? .possible : .notPossible(.viewNotReady)
    }
}

#endif
