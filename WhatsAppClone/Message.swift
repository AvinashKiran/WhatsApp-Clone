//
//  Message.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 8/27/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    
    var text: String!
    var senderId: String!
    var username: String!
    var mediaType: String!
    var mediaUrl: String!
    var ref: FIRDatabaseReference!
    var key: String = ""
    
    
    init(snapshot: FIRDataSnapshot){
        
        
        self.text = snapshot.value!["text"] as! String
        self.senderId = snapshot.value!["senderId"] as! String
        self.username = snapshot.value!["username"] as! String
        self.mediaType = snapshot.value!["mediaType"] as! String
        self.mediaUrl = snapshot.value!["mediaUrl"] as! String
        self.ref = snapshot.ref
        self.key = snapshot.key

    }
    
    
    init(text: String, key: String = "", senderId: String, username: String, mediaType: String, mediaUrl: String){
        
        
        self.text = text
        self.senderId = senderId
        self.username = username
        self.mediaUrl = mediaUrl
        self.mediaType = mediaType
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return ["text": text,"senderId": senderId, "username": username,"mediaType":mediaType, "mediaUrl":mediaUrl]
    }
    
    
    
}