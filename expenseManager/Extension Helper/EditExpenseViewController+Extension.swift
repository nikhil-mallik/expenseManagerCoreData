//
//  EditExpenseViewController+Extension.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 09/06/23.
//

import UIKit

extension EditExpenseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Handle the selected image
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Handle cancellation
        picker.dismiss(animated: true, completion: nil)
    }
}


