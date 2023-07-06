import UIKit
import CoreData

class ParticularExpenseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expAmtOutlet: UITextField!
    @IBOutlet weak var imageUploadBtnOutlet: UIButton!
    @IBOutlet weak var addBtnOutlet: UIButton!
    @IBOutlet weak var descOutlet: UITextField!
    @IBOutlet weak var ViewImage: UIImageView!

    var selectedCellIndex: Int?
    var categoryDocumentId: String?
    var expenses: [ExpenseModel] = []
    var refreshControl = UIRefreshControl()
    var newlimitAmount: Int = 0
    var managedObjectContext: NSManagedObjectContext!
    var totalExpense: Int = 0
    var budgetAmount: Int64 = 0
    var limitAmountLabel: UILabel!
    private var pickedImage: UIImage?
    var imagePickerHelper: ImagePickerHelper?
    private var isVisible: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius()
        tableView.dataSource = self
        tableView.delegate = self
      
        imagePickerHelper = ImagePickerHelper()
        navigationController?.navigationBar.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(refreshExpenses), for: .valueChanged)
        tableView.refreshControl = refreshControl
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        if managedObjectContext == nil {
            return
        }
        fetchDataForCategory()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        fetchDataForCategory()
        limitAmountLabel.removeFromSuperview()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        if managedObjectContext == nil {
            return
        }
        selectedCellIndex = nil
        tableView.reloadData()
        KeyboardHelper.stopObservingKeyboardNotifications(for: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        isVisible = true
        KeyboardHelper.startObservingKeyboardNotifications(for: self)
    }

    @objc func navBarTrailing() {
        limitAmountLabel?.removeFromSuperview()
        if isVisible {
            limitAmountLabel = UILabel()
            limitAmountLabel.textColor = .black
            limitAmountLabel.font = .systemFont(ofSize: 16)
            limitAmountLabel.text = "left: \(newlimitAmount)"
            let rightBarButton = UIBarButtonItem(customView: limitAmountLabel)
            navigationItem.rightBarButtonItem = rightBarButton
        } else {
            limitAmountLabel.removeFromSuperview()
        }
        limitAmountLabel.text = "left: \(newlimitAmount)"
    }

    @objc func refreshExpenses() {
        fetchDataForCategory()
    }

    @IBAction func imageUploadBtnAction(_ sender: Any) {
        imagePickerHelper?.presentImagePicker(in: self) { [weak self] selectedImage in
            if let image = selectedImage {
                self?.pickedImage = image
                self?.ViewImage.image = selectedImage
            }
        }
    }
    
    

    @IBAction func addBtnAction(_ sender: Any) {
        guard let categoryDocumentId = categoryDocumentId,
              let expenseAmountString = expAmtOutlet.text,
              let expenseAmount = Int(expenseAmountString),
              let description = descOutlet.text,
              !expenseAmountString.isEmpty,
              !description.isEmpty else {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.emptyWarningMessage, from: self)
            return
        }
        if expenseAmount > newlimitAmount {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.amountExceedMessage, from: self)
            return
        }
        guard let selectedImage = ViewImage.image,
              let imageData = selectedImage.jpegData(compressionQuality: 1.0) else {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.imageWarningMessage, from: self)
            return
        }
        saveExpenseData(expenseAmount: expenseAmount, description: description, imageData: imageData, categoryDocumentId: categoryDocumentId)
    }

    func saveExpenseData(expenseAmount: Int, description: String, imageData: Data, categoryDocumentId: String) {
        guard !categoryDocumentId.isEmpty else {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.emptyIDMessage, from: self)
            return
        }
        let expense = ExpenseEntity(context: managedObjectContext)
        expense.expId = UUID().uuidString
        expense.catId = categoryDocumentId
        expense.expAmt = Int64(expenseAmount)
        expense.desc = description
        expense.imageURL = imageData
        do {
            try managedObjectContext.save()
            AlertHelper.showAlert(withTitle: Message.successTitle, message: Message.successMessage, from: self)
            DispatchQueue.main.async { [weak self] in
                self?.expAmtOutlet.text = nil
                self?.descOutlet.text = nil
                self?.imageUploadBtnOutlet.setImage(nil, for: .normal)
                self?.ViewImage.image = nil
                self?.ViewImage.isHidden = true
            }
            updateCategoryTotalExpenseAmount(categoryDocumentId: categoryDocumentId, totalExpense: expenseAmount)
            fetchDataForCategory()
        } catch {
            AlertHelper.showAlert(withTitle: Message.errorTitle, message: Message.errorDataAddMessage, from: self)
        }
    }

    func fetchDataForCategory() {
        guard let categoryDocumentId = categoryDocumentId else {
            return
        }
        guard let managedObjectContext = managedObjectContext else {
            return
        }
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "catId == %@", categoryDocumentId)
        do {
            let fetchedExpenses = try managedObjectContext.fetch(fetchRequest)
            var expenseModels: [ExpenseModel] = []
            var totalExpense: Int = 0
            for expense in fetchedExpenses {
                if let categoryId = expense.catId,
                   let description = expense.desc,
                   let imageData = expense.imageURL,
                   let _ = UIImage(data: imageData as Data) {
                    let expenseModel = ExpenseModel(documentId: expense.objectID.uriRepresentation().absoluteString,
                                                    categoryId: String(categoryId),
                                                    expenseAmount: expense.expAmt,
                                                    description: description,
                                                    imageURL: imageData as Data)
                    expenseModels.append(expenseModel)
                    totalExpense += Int(expense.expAmt)
                }
            }
            expenses = expenseModels
            tableView.reloadData()
            newlimitAmount = Int(budgetAmount) - totalExpense
            DispatchQueue.main.async { [weak self] in
                self?.navBarTrailing()
            }
            updateCategoryTotalExpenseAmount(categoryDocumentId: categoryDocumentId, totalExpense: totalExpense)
        } catch {
            print("\(Message.errorFetechingDataMessage)\(error.localizedDescription)")
        }
        tableView.refreshControl?.endRefreshing()
    }

    func editButtonTapped(at indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editExpenseViewController = storyboard.instantiateViewController(withIdentifier: "EditExpenseViewController") as? EditExpenseViewController else {
            return
        }
        editExpenseViewController.documentId = expense.documentId
        editExpenseViewController.managedObjectContext = managedObjectContext
        editExpenseViewController.newLimit = newlimitAmount
        navigationController?.pushViewController(editExpenseViewController, animated: true)
    }
    
    func deleteExpense(at indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        
        ConfirmationDialogHelper.showConfirmationDialog(on: self,
                                                        title: Message.deleteTitle,
                                                        message: Message.deleteMessage,
                                                        confirmActionTitle: "Delete",
                                                        cancelActionTitle: "Cancel") { [weak self] in
            // Perform delete operation here
            self?.deleteButtonTapped(at: indexPath)
        }
    }

    func deleteButtonTapped(at indexPath: IndexPath) {
        let expense = expenses[indexPath.row]
        guard let managedObjectContext = managedObjectContext else {
            return
        }
        let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "desc == %@ AND expAmt == %@ AND catId == %@", expense.description, "\(expense.expenseAmount)", expense.categoryId)
        fetchRequest.fetchLimit = 1
        do {
            let fetchedExpenses = try managedObjectContext.fetch(fetchRequest)
            guard let expenseObject = fetchedExpenses.first else {
                return
            }
            managedObjectContext.delete(expenseObject)
            updateCategoryTotalExpenseAmount(categoryDocumentId: expense.categoryId, totalExpense: totalExpense)
            do {
                try managedObjectContext.save()
                expenses.remove(at: indexPath.row)
                tableView.reloadData()
            } catch {
                AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.deleteErrorMessage, from: self)
            }
        } catch {
            print("\(Message.errorFetechingDataMessage) \(error.localizedDescription)")
        }
    }
    func cornerRadius() {
        CornerRadiusHelper.applyCornerRadius(expAmtOutlet )
        CornerRadiusHelper.applyCornerRadius(imageUploadBtnOutlet )
        CornerRadiusHelper.applyCornerRadius(addBtnOutlet )
        CornerRadiusHelper.applyCornerRadius(descOutlet)
        CornerRadiusHelper.applyCornerRadius(ViewImage)
    }
    func updateCategoryTotalExpenseAmount(categoryDocumentId: String, totalExpense: Int) {
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "catId == %@", categoryDocumentId)
        fetchRequest.fetchLimit = 1
        do {
            let fetchedCategories = try managedObjectContext.fetch(fetchRequest)
            guard let category = fetchedCategories.first else {
                AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.dataNotFoundMessage, from: self)
                return
            }
            category.totalAmount = Int64(totalExpense)
            do {
                try managedObjectContext.save()
            } catch {
                print("\(Message.errorDataUpdateMessage) \(error.localizedDescription)")
            }
        } catch {
            print("\(Message.errorFetechingDataMessage) \(error.localizedDescription)")
        }
    }
}

