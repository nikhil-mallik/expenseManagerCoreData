//
//  ImageHelper.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 07/06/23.
//

import Foundation
import UIKit

class ImageHelper {
    static func generatePlaceholderImage(text: String) -> UIImage? {
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.lightGray.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        (text as NSString).draw(in: CGRect(x: 0, y: 10, width: size.width, height: size.height), withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


class ImagePickerHelper: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var imagePicker: UIImagePickerController?
    private var viewController: UIViewController?
    private var completionHandler: ((UIImage?) -> Void)?
    
    func presentImagePicker(in viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.viewController = viewController
        self.completionHandler = completion
        
        let actionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = viewController.view.bounds
        }
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard let viewController = viewController else {
            return
        }
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = sourceType
        
        viewController.present(imagePicker!, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        completionHandler?(selectedImage)
        
        completionHandler = nil
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completionHandler?(nil)
        
        completionHandler = nil
        imagePicker?.dismiss(animated: true, completion: nil)
    }
}
