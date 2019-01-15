//
//  TitleValueTableSection.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct TitleValueTableSection: TableSection {
    let items: [TitleValueTableItem]
    let title: String?
    let footer: String?
}
