# Task Manager App

## Introduction
The purpose of this app is to capture some of the best practices I'v learned over the years when developing iOS apps. It is by no means a complete app but merely a blueprint on how I build apps. It makes heavy use of the Model-View-ViewModel pattern with the help of the [Swift reactive extensions (RxSwift)](https://github.com/ReactiveX/RxSwift).

## View Controllers and Views
My goal is that the ViewControllers and Views hold no application logic themselves. They should merely contain logic for laying out UI elements and code for binding to the view model properties. Model-binding is done using the RxSwift (and particularly RxCocoa) frameworks:

```
self.saveButton.rx.tap
            .bind(to: self.viewModel.inputs.saveButtonTaps)
            .disposed(by: self.bag)
            
self.viewModel.outputs.saveButtonEnabled
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: self.bag)
```

## View Models
The ViewModels contain all of view-related logic. They interact with lower level services or other abstractions to perform various tasks. They also maintain the state of their corresponding views. In essence, the ViewModels accept a series of inputs, change their state, and emit a series of outputs.

I followed [Kickstarter's](https://github.com/kickstarter/ios-oss) pattern of having ViewModels implement Input and Output protocols. This makes it very easy to see what signals go into a view model and what signals come out.

My goal was to keep ViewModels as stateless as possible and to have them just keep track of a current snapshot of the view. This means that given any input into the ViewModel (such as a user input), the ViewModel would update its representation of the view state and, from that representation, generate the output signals that the ViewController or View would use to display the state on screen:

```
self.inputs.nameText
            .withLatestFrom(self.snapshot) { (name: $0, snapshot: $1) }
            .map { input in input.snapshot |> TaskModelSnapshot.nameLens *~ input.name }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
            
self.snapshot
            .map { self.createSections(from: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
```

What's happening here is that a user input (in this case a new text string for a name property) is being fed into the ViewModel. The ViewModel then updates its represtation of the view state (referred to as a snapshot in the code above) using that new text string. This updating of the state is done using [Lenses](https://www.youtube.com/watch?v=ofjehH9f-CU&t=493s). The new state representation is then used to generate a new output which is then emitted back out to the ViewController or View.

## Services
ViewModels make use of various services to perform different tasks. For instance, ViewModels may make use of data services to store or retrieve data from a local database or a web API:

```
self.inputs.saveButtonTaps
            .withLatestFrom(self.snapshot)
            .flatMapLatest { input -> Observable<OperationResult<Void>> in
                let task = TaskEntity()
                task.name = input.name
                task.notes = input.notes
                let operation = self.localTaskService.save(task: task)
                return self.converter.convert(result: operation)
            }.bind(to: self.saveTaskResult)
            .disposed(by: self.bag)
```

In the above example, the user presses on a save button. This tap is sent to the ViewModel which retrieves its latest representation of the state. It then generates a [Realm](https://realm.io) entity from the snapshot and saves it in the database. The ResultConverter used above is to ensure that the Observable sequence doesn't terminate if the data service emits an error when saving an entity. More on that later.

## Dependency Injection
Dependencies are injected into various components using the inversion of control container. In this app I used [Swinject](https://github.com/Swinject/Swinject). The benefit here is that the construction of types is left to the IoC container and my code can focus on the structure of the dependencies rather than on how they are actually built. My ViewModel simply declares the dependencies it needs and constructor injects them:

```
class EditTaskViewModel: EditTaskViewModelType, EditTaskViewModelInputs, EditTaskViewModelOutputs, ErrorBindable {
    private let localTaskService: LocalTaskService
    private let converter: ResultConverter
    
    init(localTaskService: LocalTaskService, converter: ResultConverter) {
        self.localTaskService = localTaskService
        self.converter = converter
    }
```

The IoC container is then in charge of actually resolving the dependencies. It's also in charge of how that dependency is managed (e.g. whether it's a Singleton or whether it will be created anew every time):

```
container.register(EditTaskViewModelType.self) { r in
        EditTaskViewModel(
            localTaskService: r.resolve(LocalTaskService.self)!,
            converter: r.resolve(ResultConverter.self)!
        )
    }
```

Constructor injecting dependencies also has the benefit that it's immediately clear what dependencies a particular component requires and makes it very easy to mock them out in unit tests.

## Unit Tests
I try to make my code as testable as possible. The use of the MVVM pattern, RxSwift and constructor injecting dependencies makes this a lot easier. The MVVM pattern allows me to cover more or less all of the view-related logic without having to write tests that interact with ViewControllers of Views directly. The RxSwift framework allows me to meticulously test asynchronous code and to manage multiple timelines of user interaction. Constructor injecting dependencies allows me to mock out any dependencies and focus only on testing the component under test. The following test demonstrates this:

```
func testSaveButtonTaps_then_saveTask() {
        //Arrange
        let expectedName = "Buy groceries"
        let expectedNotes = "Check out new store"
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let scheduler4 = TestScheduler(initialClock: 0)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.createColdObservable([next(100, expectedName)]).bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
        scheduler3.createColdObservable([next(100, expectedNotes)]).bind(to: self.testee.inputs.notesText).disposed(by: self.bag)
        self.mockLocalTaskService.saveStub = Observable<Void>.empty()
        scheduler1.start()
        scheduler2.start()
        scheduler3.start()
        
        //Act
        scheduler4.createColdObservable([next(100, ())]).bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler4.start()
        
        //Assert
        guard let savedTask = self.mockLocalTaskService.savedTask else {
            XCTFail("Failed to save task")
            return
        }
        XCTAssertEqual(expectedName, savedTask.name)
        XCTAssertEqual(expectedNotes, savedTask.notes)
    }
```

What's being tested above is the following:

- The view is loaded
- The name and notes of a task are entered
- The save button is tapped
- We then verify that a task is saved and that its name and notes properties are set to the values we entered

RxSwift comes with a test framework called RxTest. RxTest includes a TestScheduler which allows you to simulate a timeline of Observable sequences. In our test we have 4 different schedulers. The `scheduler1` will simulate the viewDidLoad event that's sent to the ViewModel. `scheduler2` is used to simulate the input of the name text. `scheduler3`is used to simulate the input of the notes text and `scheduler4` is used to simulate the save button tap. The reason we use separate schedulers here is because all these events happen on a separate timeline. ViewDidLoad is completely independent of the user entering any text. The name and notes text are also completely independent of each other. Finally, the save button taps are yet another independent event. Using separate schedulers, we can accurately model this in a unit test.

TestSchedulers are also used to emit mocked results from methods that emit asynchronous results:

```
func testSaveButtonTaps_when_errorSavingData_then_emitError() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let scheduler4 = TestScheduler(initialClock: 0)
        let observer = scheduler4.createObserver((errorOccurred: Bool, title: String, message: String).self)
        self.testee.outputs.error.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.createColdObservable([next(100, "Name")]).bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
        scheduler3.createColdObservable([next(100, "Notes")]).bind(to: self.testee.inputs.notesText).disposed(by: self.bag)
        self.mockLocalTaskService.saveStub = scheduler4.createColdObservable([error(100, DataAccessorError.failedToAccessDatabase)]).asObservable()
        scheduler1.start()
        scheduler2.start()
        scheduler3.start()
        
        //Act
        scheduler4.createColdObservable([next(100, ())]).bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler4.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer), "Failed to emit error")
    }
```

In the above example we use `scheduler4` to simulate the emission of an error when trying to save a Task to our database:

`self.mockLocalTaskService.saveStub = scheduler4.createColdObservable([error(100, DataAccessorError.failedToAccessDatabase)]).asObservable()`

We use `scheduler4` here because that's the scheduler on which we simulate the tapping of the save button. The save button tap is the input that directly triggers the saving of a task:

```
self.inputs.saveButtonTaps
            .withLatestFrom(self.snapshot)
            .flatMapLatest { input -> Observable<OperationResult<Void>> in
                let task = TaskEntity()
                task.name = input.name
                task.notes = input.notes
                let operation = self.localTaskService.save(task: task)
                return self.converter.convert(result: operation)
            }.bind(to: self.saveTaskResult)
            .disposed(by: self.bag)
```

Using the TestScheduler we can also emit multiple Observables in a sequence. Let's say we want to simulate the typing of individual characters into a text input. We could do this as follows:

```
scheduler.createColdObservable([next(100, "N"), next(200, "a"), next(300, "m"), next(400, "e")]).bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
```

RxSwift together with RxTest is an incredibly powerful tool for modelling the behaviour of views and view models. And all of this is possible without the use of a UI automation framework.

## Snapshot Tests

## Integration Tests

## Asynchronous Code

## Composition

## Appendix

### Localizable Strings
### ResultConverter