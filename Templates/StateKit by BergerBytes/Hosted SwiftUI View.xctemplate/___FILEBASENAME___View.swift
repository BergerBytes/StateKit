// ___COPYRIGHT___

import StateKit
import SwiftUI

typealias ___VARIABLE_productName:identifier___ViewController = HostingController<___VARIABLE_productName:identifier___ViewState, ___VARIABLE_productName:identifier___ViewControllerStore, ___VARIABLE_productName:identifier___View>

// MARK: - ___VARIABLE_productName:identifier___ViewDelegate

protocol ___VARIABLE_productName:identifier___ViewDelegate: AnyObject {
    
}

// MARK: - ___VARIABLE_productName:identifier___View

struct ___VARIABLE_productName:identifier___View: StateView {
    var state: ___VARIABLE_productName:identifier___ViewState
    weak var delegate: ___VARIABLE_productName:identifier___ViewDelegate?
    
    init(state: ___VARIABLE_productName:identifier___ViewState) {
        self.state = state
    }
    
    var body: some View {
        switch state.current {
        case .idle:
            Text("Hello, World!")
            
        case .error:
            Text("Uh oh! \(state.errorLocalizedString)")
        }
    }
}

// MARK: - ___VARIABLE_productName:identifier___View Previews

struct ___VARIABLE_productName:identifier___View_Previews: PreviewProvider {
    static var previews: some View {
        PreviewViewController {
            ___VARIABLE_productName:identifier___ViewController(viewStore: .init())
        }
    }
}
