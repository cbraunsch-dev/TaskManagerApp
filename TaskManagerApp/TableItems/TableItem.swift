//
//  TableItem.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol TableItem {
    var title: String { get }
    var action: TableItemAction { get }
}
