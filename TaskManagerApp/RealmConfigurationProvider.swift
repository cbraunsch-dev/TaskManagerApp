//
//  RealmConfigurationProvider.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 18.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift

public protocol RealmConfigurationProvider {
    func fetchConfiguration() -> Realm.Configuration
}

public class TaskManagerRealmConfigurationProvider: RealmConfigurationProvider {
    public init() {}
    
    public func fetchConfiguration() -> Realm.Configuration {
        //Note that Realm does not provide default values for new columns during a migration. Currently this has to be done manually: https://realm.io/docs/objc/latest/#migrations
        // Set the new schema version. This must be greater than the previously used version (if you've never set a schema version before, the version is 0).
        let configuration = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used version (if you've never set a schema version before, the version is 0).
            schemaVersion: 4,
            
            // Set the block which will be called automatically when opening a Realm with a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                //Schema migration code goes here...
        }
        )
        
        return configuration
    }
}
