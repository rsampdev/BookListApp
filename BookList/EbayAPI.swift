//
//  eBayAPI.swift
//  BookList
//
//  Created by Rodney Sampson on 9/24/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import CoreData

internal struct EbayAPI {
    
    static let ebayURL = "http://calm-mountain-87063.herokuapp.com/books.json"
    
    static func itemsFromJSONData(_ data: Data, inContext context: NSManagedObjectContext) -> [Item]? {
        var items = [Item]()
        var jsonArray: [[String: AnyObject]]?
        
        do {
            try jsonArray = JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: UInt(0))) as? [AnyObject] as! [[String : AnyObject]]?
        } catch let error {
            print(error)
        }
        
        precondition(jsonArray != nil, "Json can not be nil")
        var index = 0
        for jsonSinglePhotoDictionary: [String: AnyObject] in jsonArray! {
            let item: Item? = self.itemFromJSON(jsonSinglePhotoDictionary, inContext: context)
            print(index)
            precondition(item != nil)
            items.append(item!)
            index += 1
        }
        
        return items; // returning empty array for now
    }
    
    static func itemFromJSON(_ jsonDict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Item? {
        let title = jsonDict["title"] as! String?
        let author = jsonDict["author"] as! String?
        let imageURLValue = jsonDict["image_url"]
        var imageURL: URL? = nil
        
        if imageURLValue != nil {
            imageURL = URL(string: imageURLValue as! String)
        }
        
        if title == nil {
            return nil;
        }
        
        var item: Item? = nil
        
        context.performAndWait {
            if author != nil && imageURL != nil {
                item = Item(title: title!, author: author!, imageURL: imageURL!, context: context)
            } else if author != nil {
                item = Item(title: title!, author: author, context: context)
            } else if imageURL != nil {
                item = Item(title: title!, imageURL: imageURL, context: context)
            } else {
                item = Item(title: title!, context: context)
            }
        }
        
        return item
    }
    
    static func convertUnsecureURLIntoSecureURL(_ url: URL) -> URL {
        var secureURL: URL? = nil
        var components = URLComponents(string: url.absoluteString)
        components?.scheme = "https"
        secureURL = components?.url
        return secureURL!
    }
}
