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
    let key : String

    var details : String
    var completed : Bool
    var addedByUser : String
    var createdAt : String
    var updatedAt : String
    
    // constructor
    init(aDetails: String, completed: Bool, anAddedByUser: String, createdAt: String, updatedAt: String, key: String = "") {
        self.ref = nil
        self.key = key

        self.details = aDetails
        self.completed = completed
        self.addedByUser = anAddedByUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init? (snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let details = value["details"] as? String,
            let completed = value["completed"] as? Bool,
            let addedByUser = value["addedByUser"] as? String,
            let createdAt = value["createdAt"] as? String,
            let updatedAt = value["updatedAt"] as? String else { return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.details = details
        self.completed = completed
        self.addedByUser = addedByUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func toAnyObject() -> Any {
        return [
            "details": details,
            "completed": completed,
            "addedByUser": addedByUser,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
}
