//
//  ResultConverter.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol ResultConverter {
    func convert<E>(result: Observable<E>) -> Observable<OperationResult<E>>
}

class TaskManagerResultConverter: ResultConverter {
    private let bag = DisposeBag()
    private let errorMessageService: ErrorMessageService
    
    init(errorMessageService: ErrorMessageService) {
        self.errorMessageService = errorMessageService
    }
    
    func convert<E>(result: Observable<E>) -> Observable<OperationResult<E>> {
        return Observable<OperationResult<E>>.create { observer in
            result.subscribe(onNext: { result in
                observer.onNext(OperationResult.successful(result: result))
            }, onError: { error in
                let message = self.errorMessageService.getMessage(for: error)
                observer.onNext(OperationResult.failed(message: message))
            }).disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
}
