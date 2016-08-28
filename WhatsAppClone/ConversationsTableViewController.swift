//
//  ConversationsTableViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class ConversationsTableViewController: UITableViewController {

    var chatFunctions = ChatFunctions()

    
    var dataBaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage! {
        return FIRStorage.storage()
    }
    
    var chatsArray = [ChatRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchChats()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConversationsTableViewController.fetchChats), name: "updateDiscussions", object: nil)
    }

    func fetchChats(){
        chatsArray.removeAll(keepCapacity: false)
        dataBaseRef.child("ChatRooms").queryOrderedByChild("userId").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let username = snapshot.value!["username"] as! String
            let other_Username = snapshot.value!["other_Username"] as! String
            let userId = snapshot.value!["userId"] as! String
            let other_UserId = snapshot.value!["other_UserId"] as! String
            let lastMessage = snapshot.value!["lastMessage"] as! String
            let userPhotoUrl = snapshot.value!["userPhotoUrl"] as! String
            let other_UserPhotoUrl = snapshot.value!["other_UserPhotoUrl"] as! String
            let members = snapshot.value!["members"] as! [String]
            let ref = snapshot.ref
            let key = snapshot.key
            let chatRoomId = snapshot.value!["chatRoomId"] as! String
            let date = snapshot.value!["date"] as! NSNumber

            
            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl:other_UserPhotoUrl,date:date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, atIndex: 0)
            self.tableView.reloadData()
            
            
            
            }) { (error) in
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
                

        }
        
        
        dataBaseRef.child("ChatRooms").queryOrderedByChild("other_UserId").queryEqualToValue(FIRAuth.auth()!.currentUser!.uid).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let username = snapshot.value!["username"] as! String
            let other_Username = snapshot.value!["other_Username"] as! String
            let userId = snapshot.value!["userId"] as! String
            let other_UserId = snapshot.value!["other_UserId"] as! String
            let lastMessage = snapshot.value!["lastMessage"] as! String
            let userPhotoUrl = snapshot.value!["userPhotoUrl"] as! String
            let other_UserPhotoUrl = snapshot.value!["other_UserPhotoUrl"] as! String
            let members = snapshot.value!["members"] as! [String]
            let ref = snapshot.ref
            let key = snapshot.key
            let chatRoomId = snapshot.value!["chatRoomId"] as! String
            let date = snapshot.value!["date"] as! NSNumber

            var newChat = ChatRoom(username: username, other_Username: other_Username, userId: userId, other_UserId: other_UserId, members: members, chatRoomId: chatRoomId, lastMessage: lastMessage, userPhotoUrl: userPhotoUrl, other_UserPhotoUrl: other_UserPhotoUrl,date:date)
            newChat.ref = ref
            newChat.key = key
            
            self.chatsArray.insert(newChat, atIndex: 0)
            self.tableView.reloadData()
            
            
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
            
            
        }


    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatsArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("conversationsCell", forIndexPath: indexPath) as! ConversationsTableViewCell
        
        var userPhotoUrlString: String? = ""
        
        if chatsArray[indexPath.row].userId == FIRAuth.auth()!.currentUser!.uid {
            userPhotoUrlString = chatsArray[indexPath.row].other_UserPhotoUrl
            cell.usernameLabel.text = chatsArray[indexPath.row].other_Username
        }else {
            userPhotoUrlString = chatsArray[indexPath.row].userPhotoUrl
            cell.usernameLabel.text = chatsArray[indexPath.row].username
        }
        
        let fromDate = NSDate(timeIntervalSince1970: NSTimeInterval(chatsArray[indexPath.row].date))
        let toDate = NSDate()
        
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth,]
        let differenceOfDate = NSCalendar.currentCalendar().components(components, fromDate: fromDate, toDate: toDate, options: [])
        
        if differenceOfDate.second <= 0 {
            cell.dateLabel.text = "now"
        } else if differenceOfDate.second > 0 && differenceOfDate.minute == 0 {
            cell.dateLabel.text = "\(differenceOfDate.second)s."

        }else if differenceOfDate.minute > 0 && differenceOfDate.hour == 0 {
            cell.dateLabel.text = "\(differenceOfDate.minute)m."
            
        }else if differenceOfDate.hour > 0 && differenceOfDate.day == 0 {
            cell.dateLabel.text = "\(differenceOfDate.hour)h."
            
        }else if differenceOfDate.day > 0 && differenceOfDate.weekOfMonth == 0 {
            cell.dateLabel.text = "\(differenceOfDate.day)d."
            
        }else if differenceOfDate.weekOfMonth > 0 {
            cell.dateLabel.text = "\(differenceOfDate.weekOfMonth)w."
            
        }
        
        
        
        
        
        cell.lastMessageLabel.text = chatsArray[indexPath.row].lastMessage
        if let urlString = userPhotoUrlString {
            storageRef.referenceForURL(urlString).dataWithMaxSize(1 * 1024 * 1024, completion: { (imgData, error) in
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
            })
            
            
        }
        

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentUser = User(username: FIRAuth.auth()!.currentUser!.displayName!, userId: FIRAuth.auth()!.currentUser!.uid, photoUrl: String(FIRAuth.auth()!.currentUser!.photoURL!))
        var otherUser: User!
        if currentUser.uid == chatsArray[indexPath.row].userId{
             otherUser = User(username: chatsArray[indexPath.row].other_Username, userId: chatsArray[indexPath.row].other_UserId, photoUrl: chatsArray[indexPath.row].other_UserPhotoUrl)
        }else {
            otherUser = User(username: chatsArray[indexPath.row].username, userId: chatsArray[indexPath.row].userId, photoUrl: chatsArray[indexPath.row].userPhotoUrl)
        }
        
        chatFunctions.startChat(currentUser, user2: otherUser)

        performSegueWithIdentifier("goToChat1", sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            self.chatsArray[indexPath.row].ref?.removeValue()
            self.chatsArray.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        
        }
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToChat1" {
            
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.senderId = FIRAuth.auth()!.currentUser!.uid
            chatVC.senderDisplayName = FIRAuth.auth()!.currentUser!.displayName!
            chatVC.chatRoomId = chatFunctions.chatRoom_id
        }
    }
    
    
    
    
    
    
    
    
    
    }
