//
//  TableSection.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol TableSection {
    associatedtype Item: TableItem
    var items: [Item] { get }
    var title: String? { get }
    var footer: String? { get }
}
