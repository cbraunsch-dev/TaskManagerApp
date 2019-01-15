//
//  Errors.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

enum DataAccessorError: Error {
    case outOfDiskSpace
    case failedToAccessDatabase
    case itemToDeleteNotFound
}
