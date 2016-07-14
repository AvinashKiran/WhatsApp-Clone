//
//  PostsTableViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    @IBAction func likePostWithImageAction(sender: AnyObject) {
    }
    
    @IBAction func likePostWithITextAction(sender: AnyObject) {
    }
    
    @IBAction func commentPostWithImageAction(sender: AnyObject) {
    }
    
    @IBAction func commentPostWithITextAction(sender: AnyObject) {
    }
    
    @IBAction func morePostWithImageAction(sender: AnyObject) {
    }
    
    @IBAction func morePostWithITextAction(sender: AnyObject) {
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
