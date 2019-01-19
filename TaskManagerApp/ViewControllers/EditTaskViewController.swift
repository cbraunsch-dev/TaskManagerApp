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

class EditTaskViewController: UIViewController, TableDisplayCapable, AlertDisplayable {
    private let bag = DisposeBag()
    private let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: nil, action: nil)
    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    var sections = [TitleValueTableSection]()
    var delegate: EditTaskViewControllerDelegate?
    
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
        
        self.saveButton.rx.tap
            .bind(to: self.viewModel.inputs.saveButtonTaps)
            .disposed(by: self.bag)
        self.viewModel.outputs.sections.subscribe(onNext: { sections in
            self.sections.removeAll()
            self.sections.append(contentsOf: sections)
            self.tableView.reloadData()
        }).disposed(by: self.bag)
        self.viewModel.outputs.saveButtonEnabled
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: self.bag)
        self.viewModel.outputs.editName.subscribe(onNext: { name in
            self.showMessageAlertWithTextField(title: L10n.Action.Task.editName, message: L10n.Action.Task.EditName.info, actionTitle: L10n.Action.ok, placeholder: L10n.Action.Task.EditName.hint, text: name, confirmAction: { newName in
                self.viewModel.inputs.nameText.onNext(newName)
            })
        }).disposed(by: self.bag)
        self.viewModel.outputs.editNotes.subscribe(onNext: { notes in
            self.showMessageAlertWithTextField(title: L10n.Action.Task.editNotes, message: L10n.Action.Task.EditNotes.info, actionTitle: L10n.Action.ok, placeholder: L10n.Action.Task.EditNotes.hint, text: notes, confirmAction: { newNotes in
                self.viewModel.inputs.notesText.onNext(newNotes)
            })
        }).disposed(by: self.bag)
        self.viewModel.outputs.error
            .subscribe(onNext: { error in
                self.showMessageAlert(title: error.title, message: error.message)
            }).disposed(by: self.bag)
        self.viewModel.outputs.taskSaved.subscribe(onNext: {
            self.delegate?.didSaveTask()
        }).disposed(by: self.bag)
        self.viewModel.outputs.dismissView.subscribe(onNext: {
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: self.bag)
        
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.sections[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as TitleValueTableViewCell
        cell.titleValueContent.title.text = item.title
        cell.titleValueContent.value.text = item.value
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.inputs.selectItem.onNext(indexPath)
    }
}

protocol EditTaskViewControllerDelegate {
    func didSaveTask()
}
