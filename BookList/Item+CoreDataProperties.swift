//
//  Item+CoreDataProperties.swift
//  BookList
//
//  Created by Rodney Sampson on 9/27/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var author: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var title: String?
    @NSManaged public var imageKey: String?

}
