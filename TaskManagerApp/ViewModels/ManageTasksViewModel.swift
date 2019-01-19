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
    private let localTaskService: LocalTaskService
    private let converter: ResultConverter
    private let readTasksResult = PublishSubject<OperationResult<[TaskEntity]>>()
    
    var inputs: ManageTasksViewModelInputs { return self }
    var outputs: ManageTasksViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let sections = PublishSubject<[GenericTableSection]>()
    
    init(localTaskService: LocalTaskService, converter: ResultConverter) {
        self.localTaskService = localTaskService
        self.converter = converter
        
        self.inputs.viewDidLoad
            .flatMapLatest { _ -> Observable<OperationResult<[TaskEntity]>> in
                let operation = self.localTaskService.readAll()
                return self.converter.convert(result: operation)
            }.bind(to: self.readTasksResult)
            .disposed(by: self.bag)
        
        self.readTasksResult
            .filter { $0.resultValue != nil }
            .map { $0.resultValue! }
            .map { self.createTableSections(tasks: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
    }
    
    private func createTableSections(tasks: [TaskEntity]) -> [GenericTableSection] {
        guard tasks.count > 0 else {
            //Create empty placeholder
            let item = GenericTableItem(title: L10n.Table.Item.Placeholder.noTasksAvailable, action: ManageTasksTableItemAction.none, type: GenericItemType.emptyPlaceholder)
            let section = GenericTableSection(items: [item], title: nil, footer: nil)
            return [section]
        }
        let items = tasks.map { task -> GenericTableItem in
            GenericTableItem(title: task.name, action: ManageTasksTableItemAction.none, type: GenericItemType.standard)
        }
        let section = GenericTableSection(items: items, title: nil, footer: nil)
        return [section]
    }
}

enum ManageTasksTableItemAction: TableItemAction {
    case none
}
