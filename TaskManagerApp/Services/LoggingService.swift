//
//  LoggingService.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol LoggingService {
    func logErrors<E>(of response: Observable<E>, callingTypeName: String, callingFunctionName: String) -> Observable<E>
}

class ConsoleLoggingService: LoggingService {
    private let bag = DisposeBag()
    
    func logErrors<E>(of response: Observable<E>, callingTypeName: String, callingFunctionName: String) -> Observable<E> {
        return Observable<E>.create { observer in
            response.subscribe(
                onNext: { observer.onNext($0) },
                onError: { error in
                    print("An error occurred: \(error)")
                    observer.onError(error)
                }
            ).disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    
}
