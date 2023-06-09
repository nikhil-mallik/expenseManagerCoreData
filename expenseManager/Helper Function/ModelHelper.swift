//
//  ModelHelper.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 08/06/23.
//

import Foundation


// MARK: - Category Card Model

struct CardModel {
    let documentId: String
    let titleOutlet: String
    var iconImageView: Data
    let expAmtOutlet: Int64
    let leftAmtOutlet: Int64
}

// MARK: Expense Model

struct ExpenseModel {
    let documentId: String
    var categoryId: String
    var expenseAmount: Int64
    var description: String
    var imageURL: Data
    
    // Initializer
    init(documentId: String, categoryId: String, expenseAmount: Int64, description: String, imageURL: Data) {
        self.documentId = documentId
        self.categoryId = categoryId
        self.expenseAmount = expenseAmount
        self.description = description
        self.imageURL = imageURL
    }
}
