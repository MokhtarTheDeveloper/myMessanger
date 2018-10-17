//
//  Networking.swift
//  myMessenger
//
//  Created by macOS on 8/31/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation
import Firebase

class Networking {
    
    let mainDatabaseRefrence = Firebase.Database.database().reference()
    
    static let shared = Networking()
    
    func grabFriendsLatestMessages(uid : String, completionHandler : @escaping (([String : Message]) -> ())) {
        var messagesDict = [String : Message]()
        let userMessagesRef = mainDatabaseRefrence.child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded) { (snapShot) in
            let partnerID = snapShot.key
            Firebase.Database.database().reference().child("user-messages").child(uid).child(partnerID).observe(.childAdded, with: { (dataSnap) in
                
                let messageID = dataSnap.key
                
                let messageRef = self.mainDatabaseRefrence.child("messages").child(messageID)
                messageRef.observeSingleEvent(of: .value, with: { (dataSnap) in
                    if let dictionary = dataSnap.value as? [String : Any] {
                        let message = Message(dictionary: dictionary)
                        
                        if uid == message.fromID{
                            messagesDict[message.toID!] = message
                        } else {
                            messagesDict[message.fromID!] = message
                        }
                        completionHandler(messagesDict)
                    }
                })
            })
        }
    }
    
    
    func grabPartnerMessagesLog(partnerID : String, completionHandler : @escaping ((MessageViewModel) -> ())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = mainDatabaseRefrence.child("user-messages").child(uid).child(partnerID)
        userMessagesRef.observe(.childAdded, with: { (snapShot) in
            let messageID = snapShot.key
            let messageRef = self.mainDatabaseRefrence.child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (dataSnap) in
                let dict = dataSnap.value as! [String : Any]
                let messageVM = MessageViewModel(message: Message(dictionary: dict))
                completionHandler(messageVM)
            })
        }, withCancel: nil)
    }
}
