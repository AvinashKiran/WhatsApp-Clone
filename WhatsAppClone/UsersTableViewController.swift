//
//  UsersTableViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UsersTableViewController: UITableViewController {

    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        
        return FIRStorage.storage()
    }
    
    var users = [User]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let usersRef = dataBaseRef.child("users")
        usersRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            var allUsers = [User]()
            
            for user in snapshot.children {
                
                let myself = User(snapshot: user as! FIRDataSnapshot)
                
                if myself.username != FIRAuth.auth()!.currentUser!.displayName! {
                    
                    let newUser = User(snapshot: user as! FIRDataSnapshot)
                    allUsers.append(newUser)
                }
           
            }
            self.users = allUsers
            self.tableView.reloadData()
            
            
            }) { (error) in
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error.localizedDescription)
        }
        
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 106
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        performSegueWithIdentifier("showChat", sender: self)

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("usersCell", forIndexPath: indexPath) as! UsersTableViewCell

        // Configure the cell...
        
        cell.usernameLabel.text = users[indexPath.row].username
        cell.userCountryLabel.text = users[indexPath.row].country
        
        storageRef.referenceForURL(users[indexPath.row].photoURL!).dataWithMaxSize(1*1024*1024) { (data, error) in
            if error == nil {
                
                dispatch_async(dispatch_get_main_queue(), { 
                    if let data = data {
                        
                        cell.userImageView.image = UIImage(data: data)
                    }
                })
               
                
            }else {
                
                let alertView = SCLAlertView()
                alertView.showError("😁OOPS😁", subTitle: error!.localizedDescription)

            }
        }

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChat" {
            
            let chatViewController = segue.destinationViewController as! ChatViewController
            chatViewController.senderId = FIRAuth.auth()!.currentUser!.uid
            chatViewController.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            
        }
    }

   
}
