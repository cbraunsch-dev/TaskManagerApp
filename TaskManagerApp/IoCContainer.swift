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
    
    container.register(ManageTasksViewModelType.self) { r in
        ManageTasksViewModel()
    }
    
    return container
}()
