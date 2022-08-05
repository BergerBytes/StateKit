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
        self.renderPolicy = .notPossible(.viewNotReady)
        
        precondition(viewStore is Content.Delegate, "ViewStore does not conform to Delegate type: \(type(of: Content.Delegate.self))")
        
        delegate = viewStore as! Content.Delegate
        
        super.init(rootView: Content(state: viewStore.state, delegate: viewStore as? Content.Delegate))
        
        // SwiftUI does not need time to "load a view" like a UIViewController since the view is declarative.
        // The rendering can happen right away.
        self.renderPolicy = .possible
        try! self.viewStore.subscribe(from: self)
        self.viewStore.viewControllerDidLoad()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("HostingController does not support init?(coder:)")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewStore.viewControllerWillAppear()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewStore.viewControllerDidAppear()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewStore.viewControllerWillDisappear()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewStore.viewControllerDidDisappear()
    }
    
    public func render(state: State, from distinctState: State.State?, sideEffect: Effect?) {
        rootView = Content(state: state, delegate: delegate)
    }
}

#endif
