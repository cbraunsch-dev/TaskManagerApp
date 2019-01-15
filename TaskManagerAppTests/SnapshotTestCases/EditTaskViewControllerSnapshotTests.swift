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
        self.recordMode = true
        verifyViewController(viewController: self.navigationViewController)
        self.recordMode = false
    }

}
