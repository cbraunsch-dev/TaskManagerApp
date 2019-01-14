//
//  GenericTableSection.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct GenericTableSection: TableSection {
    let items: [GenericTableItem]
    let title: String?
    let footer: String?
}
