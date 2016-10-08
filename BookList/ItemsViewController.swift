//
//  ViewController.swift
//  BookList
//
//  Created by Rodney Sampson on 9/23/16.
//  Copyright © 2016 Rodney Sampson II. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController, UITableViewDataSource {
    
    var itemStore: ItemStore? = nil
    var imageStore: ImageStore? = nil
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let privateQueue = OperationQueue()
        privateQueue.addOperation {
            self.itemStore?.fetchItemsWithCompletion { (items: [Item]) -> Void in
                print("Found \(items.count) items")
                if (items.count == 0) {
                    print("Zero items! Sad times.");
                    return;
                }
                OperationQueue.main.addOperation {
                    self.itemStore?.items = items
                    self.imageStore = self.itemStore?.imageStore
                    self.tableView.reloadData()
                }
            }
        }
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore!.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as! ItemCell
        
        let item = self.itemStore?.items[indexPath.row]
        precondition(item?.title != nil || item?.title != "")
        cell.titleLabel?.text = item?.title
        
        if item?.author == nil {
            cell.authorLabel?.isHidden = true
        } else {
            cell.authorLabel?.text = item?.author
            cell.authorLabel?.isHidden = false
        }
        
        if item?.imageURL != nil {
            cell.imageView?.image = self.imageStore?.imageForKey((item?.imageKey!)!)
            cell.itemImageView?.isHidden = false
        }
        
        return cell
    }
    
}
