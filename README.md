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

Snapshot Tests are a form of automated test. The framework I use is [Uber's Snapshot Testing framework for iOS](https://github.com/uber/ios-snapshot-test-case). I believe the original framework was developed by Facebook.

In short, a Snapshot Test runs your app and takes a screenshot of the contents on screen. It then compares this screenshot to a reference screenshot you already took and fails the test if the two screenshots differ. So in a first step, you record your reference screenshots and once you decide that your ViewController or View looks the way you want it to, you stop recording and simply run the Snapshot Test again to make sure that your ViewControllers and Views still look like they did when you recorded the tests.

Snapshot Tests have the following benefits:

- They allow you to do a form of rapid UI prototyping that follows the TDD flow
- They protect your UI against regressions
- They allow you to quickly generate screenshots of your app in various states

A Snapshot Test looks like this:

```
func testNameText_when_onlyNameText_then_keepSaveButtonDisabled() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, "Clean room")]).asObservable().bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
```

If we set the `self.recordMode` property to `true` and run the test, we will record a reference image. If the flag is set to `false`, the test will simply compare the current state of the ViewController of View to the reference screenshot.

Snapshot Tests run almost as quickly as unit tests. However they tend to cover a bit more code since they also cover your ViewController and Views. This is helpful because they also cover if a lot of your binding code is wired up properly.

## Integration Tests
Using ViewModels and RxSwift's RxBlocking framework it is fairly easy to write integration tests that cover entire workflows. All you basically need to do is wire up one ViewModel's outputs to the succeeding ViewModel's inputs. Take the following example that tests the workflow of registering a new user and having that user verify his email address:

```
//Register
            self.registrationViewModel.inputs.firstName.value = firstName
            self.registrationViewModel.inputs.lastName.value = lastName
            self.registrationViewModel.inputs.email.value = email
            self.registrationViewModel.inputs.password.onNext(password)
            self.registrationViewModel.inputs.phoneNumber.onNext(phoneNumber)
            self.registrationViewModel.inputs.agreedToTerms.value = true
            self.registrationViewModel.inputs.nextButtonTaps.onNext(())
            
            guard let showVerificationScreen = self.value(of: self.registrationViewModel.outputs.showVerificationScreen) else {
                XCTFail("Failed to show verification screen")
                return
            }
            XCTAssertEqual(email, showVerificationScreen.email)
            XCTAssertEqual(password, showVerificationScreen.password)
            XCTAssertEqual(phoneNumber, showVerificationScreen.phoneNumber)
            
            //Verify user and register device
            self.emailVerificationViewModel.inputs.viewDidLoad.onNext(())
            self.emailVerificationViewModel.inputs.email.onNext(email)
            self.emailVerificationViewModel.inputs.password.onNext(password)
            self.emailVerificationViewModel.inputs.phoneNumber.onNext(phoneNumber)
            self.emailVerificationViewModel.inputs.nextButtonTaps.onNext(())
```
The helper method to extract a value out of a ViewModel's output could look like this:

```
private func value<E>(of sequence: Observable<E>) -> E? {
        guard let result = try? sequence.toBlocking(timeout: self.timeout).first() else {
            return nil
        }
        return result
    }
```

In this example, the test first feeds all the information into the `RegistrationViewModel` just as a user would. The first name, last name, phone number etc. are entered. Then the next button is pressed. The `RegistrationViewModel` then does some processing and returns us a result via one of its outputs. Before emitting an output, the `RegistrationViewModel` may be doing an API request, for example. Once we receive the output from the `RegistrationViewModel`, we pass the necessary data to the next ViewModel in the workflow. This test can span multiple ViewModels if it needs to test a more complex workflow. The above code is incomplete but it shows the potential of using MVVM together with a framework such as RxSwift to write easily understandable and powerful integration tests. And again, this is all without the use of a UI automation framework.

## Asynchronous Code

Using a reactive framework such as RxSwift makes the writing of asynchronous code much easier. Using callbacks for simple asynchronous operations may suffice but as soon as you need to chain multiple asynchronous operations together, using callbacks does not scale well. With RxSwift, however, chaining together multiple asynchronous calls works very well and remains very legible. Take the following example which interacts with bluetooth peripheral and also sends data to a web API:

```
func readPeripheralData(uuid: String) -> Observable<Void> {
    return self.bluetoothService.checkIfBluetoothEnabled()
        .flatMapLatest { _ -> Observable<Void> in
            self.bluetoothService.connectToPeripheral(uuid: uuid)
        }.flatMapLatest { _ -> Observable<Void> in
            return self.bluetoothService.discoverService()
        }.flatMapLatest { _ -> Observable<Void> in
            self.bluetoothService.discoverDataCharacteristic()
        }.flatMapLatest { _ -> Observable<Data> in
            self.bluetoothService.readDataCharacteristic()
        }.flatMapLatest { data -> Observable<Void> in
            return self.apiService.submitData(data: data)
        }.flatMapLatest { _ -> Observable<Void> in
            self.bluetoothService.unsubscribeFromCommandResponseCharacteristic()
        }.flatMapLatest { _ -> Observable<Void> in
            self.bluetoothService.disconnectFromPeripheral()
        }.do(onError: { _ in
            _ = self.bluetoothService.disconnectFromPeripheral()
        })
}
```

Each of the calls that is made is an asynchronouse call. Using RxSwift we can beautifully chain these calls together.

## Composition

In order to compose functionality easily, I found it best to create small, cohesive components that I could compose together into larget components. This allowed me to write and test functionality in just one place and to re-use that functionality wherever I needed to. In the apps I've worked on I usually called these re-usable components UseCases. More basic UseCases would encapsulate low-level functions and would then be composed into more higher-level and more complex UseCases. Take the following sample UseCases, for instance:

```
protocol CallUseCase {
    func call(user: String, muted: Bool) -> Observable<SipCallInfo>
}

class SampleCallUseCase: CallUseCase {
    private let bag = DisposeBag()
    private let registerUseCase: RegisterWithSipUseCase
    private let localSipServerSettingsService: LocalSipServerSettingsService
    private let sipService: SipService
    
    init(registerUseCase: RegisterWithSipUseCase, localSipServerSettingsService: LocalSipServerSettingsService, sipService: SipService) {
        self.registerUseCase = registerUseCase
        self.localSipServerSettingsService = localSipServerSettingsService
        self.sipService = sipService
    }
    
    func call(user: String, muted: Bool) -> Observable<SipCallInfo> {
        return self.registerUseCase.register()
            .flatMapLatest { _ -> Observable<SipServerSettingsEntity?> in
                self.localSipServerSettingsService.read()
            }.filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { serverSettings -> Observable<SipCallInfo> in
                self.sipService.call(user: user), on: serverSettings.serverUrl, muted: muted)
            }.distinctUntilChanged()
    }
}
```

This UseCase uses the SIP protocol to place a VoIP call. It first uses the `RegisterWithSipUseCase` to register the user using on SIP. It then loads some local user settings and places the call. Now look at the following UseCase:

```
protocol SendDtmfCommandUseCase {
    func sendDtmfCommand(command: String, callerId: String) -> Observable<Void>
}

class SampleSendDtmfCommandUseCase: SendDtmfCommandUseCase, SchedulingCapable {
    private let sipService: SipService
    private let callUseCase: CallUseCase
    
    init(sipService: SipService, callUseCase: CallUseCase) {
        self.sipService = sipService
        self.callUseCase = callUseCase
    }
    
    func sendDtmfCommand(command: String, callerId: String) -> Observable<Void> {
        return self.callUseCase.call(user: callerId, muted: true)
            .flatMapLatest { callInfo -> Observable<Void> in
                self.sipService.sendCommand(callId: callInfo.callId, command: command)
            }.flatMapLatest { _ -> Observable<Void> in
                self.sipService.hangup()
        }
    }
}
```

This UseCase uses the aforementioned `CallUseCase` to first place a call to a user and then send a command to that user over SIP (using what's called DTMF).

Both of these UseCases have their own suite of unit tests that verify that their behavior is as specified. The UseCases can then very easily be injected into various higher level components (either higher-level UseCases or ViewModels).

## Appendix

### Localizable Strings
I use [SwiftGen](https://github.com/SwiftGen/SwiftGen) to generate Swift types out of my localizable string resources. This allows me to access my localized strings in a compiler-checked way. A string in my localizable File looks like this:

`"action.task.editName.hint" = "E.g. Buy food";`

I access this string like this:

`L10n.Action.Task.EditName.hint`

### ResultConverter

You may have noticed code such as the following before:

```
.flatMapLatest { input -> Observable<OperationResult<Void>> in
                let task = TaskEntity()
                task.name = input.name
                task.notes = input.notes
                let operation = self.localTaskService.save(task: task)
                return self.converter.convert(result: operation)
            }.bind(to: self.saveTaskResult)
```

In particular, you may have noticed that the return type of the flatMapLatest call is wrapped in an `OperationResult`. The reason why this is necessary is because if the `localTaskService.save()` method emits an error, we have to make sure that our Observable sequence doesn't get terminated. Observable sequences get terminated when they emit an error. However, by wrapping it in the `OperationResult` using the `ResultConverter` we allow the sequence to continue even if an error occurs while at the same time emitting info about the error in a ViewModel-friendly way.