import UIKit
import FirebaseAuth
import CoreData

class CategoryViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var tableShowOutlet: UITableView!
    @IBOutlet weak var noRecordFound: UILabel!
    @IBOutlet weak var navtoCateOutlet: UIButton!
    
    // MARK: Properties
    var cardData: [CardModel] = []
    var managedObjectContext: NSManagedObjectContext?
    var categoryId: String?
    var selectedIndexPath: IndexPath?
    var userId: String?
    var titleLabel: UILabel? = nil
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableShowOutlet.dataSource = self
        tableShowOutlet.delegate = self
        fetchCategories()
        navBar()
        setupUI()
        setupManagedObjectContext()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    
    // MARK: Managed Object Context
    
    private func setupManagedObjectContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        if managedObjectContext == nil { return }
    }
    func setupUI() {
        // Hide the default back button
        navigationItem.hidesBackButton = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableShowOutlet.refreshControl = refreshControl
        // Set the corner radius to half of the button's width
        navtoCateOutlet.layer.cornerRadius = navtoCateOutlet.frame.size.width / 2
        navtoCateOutlet.clipsToBounds = true
        // Add Auto Layout constraints to center the label
        NSLayoutConstraint.activate([
            noRecordFound.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noRecordFound.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func navBar() {
        // Create a logout button with a custom title
        let logoutButton = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(showConfirmationDialog))
        // Set the title color for the logout button
        logoutButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        // Set the logout button as the right bar button item
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func showConfirmationDialog() {
        ConfirmationDialogHelper.showConfirmationDialog(on: self, title: "Confirmation", message: "Are you sure you want to proceed?", confirmActionTitle: "Confirm", cancelActionTitle: "Cancel") {
            self.logoutButton()
        }
    }
    
    func logoutButton() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            AlertHelper.showAlert(withTitle: "Alert", message: "Error logging out: \(error.localizedDescription)", from: self)
        }
    }
    
    func fetchCategories() {
        guard let managedObjectContext = managedObjectContext else {
            print("Managed object context is nil")
            return
        }
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        do {
            let fetchedCategories = try managedObjectContext.fetch(fetchRequest)
            // Process the fetched categories and populate the cardData array
            cardData = fetchedCategories.map { category in
                return CardModel(
                    documentId: category.catId ?? "",
                    titleOutlet: category.title ?? "",
                    iconImageView: category.imageURL ?? Data(),
                    expAmtOutlet: category.totalAmount,
                    leftAmtOutlet: category.budget
                )
            }
            // Store the catId in a variable
            categoryId = fetchedCategories.first?.catId
            tableShowOutlet.reloadData()
            noRecordFound.isHidden = !cardData.isEmpty
        } catch {
            AlertHelper.showAlert(withTitle: "Alert", message: "Error fetching categories from Core Data: \(error.localizedDescription)", from: self)
        }
    }
    
    func detailAction(indexPath: IndexPath) {
        let card = cardData[indexPath.row]
        // Instantiate the ParticularExpenseViewController from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let particularExpenseViewController = storyboard.instantiateViewController(withIdentifier: "ParticularExpenseViewController") as? ParticularExpenseViewController else {
            return
        }
        particularExpenseViewController.title = card.titleOutlet
        // Fetch the category object from Core Data using the selected index path
        let categoryId = card.documentId
        // Pass the category ID to the ParticularExpenseViewController
        particularExpenseViewController.categoryDocumentId = categoryId
        // Pass the budget to the ParticularExpenseViewController
        particularExpenseViewController.budgetAmount = card.leftAmtOutlet
        navigationController?.pushViewController(particularExpenseViewController, animated: true)
    }
    
    func handleEditAction(at indexPath: IndexPath) {
        let card = cardData[indexPath.row]
        // Instantiate the EditCategoryViewController from storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editCategoryViewController = storyboard.instantiateViewController(withIdentifier: "EditCategoryViewController") as? EditCategoryViewController else {
            return
        }
        // Pass the categoryId to the EditCategoryViewController
        editCategoryViewController.categoryId = card.documentId
        // Fetch the category object using the categoryId
        guard let categoryId = editCategoryViewController.categoryId else {
            return
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "catId == %@", categoryId)
        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            guard let category = fetchedCategories.first else {
                AlertHelper.showAlert(withTitle: "Alert", message: "Category not found.", from: self)
                return
            }
            // Pass the category object to the EditCategoryViewController
            editCategoryViewController.category = category
            // Push the EditCategoryViewController to the navigation stack
            navigationController?.pushViewController(editCategoryViewController, animated: true)
        } catch {
            AlertHelper.showAlert(withTitle: "Alert", message: "Error fetching category: \(error.localizedDescription)", from: self)
        }
    }
    
    func handleDeleteAction(at indexPath: IndexPath) {
        let category = cardData[indexPath.row]
        guard let managedObjectContext = managedObjectContext else {
            print("Managed object context is nil")
            return
        }
        do {
            let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "catId == %@", category.documentId)
            
            let fetchedCategories = try managedObjectContext.fetch(fetchRequest)
            if let categoryObject = fetchedCategories.first {
                managedObjectContext.delete(categoryObject)
                
                do {
                    try managedObjectContext.save()
                    cardData.remove(at: indexPath.row)
                    tableShowOutlet.deleteRows(at: [indexPath], with: .automatic)
                    noRecordFound.isHidden = !cardData.isEmpty
                } catch {
                    AlertHelper.showAlert(withTitle: "Alert", message: "Error deleting category: \(error.localizedDescription)", from: self)
                }
            }
        } catch {
            AlertHelper.showAlert(withTitle: "Alert", message: "Error fetching category from Core Data: \(error.localizedDescription)", from: self)
        }
    }
    
    // MARK: Actions
    @IBAction func navtoCateAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addCategoryViewController = storyboard.instantiateViewController(withIdentifier: "AddCategoryViewController") as? AddCategoryViewController
        else {
            return
        }
        addCategoryViewController.userId = self.userId
        navigationController?.pushViewController(addCategoryViewController, animated: true)
    }
    
    // MARK: Pull-down Refresh
    @objc func refreshData(_ sender: Any) {
        tableShowOutlet.refreshControl?.endRefreshing()
    }
}
