//
//  Book+CoreDataProperties.swift
//  CoredataOperation
//
//  Created by Nagib Azad on 21/12/18.
//  Copyright © 2018 Nagib Bin Azad. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var name: String?
    @NSManaged public var isRead: Bool

}
