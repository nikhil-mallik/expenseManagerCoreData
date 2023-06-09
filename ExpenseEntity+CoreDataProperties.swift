//
//  ExpenseEntity+CoreDataProperties.swift
//  
//
//  Created by Nikhil Mallik on 09/06/23.
//
//

import Foundation
import CoreData


extension ExpenseEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseEntity> {
        return NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
    }

    @NSManaged public var catId: String?
    @NSManaged public var desc: String?
    @NSManaged public var expAmt: Int64
    @NSManaged public var expId: String?
    @NSManaged public var imageURL: Data?
    @NSManaged public var time: Date?

}
