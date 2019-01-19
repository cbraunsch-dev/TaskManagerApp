//
//  AlertDisplayable.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 19.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

protocol AlertDisplayable {}

extension AlertDisplayable where Self: UIViewController {
    func showMessageAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: L10n.Action.ok, style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func showMessageAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true)
    }
    
    func showMessageAlertWithTextField(title: String, message: String, actionTitle: String, placeholder: String, confirmAction: @escaping (_: String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: actionTitle, style: .default) { action in
            guard let textFields = alert.textFields else {
                return
            }
            guard textFields.count > 0  else {
                return
            }
            guard let textField = textFields.first else {
                return
            }
            guard let enteredText = textField.text else {
                return
            }
            confirmAction(enteredText)
        }
        let cancelAction = UIAlertAction(title: L10n.Action.cancel, style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        alert.addTextField() { textField in
            textField.placeholder = placeholder
        }
        self.present(alert, animated: true)
    }
}
