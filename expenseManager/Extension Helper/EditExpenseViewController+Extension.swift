//
//  EditExpenseViewController+Extension.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 09/06/23.
//

import UIKit

extension EditExpenseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // MARK: Image Picker Delegate
    
    func presentImagePicker() {
        let imagePickerHelper = ImagePickerHelper()
        imagePickerHelper.presentImagePicker(in: self) { [weak self] selectedImage in
            self?.imageViewOutlet.image = selectedImage
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the image picker after selecting an image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the image picker on cancellation
    }
}


