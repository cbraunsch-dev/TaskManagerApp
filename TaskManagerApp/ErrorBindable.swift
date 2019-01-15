//
//  ErrorBindable.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ErrorBindable: ErrorEmissionCapable {}

extension ErrorBindable {
    func bindError<E>(of result: Observable<OperationResult<E>>, disposedWith bag: DisposeBag) {
        result
            .filter { $0.error != nil }
            .map { (errorOccurred: true, title: L10n.Error.Generic.short, message: $0.error!) }
            .bind(to: self.error)
            .disposed(by: bag)
    }
}
