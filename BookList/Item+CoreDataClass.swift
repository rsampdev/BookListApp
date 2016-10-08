//
//  Item+CoreDataClass.swift
//  BookList
//
//  Created by Rodney Sampson on 9/27/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData


internal class Item: NSManagedObject {
    
    convenience init(title: String, author: String?, imageURL: URL?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.author = author
        self.imageURL = imageURL
    }
    
    convenience init(title: String, author: String?, context: NSManagedObjectContext) {
        self.init(title: title, author: author, imageURL: nil, context: context)
    }
    
    convenience init(title: String, imageURL: URL?, context: NSManagedObjectContext) {
        self.init(title: title, author: nil, imageURL: imageURL, context: context)
    }
    
    convenience init(title: String, context: NSManagedObjectContext?) {
        self.init(title: title, author: nil, imageURL: nil, context: context!)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.title = ""
        self.author = ""
        self.imageURL = URL(string: "")
        self.imageKey = UUID().uuidString
    }
    
}

