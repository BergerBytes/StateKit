#if os(iOS)

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public protocol StateView: View {
    associatedtype StateType: ViewState
    var state: StateType { get set }
    
    associatedtype Delegate
    var delegate: Delegate? { get set }
    
    init(state: StateType)
    init(state: StateType, delegate: Delegate?)
}

@available(iOS 13.0, *)
extension StateView {
    public init(state: StateType, delegate: Delegate?) {
        self.init(state: state)
        self.delegate = delegate
    }
}

#endif
