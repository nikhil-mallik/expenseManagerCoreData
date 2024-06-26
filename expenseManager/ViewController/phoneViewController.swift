//
//  phoneViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit

class phoneViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var phoneTextOutlet: UITextField!
    @IBOutlet weak var sendOTPOutlet: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextOutlet.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardHelper.startObservingKeyboardNotifications(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.stopObservingKeyboardNotifications(for: self)
    }
    
    // MARK: - Actions
    
    @IBAction func sendOTPAction(_ sender: Any) {
        guard let phoneNumber = phoneTextOutlet.text, !phoneNumber.isEmpty else {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.errorEmptyPhoneMessage, from: self)
            return
        }
        // Validate phone number format
        let phoneNumberRegex = "^\\d{10}$"
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        let isValidPhoneNumber = phoneNumberPredicate.evaluate(with: phoneNumber)
        if !isValidPhoneNumber {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.errorValidPhoneMessage, from: self)
            return
        }
        let number = "+91\(phoneNumber)"
        AuthManager.shared.startAuth(phoneNumber: number) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    guard let otpViewController = self?.storyboard?.instantiateViewController(withIdentifier: "otpViewController") as? otpViewController else {
                        return
                    }
                    otpViewController.title = "Enter Code"
                    otpViewController.phoneNumber = phoneNumber // Pass the phoneNumber to otpViewController
                    self?.navigationController?.pushViewController(otpViewController, animated: true)
                }
            } else {
                // Show the error message in an alert
                AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.errorSendOTPMessage, from: self!)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
