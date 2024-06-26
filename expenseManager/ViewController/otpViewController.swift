//
//  otpViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit
import FirebaseAuth

class otpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var resendOtpOutlet: UIButton!
    @IBOutlet weak var OtpCodeOutlet: UITextField!
    @IBOutlet weak var verifyBtnOutlet: UIButton!
    
    // MARK: Properties
    
    var verificationID: String?
    var phoneNumber: String?
    var userId: String?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.black
        // Set the delegate for the OTP text field
        OtpCodeOutlet.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardHelper.startObservingKeyboardNotifications(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.stopObservingKeyboardNotifications(for: self)
    }
    
    func resendOTP(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        // Simulating the resend OTP logic with a delay of 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let success = true // Set the success status based on your implementation
            let errorMessage: String? = success ? nil : "Failed to resend OTP" // Set the error message if applicable
            completion(success, errorMessage)
        }
    }
    // MARK: - Actions
    @IBAction func resendOtpAction(_ sender: Any) {
        guard let phoneNumber = phoneNumber else {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.errorPhoneMessage, from: self)
            return
        }
        
        resendOTP(phoneNumber: phoneNumber) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    AlertHelper.showAlert(withTitle: Message.successTitle, message: Message.resendOTPSuccessMessage, from: self)
                } else if let errorMessage = errorMessage {
                    AlertHelper.showAlert(withTitle: Message.alertTitle, message: "\(Message.errorSendOTPMessage) \(errorMessage)", from: self)
                } else {
                    AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.errorSendOTPMessage, from: self)
                }
            }
        }
    }
    @IBAction func verifyBtnAction(_ sender: Any) {
        if let text = OtpCodeOutlet.text, !text.isEmpty {
            let code = text
            AuthManager.shared.verifyCode(smsCode: code) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let categoryVC = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                    categoryVC.modalPresentationStyle = .fullScreen
                    categoryVC.title = "Expense Manager"
                    self?.navigationController?.pushViewController(categoryVC, animated: true)
                }
            }
        }
    }
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
