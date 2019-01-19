//
//  ManageTasksViewModelTests.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 19.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import TaskManagerApp

class ManageTasksViewModelTests: XCTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockLocalTaskService: MockLocalTaskService!
    private var testee: ManageTasksViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockLocalTaskService = MockLocalTaskService()
        self.testee = ManageTasksViewModel(localTaskService: self.mockLocalTaskService, converter: TaskManagerResultConverter(errorMessageService: LocalizedErrorMessageService()))
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockLocalTaskService = nil
        self.testee = nil
    }

    func testDidSaveTask_then_readTasks() {
        //Arrange
        self.mockLocalTaskService.readStub = Observable<[TaskEntity]>.empty()
        
        //Act
        self.scheduler.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.didSaveTask).disposed(by: self.bag)
        self.scheduler.start()
        
        //Assert
        XCTAssertTrue(self.mockLocalTaskService.didRead)
    }
}
