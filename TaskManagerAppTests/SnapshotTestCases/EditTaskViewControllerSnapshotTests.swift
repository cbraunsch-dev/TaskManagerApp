//
//  EditTaskViewControllerSnapshotTests.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import FBSnapshotTestCase
@testable import TaskManagerApp

class EditTaskViewControllerSnapshotTests: FBSnapshotTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockLocalTaskService: MockLocalTaskService!
    private var testee: EditTaskViewModel!
    private var navigationViewController: UINavigationController!
    private var viewController: EditTaskViewController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.mockLocalTaskService = MockLocalTaskService()
        self.testee = EditTaskViewModel(localTaskService: self.mockLocalTaskService, converter: TaskManagerResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.navigationViewController = UINavigationController()
        self.viewController = (UIStoryboard(name: StoryboardName.manageTasks.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "EditTaskViewController") as! EditTaskViewController)
        self.viewController.viewModel = self.testee
        self.navigationViewController.pushViewController(self.viewController, animated: false)
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        self.mockLocalTaskService = nil
        self.testee = nil
        self.viewController = nil
        self.navigationViewController = nil
        self.scheduler = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        //Arrange/Act
        self.loadView(of: self.viewController)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
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
    
    func testNotesText_when_onlyNotesText_then_keepSaveButtonDisabled() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, "Use air freshener")]).asObservable().bind(to: self.testee.inputs.notesText).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testNotesText_when_nameText_then_enableSaveButton() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, "Clean room")]).asObservable().bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
        scheduler3.createColdObservable([next(100, "Use air freshener")]).asObservable().bind(to: self.testee.inputs.notesText).disposed(by: self.bag)
        scheduler2.start()
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
