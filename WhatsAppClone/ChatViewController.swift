//
//  ChatViewController.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/13/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseAuth
import FirebaseDatabase
import AVKit

class ChatViewController: JSQMessagesViewController {

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!

    var messages = [JSQMessage]()
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "MESSAGES"
        
        let factory = JSQMessagesBubbleImageFactory()
        
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        addMessage("boom", displayName: "User2", text: "Hey, how are you?")
        addMessage("boom", displayName: "User2", text: "Jhon")
        addMessage(senderId, displayName: FIRAuth.auth()!.currentUser!.displayName!, text: "Hey, I am good and you?")

        finishReceivingMessage()


    }

    func addMessage(id: String, displayName: String, text: String){
        
        let message = JSQMessage(senderId:id, displayName: displayName, text: text)
        messages.append(message)
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.whiteColor()
        }else {
            cell.textView.textColor = UIColor.blackColor()

        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let messageRef = databaseRef.child("ChatRooms").child("jdbdjdbkcakjfbkas").child("Messages").childByAutoId()
        
        let message = Message(text: text, senderId: senderId, key: "")
        
        messageRef.setValue(message.toAnyObject()) { (error, ref) in
            if error == nil {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                
            }else {
                
            }
        }
        
        
        
        
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
}
