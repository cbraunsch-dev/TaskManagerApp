//
//  EditTaskViewModelTests.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 18.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import FBSnapshotTestCase
@testable import TaskManagerApp

class EditTaskViewModelTests: XCTestCase, AssertionDataExtractionCapable {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockLocalTaskService: MockLocalTaskService!
    private var testee: EditTaskViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockLocalTaskService = MockLocalTaskService()
        self.testee = EditTaskViewModel(localTaskService: self.mockLocalTaskService, converter: TaskManagerResultConverter(errorMessageService: LocalizedErrorMessageService()))
    }

    override func tearDown() {
        self.scheduler = nil
        self.mockLocalTaskService = nil
        self.testee = nil
        super.tearDown()
    }

    func testSelectItem_when_firstItem_then_editName() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.editName.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer), "Failed to edit the name")
    }

    func testSelectItem_when_secondItem_then_editNotes() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.editNotes.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, IndexPath(row: 1, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer), "Failed to edit the notes")
    }
    
    func testSelectItem_when_firstItemAndNameAlreadyEntered_then_editNameAndEmitAlreadyEnteredName() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let alreadyEnteredName = "Buy groceries"
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.editName.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.createColdObservable([next(100, alreadyEnteredName)]).bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.start()
        
        //Act
        scheduler3.createColdObservable([next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to edit the name")
            return
        }
        XCTAssertEqual(alreadyEnteredName, result, "Failed to emit the name that was already entered")
    }

    func testSelectItem_when_secondItemAndNotesAlreadyEntered_then_editNotesAndEmitAlreadyEnteredNotes() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let alreadyEnteredNotes = "Check out new store"
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.editNotes.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.createColdObservable([next(100, alreadyEnteredNotes)]).bind(to: self.testee.inputs.notesText).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.start()
        
        //Act
        scheduler3.createColdObservable([next(100, IndexPath(row: 1, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to edit the notes")
            return
        }
        XCTAssertEqual(alreadyEnteredNotes, result, "Failed to emit the notes that was already entered")
    }
    
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
    
    func testSaveButtonTaps_when_dataSaved_then_emitSuccess() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let scheduler4 = TestScheduler(initialClock: 0)
        let observer = scheduler4.createObserver(Void.self)
        self.testee.outputs.taskSaved.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.createColdObservable([next(100, "Name")]).bind(to: self.testee.inputs.nameText).disposed(by: self.bag)
        scheduler3.createColdObservable([next(100, "Notes")]).bind(to: self.testee.inputs.notesText).disposed(by: self.bag)
        self.mockLocalTaskService.saveStub = scheduler4.createColdObservable([next(100, ())]).asObservable()
        scheduler1.start()
        scheduler2.start()
        scheduler3.start()
        
        //Act
        scheduler4.createColdObservable([next(100, ())]).bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler4.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer), "Failed to emit success")
    }
    
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
}
