//
//  Message.swift
//  WhatsAppClone
//
//  Created by Frezy Stone Mboumba on 7/23/16.
//  Copyright © 2016 Frezy Stone Mboumba. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    
    var text: String!
    var senderId: String!
    var ref: FIRDatabaseReference!
    var key: String = ""
    
    init(snapshot: FIRDataSnapshot){
        
        self.text = snapshot.value!["text"] as! String
        self.senderId = snapshot.value!["senderId"] as! String
        self.key = snapshot.key
        self.ref = snapshot.ref

    }
    
    init(text: String,senderId: String, key: String = ""){
        
        self.text = text
        self.senderId = senderId
        
    }
    
    
    func toAnyObject() -> [String: AnyObject]{
        
        return  ["text": text,"senderId": senderId]
    }
    
    
    
    
}
