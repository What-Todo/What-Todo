//
//  Category.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import Foundation
import Firebase

struct Category {
    
    let ref : DatabaseReference? 
    let key : String

    var name : String
    let addedByUser : String
    var members : [String] = []
    
    // constructor
    init(aName: String, anAddedByUser: String, aMembers : [String], key: String = "") {
        self.ref = nil
        self.key = key

        self.name = aName
        self.addedByUser = anAddedByUser
        self.members = aMembers
    }
    
    init? (snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let details = value["details"] as? String,
            let addedByUser = value["addedByUser"] as? String,
            let members = value["members"]as? [String] else { return nil }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = details
        self.addedByUser = addedByUser
        self.members = members
    }
    
    func toAnyObject() -> Any {
        return [
            "details": name,
            "addedByUser": addedByUser,
            "members": members
        ]
    }
}
