//
//  EditTaskViewModel.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol EditTaskViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var selectItem: PublishSubject<IndexPath> { get }
    var nameText: PublishSubject<String> { get }
    var notesText: PublishSubject<String> { get }
    var saveButtonTaps: PublishSubject<Void> { get }
    var cancelButtonTaps: PublishSubject<Void> { get }
    var confirmCancellation: PublishSubject<Void> { get }
    var confirmDeletion: PublishSubject<Void> { get }
}

protocol EditTaskViewModelOutputs: ErrorEmissionCapable {
    var sections: PublishSubject<[TitleValueTableSection]> { get }
    var saveButtonEnabled: PublishSubject<Bool> { get }
    var editName: PublishSubject<String> { get }
    var editNotes: PublishSubject<String> { get }
    var taskSaved: PublishSubject<Void> { get }
    var dismissView: PublishSubject<Void> { get }
    var showCancelConfirmationDialog: PublishSubject<(title: String, message: String)> { get }
    var showDeleteConfirmationDialog: PublishSubject<(title: String, message: String)> { get }
}

protocol EditTaskViewModelType {
    var inputs: EditTaskViewModelInputs { get }
    var outputs: EditTaskViewModelOutputs { get }
}

class EditTaskViewModel: EditTaskViewModelType, EditTaskViewModelInputs, EditTaskViewModelOutputs, ErrorBindable {
    private let bag = DisposeBag()
    private let localTaskService: LocalTaskService
    private let converter: ResultConverter
    private let initialSnapshot = PublishSubject<TaskModelSnapshot>()
    private let snapshot = PublishSubject<TaskModelSnapshot>()
    private let selectedItemType = PublishSubject<EditTaskTableItemType>()
    private let saveTaskResult = PublishSubject<OperationResult<Void>>()
    
    var inputs: EditTaskViewModelInputs { return self }
    var outputs: EditTaskViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let selectItem = PublishSubject<IndexPath>()
    let nameText = PublishSubject<String>()
    let notesText = PublishSubject<String>()
    let saveButtonTaps = PublishSubject<Void>()
    let cancelButtonTaps = PublishSubject<Void>()
    let confirmCancellation = PublishSubject<Void>()
    let confirmDeletion = PublishSubject<Void>()
    let sections = PublishSubject<[TitleValueTableSection]>()
    let saveButtonEnabled = PublishSubject<Bool>()
    let editName = PublishSubject<String>()
    let editNotes = PublishSubject<String>()
    let taskSaved = PublishSubject<Void>()
    let dismissView = PublishSubject<Void>()
    let showCancelConfirmationDialog = PublishSubject<(title: String, message: String)>()
    let showDeleteConfirmationDialog = PublishSubject<(title: String, message: String)>()
    let error = PublishSubject<(errorOccurred: Bool, title: String, message: String)>()
    
    init(localTaskService: LocalTaskService, converter: ResultConverter) {
        self.localTaskService = localTaskService
        self.converter = converter
        
        self.inputs.viewDidLoad
            .map { TaskModelSnapshot(name: "", notes: "", isNew: true) }
            .bind(to: self.initialSnapshot)
            .disposed(by: self.bag)
        self.inputs.viewDidLoad
            .map { false }
            .bind(to: self.outputs.saveButtonEnabled)
            .disposed(by: self.bag)
        self.inputs.nameText
            .withLatestFrom(self.snapshot) { (name: $0, snapshot: $1) }
            .map { input in input.snapshot |> TaskModelSnapshot.nameLens *~ input.name }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.notesText
            .withLatestFrom(self.snapshot) { (notes: $0, snapshot: $1) }
            .map { input in input.snapshot |> TaskModelSnapshot.notesLens *~ input.notes }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.selectItem
            .withLatestFrom(self.outputs.sections) { (selection: $0, sections: $1) }
            .map { input -> EditTaskTableItemType? in
                input.sections[input.selection.section].items[input.selection.row].type as? EditTaskTableItemType
            }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: self.selectedItemType)
            .disposed(by: self.bag)
        self.inputs.saveButtonTaps
            .withLatestFrom(self.snapshot)
            .flatMapLatest { input -> Observable<OperationResult<Void>> in
                let task = TaskEntity()
                task.name = input.name
                task.notes = input.notes
                let operation = self.localTaskService.save(task: task)
                return self.converter.convert(result: operation)
            }.bind(to: self.saveTaskResult)
            .disposed(by: self.bag)
        
        self.initialSnapshot
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.snapshot
            .map { self.createSections(from: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        self.snapshot
            .withLatestFrom(self.initialSnapshot) { (snapshot: $0, initial: $1) }
            .map { $0.initial != $0.snapshot && $0.snapshot.name.count > 0 && $0.snapshot.notes.count > 0 }
            .bind(to: self.saveButtonEnabled)
            .disposed(by: self.bag)
        self.selectedItemType
            .filter { $0 == EditTaskTableItemType.name }
            .withLatestFrom(self.snapshot)
            .map { $0.name }
            .bind(to: self.outputs.editName)
            .disposed(by: self.bag)
        self.selectedItemType
            .filter { $0 == EditTaskTableItemType.notes }
            .withLatestFrom(self.snapshot)
            .map { $0.notes }
            .bind(to: self.outputs.editNotes)
            .disposed(by: self.bag)
        self.saveTaskResult
            .filter { $0.resultValue != nil }
            .map { _ in return }
            .bind(to: self.outputs.taskSaved)
            .disposed(by: self.bag)
        
        self.outputs.taskSaved
            .bind(to: self.outputs.dismissView)
            .disposed(by: self.bag)
        
        self.bindError(of: self.saveTaskResult, disposedWith: self.bag)
    }
    
    private func createSections(from snapshot: TaskModelSnapshot) -> [TitleValueTableSection] {
        var items = [TitleValueTableItem]()
        let nameItem = TitleValueTableItem(title: L10n.Action.Task.EditName.title, action: ManageTasksTableItemAction.none, value: snapshot.name, hint: L10n.Action.Task.EditName.hint, type: EditTaskTableItemType.name)
        let notesItem = TitleValueTableItem(title: L10n.Action.Task.EditNotes.title, action: ManageTasksTableItemAction.none, value: snapshot.notes, hint: L10n.Action.Task.EditNotes.hint, type: EditTaskTableItemType.notes)
        items.append(nameItem)
        items.append(notesItem)
        
        let generalSection = TitleValueTableSection(items: items, title: nil, footer: nil)
        return [generalSection]
    }
    
    struct TaskModelSnapshot: Equatable {
        let name: String
        let notes: String
        let isNew: Bool
        
        static func ==(lhs: TaskModelSnapshot, rhs: TaskModelSnapshot) -> Bool {
            return
                lhs.name == rhs.name &&
                lhs.notes == rhs.notes &&
                lhs.isNew == rhs.isNew
        }
      
        static let nameLens = Lens<TaskModelSnapshot, String>(
            get: { $0.name },
            set: { name, model in TaskModelSnapshot(name: name, notes: model.notes, isNew: model.isNew) }
        )
        
        static let notesLens = Lens<TaskModelSnapshot, String>(
            get: { $0.notes },
            set: { notes, model in TaskModelSnapshot(name: model.name, notes: notes, isNew: model.isNew) }
        )
    }
}

enum EditTaskTableItemType: TableItemType {
    case name
    case notes
}
