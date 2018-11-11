//
//  RecentMessagesViewPresenter.swift
//  myMessenger
//
//  Created by Mokhtar on 11/9/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation
import Firebase

@objc protocol RecentMessagesPresenterDelegate {
    func setupBarView()
    func reloadTableView()
    @objc func handleLogout()
    func presentChatLogWithUser(userVM: UserViewModel)
}

class RecentMessagesViewPresenter {
    
    weak var recentMessagesPresenterDelegate : RecentMessagesPresenterDelegate?
    let databaseReference = Firebase.Database.database().reference()
    var userViewModel : UserViewModel?
    var messagesModelViewArray = [MessageViewModel]()
    var timer : Timer?
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.email == nil {
            print("nil")
            handleLogout()
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Firebase.Database.database().reference().child("user").child(uid).observe(.value, with: { (dataSnap) in
                if let dictionary = dataSnap.value as? [String : AnyObject]{
                    self.userViewModel = UserViewModel(user: User(dictionary: dictionary, id: uid))
                    self.recentMessagesPresenterDelegate?.setupBarView()
                }
            }) { (error) in
                print(error)
            }
        }
    }
    
    func grabUserMessages() {
        guard let uid = userViewModel?.id else { return }
        Networking.shared.grabFriendsLatestMessages(uid: uid) { (messagesDict) in
            self.messagesModelViewArray = Array(messagesDict.values).map({MessageViewModel(message: $0)})
            self.messagesModelViewArray.sort(by: { (messageModelView1, messageModelView2) -> Bool in
                return (messageModelView1.timeDoubleValue)! > (messageModelView2.timeDoubleValue)!
            })
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.recentMessagesPresenterDelegate?.reloadTableView), userInfo: nil, repeats: false)
        }
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            
        } catch{
            print(error)
        }
        recentMessagesPresenterDelegate?.handleLogout()
    }

    @objc func reloadTableView() {
        recentMessagesPresenterDelegate?.reloadTableView()
    }
    
    func a(messageModelView : MessageViewModel) {
        let userID = messageModelView.partnerID
        let ref = Firebase.Database.database().reference().child("user").child(userID!)
        ref.observeSingleEvent(of: .value, with: { (snapShot) in
            if let dict = snapShot.value as? [String : String] {
                let user = User(dictionary: dict, id: userID)
                let userVM = UserViewModel(user: user)
                self.recentMessagesPresenterDelegate?.presentChatLogWithUser(userVM: userVM)
            }
        }, withCancel: nil)
    }
}

