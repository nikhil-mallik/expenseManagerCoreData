//
//  AppDelegate.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit
import Firebase
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // Schedule the uploadDataToFirestore function to execute at 4:30 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 16 // 4 PM
        dateComponents.minute = 49 // 30 minutes
        let uploadDate = Calendar.current.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) ?? Date()
        
        let uploadTimer = Timer(fire: uploadDate, interval: 86400, repeats: true) { _ in
            self.uploadDataToFirestore()
        }
        RunLoop.current.add(uploadTimer, forMode: .common)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "expenseManager")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - Firestore Upload and Fetch Functions
    
    func uploadDataToFirestore() {
        let context = persistentContainer.viewContext
        
        // Fetch CategoryEntity objects from Core Data
        let categoryFetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let categories = try? context.fetch(categoryFetchRequest)
        
        // Upload CategoryEntity data to Firestore
        for category in categories ?? [] {
            guard let catId = category.catId else { continue }
            
            let categoryDocRef = Firestore.firestore().collection("Category").document(catId)
            
            let categoryData: [String: Any] = [
                "budget": category.budget,
                "catId": catId,
                "imageURL": category.imageURL ?? "",
                "time": category.time ?? "",
                "title": category.title ?? "",
                "totalAmount": category.totalAmount,
                "uid": category.uid ?? ""
                // Include other properties as required
            ]
            
            categoryDocRef.setData(categoryData) { error in
                if let error = error {
                    print("Error uploading category data: \(error.localizedDescription)")
                } else {
                    print("Category data uploaded successfully!")
                }
            }
            
            // Upload the image to Firebase Storage
            if let imageData = category.imageURL {
                let storageRef = Storage.storage().reference().child("categoryImages/\(catId).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storageRef.putData(imageData, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Error uploading category image: \(error.localizedDescription)")
                    } else {
                        // Get the download URL of the uploaded image
                        storageRef.downloadURL { url, error in
                            if let imageURL = url?.absoluteString {
                                // Update the "imageURL" property with the download URL
                                categoryDocRef.updateData(["imageURL": imageURL])
                            }
                        }
                    }
                }
            }
        }
        
        // Fetch ExpenseEntity objects from Core Data
        let expenseFetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        let expenses = try? context.fetch(expenseFetchRequest)
        
        // Upload ExpenseEntity data to Firestore
        for expense in expenses ?? [] {
            guard let expId = expense.expId else { continue }
            
            let expenseDocRef = Firestore.firestore().collection("Expense").document(expId)
            
            let expenseData: [String: Any] = [
                "catId": expense.catId ?? "",
                "desc": expense.desc ?? "",
                "expAmt": expense.expAmt,
                "time": expense.time ?? "",
                "expId": expense.expId ?? ""
                // Include other properties as required
            ]
            
            expenseDocRef.setData(expenseData) { error in
                if let error = error {
                    print("Error uploading expense data: \(error.localizedDescription)")
                } else {
                    print("Expense data uploaded successfully!")
                }
            }
            
            // Upload the image to Firebase Storage
            if let imageData = expense.imageURL {
                let storageRef = Storage.storage().reference().child("expenseImages/\(expId).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storageRef.putData(imageData, metadata: metadata) { metadata, error in
                    if let error = error {
                        print("Error uploading expense image: \(error.localizedDescription)")
                    } else {
                        // Get the download URL of the uploaded image
                        storageRef.downloadURL { url, error in
                            if let imageURL = url?.absoluteString {
                                // Update the "imageURL" property with the download URL
                                expenseDocRef.updateData(["imageURL": imageURL])
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchDataFromFirestore() {
        let context = persistentContainer.viewContext
        
        // Fetch data from the "categories" collection in Firestore
        Firestore.firestore().collection("Category").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching category data: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else {
                    print("No category documents found.")
                    return
                }
                
                for document in documents {
                    let categoryData = document.data()
                    
                    let category = CategoryEntity(context: context)
                    category.budget = categoryData["budget"] as? Int64 ?? 0
                    category.catId = categoryData["catId"] as? String
                    category.time = categoryData["time"] as? Date
                    category.title = categoryData["title"] as? String
                    category.totalAmount = categoryData["totalAmount"] as? Int64 ?? 0
                    category.uid = categoryData["uid"] as? String
                    
                    // Download the image from Firebase Storage
                    if let imageURL = categoryData["imageURL"] as? String {
                        let storageRef = Storage.storage().reference(forURL: imageURL)
                        
                        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error downloading image: \(error.localizedDescription)")
                            } else if let imageData = data {
                                // Assuming you have an "imageData" property in CategoryEntity
                                category.imageURL = imageData
                                self.saveContext()
                            }
                        }
                    }
                    
                    self.saveContext()
                }
                
                print("Category data fetched and stored in Core Data.")
            }
        }
        
        // Fetch data from the "Expense" collection in Firestore
        Firestore.firestore().collection("Expense").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching expense data: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else {
                    print("No expense documents found.")
                    return
                }
                
                for document in documents {
                    let expenseData = document.data()
                    
                    let expense = ExpenseEntity(context: context)
                    expense.catId = expenseData["catId"] as? String
                    expense.desc = expenseData["desc"] as? String
                    expense.expAmt = expenseData["expAmt"] as? Int64 ?? 0
                    expense.time = expenseData["time"] as? Date
                    expense.expId = expenseData["expId"] as? String
                    
                    // Download the image from Firebase Storage
                    if let imageURL = expenseData["imageURL"] as? String {
                        let storageRef = Storage.storage().reference(forURL: imageURL)
                        
                        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error downloading image: \(error.localizedDescription)")
                            } else if let imageData = data {
                                // Assuming you have an "imageData" property in ExpenseEntity
                                expense.imageURL = imageData
                                self.saveContext()
                            }
                        }
                    }
                    
                    self.saveContext()
                }
                
                print("Expense data fetched and stored in Core Data.")
            }
        }
    }
    
}
