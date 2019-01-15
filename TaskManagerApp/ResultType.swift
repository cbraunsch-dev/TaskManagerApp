//
//  ResultType.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol ResultType {
    associatedtype Value
    
    var resultValue: Value? { get }
}
