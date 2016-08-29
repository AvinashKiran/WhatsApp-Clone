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
import FirebaseStorage
import FirebaseDatabase
import MobileCoreServices
import AVKit


class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chatRoomId: String!
    
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!

    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var userIsTypingRef: FIRDatabaseReference!
    
    private var localTyping: Bool = false
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        observeTypingUser()
        
            self.title = "MESSAGES"
        let factory = JSQMessagesBubbleImageFactory()
        
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        collectionView.backgroundView = UIImageView(image: UIImage(named: "whatsapp-bg.jpg")!)
        
        fetchMessages()
        
    }


    
    func fetchMessages(){
        
        let messageQuery = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").queryLimitedToLast(30)
        messageQuery.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            
            let senderId = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            let displayName = snapshot.value!["username"] as! String
            let mediaType = snapshot.value!["mediaType"] as! String
            let mediaUrl = snapshot.value!["mediaUrl"] as! String
            
            
            
            
            
            
            switch mediaType {
            case "TEXT":
                
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))

            case "PHOTO":
                
                let picture = UIImage(data: NSData(contentsOfURL: NSURL(string: mediaUrl)!)!)
                let photo = JSQPhotoMediaItem(image: picture)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: photo))

            case "VIDEO":
                
                if let url = NSURL(string: mediaUrl) {
                let video = JSQVideoMediaItem(fileURL: url, isReadyToPlay: true)
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: video))

                    }
                
            default: break
            }
            
            self.finishReceivingMessage()
            
        }) { (error) in
            let alertView = SCLAlertView()
            alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
        

    }
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
    }
    
    private func observeTypingUser(){
        let typingRef = databaseRef.child("ChatRooms").child(chatRoomId).child("typingIndicator")
        userIsTypingRef = typingRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        let userIsTypingQuery = typingRef.queryOrderedByValue().queryEqualToValue(true)
        
        userIsTypingQuery.observeEventType(.Value, withBlock: { (snapshot) in
            
            if snapshot.childrenCount == 1 && self.isTyping {
                return
            }
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottomAnimated(true)
            
            
            
            }) { (error) in
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error.localizedDescription)
        }
        
        
    }
    
    
    
 
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = messages[indexPath.item]
        
        if message.isMediaMessage {
            if let media = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(URL: media.fileURL)
                let avPlayerViewController = AVPlayerViewController()
                avPlayerViewController.player = player
                self.presentViewController(avPlayerViewController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let messageRef = databaseRef.child("ChatRooms").child(chatRoomId).child("Messages").childByAutoId()
        let message = Message(text: text, senderId: senderId, username: senderDisplayName, mediaType: "TEXT", mediaUrl: "")
        
        messageRef.setValue(message.toAnyObject()) { (error, ref) in
            if error == nil {
                
                let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                lastMessageRef.setValue(text, withCompletionBlock: { (error, ref) in
                    if error == nil {
                      
                        NSNotificationCenter.defaultCenter().postNotificationName("updateDiscussions", object: nil)
                 
                    }else {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error!.localizedDescription)

                    }
                    
                    
                })
                let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                    if error == nil {
                                                
                    }else {
                        let alertView = SCLAlertView()
                        alertView.showError("OOPS", subTitle: error!.localizedDescription)
                        
                    }
                })
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
            }else {
                let alertView = SCLAlertView()
                alertView.showError("OOPS", subTitle: error!.localizedDescription)
            }
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let alertController = UIAlertController(title: "Medias", message: "Choose your media type", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        
        let imageAction = UIAlertAction(title: "Image", style: UIAlertActionStyle.Default) { (action) in
        self.getMedia(kUTTypeImage)
            
        }
        
        let videoAction = UIAlertAction(title: "Video", style: UIAlertActionStyle.Default) { (action) in
            self.getMedia(kUTTypeMovie)

            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addAction(imageAction)
        alertController.addAction(videoAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)


    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
            self.saveMediaMessage(withImage: picture, withVideo: nil)
            
            
        } else if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            
            self.saveMediaMessage(withImage: nil, withVideo: videoUrl)

        }
        
        self.dismissViewControllerAnimated(true) {
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            self.finishSendingMessage()

        }

    }
    
    private func saveMediaMessage(withImage image: UIImage?, withVideo: NSURL?){
        
        if let image = image {
            
            let imagePath = "messageWithMedia\(chatRoomId + NSUUID().UUIDString)/photo.jpg"
            
            let imageRef = storageRef.reference().child(imagePath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)!
            
            imageRef.putData(imageData, metadata: metadata, completion: { (newMetaData, error) in
                
                if error == nil {
                    
                    let message = Message(text: "", senderId: self.senderId, username: self.senderDisplayName, mediaType: "PHOTO", mediaUrl: String(newMetaData!.downloadURL()!))
                  let messageRef =  self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").childByAutoId()
                    
                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue(String(newMetaData!.downloadURL()!), withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("updateDiscussions", object: nil)
                                    
                                }else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                                    
                                }
                                
                                
                            })
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                            lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                }else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                                    
                                }
                            })
                            
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            
                        }
                        
                    })
                    
                    
                }else {
                    let alertView = SCLAlertView()
                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                }
            })
            
            
        } else {
            
            
            let videoPath = "messageWithMedia\(chatRoomId + NSUUID().UUIDString)/video.mp4"
            
            let videoRef = storageRef.reference().child(videoPath)
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            
            let videoData = NSData(contentsOfURL: withVideo!)!
            
            videoRef.putData(videoData, metadata: metadata, completion: { (newMetaData, error) in
                
                if error == nil {
                    
                    let message = Message(text: "", senderId: self.senderId, username: self.senderDisplayName, mediaType: "VIDEO", mediaUrl: String(newMetaData!.downloadURL()!))
                    
                    let messageRef =  self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("Messages").childByAutoId()

                    messageRef.setValue(message.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            let lastMessageRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("lastMessage")
                            lastMessageRef.setValue(String(newMetaData!.downloadURL()!), withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("updateDiscussions", object: nil)
                                    
                                }else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                                    
                                }
                                
                                
                            })
                            let lastTimeRef = self.databaseRef.child("ChatRooms").child(self.chatRoomId).child("date")
                            lastTimeRef.setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error, ref) in
                                if error == nil {
                                    
                                }else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                                    
                                }
                            })
                            
                            JSQSystemSoundPlayer.jsq_playMessageSentSound()
                            self.finishSendingMessage()
                            
                        }
                        
                    })
                    
                }else {
                    let alertView = SCLAlertView()
                    alertView.showError("OOPS", subTitle: error!.localizedDescription)
                }
            })
            
            
            
            
            
            
        }
        
        
    }
    
    private func getMedia(mediaType: CFString){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.editing = true
        
        if mediaType == kUTTypeImage {
            
            imagePicker.mediaTypes = [mediaType as String]
            
        } else if mediaType == kUTTypeMovie {
            
            imagePicker.mediaTypes = [mediaType as String]

        }
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }else {
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if !message.isMediaMessage {
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.whiteColor()
        }else {
            cell.textView.textColor = UIColor.blackColor()
        }
        }
        
        
        return cell
    }
    
    
    
    
    
    
    
}
