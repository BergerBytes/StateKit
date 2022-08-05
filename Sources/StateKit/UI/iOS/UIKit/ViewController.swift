#if os(iOS)

import UIKit

open class ViewController<Store: ViewControllerStoreType, Delegate>: UIViewController, StatefulView {
    public typealias State = Store.State
    public typealias Effect = Store.Effect

    private var viewStore: Store
    public var delegate: Delegate?

    /// The last rendered state.
    /// - Note: The state provided in ``render(state:from:)`` should still be used as the main way a view is updated; This property should
    /// mainly be used data source patterned subviews, i.e. collection views.
    public private(set) var state: State

    public required init(viewStore: Store) {
        self.viewStore = viewStore
        self.state = viewStore.state
        
        super.init(nibName: nil, bundle: nil)
        
        precondition(self.viewStore is Delegate, "ViewStore does not conform to Delegate type: \(type(of: Delegate.self))")
        
        delegate = self.viewStore as? Delegate
    }
    
    public required init?(coder: NSCoder) {
        fatalError("ViewController does not support init?(coder:)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
                
        // Subscription should happen after the subclass has completed any ViewDidLoad work.
        // Queue the subscription to ensure it happens after the current stack completes.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            try! self.viewStore.subscribe(from: self)
            self.viewStore.viewControllerDidLoad()
        }
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
        
    open func render(state: State, from distinctState: State.State?) {
        self.state = state
    }
    
    open func render(state: State, from distinctState: State.State?, sideEffect: Effect?) {
        self.state = state
    }
}

#endif
