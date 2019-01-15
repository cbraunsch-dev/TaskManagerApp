//
//  ManageTasksViewController.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 11.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ManageTasksViewController: UIViewController, TableDisplayCapable, SegueHandlerType {
    private let bag = DisposeBag()
    let tableView = UITableView()
    
    var viewModel: ManageTasksViewModelType!
    var sections = [GenericTableSection]()
    
    enum SegueIdentifier: String {
        case addTask
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = L10n.Title.viewTasks
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        self.setupTable()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: String.init(describing: UITableViewCell.self))
        
        self.viewModel.outputs.sections.subscribe(onNext: { sections in
            self.sections.removeAll()
            self.sections.append(contentsOf: sections)
            self.tableView.reloadData()
        }).disposed(by: self.bag)

        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let item = section.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = .none
        cell.textLabel?.text = item.title
        return cell
    }
}
