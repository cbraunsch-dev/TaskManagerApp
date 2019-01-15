//
//  LocalTaskService.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol LocalTaskService {
    func readAll() -> Observable<[TaskEntity]>
    
    func getTaskById(with id: String) -> Observable<TaskEntity?>
    
    func save(task: TaskEntity) -> Observable<Void>
    
    func removeTask(with id: String) -> Observable<Void>
}

class TaskManagerLocalTaskService: LocalTaskService {
    private let bag = DisposeBag()
    private let dataAccessor: TaskDataAccessor
    private let loggingService: LoggingService
    
    init(dataAccessor: TaskDataAccessor, loggingService: LoggingService) {
        self.dataAccessor = dataAccessor
        self.loggingService = loggingService
    }
    
    func readAll() -> Observable<[TaskEntity]> {
        return self.loggingService.logErrors(of: self.dataAccessor.readAll(), callingTypeName: "\(type(of: self))", callingFunctionName: #function)
    }
    
    func getTaskById(with id: String) -> Observable<TaskEntity?> {
        return self.loggingService.logErrors(of: self.dataAccessor.getTaskById(with: id), callingTypeName: "\(type(of: self))", callingFunctionName: #function)
    }
    
    func save(task: TaskEntity) -> Observable<Void> {
        return self.loggingService.logErrors(of: self.dataAccessor.save(task: task), callingTypeName: "\(type(of: self))", callingFunctionName: #function)
    }
    
    func removeTask(with id: String) -> Observable<Void> {
        return self.loggingService.logErrors(of: self.dataAccessor.removeTask(with: id), callingTypeName: "\(type(of: self))", callingFunctionName: #function)
    }
}
