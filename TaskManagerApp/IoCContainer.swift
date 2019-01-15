//
//  IoCContainer.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 11.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import Swinject

let appContainer: Container = {
    let container = Container()
    
    container.register(TaskDataAccessor.self) { _ in
        RealmTaskDataAccessor()
    }
    
    container.register(LoggingService.self) { _ in
        ConsoleLoggingService()
    }
    container.register(LocalTaskService.self) { r in
        TaskManagerLocalTaskService(
            dataAccessor: r.resolve(TaskDataAccessor.self)!,
            loggingService: r.resolve(LoggingService.self)!
        )
    }
    container.register(ErrorMessageService.self) { r in
        LocalizedErrorMessageService()
    }
    
    container.register(ManageTasksViewModelType.self) { r in
        ManageTasksViewModel()
    }
    container.register(EditTaskViewModelType.self) { r in
        EditTaskViewModel(
            localTaskService: r.resolve(LocalTaskService.self)!,
            converter: r.resolve(ResultConverter.self)!
        )
    }
    
    container.register(ResultConverter.self) { r in
        TaskManagerResultConverter(
            errorMessageService: r.resolve(ErrorMessageService.self)!
        )
    }
    
    return container
}()
