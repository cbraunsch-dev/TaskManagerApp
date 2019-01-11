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

class ManageTasksViewController: UIViewController {
    private let bag = DisposeBag()
    
    var viewModel: ManageTasksViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.inputs.viewDidLoad.onNext(())
    }
}
