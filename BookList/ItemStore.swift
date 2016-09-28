//
//  ItemStore.swift
//  BookList
//
//  Created by Rodney Sampson on 9/24/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import Foundation
import UIKit

class ItemStore {
    
    var session: URLSession
    var coreDataStack: CoreDataStack
    var items: [Item]
    var imageStore: ImageStore
    
    init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
        coreDataStack = CoreDataStack(withModelName: "BookList")
        items = [Item]()
        imageStore = ImageStore()
    }
    
    func fetchItemsWithCompletion(completion: @escaping ([Item]) -> Void ) {
        let url = EbayAPI.convertUnsecureURLIntoSecureURL(URL(string: EbayAPI.ebayURL)!)
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            let items = self.processItemsRequestWithData(data, error: error)! as! [Item]
            
            let saveError: Error? = nil;
            if self.coreDataStack.saveChanges(error: saveError) == false {
                print("Failed to save the store! Error: \(saveError)")
            }
            
            let privateQueueContext = self.coreDataStack.privateQueueContext
            privateQueueContext.performAndWait {
                for item in items {
                    self.items.append(item)
                    if item.imageURL != nil {
                        let image = self.fetchImageForItem(item, withCompletion: {image in})
                        if image != nil {
                            let key = item.imageKey
                            self.imageStore.setImage(image!, forKey: key!)
                        }
                    }
                }
            }
            
            let mainQueueContext = self.coreDataStack.mainQueueContext
            mainQueueContext.performAndWait {
                if mainQueueContext.hasChanges {
                    let saveError: Error? = nil
                    self.coreDataStack.saveChanges(error: saveError)
                }
            }
            
            completion(items)
        })
        task.resume()
    }
    
    func processItemsRequestWithData(_ data: Data?, error: Error?) -> [AnyObject]? {
        if (data != nil) {
            return EbayAPI.itemsFromJSONData(data!, inContext: self.coreDataStack.mainQueueContext)
        }
        else {
            return nil;
        }
    }
    
    @discardableResult
    func fetchImageForItem(_ item: Item, withCompletion: @escaping (_ image: UIImage) -> Void ) -> UIImage? {
        let imageKey = item.imageKey
        if imageKey == nil || item.imageKey == nil || item.imageURL == nil {
            return nil
        }
        var image = self.imageStore.imageForKey(imageKey!) as UIImage?
        if (image != nil) {
            withCompletion(image!);
            return image;
        }
        let request = URLRequest(url: EbayAPI.convertUnsecureURLIntoSecureURL(item.imageURL!))
        let task = self.session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if data != nil {
                let requestImage = self.processImageRequestWithData(data!)
                if requestImage != nil {
                    self.imageStore.setImage(requestImage!, forKey: (item.imageKey)!)
                    image = requestImage
                }
                withCompletion(image!)
            }
        }
        task.resume()
        return image
    }
    
    func processImageRequestWithData(_ data: Data?) -> UIImage? {
        if (data != nil) {
            let image = UIImage(data: data!)
            return image;
        } else {
            return nil;
        }
    }
    
}
