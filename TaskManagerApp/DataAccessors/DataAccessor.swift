//
//  DataAccessor.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 18.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

public class DataAccessor {
    private let configurationProvider: RealmConfigurationProvider
    
    init(configurationProvider: RealmConfigurationProvider) {
        self.configurationProvider = configurationProvider
    }
    
    func obtainRealm() throws -> Realm {
        let configuration = self.configurationProvider.fetchConfiguration()
        
        // Now that we've told Realm how to handle the schema change, opening the file will automatically perform the migration
        guard let realm = try? Realm(configuration: configuration) else {
            throw DataAccessorError.failedToAccessDatabase
        }
        return realm
    }
}
