//
//  Alert Helper.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 07/06/23.
//

import Foundation
import UIKit

class AlertHelper {
    static func showAlert(withTitle title: String, message: String, from viewController: UIViewController, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        viewController.present(alert, animated: true, completion: nil)
    }
}

class ConfirmationDialogHelper {
    
    static func showConfirmationDialog(on viewController: UIViewController, title: String, message: String, confirmActionTitle: String, cancelActionTitle: String, confirmActionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .destructive) { (_) in
            confirmActionHandler()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

