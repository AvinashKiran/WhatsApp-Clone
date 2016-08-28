//
//  UsersTableViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UsersTableViewController: UITableViewController {

    var usersArray = [User]()
    var chatFunctions = ChatFunctions()
    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loadUsers()
    }

    func loadUsers(){
        
        let usersRef = dataBaseRef.child("users")
        
        usersRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            var allusers = [User]()
            
            for user in snapshot.children {
                
                let newUser = User(snapshot: user as! FIRDataSnapshot)
                
                if newUser.uid != FIRAuth.auth()!.currentUser!.uid{
                
                    allusers.append(newUser)
                }
                
            }
            self.usersArray = allusers.sort({ (user1, user2) -> Bool in
                user1.username < user2.username
            
            })
            self.tableView.reloadData()

            
            
            }) { (error) in
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
                

        }
        
        
        
        
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersArray.count
    }

   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 106
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(FIRAuth.auth()!.currentUser!.photoURL!))
        chatFunctions.startChat(currentUser, user2: usersArray[indexPath.row])
        
        performSegueWithIdentifier("goToChat", sender: self)

    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("usersCell", forIndexPath: indexPath) as! UsersTableViewCell
        
        self.configureCell(cell, indexPath: indexPath, usersArray: self.usersArray)

        return cell
    }
    
    
   private func configureCell(cell: UsersTableViewCell, indexPath: NSIndexPath, usersArray: [User]){
        
        cell.usernameLabel.text = usersArray[indexPath.row].username
        cell.userCountryLabel.text = usersArray[indexPath.row].country
        storageRef.referenceForURL(usersArray[indexPath.row].photoURL).dataWithMaxSize(1 * 1024 * 1024) { (imgData, error) in
            if let error = error {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
            }else {
                
                
                dispatch_async(dispatch_get_main_queue(), { 
                    if let data = imgData {
                        cell.userImageView.image = UIImage(data: data)
                    }
                })
                
               
                
            }
        }
 
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToChat" {
            
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
