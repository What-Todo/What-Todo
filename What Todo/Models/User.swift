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
    let userId: String
    let email: String

    let name: String
    let displayName: String
    let location: String
    
    init(authData: Firebase.User, aName: String, aDisplayName: String, aLocation: String) {
        userId = authData.uid
        email = authData.email!
        name = aName
        displayName = aDisplayName
        location = aLocation
    }
    
    init(aUserId: String, aEmail: String, aName: String, aDisplayName: String) {
        userId = aUserId
        email = aEmail
        name = aName
        displayName = aDisplayName
        location = ""
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
