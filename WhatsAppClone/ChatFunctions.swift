//
//  ChatFunctions.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/23/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase

struct ChatFunctions {
    
    
    
   private var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    func startChat(user1: User, user2: User)-> String{
        
        let userId1 = user1.uid
        let userId2 = user2.uid
        
        var chatRoomId: String = ""
        
        
        
        let comparison = userId1.compare(userId2).rawValue
        
        let members = [user1.username,user2.username]

        if comparison < 0 {
            
            chatRoomId = userId1.stringByAppendingString(userId2)
        }else {
            chatRoomId = userId2.stringByAppendingString(userId1)

        }
        
        self.createChatRoom(user1, user2: user2, members: members, chatRoomId: chatRoomId)
        
        return chatRoomId
    }
    
   private func createChatRoom(user1: User, user2: User, members: [String], chatRoomId: String){
    
    let chatRoomRef = dataBaseRef.child("ChatRooms").queryOrderedByChild("chatRoomId").queryEqualToValue(chatRoomId)
    
    chatRoomRef.observeEventType(.Value) { (snapshot) in
        var createChatRoom = true
        
        if snapshot.exists(){
            
            for chatRoom in snapshot.value!.allValues {
                
                if chatRoom["chatRoomId"] as! String == chatRoomId {
                    createChatRoom = false
                    
                }
            }
            
        }
        
        if createChatRoom {
            self.createNewChatRoom(user1, user2: user2, members: members, chatRoomId: chatRoomId)
            
        }
    }
    
    
    
    }
    
    
    private func createNewChatRoom(user1: User, user2: User, members: [String], chatRoomId: String){
        let chatRoom = ChatRoom(username: user1.username, other_Username: user2.username, userId: user1.uid, other_UserId: user2.uid, members: members, chatRoomId: chatRoomId)
        
        let chatRoomRef = dataBaseRef.child("ChatRooms").child(chatRoomId)
        chatRoomRef.setValue(chatRoom.toAnyObject())
        
        
    }
    
    
}
