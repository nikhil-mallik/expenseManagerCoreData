//
//  editCategoryTests.swift
//  expenseManagerUnitTests
//
//  Created by Nikhil Mallik on 30/06/23.
//

//import XCTest
//@testable import expenseManager
//import CoreData
//
//final class editCategoryTests: XCTestCase {
//
//    var viewController: EditCategoryViewController!
//    var mockImagePickerHelper: MockImagePickerHelper!
//    var mockLoaderViewHelper: MockLoaderViewHelper!
//    var mockAlertHelper: MockAlertHelper!
//    var mockContext: MockContext!
//    var mockNavigationController: MockNavigationController!
//
//    override func setUp() {
//        super.setUp()
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        viewController = storyboard.instantiateViewController(withIdentifier: "EditCategoryViewController") as? EditCategoryViewController
//        viewController.loadViewIfNeeded()
//
//        mockImagePickerHelper = MockImagePickerHelper()
//        viewController.imagePickerHelper = mockImagePickerHelper
//
//        mockLoaderViewHelper = MockLoaderViewHelper()
//        MockLoaderViewHelper.stubbedShowLoader = { _ in
//            mockLoaderViewHelper.isLoaderShown = true
//        }
//        MockLoaderViewHelper.stubbedHideLoader = {
//            mockLoaderViewHelper.isLoaderHidden = true
//        }
//
//        mockAlertHelper = MockAlertHelper()
//        MockAlertHelper.stubbedShowAlert = { title, message, _, completion in
//            mockAlertHelper.title = title
//            mockAlertHelper.message = message
//            completion?()
//        }
//
//        mockContext = MockContext()
//        let mockFetchRequest = MockFetchRequest<CategoryEntity>()
//        let mockFetchedCategories = [CategoryEntity()]
//        mockFetchRequest.stubbedFetchResult = mockFetchedCategories
//        mockContext.stubbedFetchRequest = mockFetchRequest
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.stubbedPersistentContainer = mockContext.persistentContainer
//
//        viewController.categoryId = "YourCategoryId"
//
//        mockNavigationController = MockNavigationController(rootViewController: viewController)
//        viewController.navigationController = mockNavigationController
//    }
//
//    override func tearDown() {
//        viewController = nil
//        mockImagePickerHelper = nil
//        mockLoaderViewHelper = nil
//        mockAlertHelper = nil
//        mockContext = nil
//        mockNavigationController = nil
//
//        super.tearDown()
//    }
//
//    // MARK: - Test View Lifecycle
//
//    func testViewDidLoad() {
//        viewController.viewDidLoad()
//
//        // Assert that the necessary UI elements are not nil
//        XCTAssertNotNil(viewController.titleOutlet)
//        XCTAssertNotNil(viewController.budgetOutlet)
//        XCTAssertNotNil(viewController.imageViewOutlet)
//        XCTAssertNotNil(viewController.updateBtnOutlet)
//    }
//
//    func testViewWillAppear() {
//        let animated = true
//        viewController.viewWillAppear(animated)
//
//        // Assert that keyboard observing is started
//        XCTAssertTrue(viewController.isKeyboardObservingEnabled)
//    }
//
//    func testViewWillDisappear() {
//        let animated = true
//        viewController.viewWillDisappear(animated)
//
//        // Assert that keyboard observing is stopped
//        XCTAssertFalse(viewController.isKeyboardObservingEnabled)
//    }
//
//    // MARK: - Test UI Setup
//
//    func testFillData() {
//        // Create a mock category
//        let mockCategory = CategoryEntity()
//        mockCategory.title = "Test Category"
//        mockCategory.budget = 100
//        mockCategory.imageURL = Data()
//        viewController.category = mockCategory
//
//        viewController.fillData()
//
//        // Assert that the UI elements are populated with the correct data
//        XCTAssertEqual(viewController.titleOutlet.text, mockCategory.title)
//        XCTAssertEqual(viewController.budgetOutlet.text, String(mockCategory.budget))
//        XCTAssertNotNil(viewController.imageViewOutlet.image)
//    }
//
//    func testSetupImageView() {
//        viewController.setupImageView()
//
//        // Assert that the image view's properties are set correctly
//        XCTAssertEqual(viewController.imageViewOutlet.contentMode, .scaleAspectFill)
//        XCTAssertEqual(viewController.imageViewOutlet.layer.cornerRadius, min(viewController.imageViewOutlet.frame.size.width, viewController.imageViewOutlet.frame.size.height) / 2)
//        XCTAssertTrue(viewController.imageViewOutlet.layer.masksToBounds)
//        XCTAssertEqual(viewController.navigationController?.navigationBar.tintColor, .black)
//    }
//
//    func testCornerRadius() {
//        viewController.cornerRadius()
//
//        // Assert that corner radius is applied to the buttons and text field
//        XCTAssertTrue(mockCornerRadiusHelper.isCornerRadiusAppliedToViewCalled)
//        XCTAssertTrue(mockCornerRadiusHelper.isCornerRadiusAppliedToTextFieldCalled)
//    }
//
//    // MARK: - Test Actions
//
//    func testUploadImageAction() {
//        viewController.uploadImageAction(self)
//
//        // Assert that the image picker helper is presented
//        XCTAssertTrue(mockImagePickerHelper.isImagePickerPresented)
//    }
//
//    func testUpdateBtnAction_WithValidImageData() {
//        // Create a mock image data
//        let imageData = Data()
//        // Set the image view's image to simulate selecting an image
//        viewController.imageViewOutlet.image = UIImage()
//
//        viewController.updateBtnAction(self)
//
//        // Assert that the image data is passed to the updateCategoryData method
//        XCTAssertEqual(mockContext.stubbedSaveCallCount, 1)
//        // Example: XCTAssertEqual(viewController.alertHelper.title, "Success")
//        // Example: XCTAssertEqual(viewController.alertHelper.message, "Category updated successfully.")
//        // Example: XCTAssertTrue(mockNavigationController.isViewControllerPopped)
//    }
//
//    func testUpdateBtnAction_WithInvalidImageData() {
//        viewController.updateBtnAction(self)
//
//        // Assert that the update is not performed due to invalid image data
//        XCTAssertEqual(mockContext.stubbedSaveCallCount, 0)
//        // Example: XCTAssertEqual(viewController.alertHelper.title, "Alert")
//        // Example: XCTAssertEqual(viewController.alertHelper.message, "Invalid budget value.")
//        // Example: XCTAssertFalse(mockNavigationController.isViewControllerPopped)
//    }
//
//    // MARK: - Test Data Update
//
//    // Add test cases to test the updateCategoryData method with different scenarios
//
//    // MARK: - Helper Methods
//
//    // Add any helper methods or classes here as needed
//
//}
//
//// Example mock classes for testing
//
//class MockImagePickerHelper: ImagePickerHelper {
//    var isImagePickerPresented = false
//
//    override func presentImagePicker(in viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
//        isImagePickerPresented = true
//    }
//}
//
//class MockLoaderViewHelper: LoaderViewHelper {
//    var isLoaderShown = false
//    var isLoaderHidden = false
//
//    func showLoader(on view: UIView) {
//        isLoaderShown = true
//    }
//
//    func hideLoader() {
//        isLoaderHidden = true
//    }
//}
//
//class MockAlertHelper: AlertHelper {
//    var title: String?
//    var message: String?
//
//    func showAlert(withTitle title: String, message: String, from viewController: UIViewController, completion: (() -> Void)? = nil) {
//        self.title = title
//        self.message = message
//        completion?()
//    }
//}
//
//class MockContext: NSManagedObjectContext {
//    var isContextSaved = false
//
//    override func save() throws {
//        isContextSaved = true
//    }
//}
//
//class MockFetchRequest<T>: NSFetchRequest<T> {
//    var stubbedFetchResult: [T] = []
//
//    func fetch() throws -> [T] {
//        return stubbedFetchResult
//    }
//}
//
//class MockNavigationController: UINavigationController {
//    var isViewControllerPopped = false
//
//    override func popViewController(animated: Bool) -> UIViewController? {
//        isViewControllerPopped = true
//        return super.popViewController(animated: animated)
//    }
//}
