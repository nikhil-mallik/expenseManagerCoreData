//
//  CategoryEntity+CoreDataProperties.swift
//  
//
//  Created by Nikhil Mallik on 09/06/23.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var budget: Int64
    @NSManaged public var catId: String?
    @NSManaged public var imageURL: Data?
    @NSManaged public var time: Date?
    @NSManaged public var title: String?
    @NSManaged public var totalAmount: Int64
    @NSManaged public var uid: String?

}
