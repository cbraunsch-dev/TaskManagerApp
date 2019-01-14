//
//  GenericTableItem.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct GenericTableItem: TableItem {
    let title: String
    let action: TableItemAction
    let type: TableItemType
}

enum GenericItemType: TableItemType {
    case emptyPlaceholder
    case standard
}
