//
//  AddCategoryViewController+Extension.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 09/06/23.
//

import Foundation
import UIKit

extension AddCategoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Handle the selected image here
            self.pickedImage = selectedImage
            self.viewImage.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
