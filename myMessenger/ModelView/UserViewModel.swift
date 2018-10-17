//
//  UsersViewModel.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 8/17/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

class UserViewModel : NSObject {
    
    var name : String?
    var mail : String?
    var userProfileImageUrl : URL?
    var id : String?

    
    
    init(user: User) {
        self.name = user.name
        if let url = user.profileImageURL {
            self.userProfileImageUrl = URL(string: url)
        }
        self.mail = user.mail
        self.id = user.id
    }
    
}
