//
//  Variable.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 06/07/23.
//

import Foundation
import CoreData
import UIKit


var cardData: [CardModel] = []
var managedObjectContext: NSManagedObjectContext?
var categoryId: String?
var selectedIndexPath: IndexPath?
var userId: String!
var titleLabel: UILabel? = nil
var currentUser: String!
var auth: AuthManager?
var navigationControllerStub: UINavigationController?




// ParticularExpenseViewController variables
var selectedCellIndex: Int?
var categoryDocumentId: String?
var expenses: [ExpenseModel] = []
var refreshControl = UIRefreshControl()
var newlimitAmount: Int = 0
var totalExpense: Int = 0
var budgetAmount: Int64 = 0
var limitAmountLabel: UILabel!
var pickedImage: UIImage?
var imagePickerHelper: ImagePickerHelper?
var isVisible: Bool = false



var category: CategoryEntity?




var expense: ExpenseEntity?
var documentId: String?
var newLimit: Int?
