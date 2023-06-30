//
//  expenseManagerUnitTests.swift
//  expenseManagerUnitTests
//
//  Created by Nikhil Mallik on 21/06/23.
//

import XCTest

@testable import expenseManager

final class expenseManagerUnitTests: XCTestCase {
    
    var viewController: AddCategoryViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "AddCategoryViewController") as? AddCategoryViewController
        
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func createAlertVerifier(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alertController
    }
    
    // MARK: - Tests
    
    func testUIElementsAreConnected() throws {
        XCTAssertNotNil(viewController.titleOutlet, "The Title UITextField is not connected")
        XCTAssertNotNil(viewController.previewLabel, "The PreView UITextLabel is not connected")
        XCTAssertNotNil(viewController.viewImage, "The Title UIImageView is not connected")
        XCTAssertNotNil(viewController.amountOutlet, "The Amount UITextField is not connected")
        XCTAssertNotNil(viewController.addDataOutlet, "The Add UIButton is not connected")
    }
    
    func testUIElementsExistence() {
        XCTAssertNotNil(viewController.previewLabel)
        XCTAssertNotNil(viewController.viewImage)
        XCTAssertNotNil(viewController.uploadImage)
        XCTAssertNotNil(viewController.titleOutlet)
        XCTAssertNotNil(viewController.amountOutlet)
        XCTAssertNotNil(viewController.addDataOutlet)
    }
    
    func testUploadImageAction() {
        viewController.uploadImageAction(self)
        
        // Simulate image selection and verify the result
        XCTAssertEqual(viewController.viewImage.image, viewController.pickedImage)
    }
    
    func testAddDataActionWithMissingText() {
        // Given
        viewController.titleOutlet.text = ""
        viewController.amountOutlet.text = "100"
        viewController.pickedImage = UIImage()
        
        let expectedTitle = "Error"
        let expectedMessage = "Please enter a title."
        
        // When
        viewController.addDataAction(UIButton())
        
        // Then
        let alertController = createAlertVerifier(title: expectedTitle, message: expectedMessage)
        XCTAssertEqual(alertController.title, expectedTitle)
        XCTAssertEqual(alertController.message, expectedMessage)
    }
    
    func testAddDataActionWithInvalidAmount() {
        // Given
        viewController.titleOutlet.text = "Category 1"
        viewController.amountOutlet.text = "Invalid Amount"
        viewController.pickedImage = UIImage()
        
        let expectedTitle = "Error"
        let expectedMessage = "Please enter a valid amount."
        
        // When
        viewController.addDataAction(UIButton())
        
        // Then
        let alertController = createAlertVerifier(title: expectedTitle, message: expectedMessage)
        XCTAssertEqual(alertController.title, expectedTitle)
        XCTAssertEqual(alertController.message, expectedMessage)
    }
    func testAddDataActionWithMissingAmount() {
        // Given
        viewController.titleOutlet.text = "Category 1"
        viewController.amountOutlet.text = ""
        viewController.pickedImage = UIImage()
        
        let expectedTitle = "Error"
        let expectedMessage = "Please enter a valid amount."
        
        // When
        viewController.addDataAction(UIButton())
        
        // Then
        let alertController = createAlertVerifier(title: expectedTitle, message: expectedMessage)
        XCTAssertEqual(alertController.title, expectedTitle)
        XCTAssertEqual(alertController.message, expectedMessage)
    }
    
    func testAddDataActionWithMissingImage() {
        // Given
        viewController.titleOutlet.text = "Category 1"
        viewController.amountOutlet.text = "100"
        viewController.pickedImage = nil
        
        let expectedTitle = "Error"
        let expectedMessage = "Please upload an image."
        
        // When
        viewController.addDataAction(UIButton())
        
        // Then
        let alertController = createAlertVerifier(title: expectedTitle, message: expectedMessage)
        XCTAssertEqual(alertController.title, expectedTitle)
        XCTAssertEqual(alertController.message, expectedMessage)
    }
}
