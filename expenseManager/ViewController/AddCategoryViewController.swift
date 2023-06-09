//
//  AddCategoryViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 26/05/23.
//
import UIKit
import CoreData

class AddCategoryViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var uploadImage: UIButton!
    @IBOutlet weak var titleOutlet: UITextField!
    @IBOutlet weak var amountOutlet: UITextField!
    @IBOutlet weak var addDataOutlet: UIButton!
    
    // MARK: Properties
    
    private var pickedImage: UIImage?
    private var managedObjectContext: NSManagedObjectContext!
    var userId: String?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupManagedObjectContext()
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
    
    private func setupUI() {
        navigationItem.title = "Add Category"
        navigationController?.navigationBar.tintColor = .black
        viewImage.contentMode = .scaleAspectFill
        viewImage.layer.cornerRadius = min(viewImage.frame.size.width, viewImage.frame.size.height) / 2
        viewImage.layer.masksToBounds = true
    }
    
    // MARK: Managed Object Context
    
    private func setupManagedObjectContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get the managed object context.")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: Actions
    
    @IBAction func uploadImageAction(_ sender: Any) {
        let imagePickerHelper = ImagePickerHelper()
        imagePickerHelper.presentImagePicker(in: self) { [weak self] selectedImage in
            if let image = selectedImage {
                self?.pickedImage = image
                self?.viewImage.image = selectedImage
            }
        }
    }
    
    @IBAction func addDataAction(_ sender: Any) {
        guard let title = titleOutlet.text, !title.isEmpty else {
            showAlert(withTitle: "Error", message: "Please enter a title.")
            return
        }
        
        guard let amountString = amountOutlet.text, !amountString.isEmpty, let amount = Int(amountString) else {
            showAlert(withTitle: "Error", message: "Please enter a valid amount.")
            return
        }
        
        guard let selectedImage = pickedImage else {
            showAlert(withTitle: "Error", message: "Please upload an image.")
            return
        }
        
        LoaderViewHelper.showLoader(on: view)
        saveCategory(withTitle: title, amount: amount, image: selectedImage)
    }
    
    // MARK: Core Data Operations
    
    private func saveCategory(withTitle title: String, amount: Int, image: UIImage) {
        guard let userId = userId else {
            return
        }
        
        let category = CategoryEntity(context: managedObjectContext)
        category.catId = UUID().uuidString
        category.title = title
        category.budget = Int64(amount)
        category.totalAmount = 0
        category.time = Date()
        category.uid = userId
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            category.imageURL = imageData
        }
        
        do {
            try managedObjectContext.save()
            let storeURL = managedObjectContext.persistentStoreCoordinator?.persistentStores.first?.url
            print("Database location: \(storeURL?.path ?? "Unknown")")
            
            showAlert(withTitle: "Success", message: "Category added successfully.") { [weak self] in
                self?.clearFields()
            }
        } catch {
            showAlert(withTitle: "Error", message: "Failed to save category. Please try again.")
        }
    }
    
    // MARK: Helper Methods
    
    private func showAlert(withTitle title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func clearFields() {
        titleOutlet.text = ""
        amountOutlet.text = ""
        viewImage.image = nil
        previewLabel.text = ""
        addDataOutlet.isEnabled = true
        LoaderViewHelper.hideLoader()
    }
}
