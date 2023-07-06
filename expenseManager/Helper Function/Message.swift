//
//  Message.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 06/07/23.
//

import Foundation

struct Message {
    static let errorTitle = "Error"
    static let successTitle = "Success"
    static let successMessage = "Data added successfully."
    static let successUpdateMessage = "Data updated successfully."
    static let errorDataAddMessage = "Failed to add data."
    static let confirmTitle = "Confirmation"
    static let confirmMessage = "Are you sure you want to proceed?"
    static let alertTitle = "Alert"
    static let logoutAlertMessage = "Error logging out"
    static let errorFetechingDataMessage = "Error fetching Data: "
    static let dataNotFoundMessage = "Data not found."
    static let errorDataUpdateMessage = "Error updating data: "
    static let deleteTitle = "Delete"
    static let deleteMessage = "Are you sure you want to delete"
    static let deleteErrorMessage = "Error deleting data: "
    static let budgetInvalidMessage = "Invalid budget value."
    static let emptyWarningMessage = "Please fill in all fields."
    static  let amountExceedMessage = "Expense amount exceeds the available limit."
    static let imageWarningMessage = "Please select an image."
    static let emptyIDMessage = "Document ID is empty."
    static let limitExceedTitle = "Limit Exceeded"
    static let limitExceedMessage = "The updated expense amount exceeds the limit."
    static let errorEmptyTitleMessage = "Please enter a title."
    static let errorEmptyAmountMessage = "Please enter a title."
    static let errorEmptyImageMessage = "Please enter a title."
    static let errorSaveMessage = "Failed to save data. Please try again."
    static let errorPhoneMessage = "No phone number found."
    static let resendOTPSuccessMessage = "OTP has been resent successfully."
    static let errorSendOTPMessage = "Failed to send OTP. Please try again."
    static let errorEmptyPhoneMessage = "Please enter a phone number."
    static let errorValidPhoneMessage = "Please enter a valid 10-digit phone number."
}
