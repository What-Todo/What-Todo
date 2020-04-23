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
    
    let ref : DatabaseReference? // use ref instead of categoryId?
    let key : String

    var name : String
    var addedByUser : String
    
    // constructor
    init(aName: String, completed: Bool, anAddedByUser: String, key: String = "") {
        self.ref = nil
        self.key = key

        self.name = aName
        self.addedByUser = anAddedByUser
    }
    
    init? (snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let details = value["details"] as? String,
            let addedByUser = value["addedByUser"] as? String else { return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = details
        self.addedByUser = addedByUser
    }
    
    func toAnyObject() -> Any {
        return [
            "details": name,
            "addedByUser": addedByUser,
        ]
    }
}
