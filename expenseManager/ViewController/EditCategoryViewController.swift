//
//  EditCategoryViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 30/05/23.
//

import UIKit
import CoreData

class EditCategoryViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var previewImageOutlet: UILabel!
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var budgetOutlet: UITextField!
    @IBOutlet weak var updateBtnOutlet: UIButton!
    @IBOutlet weak var addimageOutlet: UIButton!
    
    // MARK: Properties
    
    var imagePickerHelper: ImagePickerHelper?
    var category: CategoryEntity?
    var categoryId: String?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillData()
        setupImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardHelper.startObservingKeyboardNotifications(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.stopObservingKeyboardNotifications(for: self)
    }
    
    // MARK: UI Setup
    
    func fillData() {
        if let category = category {
            titleOutlet.text = category.title
            budgetOutlet.text = String(category.budget)
            if let imageData = category.imageURL,
               let image = UIImage(data: imageData) {
                imageViewOutlet.image = image
            } else {
                imageViewOutlet.image = ImageHelper.generatePlaceholderImage(text: category.title ?? "")
            }
        }
    }
    
    func setupImageView() {
        imageViewOutlet.contentMode = .scaleAspectFill
        imageViewOutlet.layer.cornerRadius = min(imageViewOutlet.frame.size.width, imageViewOutlet.frame.size.height) / 2
        imageViewOutlet.layer.masksToBounds = true
        navigationController?.navigationBar.tintColor = .black
        cornerRadius()
    }
    
    func cornerRadius() {
        CornerRadiusHelper.applyCornerRadius(budgetOutlet)
        CornerRadiusHelper.applyCornerRadius(updateBtnOutlet)
    }
    
    // MARK: Actions
    
    @IBAction func addimageAction(_ sender: Any) {
        imagePickerHelper = ImagePickerHelper()
        imagePickerHelper?.presentImagePicker(in: self) { [weak self] selectedImage in
            self?.imageViewOutlet.image = selectedImage
        }
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        guard let imageData = imageViewOutlet.image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        LoaderViewHelper.showLoader(on: view)
        updateCategoryData(imageData)
        LoaderViewHelper.hideLoader()
    }
    
    // MARK: Data Update
    
    func updateCategoryData(_ imageData: Data) {
        guard let categoryId = categoryId else {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "catId == %@", categoryId)
        
        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            guard let categoryToUpdate = fetchedCategories.first else {
                return
            }
            
            categoryToUpdate.title = titleOutlet.text
            if let budgetText = budgetOutlet.text, let budget = Int64(budgetText) {
                categoryToUpdate.budget = budget
            } else {
                AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.budgetInvalidMessage , from: self)
                return
            }
            categoryToUpdate.imageURL = imageData
            
            try context.save()
            AlertHelper.showAlert(withTitle: Message.successTitle, message: Message.successUpdateMessage, from: self) {
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: "\(Message.errorDataUpdateMessage) \(error.localizedDescription)", from: self)
            
        }
    }
}
