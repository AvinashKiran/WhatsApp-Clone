//
//  ChatRoom.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 8/27/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import Foundation
import FirebaseDatabase


struct ChatRoom {
    
    var username: String!
    var other_Username: String!
    var userId: String!
    var other_UserId: String!
    var members: [String]!
    var chatRoomId: String!
    var key: String = ""
    var lastMessage: String!
    var ref: FIRDatabaseReference!
    var userPhotoUrl: String!
    var other_UserPhotoUrl: String!
    var date: NSNumber!
    
    init(snapshot: FIRDataSnapshot){
        
        self.username = snapshot.value!["username"] as! String
        self.other_Username = snapshot.value!["other_Username"] as! String
        self.userId = snapshot.value!["userId"] as! String
        self.other_UserId = snapshot.value!["other_UserId"] as! String
        self.lastMessage = snapshot.value!["lastMessage"] as! String
        self.userPhotoUrl = snapshot.value!["userPhotoUrl"] as! String
        self.other_UserPhotoUrl = snapshot.value!["other_UserPhotoUrl "] as! String
        self.members = snapshot.value!["members"] as! [String]
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.chatRoomId = snapshot.value!["chatRoomId"] as! String
        self.date = snapshot.value!["date"] as! NSNumber
    }
    
    
    init(username: String, other_Username: String,userId: String,other_UserId: String,members: [String],chatRoomId: String,lastMessage: String,key: String = "",userPhotoUrl: String,other_UserPhotoUrl: String, date: NSNumber){
        
        self.username = username
        self.other_UserPhotoUrl = other_UserPhotoUrl
        self.other_Username = other_Username
        self.userId = userId
        self.other_UserId = other_UserId
        self.userPhotoUrl = userPhotoUrl
        self.members = members
        self.lastMessage = lastMessage
        self.chatRoomId = chatRoomId
        self.date = date
    
        
    }

    func toAnyObject() -> [String: AnyObject] {
        
        return ["username": username, "other_Username": other_Username,"userId": userId,"other_UserId": other_UserId,"members": members,"chatRoomId": chatRoomId,"lastMessage": lastMessage,"userPhotoUrl": userPhotoUrl,"other_UserPhotoUrl": other_UserPhotoUrl,"date":date]
        
    }
    
}