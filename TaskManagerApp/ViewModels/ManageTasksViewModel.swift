//
//  ManageTasksViewModel.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 11.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ManageTasksViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol ManageTasksViewModelOutputs {
    var sections: PublishSubject<[GenericTableSection]> { get }
}

protocol ManageTasksViewModelType {
    var inputs: ManageTasksViewModelInputs { get }
    var outputs: ManageTasksViewModelOutputs { get }
}

class ManageTasksViewModel: ManageTasksViewModelType, ManageTasksViewModelInputs, ManageTasksViewModelOutputs {
    private let bag = DisposeBag()
    
    var inputs: ManageTasksViewModelInputs { return self }
    var outputs: ManageTasksViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let sections = PublishSubject<[GenericTableSection]>()
    
    init() {
        self.inputs.viewDidLoad
            .map { _ -> [GenericTableSection] in
                self.createTableSections()
            }.bind(to: self.outputs.sections)
            .disposed(by: self.bag)
    }
    
    private func createTableSections() -> [GenericTableSection] {
        //Create empty placeholder
        let item = GenericTableItem(title: L10n.Table.Item.Placeholder.noTasksAvailable, action: ManageTasksTableItemAction.none, type: GenericItemType.emptyPlaceholder)
        let section = GenericTableSection(items: [item], title: nil, footer: nil)
        return [section]
    }
}

enum ManageTasksTableItemAction: TableItemAction {
    case none
}
