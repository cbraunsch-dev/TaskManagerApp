//
//  TestDataGenerating.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 19.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
@testable import TaskManagerApp

protocol TestDataGenerating {}

extension TestDataGenerating {
    func createDummyTasks1() -> [TaskEntity] {
        let task1 = TaskEntity()
        task1.name = "Buy milk"
        task1.notes = "There is a new grocery store"
        
        let task2 = TaskEntity()
        task2.name = "Check courses"
        task2.notes = "What materials do I need?"
        
        let task3 = TaskEntity()
        task3.name = "Call insurance company"
        task3.name = "Car might need new tires"
        
        return [task1, task2, task3]
    }
}
