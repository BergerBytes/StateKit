import Foundation
import SwiftUI

@available(iOS 14.0, macOS 11.0, *)
public struct ViewWith<State: StateContainer, Store: ObservableViewStore<State>, Content>: View where Content : View  {
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
public struct NSViewWith<State: StateContainer, Store: NSObservableViewStore<State>, Content>: View where Content : View  {
    @StateObject var store: Store
    @ViewBuilder var view: (Store) -> Content

    public var body: some View {
        view(store)
    }
}

@available(iOS 14.0, macOS 11.0, *)
extension NSViewWith {
    public init(_ store: Store, view: @escaping (Store) -> Content) {
        self.init(store: store, view: view)
    }
}

