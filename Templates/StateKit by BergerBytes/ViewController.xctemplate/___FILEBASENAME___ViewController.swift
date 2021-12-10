// ___COPYRIGHT___

import StateKit
import UIKit

// MARK: - ___VARIABLE_productName:identifier___ViewDelegate

protocol ___VARIABLE_productName:identifier___ViewDelegate: AnyObject {
    
}

// MARK: - ___VARIABLE_productName:identifier___ViewController

class ___VARIABLE_productName:identifier___ViewController: ViewController<___VARIABLE_productName:identifier___ViewState, ___VARIABLE_productName:identifier___ViewControllerStore, ___VARIABLE_productName:identifier___ViewDelegate> {
    required init(viewStore: ___VARIABLE_productName:identifier___ViewControllerStore) {
        super.init(viewStore: viewStore)
    }
    
    @available(*, unavailable)
    required convenience init?(coder: NSCoder) {
        self.init(viewStore: .init())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    override func render(state: ___VARIABLE_productName:identifier___ViewState, from distinctState: ___VARIABLE_productName:identifier___ViewState.State?) {
        super.render(state: state, from: distinctState)
    }
}

// MARK: - Setup Subviews

extension ___VARIABLE_productName:identifier___ViewController {
    private func setupSubviews() {
        
    }
}
