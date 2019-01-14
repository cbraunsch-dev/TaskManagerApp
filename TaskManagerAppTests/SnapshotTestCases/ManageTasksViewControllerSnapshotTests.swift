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

class ManageTasksViewControllerSnapshotTests: FBSnapshotTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var viewController: ManageTasksViewController!
    private var navigationViewController: UINavigationController!
    private var viewModel: ManageTasksViewModel!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.viewController = (UIStoryboard(name: StoryboardName.manageTasks.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "ManageTasksViewController") as! ManageTasksViewController)
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
        self.viewModel = ManageTasksViewModel()
        self.viewController.viewModel = self.viewModel
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.viewController = nil
        self.navigationViewController = nil
        self.viewModel = nil
    }
    
    func testViewDidLoad_when_noData_then_showEmptyMessage() {
        //Arrange/Act
        self.loadView(of: self.viewController)
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
