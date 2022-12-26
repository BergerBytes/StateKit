// ___COPYRIGHT___

import Combine
import StateKit

typealias ___VARIABLE_productName:identifier___ViewEffect = NoSideEffects

/// ViewStore for ``___VARIABLE_productName:identifier___View``
class ___VARIABLE_productName:identifier___ViewStore: ObservableViewStore<___VARIABLE_productName:identifier___ViewState, ___VARIABLE_productName:identifier___ViewEffect> {
    init() {
        super.init(initialState: .init(current: .loading))
    }
}

// MARK: - ___VARIABLE_productName:identifier___ViewDelegate

extension ___VARIABLE_productName:identifier___ViewStore: ___VARIABLE_productName:identifier___ViewDelegate { }

// MARK: - ___VARIABLE_productName:identifier___ViewEffectPublisher

typealias ___VARIABLE_productName:identifier___ViewEffectPublisher = AnyEffectPublisher<___VARIABLE_productName:identifier___ViewEffect>
