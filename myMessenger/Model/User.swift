//
//  User.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/21/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation

class User: NSObject{
    var mail : String?
    var name : String?
    var profileImageURL : String?
    var id : String?
    
    
    init(dictionary : [String : Any], id : String?) {
        super.init()
        self.mail = dictionary["mail"] as? String
        self.name = dictionary["name"] as? String
        self.profileImageURL = dictionary["imageUrl"] as? String
        self.id = id
    }
    
}
