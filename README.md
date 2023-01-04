# 📦 StateKit

A UI agnostic state management system to control the madness of scaling apps and teams.

## Description

StateKit aims to solve the issue of the implicit state that comes out of many alternative architectures. As applications and teams grow, the need to easily digest and understand architecture becomes incredibly important.

## Key features

- Deterministic state
- All state changes happen within an explicit transaction
- Testable by default
- Breaks down applications into easy to understand and assemble blocks
- View layer agnostic, built-in support for UIKit and SwiftUI
- Compiler enforced

# Installation

## Swift Package Manager

Swift package manager is the preferred way to use StateKit. Just add this repository. Locking to the current minor version is recommended.

```swift
https://github.com/BergerBytes/StateKit
```

# Motivation

A common problem with architecture patterns like MVC, MVVM, etc., is they result in **multiple, scattered, and out-of-sync outputs**. These outputs prevent the explicit ability to control how the state is changed and passed throughout the application. An app with this problem will commonly run into odd state issues, especially when deviating from the "happy path".

Consider this simple example of a traditional MVVM ViewModel:

```swift
class FileListViewModel {
    private(set) var loading: Bool
    private(set) var files: [File]
    private(set) var error: Error
    
    func fetchFiles(completed: () -> Void) {
        loading = true
        service.loadFiles { files, error in
            loading = false
            if error {
                self.error = error
            } else {
                self.files = files
            }

			 completed()
        }
    }
}
```

The view model has three outputs: `loading`, `files` and `errors`. These outputs can change independently, whether from the view calling methods or as a response to internal callbacks. This will inevitably lead to conflicting states in the view.

For example, imagine we call `fetchFiles`, and it fails. We then call the function again; we would have `loading = true` and `error != nil` for a little while until the `service.loadFiles` callback is invoked. Does that make sense? It depends; in this example, we could set the error to nil before the fetchFiles call, but as you add more and more properties having consistency across the different outputs of your view model can be quite hard.

When trying to use this ViewModel to derive a view you can easily imagine a situation like the following:

```swift
if let error = viewModel.error { ... }
else if viewModel.loading { ... }
else if let files = viewModel.files { ... }
```

Some questions come to mind when looking at this logic:

- Should I always check `viewModel.error` before `viewModel.loading`?
- Can `viewModel.files` be valid when `viewModel.loading == true`? Or when in `viewModel.error != nil`?
- Should I always access `viewModel.files` after having checked `viewModel.error` and `viewModel.loading`?

This is where the aforementioned outputs consistency problem makes special sense. If we can be sure about the consistency, the order doesn't matter. We can even forget about an else statement there, and everything will work as expected. In any case, from an API point of view, nothing is telling me all that. We should aim to make our APIs convey the proper usage.

StateKit aims to solve problems like this.

# The Solution

StateKit sits between an application's global state, for example, a server api, and the UI layer. StateKit's core responsibility is to move state into bespoke `StateContainer` structs provided from dedicated `Stores`. These stores have small, focused scopes of concerns, usually handling specific responsibilities, such as a UserProfileStore, CartStore, ProductStore, etc. One of the most powerful abilities of stores is the ability to subscribe to other stores and receive updates when the subscribed store's state changes. This allows stores to form complex state trees while keeping everything modular and easy to understand.

To understand how this is accomplished, let's take a look at the code:

## StateContainer

`StateContainers` consist of three main sections:

- Storage
- Queries
- Transactions

### Storage

```swift
// 1
struct ExampleState: StateContainer {
	// 2
	enum State: EnumState {
		case loading
		case main(firstName: String, lastName: String)
		case error(EquatableError)
	}
	
	// 3
	var current: State = .main
}
```

1. The `StateContainer` protocol requires the struct to be `Equatable` and the definition of a `current` property.
2. All `StateContainers` have a nested enum called `State`, which conforms to the `EnumState` protocol. The cases defined here are the bespoke state's this state can be in. In this example, this state can either be in a "loading", "main or "error" state. This enum is the main place where all raw data is stored within a state. If data is exclusive to, and typically required by, a specific state, it should be stored as an associated value in the appropriate case. This will make the data required when changing the current state to that case and better prevent out-of-sync state. You can see an examples of this in the main and error cases. The following sections will show how this data is accessed and changed.

> Why use an enum?

