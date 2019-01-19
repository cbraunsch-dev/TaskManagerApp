//
//  TaskEntity.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import RealmSwift
import Foundation

public class TaskEntity: Object {
    @objc public dynamic var taskID = UUID().uuidString
    @objc public dynamic var name = ""
    @objc public dynamic var notes = ""
    
    override public static func primaryKey() -> String? {
        return "taskID"
    }
}


