// ___COPYRIGHT___

import Foundation
import StateKit
import SwiftUI

// MARK: - ___VARIABLE_productName:identifier___ViewDelegate

protocol ___VARIABLE_productName:identifier___ViewDelegate: AnyObject { }

// MARK: - ___VARIABLE_productName:identifier___View

struct ___VARIABLE_productName:identifier___View: View {
    var state: ___VARIABLE_productName:identifier___ViewState
    weak var delegate: ___VARIABLE_productName:identifier___ViewDelegate?
    
    var body: some View {
        switch state.current {
        case .loading:
            Text("Loading...")
            
        case .loaded:
            Text("Hello, World!")
            
        case .error:
            Text("Uh oh! \(state.errorLocalizedString)")
        }
    }
}

// MARK: - ___VARIABLE_productName:identifier___View Builder

extension ___VARIABLE_productName:identifier___View {
    @MainActor @ViewBuilder
    static func make() -> some View {
        ViewWith(___VARIABLE_productName:identifier___ViewStore()) { ___VARIABLE_productName:identifier___View(state: $0.state, delegate: $0) }
    }
}


// MARK: - ___VARIABLE_productName:identifier___View Previews

struct ___VARIABLE_productName:identifier___View_Previews: PreviewProvider {
    static var previews: some View {
        ___VARIABLE_productName:identifier___View(state: .init(current: .loading))
            .previewDisplayName("loading")

        ___VARIABLE_productName:identifier___View(state: .init(current: .loaded))
            .previewDisplayName("loaded")
    }
}
