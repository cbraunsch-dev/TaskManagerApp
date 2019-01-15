//
//  TaskDataAccessor.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol TaskDataAccessor {
    func readAll() -> Observable<[TaskEntity]>
    
    func getTaskById(with id: String) -> Observable<TaskEntity?>
    
    func save(task: TaskEntity) -> Observable<Void>
    
    func removeTask(with id: String) -> Observable<Void>
}

//TODO: Implement realm code
class RealmTaskDataAccessor: TaskDataAccessor {
    func readAll() -> Observable<[TaskEntity]> {
        fatalError("Not yet implemented")
    }
    
    func getTaskById(with id: String) -> Observable<TaskEntity?> {
        fatalError("Not yet implemented")
    }
    
    func save(task: TaskEntity) -> Observable<Void> {
        fatalError("Not yet implemented")
    }
    
    func removeTask(with id: String) -> Observable<Void> {
        fatalError("Not yet implemented")
    }
}
