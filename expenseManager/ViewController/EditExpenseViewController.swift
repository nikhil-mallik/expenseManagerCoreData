//
//  EditExpenseViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 30/05/23.
//

import UIKit
import CoreData

class EditExpenseViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var previewImageOutlet: UILabel!
    @IBOutlet weak var expAmtOutlet: UITextField!
    @IBOutlet weak var updateBtnOutlet: UIButton!
    @IBOutlet weak var descOutlet: UITextField!
    @IBOutlet weak var addimageOutlet: UIButton!
    
    // MARK: Properties
    
    var imagePickerHelper: ImagePickerHelper?
    var expense: ExpenseEntity?
    var documentId: String?
    var newLimit: Int?
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Call the helper method to initialize the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardHelper.startObservingKeyboardNotifications(for: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardHelper.stopObservingKeyboardNotifications(for: self)
    }
    
    // MARK: Helper Methods
    func setupUI() {
        cornerRadius()
        imageViewOutlet.contentMode = .scaleAspectFill
        imagePickerHelper = ImagePickerHelper()
        imageViewOutlet.layer.cornerRadius = min(imageViewOutlet.frame.size.width, imageViewOutlet.frame.size.height) / 2
        imageViewOutlet.layer.masksToBounds = true
        navigationController?.navigationBar.tintColor = .black
        guard let documentId = documentId,
              let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        do {
            // Fetch the expense using the document ID
            if let objectId = try managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: documentId)!),
               let expense = try managedObjectContext.existingObject(with: objectId) as? ExpenseEntity {
                self.expense = expense
                
                expAmtOutlet.text = "\(expense.expAmt)" // Set the expense amount in the text field
                descOutlet.text = expense.desc // Set the expense description in the text field
                
                if let imageData = expense.imageURL,
                   let image = UIImage(data: imageData) {
                    imageViewOutlet.image = image // Set the expense image
                    imageViewOutlet.isHidden = false
                }
            } else {
                print("Expense not found.")
            }
        } catch {
            print("Error fetching expense: \(error.localizedDescription)")
        }
    }
    
    func cornerRadius() {
        CornerRadiusHelper.applyCornerRadius(expAmtOutlet )
        CornerRadiusHelper.applyCornerRadius(updateBtnOutlet )
        CornerRadiusHelper.applyCornerRadius(descOutlet)
    }
    func fetchCategory(with categoryId: String) -> CategoryEntity? {
        guard let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return nil
        }
        
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "catId == %@", categoryId)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching category: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: IBActions
    
    
    @IBAction func addimageAction(_ sender: Any) {
        imagePickerHelper = ImagePickerHelper()
        imagePickerHelper?.presentImagePicker(in: self) { [weak self] selectedImage in
            self?.imageViewOutlet.image = selectedImage
        }
    }
    
    @IBAction func updateBtnAction(_ sender: Any) {
        guard let expense = self.expense,
              let _ = documentId,
              let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext,
              let updatedExpenseAmount = expAmtOutlet.text,
              let updatedDescription = descOutlet.text else {
            return
        }
        
        do {
            if let categoryId = expense.catId,
               let category = fetchCategory(with: categoryId) {
                let oldExpenseAmount = expense.expAmt
                let categoryTotalAmount = category.totalAmount
                
                if let newExpenseAmount = Int64(updatedExpenseAmount) {
                    let expenseDifference = newExpenseAmount - oldExpenseAmount
                    let newTotalExpense = categoryTotalAmount + expenseDifference
                    category.totalAmount = newTotalExpense
                }
            }
            
            let limit = newLimit ?? 0
            let sum = limit + Int(expense.expAmt)
            
            if let updatedExpense = Int64(updatedExpenseAmount), updatedExpense > sum {
                AlertHelper.showAlert(withTitle: "Limit Exceeded", message: "The updated expense amount exceeds the limit.", from: self)
                return
            }
            
            expense.expAmt = Int64(updatedExpenseAmount) ?? 0 // Update the expense amount
            expense.desc = updatedDescription // Update the expense description
            
            if let updatedImage = imageViewOutlet.image {
                expense.imageURL = updatedImage.jpegData(compressionQuality: 0.5) // Update the expense image
            }
            
            try managedObjectContext.save() // Save the changes to the managed object context
            AlertHelper.showAlert(withTitle: "Success", message: "Expense updated successfully.", from: self) {
                self.navigationController?.popViewController(animated: true) // Pop the view controller from the navigation stack
            }
        } catch {
            print("Error updating expense: \(error.localizedDescription)")
        }
    }
}
