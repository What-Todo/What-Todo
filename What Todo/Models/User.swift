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
    let name: String
    let location: String
    
    init(authData: Firebase.User) {
        userId = authData.uid
        name = authData.displayName!
        location = ""
    }
    
    init(aUserId: String, aName: String, aLocation: String) {
        self.userId = aUserId
        self.name = aName
        self.location = aLocation
    }
}
