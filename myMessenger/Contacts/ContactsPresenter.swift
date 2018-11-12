//
//  ContactsPresenter.swift
//  myMessenger
//
//  Created by Mokhtar on 11/9/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation
import Firebase

protocol ContactPresenterDelegate :class {
    func reloadTableView()
}

class ContactPresenter {
    weak var delegate : ContactPresenterDelegate?
    let ref = Firebase.Database.database().reference().child("user")
    var usersArray = [User]()
    
    func fetchData() {
        ref.observe(.childAdded, with: { (dataSnap) in
            guard let dictionary = dataSnap.value as? [String : AnyObject] else { return }
            let id = dataSnap.key
            let user = User(dictionary: dictionary, id: id)
            if Auth.auth().currentUser?.uid != id{
                self.usersArray.append(user)
                self.delegate?.reloadTableView()
            }
        }) { (error) in
            print(error)
        }
    }
}
