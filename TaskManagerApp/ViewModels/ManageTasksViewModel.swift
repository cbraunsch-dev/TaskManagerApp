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

protocol ManageTasksViewModelOutputs {}

protocol ManageTasksViewModelType {
    var inputs: ManageTasksViewModelInputs { get }
    var outputs: ManageTasksViewModelOutputs { get }
}

class ManageTasksViewModel: ManageTasksViewModelType, ManageTasksViewModelInputs, ManageTasksViewModelOutputs {
    private let bag = DisposeBag()
    
    var inputs: ManageTasksViewModelInputs { return self }
    var outputs: ManageTasksViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    
    init() {
        self.inputs.viewDidLoad
            .subscribe(onNext: { print("Hello ViewDidLoad World!") })
            .disposed(by: self.bag)
    }
}
