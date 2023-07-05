//
//  CategoryViewControllerTest.swift
//  expenseManagerUnitTests
//
//  Created by Nikhil Mallik on 25/06/23.

import XCTest
import CoreData

@testable import expenseManager

final class CategoryViewControllerTest: XCTestCase {
    
    
    var sut: CategoryViewController!
    var mockManagedObjectContext: NSManagedObjectContext!
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create a mock managed object context
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        
        mockManagedObjectContext = NSManagedObjectContextMock(concurrencyType: .mainQueueConcurrencyType)
        mockManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        // Instantiate the CategoryViewController with the mock managed object context
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as? CategoryViewController
        sut.managedObjectContext = mockManagedObjectContext
        
        // Assign AuthManagerMock instance to auth property
        let authMock = AuthManagerMock(isUserLoggedIn: true) // Update isUserLoggedIn to true
        sut.auth = authMock
        
        sut.loadViewIfNeeded()
    }
    
    
    override func tearDownWithError() throws {
        sut = nil
        mockManagedObjectContext = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Tests
    
    func testFetchCurrentUser_WhenUserIsLoggedIn_ShouldSetUserId() {
        // Simulate a logged-in user
        let authMock = AuthManagerMock(isUserLoggedIn: false)
        sut.auth = authMock
        
        sut.fetchCurrentUser()
        
        XCTAssertEqual(sut.userId, "FxQC8NlILGXhdynZXt0V9pd6ZT33")
    }
    
    func testFetchCurrentUser_WhenUserIsNotLoggedIn_ShouldNotSetUserId() {
        // Simulate no logged-in user
        let authMock = AuthManagerMock(isUserLoggedIn: false)
        sut.auth = authMock
        
        sut.fetchCurrentUser()
        
        // Wait for the fetch operation to complete
        let expectation = XCTestExpectation(description: "Fetch current user")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNil(sut.userId, "userId should be nil when the user is not logged in.")
    }
    
    func testFetchCategories_WhenManagedObjectContextIsNil_ShouldNotFetchData() {
        sut.managedObjectContext = nil
        
        sut.fetchCategories()
        
        XCTAssertTrue(sut.cardData.isEmpty)
    }
    
    func testFetchCategories_WhenManagedObjectContextIsValid_ShouldFetchData() {
        // Prepare test data in the mock managed object context
        let categoryEntity = CategoryEntity(context: mockManagedObjectContext)
        categoryEntity.catId = "51AF5746-01C3-46D8-A74C-81882B476715"
        categoryEntity.title = "Test"
        categoryEntity.totalAmount = 1700
        categoryEntity.budget = 15000
        
        try? mockManagedObjectContext.save()
        
        sut.fetchCategories()
        
        // Wait for the fetch operation to complete
        let expectation = XCTestExpectation(description: "Fetch categories")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Assert that the cardData array has at least one element
        XCTAssertGreaterThan(sut.cardData.count, 0, "cardData should contain at least one element.")
        
        if let firstCategory = sut.cardData.first {
            XCTAssertEqual(firstCategory.documentId, "51AF5746-01C3-46D8-A74C-81882B476715")
            XCTAssertEqual(firstCategory.titleOutlet, "Test")
            XCTAssertEqual(firstCategory.expAmtOutlet, 1700)
            XCTAssertEqual(firstCategory.leftAmtOutlet, 15000)
        } else {
            XCTFail("cardData should contain at least one element.")
        }
    }
    

    
    func testLogoutButton_WhenUserIsNotLoggedIn_ShouldNotSignOutAndNavigateToPhoneViewController() {
        // Simulate no logged-in user
        let authMock = AuthManagerMock(isUserLoggedIn: false)
        sut.auth = authMock
        
        // Create a mock navigation controller
        let navigationController = MockNavigationController(rootViewController: sut)
        
        sut.logoutButton()
        
        // Assert that signOut() is not called on the authManagerMock
        XCTAssertFalse(authMock.didCallSignOut, "signOut() should not be called when the user is not logged in.")
        
        // Assert that the navigation controller is still presenting the sut
        XCTAssertEqual(navigationController.viewControllers.count, 1, "The navigation controller should not pop to the previous view controller.")
        XCTAssertEqual(navigationController.viewControllers.first, sut, "The navigation controller should still present the CategoryViewController.")
    }
    
    
    func testDeleteCategory_WhenManagedObjectContextIsNil_ShouldNotDeleteCategory() {
        sut.managedObjectContext = nil
        
        sut.deleteCategory(at: IndexPath(row: 0, section: 0))
        
        // Assert that no delete operation is performed
        XCTAssertNil(sut.managedObjectContext, "managedObjectContext should be nil.")
        XCTAssertEqual(sut.cardData.count, 0, "cardData should not be modified.")
        XCTAssertEqual(sut.tableShowOutlet.numberOfRows(inSection: 0), 0, "No table row should be deleted.")
    }
    
    func testDeleteCategory_WhenManagedObjectContextIsValid_ShouldDeleteCategory() {
        // Create a mock NSManagedObjectContext
        let managedObjectContextMock = NSManagedObjectContextMock(concurrencyType: .mainQueueConcurrencyType)
        sut.managedObjectContext = managedObjectContextMock
        
        // Add a mock category object to cardData
        let category = CardModel(documentId: "1", titleOutlet: "Category", iconImageView: Data(), expAmtOutlet: 100, leftAmtOutlet: 200)
        sut.cardData.append(category)
        
        // Simulate tapping the delete button on the category cell
        sut.deleteCategory(at: IndexPath(row: 0, section: 0))
        
        // Assert that the category is deleted
        XCTAssertEqual(sut.tableShowOutlet.numberOfRows(inSection: 0), 0, "The table row should be deleted.")
    }
}

// MARK: - Mocks

class AuthManagerMock: AuthManager {
    let isUserLoggedIn: Bool
    var didCallSignOut = false
    
    init(isUserLoggedIn: Bool) {
        self.isUserLoggedIn = isUserLoggedIn
    }
    
    var isLoggedIn: Bool {
        return isUserLoggedIn
    }
    
    func signOut() {
        print("signOut() called")
        didCallSignOut = true
    }
}

class MockNavigationController: UINavigationController {
    var didCallPopToViewController = false
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        print("popToViewController called")
        didCallPopToViewController = true
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        print("popToRootViewController called")
        didCallPopToViewController = true
        return super.popToRootViewController(animated: animated)
    }
}

class NSManagedObjectContextMock: NSManagedObjectContext {
    var saveCalled = false
    
    override func save() throws {
        saveCalled = true
    }
}
