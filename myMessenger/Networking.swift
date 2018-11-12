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
    
    
    func grabPartnerMessagesLog(partnerID : String, completionHandler : @escaping ((Message) -> ())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = mainDatabaseRefrence.child("user-messages").child(uid).child(partnerID)
        userMessagesRef.observe(.childAdded, with: { (snapShot) in
            let messageID = snapShot.key
            let messageRef = self.mainDatabaseRefrence.child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (dataSnap) in
                let dict = dataSnap.value as! [String : Any]
                let messageVM = Message(dictionary: dict)
                completionHandler(messageVM)
            })
        }, withCancel: nil)
    }
    
    
    
    
    func uploadImage(originalImage: UIImage, imageStorageRef: StorageReference, comletionHandler: @escaping (String)->() ) {
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        guard let imageData = originalImage.jpegData(compressionQuality: 0.5) else { return }
        imageStorageRef.putData(imageData, metadata: metaData, completion: { (meta, error) in
            if error != nil{
                print(error!)
            } else {
                imageStorageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        if let imageUrl = url?.absoluteString {
                            comletionHandler(imageUrl)
                            
                        }
                    }
                })
            }
        })
    }
    
    
    func sendMessageWithProperties(properties : [String : Any], toID: String) {
        let messageRef = Firebase.Database.database().reference().child("messages").childByAutoId()
        guard let fromID = Auth.auth().currentUser?.uid else { return }
        
        var values : [String : Any] = ["fromID" : fromID, "date" : Int(Date().timeIntervalSince1970), "toID" : toID]
        properties.forEach { (arg) in
            let (key, value) = arg
            values[key] = value
        }
        messageRef.updateChildValues(values) { (error, ref) in
            if let fromID = Auth.auth().currentUser?.uid {
                let senderMesssageRef = Firebase.Database.database().reference().child("user-messages").child(fromID).child(toID)
                let messagesKey = [messageRef.key : 1]
                senderMesssageRef.updateChildValues(messagesKey)
                let reciverMessageRef = Firebase.Database.database().reference().child("user-messages").child(toID).child(fromID)
                reciverMessageRef.updateChildValues(messagesKey)
            }
        }
    }
}
