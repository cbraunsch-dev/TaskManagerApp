//
//  Mocks.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
@testable import TaskManagerApp

class MockLocalTaskService: LocalTaskService {
    var didSave = false
    var savedTask: TaskEntity?
    var saveStub: Observable<Void>?
    var didRead = false
    var readStub: Observable<[TaskEntity]>?
    var didGetTaskById = false
    var getTaskByIdStub: Observable<TaskEntity?>?
    var didRemoveTask = false
    var removedTaskId: String?
    var removeTaskStub: Observable<Void>?
    
    func save(task: TaskEntity) -> Observable<Void> {
        self.didSave = true
        self.savedTask = task
        if let stub = self.saveStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
    
    func getTaskById(with id: String) -> Observable<TaskEntity?> {
        self.didGetTaskById = true
        if let stub = self.getTaskByIdStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
    
    func readAll() -> Observable<[TaskEntity]> {
        self.didRead = true
        if let stub = self.readStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
    
    func removeTask(with id: String)-> Observable<Void> {
        self.didRemoveTask = true
        self.removedTaskId = id
        if let stub = self.removeTaskStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
}
