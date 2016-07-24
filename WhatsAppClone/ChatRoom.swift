//
//  ChatRoom.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/23/16.
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
    var ref: FIRDatabaseReference!
    var key: String!
    
    init(username:String,other_Username: String,userId: String,other_UserId: String,members: [String],chatRoomId: String,key: String = ""){
        
        self.username = username
        self.other_Username = other_Username
        self.userId = userId
        self.other_UserId = other_UserId
        self.members = members
        self.chatRoomId = chatRoomId
        self.ref = FIRDatabase.database().reference()
            }
    
    init (snapshot: FIRDataSnapshot){
        
        self.username = snapshot.value!["username"] as! String
        self.other_Username = snapshot.value!["other_Username"] as! String
        self.userId = snapshot.value!["userId"] as! String
        self.other_UserId = snapshot.value!["other_UserId"] as! String
        self.chatRoomId = snapshot.value!["chatRoomId"] as! String
        self.members = snapshot.value!["members"] as! [String]
        self.ref = snapshot.ref
        self.key = snapshot.key
        
    }
    
    func toAnyObject()-> [String: AnyObject] {
        
        return ["username": username, "other_Username": other_Username,"userId": userId, "other_UserId": other_UserId,"chatRoomId":chatRoomId,"members":members]
    }
}
