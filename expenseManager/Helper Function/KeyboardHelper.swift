//
//  KeyboardHelper.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 07/06/23.
//

import Foundation
import UIKit

class KeyboardHelper {
    // MARK: Keyboard Observing

    static func startObservingKeyboardNotifications(for viewController: UIViewController) {
        NotificationCenter.default.addObserver(viewController, selector: #selector(viewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(viewController, selector: #selector(viewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: viewController, action: #selector(viewController.handleTap(_:)))
                viewController.view.addGestureRecognizer(tapGesture)
    }

    static func stopObservingKeyboardNotifications(for viewController: UIViewController) {
        NotificationCenter.default.removeObserver(viewController, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(viewController, name: UIResponder.keyboardWillHideNotification, object: nil)
    }


}

private var textFieldBottomPaddingKey: UInt8 = 0

extension UIViewController {
    // MARK: Keyboard Handling

    @objc func keyboardWillShow(notification: Notification) {
        guard let activeTextField = findFirstResponder(in: view) as? UITextField,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let textFieldBottomY = activeTextField.frame.maxY
        let convertedKeyboardFrame = view.convert(keyboardFrame, from: nil)

        let padding = textFieldBottomPadding
        let offsetY = textFieldBottomY - convertedKeyboardFrame.origin.y + padding

        if offsetY > 0 {
            view.frame.origin.y = -offsetY
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            view.endEditing(true)
        }
    
    // Helper method to find the first responder (active) text field in a view hierarchy
    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }

        for subview in view.subviews {
            if let firstResponder = findFirstResponder(in: subview) {
                return firstResponder
            }
        }

        return nil
    }

    // MARK: Properties

    private var textFieldBottomPadding: CGFloat {
        get {
            return objc_getAssociatedObject(self, &textFieldBottomPaddingKey) as? CGFloat ?? 20.0
        }
        set {
            objc_setAssociatedObject(self, &textFieldBottomPaddingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setTextFieldBottomPadding(_ padding: CGFloat) {
        textFieldBottomPadding = padding
    }
 
}




