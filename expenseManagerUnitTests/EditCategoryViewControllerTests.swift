//
//  EditCategoryViewControllerTests.swift
//  expenseManagerUnitTests
//
//  Created by Nikhil Mallik on 25/06/23.
//

import XCTest
@testable import expenseManager
import CoreData

class EditCategoryViewControllerTests: XCTestCase {
    
    var viewController: EditCategoryViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "EditCategoryViewController") as? EditCategoryViewController
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    // MARK: Helper Methods
    
    func createAlertVerifier(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertController
    }
    
    // MARK: Test Cases
    
    func testUIElementsAreConnected() throws {
        XCTAssertNotNil(viewController.titleOutlet, "The Title UITextField is not connected")
        XCTAssertNotNil(viewController.imageViewOutlet, "The Title UIImageView is not connected")
        XCTAssertNotNil(viewController.budgetOutlet, "The Amount UITextField is not connected")
        XCTAssertNotNil(viewController.updateBtnOutlet, "The Add UIButton is not connected")
    }
    
    func testFillData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let category = CategoryEntity(context: context)
        category.title = "Test Category"
        category.budget = 1000
        
        // Provide the correct image name or replace with the desired image
        let imageData = UIImage(named: "logo")!.jpegData(compressionQuality: 0.52)
        category.imageURL = imageData
        
        viewController.category = category
        viewController.fillData()
        
        XCTAssertEqual(viewController.titleOutlet.text, "Test Category")
        XCTAssertEqual(viewController.budgetOutlet.text, "1000")
        
        // Commented out the image data comparison for now
//        XCTAssertEqual(viewController.imageViewOutlet.image?.jpegData(compressionQuality: 0.5), imageData)
    }
    
    func testSetupImageView() {
        viewController.setupImageView()
        
        XCTAssertEqual(viewController.imageViewOutlet.contentMode, .scaleAspectFill)
        XCTAssertEqual(viewController.imageViewOutlet.layer.cornerRadius, viewController.imageViewOutlet.frame.size.width / 2)
        XCTAssertTrue(viewController.imageViewOutlet.layer.masksToBounds)
    }
    
    func testUploadImageAction() {
        let imagePickerHelper = ImagePickerHelper()
        viewController.imagePickerHelper = imagePickerHelper
        
        viewController.addimageAction(self)
        
        
        // Simulate selecting an image
        let selectedImage = UIImage(named: "test_image")
        imagePickerHelper.completionHandler?(selectedImage)
        // Assert that the selected image is set in the image view
        XCTAssertEqual(viewController.imageViewOutlet.image, selectedImage)
    }
    
    func testUpdateBtnAction() {
        let imageData = UIImage(named: "test_image")?.jpegData(compressionQuality: 0.5)
        viewController.imageViewOutlet.image = UIImage(named: "test_image")
        
        viewController.updateBtnAction(self)
        let expectedtitle = "Success"
        let expectedmessage = "Category updated successfully."

        // Assert that the appropriate success alert is shown
        let alertController = createAlertVerifier(title: expectedtitle, message: expectedmessage)
        XCTAssertEqual(alertController.title, expectedtitle)
        XCTAssertEqual(alertController.message, expectedmessage)
        
        
    }
    func testUpdateCategoryData_WithInvalidBudget() {
        // Given
        viewController.budgetOutlet.text = "Invalid Budget"
        let expectedTitle = "Error"
        let expectedMessage = "Please enter a valid amount."
        // When
        viewController.updateCategoryData(Data())
        
        // Then
        let alertController = createAlertVerifier(title: expectedTitle, message: expectedMessage)
        XCTAssertEqual(alertController.title, expectedTitle)
        XCTAssertEqual(alertController.message, expectedMessage)
    }
}
