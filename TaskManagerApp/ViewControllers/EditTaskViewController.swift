//
//  EditTaskViewController.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditTaskViewController: UIViewController, TableDisplayCapable {
    private let bag = DisposeBag()
    private let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: nil, action: nil)
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var sections = [TitleValueTableSection]()
    
    var viewModel: EditTaskViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.editTask
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        self.setupTable()
        self.tableView.register(TitleValueTableViewCell.self, forCellReuseIdentifier: String.init(describing: TitleValueTableViewCell.self))
        self.navigationItem.rightBarButtonItem = self.saveButton
        
        self.viewModel.outputs.sections.subscribe(onNext: { sections in
            self.sections.removeAll()
            self.sections.append(contentsOf: sections)
            self.tableView.reloadData()
        }).disposed(by: self.bag)
        self.viewModel.outputs.saveButtonEnabled
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: self.bag)
        
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.sections[indexPath.section].items[indexPath.row]
        guard let itemType = item.type as? EditTaskTableItemType else {
            fatalError("Cell items in \(type(of: self)) are of the wrong type")
        }
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TitleValueTableViewCell
        cell.titleValueContent.title.text = item.title
        cell.titleValueContent.value.text = item.value
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