> Sum types are one of the most overlooked features when developing in Swift. As product types, sum types are [Algebraic Data Types](https://en.wikipedia.org/wiki/Algebraic_data_type), also known as tagged or disjoint unions. An example of product types in Swift is tuples. Enums with associated values are the Swift version of a sum type.

> Sum types, alongside pattern matching and exhaustive switches, can model exclusive states in a simple yet powerful way. Moreover, as we will see later, the enum removes most of the needed conditional logic a state consumer will need to transition between states.

3. The `current` property is the current state the container is in. The `current` property does not need a default value, but the initializer will require an initial state if left off. i.e. `ExampleState(current: .main)`. Either method is fine as there might be cases where the first state is conditional.

### Queries

```swift
// MARK: - Queries

extension ExampleState {
    private var fullName: String? {
        switch current {
        case let .main(firstName, lastName):
            return "\(firstName) \(lastName)"
            
        case .loading, .error:
            return nil
        }
    }
    
    var titleText: String {
        if let fullName = fullName {
            return "Hello, \(fullName)"
        }
        
        return "Hello!"
    }
    
    var error: Error? {
        if case let .error(error) = current {
            return error.error
        }
        
        return nil
    }
}
```

Queries are responsible for computing derived state. A lot of times, state can be a complex thing to manage. It can be a huge tree with many nodes, and accessing a piece of it will not always be as easy as it sounds. Queries are functions that return some parts of the state for easy consumption. In addition, they are composable, as they can use other queries as well.

A critical feature of queries is that they decouple the raw data shape from our views/state consumers, making it feasible to refactor domain state to other different shapes in the future without huge impact.

For example, let's consider a case where the state consumer has an error view that should either be shown or hidden. We wouldn't want the consumer to have any conditional logic.

```swift
❌ errorView.isEnabled = state.error != nil
```

This puts logic into the consumer layer and is counter to having declarative state and decoupled layers. We also wouldn't want to add a property on the store's state, as this could quickly become out of sync as the code changes. So instead, we can add a query to the state itself.

```swift
✅ var showError: Bool { error != nil }
```

This allows the consumer to use the property with zero concern for what drives the value.

> This is a straightforward example and, as we will see later, is not how you might want to handle an error view, but the concept applies to any derived logic/data.

Another common use case for queries is extracting associated values from the enum state. An example of this is included in the template. Here we get access to the error object:

```swift
var error: EquatableError? {  
	if case let .error(error) = current {  
		return error  
	}

	return nil
}
```

This reduces the amount of boilerplate needed to get access to embedded data. In this case, we are using `if case let` and falling through to `return nil`. This is okay in this instance because there should never be an error in any other case. However, when pulling data from cases it's usually more appropriate to explicitly handle all cases. This protects you from missing case handling when adding new cases.

```swift
private var fullName: String? {
    switch current {
    case let .main(firstName, lastName):
        return "\(firstName) \(lastName)"
        
    case .loading, .error:
        return nil
	// Adding a new case will cause a compiler error ✅
    }
}
```

### Transactions

```swift
// MARK: - Transactions

extension ExampleState {
   mutating func toMain(firstName: String, lastName: String) {
       update { $0.current = .main(firstName: firstName, lastName: lastName) }
   }
   
   mutating func to(error: Error) {
       update { $0.current = .error(.init(error)) }
   }
}
```

**The `mutating` functions are our *transactions*.** They represent how stores can change our state. Most business logic will live here, and the ***only place where the state is mutated***. Transactions encapsulate change logic to provide an easy way to understand a state object and make it very easy to unit test.

> Do not be misled by the `mutating` word. It is not really *mutating* anything in place, it will recreate the whole value layer tree. *What about performance?*, you might think. Most of the time, this is cheap. But in case you have a huge data set, you could bump into performance issues. However, even the most complicated apps would have trouble running into any problems. So the advantages outweigh the potential for any performance trade-off.

When mutating the state you use `update { }` to execute all the changes as a single update to the subscribers. This prevents multiple updates being sent to the subscribers and prevents unnecessary renders in the view layer. Calling `update { }` will automatically push the state update to the store's subscribers.

Below is another example of deriving state conditionally within a transaction. In this example, we see a transaction that will update the state based on provided data.

```swift
mutating func updated(searchText: String) {
    update {
        $0.searchText = searchText
        $0.current = searchText.isEmpty ? .emptySearch(isFetching: $0.isFetchingResults) : $0.current
    }
}
```

## Store

```swift
class ExampleStore: Store<ExampleState> {
    init() {
        super.init(initialState: .init())
    }
}
```

Stores are *domain state holders* and coordinators. They communicate with other collaborators, like services to do network requests, or the persistence layer to save data. They are responsible for side effects in a way. They also make sure that the state is only mutated inside transactions in the proper serial queue. The goal is always the same: mutate the state appropriately once the specific job is done and let the world know.

An empty store is extremely simple. All of the magic comes from the base type `Store<ExampleState>`, but lets look at using stores first. The first thing you will notice is `super.init(initialState: .init())`. All stores contain a single state object, as defined by the generic constraint, and they must always provide a valid state. When initializing a store an initial state must be provided.

Let's look at a simple example store to better understand how to use them.

```swift
class ExampleStore: Store<ExampleState> {
    private let someDataService: SomeDataService
    
    init(someDataService: SomeDataService = .shared) {
        self.someDataService = someDataService
        super.init(initialState: .init())
    }
    
    func fetchSomeData() {
        state.toLoading()
        someDataService.fetchSomeData { [weak self] result in
            switch result {
            case .success(let data):
                self?.state.update(data: data)
            case .failure(let error):
                self?.state.toError(error)
            }
        }
    }
}
```

And here is the sample state object for this store

```swift
struct ExampleState: StateContainer {
    enum State: EnumState {
        case initial
        case loading
        case main(SomeData)
        case error(EquatableError)
    }
    
    var current: State = .initial
}

// MARK: - Queries

extension ExampleState {
    var someData: SomeData? {
        switch current {
        case .main(let data):
            return data
        case .initial, .loading, .error:
            return nil
        }
    }
    
    var error: EquatableError? {
        if case let .error(error) = current {
            return error
        }
        
        return nil
    }
}

// MARK: - Transactions

extension ExampleState {
    mutating func update(data: SomeData) {
        update { $0.current = .main(data) }
    }
    
    mutating func toLoading() {
        update { $0.current = .loading }
    }
    
    mutating func toError(_ error: EquatableError) {
        update { $0.current = .error(error) }
    }
}
```

In this example, we use `SomeDataService` to fetch some data and mutate the state with the result. Stores should inject all dependencies in the initializer. Stores are not static and are created and destroyed when needed, typically by other stores.

There are a couple of things to note. Looking at the `fetchSomeData()` function, you will notice that it neither returns anything nor takes in a callback. All calls into stores should be treated as statement actions and are decoupled from the response. Any output from a store is delivered in the state object. The first line in `fetchSomeData()` is a state transformation. `state.toLoading()` transforms the state from it's current state to the loading state. You have two options when changing state within a store. You can call one of the transaction mutating functions on the state (usually the recommended approach), or replace the state with a completely new state object.

```swift
✅ state.toLoading()
// or
✅ state = .init(current: .loading)
```

Both of these methods work, but because transaction functions can provide safe guards, other required changes and are easier to test, it's recommended to use transactions. You might want to replace the state outright if you want to ensure all stored data (non-associated values) is cleared/reset.

Editing the state will automatically push the new state to the store's subscribers.

### Subscription

The basics of store subscriptions involve creating a property to store the subscription and then creating the subscription to receive the state.

```swift
let someStore = SomeStore()
var someStoreSubscription: StateSubscription<SomeStoreState>?

// ...

someStoreSubscription = someStore.subscribe { [weak self] state in
    
}
```

Typically, only stores will subscribe to other stores. However, a helper function removes the need to store the subscription manually.

```swift
let someStore = SomeStore()

// ...

subscribe(to: someStore) { [weak self] state in
    
}
```

The pattern of State and Stores drives the core of the architecture; we have only looked at the data layer. Let's take a look at how the view layer ties into this.

## ViewStore

A ViewStore is just a specialized store for delivering a state object to the view layer. It works exactly the same as a regular store except that it allows `StatefulView`s to receive state updates. Typically, ViewStores are paired with a single ViewController so there is a specialized ViewStore called ViewControllerStore. As you can see from the definition below, there is nothing inherently special with ViewControllerStore by default other than the ability to optionally receive view controller lifecycle events.

```swift
class ExampleViewControllerStore: ViewControllerStore<ExampleViewState> {
    init() {
        super.init(initialState: .init(current: .idle))
    }

	// Optional lifecycle events
    override func viewControllerDidLoad() {
        super.viewControllerDidLoad()
    }

    override func viewControllerDidDisappear() {
        super.viewControllerDidAppear()
    }
}

// Required ViewDelegate conformance. See ViewController section below.
extension ExampleViewControllerStore: ExampleViewDelegate {
    
}
```

The lifecycle events highlight an important point about communication between the ViewStore and the ViewController. As we will see later, the view controller does not have access to the ViewModel. **It can not directly access properties or call functions.** All data from the ViewState is delivered as part of the state object, and all input from the ViewController must be defined in the `ViewControllerDelegate`. For example, if we wanted to respond to a button push from the view controller, a function would be defined in the delegate, for example `func viewControllerDidTapButton()`. The wording of this function is deliberate, it should express what the view controller did, not what should happen.

```swift
protocol ExampleViewDelegate: AnyObject {
    ✅ func viewControllerDidPullToRefresh()
    ❌ func refreshData()
}
```

This allows the scope of the layers to be separate, both logically and cognitively. This kind of separation lends itself to better unit testing and scalability. As an added bonus, since it’s easier to reason about each layer separately, it helps make code reviews and context switching much faster.

### ViewController (UIKit)

Looking at the ViewController class definition we can break down what is required.

```swift
open class ViewController<State: ViewState, Store: ViewControllerStore<State>, Delegate>: UIViewController, StatefulView
```

There are three generic constrains that need to be defined:

1. State: The state struct, the same struct used by the ViewStore.
2. ViewControllerStore: The ViewStore that will provide state to the view controller.
3. Delegate: The protocol used to allow the view layer to send events up to the view store.

The view controller also needs to conform to `StatefulView`, Let's look at an example of a simple implementation:

```swift
// MARK: - ExampleViewDelegate

protocol ExampleViewDelegate: AnyObject {
    
}

// MARK: - ExampleViewController

class ExampleViewController: ViewController<ExampleViewState, ExampleViewControllerStore, ExampleViewDelegate> {
    override func render(state: ExampleViewState, from distinctState: ExampleViewState.State?) {
        super.render(state: state, from: distinctState)
    }
}
```

The ViewController conforms to `StatefulView` which defines a render function. This render function is the place where the UI should be updated. It provides the view state object as well as an optional distinct state. The distinct state is the previous state **if** the previous state was a different base case. For example, if the state changes from `loading` to `error`, the distinct state would be `loading`. This allows you to transition from the old state, remove views etc.

### SwiftUI

Because the view layer is decoupled from the view store, it's easy to use SwiftUI in place of a UIKit view controller. The render function is handled internally, all you need to do is define the body and call functions on the delegate. To use this view within the app you instantiate the provided `HostingController` just like you would a `ViewController`.

```swift
typealias ExampleViewController = HostingController<ExampleViewState, ExampleViewControllerStore, ExampleView>

// MARK: - ExampleViewDelegate

protocol ExampleViewDelegate: AnyObject {
    
}

// MARK: - ExampleView

struct ExampleView: StateView {
    var state: ExampleViewState
    weak var delegate: ExampleViewDelegate?
    
    init(state: ExampleViewState) {
        self.state = state
    }
    
    var body: some View {
        switch state.current {
        case .idle:
            Text(state.greetingLocalizedString)
            
        case .error:
            Text(state.errorLocalizedString)
        }
    }
}

// MARK: - ExampleView Previews

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewViewController {
            ExampleViewController(viewStore: .init())
        }
    }
}
```

# Recap: State Container based architecture

The core of the architecture is breaking down your state management into small, reusable pieces that only handle their specific scope. These small state stores are then used to construct a declarative "tree" that results into a single view state to pass to the UI layer. Stores are quite smart though about mutation and propagation of the state.

- They will only allow mutation via a transaction. Other mutations will wait for the current mutation to finish. This will avoid unpleasant race conditions.
- They will only propagate changes when it is needed. State mutations that result in the very same state will not be broadcasted.

Stores can subscribe to other stores. Views and view controllers can subscribe to a ViewStore. Multiple views can subscribe to the very same ViewStore if needed.
