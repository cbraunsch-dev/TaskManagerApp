//
//  TableDisplayCapable.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

protocol TableDisplayCapable: UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView { get }
}

extension TableDisplayCapable {
    func setupTable() {
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 140
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
    }
}
