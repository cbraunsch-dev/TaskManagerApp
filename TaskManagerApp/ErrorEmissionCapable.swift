//
//  ErrorEmissionCapable.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 15.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol ErrorEmissionCapable {
    var error: PublishSubject<(errorOccurred: Bool, title: String, message: String)> { get }
}
