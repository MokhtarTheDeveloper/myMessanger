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
    var profileImageURL : URL?
    var id : String?
    
    
    init(dictionary : [String : Any], id : String?) {
        super.init()
        self.mail = dictionary["mail"] as? String
        self.name = dictionary["name"] as? String
        if let profileImageURLString = dictionary["imageUrl"] as? String {
            self.profileImageURL = URL(string: profileImageURLString)
        }
        self.id = id
    }
    
}
