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
    var userId: String!
    var titleLabel: UILabel? = nil
    var currentUser: String!
    var auth: AuthManager?
    var navigationControllerStub: UINavigationController?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableShowOutlet.dataSource = self
        tableShowOutlet.delegate = self
        fetchCategories()
        navBar()
        setupUI()
        setupManagedObjectContext()
        fetchCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategories()
    }
    
    // MARK: Firebase Authentication
    func fetchCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            self.userId = userId
        } else {
            self.userId = nil
        }
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
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(showConfirmationDialog))
        // Set the title color for the logout button
        logoutButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        // Set the logout button as the right bar button item
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func showConfirmationDialog() {
        ConfirmationDialogHelper.showConfirmationDialog(on: self, title: Message.confirmTitle, message: Message.confirmMessage, confirmActionTitle: "Confirm", cancelActionTitle: "Cancel") {
            self.logoutButton()
        }
    }
    
    @objc func logoutButton() {
        AuthManager.shared.signOut { [weak self] success in
            if success {
                // Get the navigation controller
                if let navController = self?.navigationController {
                    // Check if the root view controller is already the phoneViewController
                    if let phoneViewController = navController.viewControllers.first as? phoneViewController {
                        // Pop back to the phoneViewController
                        navController.popToViewController(phoneViewController, animated: true)
                    } else {
                        // Instantiate the phoneViewController
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let phoneViewController = storyboard.instantiateViewController(withIdentifier: "phoneViewController") as! phoneViewController
                        phoneViewController.title = "Sign In"
                        
                        // Set the phoneViewController as the root view controller
                        navController.setViewControllers([phoneViewController], animated: true)
                    }
                }
            } else {
                AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.logoutAlertMessage, from: self!)
            }
        }
    }
    
    func fetchCategories() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let managedObjectContext = self.managedObjectContext else { return }
            
            let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            
            do {
                let fetchedCategories = try managedObjectContext.fetch(fetchRequest)
                
                DispatchQueue.main.async {
                    self.processFetchedCategories(fetchedCategories)
                }
            } catch {
                DispatchQueue.main.async {
                    AlertHelper.showAlert(withTitle: Message.alertTitle, message: "\(Message.errorFetechingDataMessage) \(error.localizedDescription)", from: self)
                }
            }
        }
    }

    func processFetchedCategories(_ fetchedCategories: [CategoryEntity]) {
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
                AlertHelper.showAlert(withTitle: Message.alertTitle, message: Message.dataNotFoundMessage, from: self)
                return
            }
            // Pass the category object to the EditCategoryViewController
            editCategoryViewController.category = category
            // Push the EditCategoryViewController to the navigation stack
            navigationController?.pushViewController(editCategoryViewController, animated: true)
        } catch {
            AlertHelper.showAlert(withTitle: Message.alertTitle, message: "\(Message.errorFetechingDataMessage) \(error.localizedDescription)", from: self)
        }
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        guard indexPath.row < cardData.count else {
            // Invalid index, handle the error gracefully
            return
        }
        let category = cardData[indexPath.row]
        
        ConfirmationDialogHelper.showConfirmationDialog(on: self,
                                                        title: Message.deleteTitle,
                                                        message: "\(Message.deleteMessage) \(category.titleOutlet)?",
                                                        confirmActionTitle: "Delete",
                                                        cancelActionTitle: "Cancel") { [weak self] in
            // Perform delete operation here
            self?.handleDeleteAction(at: indexPath)
        }
    }
    
    func handleDeleteAction(at indexPath: IndexPath) {
        guard indexPath.row < cardData.count else {
            // Invalid index, handle the error gracefully
            return
        }
        
        let category = cardData[indexPath.row]
        
        DispatchQueue.global().async { [weak self] in
            // Perform the deletion on a background thread
            guard let self = self else { return }
            guard let managedObjectContext = self.managedObjectContext else { return }
            
            let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "catId == %@", category.documentId)
            
            do {
                let fetchedCategories = try managedObjectContext.fetch(fetchRequest)
                
                if let categoryObject = fetchedCategories.first {
                    // Remove category from cardData array
                    self.cardData.remove(at: indexPath.row)
                    managedObjectContext.delete(categoryObject)
                    
                    DispatchQueue.main.async {
                        // Update UI on the main thread
                        do {
                            try managedObjectContext.save()
                            self.tableShowOutlet.deleteRows(at: [indexPath], with: .automatic)
                            self.noRecordFound.isHidden = !self.cardData.isEmpty
                        } catch {
                            AlertHelper.showAlert(withTitle: Message.alertTitle, message: "\(Message.deleteErrorMessage) \(error.localizedDescription)", from: self)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    AlertHelper.showAlert(withTitle: Message.alertTitle, message: "\(Message.errorFetechingDataMessage) \(error.localizedDescription)", from: self)
                }
            }
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
