//
//  SwinjectStoryboard+Extension.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 11.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import SwinjectStoryboard
import Swinject

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.storyboardInitCompleted(ManageTasksViewController.self) { r, c in
            c.viewModel = appContainer.resolve(ManageTasksViewModelType.self)!
        }
    }
}
