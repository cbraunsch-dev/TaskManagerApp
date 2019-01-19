//
//  Realm+Extension.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 18.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    func write(transaction block: @escaping () -> Void, completion: () -> Void) throws {
        try write(block)
        completion()
    }
}
