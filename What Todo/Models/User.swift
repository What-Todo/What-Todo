//
//  User.swift
//  What Todo
//
//  Created by Soma Yoshida on 4/22/20.
//  Copyright © 2020 What Todo. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let ref : DatabaseReference?
    var key : String = "key"
    
    let userId: String
    let email: String

    let name: String
    let displayName: String
    let location: String
    
    init(authData: Firebase.User, aName: String, aDisplayName: String, aLocation: String = "", key: String = "") {
        self.ref = nil
        self.key = key
        
        self.userId = authData.uid
        self.email = authData.email!
        self.name = aName
        self.displayName = aDisplayName
        self.location = aLocation
    }
    
    init(aUserId: String, aEmail: String, aName: String, aDisplayName: String, aLocation: String = "", key: String = "") {
        self.ref = nil
        self.key = key
        
        self.userId = aUserId
        self.email = aEmail
        self.name = aName
        self.displayName = aDisplayName
        self.location = aLocation
    }
    
    init? (snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let userId = value["userId"] as? String,
            let email = value["email"] as? String,
            let name = value["name"] as? String,
            let displayName = value["displayName"] as? String,
            let location = value["location"] as? String else { return nil}
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.userId = userId
        self.email = email
        self.name = name
        self.displayName = displayName
        self.location = location
    }
    
    func toAnyObject() -> Any {
        return [
            "userId": userId,
            "email": email,
            "name": name,
            "displayName": displayName,
            "location": location
        ]
    }
}
