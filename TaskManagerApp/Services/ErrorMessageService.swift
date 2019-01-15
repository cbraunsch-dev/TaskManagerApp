//
//  ErrorMessageService.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol ErrorMessageService {
    func getMessage(for error: Error) -> String
}

class LocalizedErrorMessageService: ErrorMessageService {
    func getMessage(for error: Error) -> String {
        if let dataAccessorError = error as? DataAccessorError {
            switch dataAccessorError {
            case .failedToAccessDatabase:
                    return L10n.Error.DataAccessor.failedToAccessDatabase
            case .itemToDeleteNotFound:
                return L10n.Error.DataAccessor.itemToDeleteNotFound
            case .outOfDiskSpace:
                return L10n.Error.DataAccessor.outOfDiskSpace
            }
        }
        return L10n.Error.generic
    }
}
