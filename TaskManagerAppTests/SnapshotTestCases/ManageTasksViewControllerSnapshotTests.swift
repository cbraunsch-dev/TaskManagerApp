//
//  ManageTasksViewControllerSnapshotTests.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import TaskManagerApp

class ManageTasksViewControllerSnapshotTests: FBSnapshotTestCase, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var viewController: ManageTasksViewController!
    private var navigationViewController: UINavigationController!
    private var mockLocalTaskService: MockLocalTaskService!
    private var viewModel: ManageTasksViewModel!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.viewController = (UIStoryboard(name: StoryboardName.manageTasks.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "ManageTasksViewController") as! ManageTasksViewController)
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
        self.mockLocalTaskService = MockLocalTaskService()
        self.viewModel = ManageTasksViewModel(localTaskService: self.mockLocalTaskService, converter: TaskManagerResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.viewController.viewModel = self.viewModel
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.viewController = nil
        self.navigationViewController = nil
        self.mockLocalTaskService = nil
        self.viewModel = nil
    }
    
    func testViewDidLoad_when_noData_then_showEmptyMessage() {
        //Arrange
        self.mockLocalTaskService.readStub = self.scheduler.createColdObservable([next(100, [TaskEntity]())]).asObservable()
        
        //Act
        self.loadView(of: self.viewController)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testViewDidLoad_when_data_then_showTasks() {
        //Arrange
        let tasks = self.createDummyTasks1()
        self.mockLocalTaskService.readStub = self.scheduler.createColdObservable([next(100, tasks)]).asObservable()
        
        //Act
        self.loadView(of: self.viewController)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
