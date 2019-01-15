//
//  TaskEntity.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

//TODO: Make this a Realm entity
import Foundation

public class TaskEntity {
    @objc public dynamic var taskID = UUID().uuidString
    @objc public dynamic var name = ""
    @objc public dynamic var notes = ""
    
    //TODO: Uncomment this once this is a Realm type
    /*override public static func primaryKey() -> String? {
        return "taskID"
    }*/
}


