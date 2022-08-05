import Foundation
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
public struct ViewWith<State: StateContainer, Effect: SideEffect, Store: ObservableViewStore<State, Effect>, Content>: View where Content : View  {
    @StateObject var store: Store
    @ViewBuilder var view: (Store) -> Content

    public var body: some View {
        view(store)
    }
}

@available(iOS 14.0, macOS 11.0, *)
public struct ViewFor<Store: ObservableViewStoreType, Content>: View where Content : View  {
    public typealias State = Store.State
    public typealias Effect = Store.Effect
    
    @StateObject var store: Store
    @ViewBuilder var view: (Store) -> Content

    public var body: some View {
        view(store)
    }
}

@available(iOS 14.0, macOS 11.0, *)
extension ViewWith {
    public init(_ store: Store, view: @escaping (Store) -> Content) {
        self.init(store: store, view: view)
    }
}

@available(iOS 14.0, macOS 11.0, *)
extension ViewFor {
    public init(_ store: Store, view: @escaping (Store) -> Content) {
        self.init(store: store, view: view)
    }
}
