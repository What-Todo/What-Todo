//
//  Post.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import Foundation
import Firebase

struct Post {
    
    let ref : DatabaseReference? // use ref instead of postId?
    var key : String = "key"

    var details : String
    var completed : Bool
    var addedByUser : String
    var timestamp : String
    
    // constructor
    init(aDetails: String, completed: Bool, anAddedByUser: String, timestamp: String, key: String = "") {
        self.ref = nil
        self.key = key

        self.details = aDetails
        self.completed = completed
        self.addedByUser = anAddedByUser
        self.timestamp = timestamp
    }
    
    init? (snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let details = value["details"] as? String,
            let completed = value["completed"] as? Bool,
            let addedByUser = value["addedByUser"] as? String,
            let timestamp = value["timestamp"] as? String else { return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.details = details
        self.completed = completed
        self.addedByUser = addedByUser
        self.timestamp = timestamp
    }
    
    func toAnyObject() -> Any {
        return [
            "details": details,
            "completed": completed,
            "addedByUser": addedByUser,
            "timestamp": timestamp,
        ]
    }
}
