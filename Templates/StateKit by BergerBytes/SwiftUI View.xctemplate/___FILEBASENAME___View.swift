// ___COPYRIGHT___

import Combine
import Foundation
import StateKit
import SwiftUI

// MARK: - ___VARIABLE_productName:identifier___ViewDelegate

protocol ___VARIABLE_productName:identifier___ViewDelegate: AnyObject { }

// MARK: - ___VARIABLE_productName:identifier___View

/// View for ``___VARIABLE_productName:identifier___ViewStore``
struct ___VARIABLE_productName:identifier___View: View {
    let state: ___VARIABLE_productName:identifier___ViewState
    let effects: ___VARIABLE_productName:identifier___ViewEffectPublisher
    weak var delegate: ___VARIABLE_productName:identifier___ViewDelegate?
    
    var body: some View {
        Group {
           switch state.current {
           case .loading:
               Text("Loading...")

           case .loaded:
              Text("Hello, World!")

           case .error:
             Text("Uh oh! \(state.errorLocalizedString)")
            }
        }
        .onReceive(effects) { effect in
            switch effect { }
        }
    }
}

// MARK: - ___VARIABLE_productName:identifier___View Builder

extension ___VARIABLE_productName:identifier___View {
    @MainActor @ViewBuilder
    static func make() -> some View {
        ViewFor(___VARIABLE_productName:identifier___ViewStore()) { 
            ___VARIABLE_productName:identifier___View(state: $0.state, effects: $0.eraseToAnyPublisher(), delegate: $0)
        }
    }
}

// MARK: - ___VARIABLE_productName:identifier___View Previews

struct ___VARIABLE_productName:identifier___View_Previews: PreviewProvider {
    static var previews: some View {
        ___VARIABLE_productName:identifier___View(
            state: .init(current: .loaded),
            effects: .empty()
        )
            .previewDisplayName("loaded")

        ___VARIABLE_productName:identifier___View(
            state: .init(current: .loading), 
            effects: .empty()
        )
            .previewDisplayName("loading")
    }
}
