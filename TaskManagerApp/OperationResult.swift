//
//  OperationResult.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

enum OperationResult<E>: ResultType, ErrorType {
    case successful(result: E)
    case failed(message: String)
    
    var resultValue: E? {
        switch self {
        case .successful(let result):
            return result
        default:
            return nil
        }
    }
    
    var error: String? {
        switch self {
        case .failed(let message):
            return message
        default:
            return nil
        }
    }
}
