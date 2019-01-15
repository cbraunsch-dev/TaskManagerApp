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
    let taskSaved = PublishSubject<Void>()
    let dismissView = PublishSubject<Void>()
    let showCancelConfirmationDialog = PublishSubject<(title: String, message: String)>()
    let showDeleteConfirmationDialog = PublishSubject<(title: String, message: String)>()
    let error = PublishSubject<(errorOccurred: Bool, title: String, message: String)>()
    
    init(localTaskService: LocalTaskService, converter: ResultConverter) {
        self.localTaskService = localTaskService
        self.converter = converter
    }
}

enum EditTaskTableItemType: TableItemType {
    case name
    case notes
}
