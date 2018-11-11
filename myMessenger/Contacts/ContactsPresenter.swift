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
    var usersViewModelArray = [UserViewModel]()
    
    func fetchData() {
        ref.observe(.childAdded, with: { (dataSnap) in
            guard let dictionary = dataSnap.value as? [String : AnyObject] else { return }
            let id = dataSnap.key
            let user = User(dictionary: dictionary, id: id)
            let userVM = UserViewModel(user: user)
            if Auth.auth().currentUser?.uid != id{
                self.usersViewModelArray.append(userVM)
                self.delegate?.reloadTableView()
            }
        }) { (error) in
            print(error)
        }
    }
}
