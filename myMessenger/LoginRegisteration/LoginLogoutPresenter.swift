//
//  LoginLogoutPresenter.swift
//  myMessenger
//
//  Created by Mokhtar on 11/9/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation
import Firebase

protocol LoginLogoutDelegate: class {
    func dismiss()
}

class LoginLogoutPresenter {
    weak var delegate: LoginLogoutDelegate?
    
    func handleLogin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!)
            } else{
                self.delegate?.dismiss()
            }
        }
    }
    
    func handleRegisteration(email: String, password: String, name: String, imageData: Data) {
        Auth.auth().createUser(withEmail: email, password: password) { (response, error) in
            if error != nil{
                print("Faild to login to firebase")
            } else{
                print("Successed to login to firebase")
                self.delegate?.dismiss()
            }
            
            guard let uid = response?.user.uid else { return }
            var values = [ String : String ]()
            let storageRef = Firebase.Storage.storage().reference().child(uid).child("profileImage.jpeg")
            let metaData = StorageMetadata()
            
            
            metaData.contentType = "image/jpeg"
            storageRef.putData(imageData, metadata: metaData, completion: { (meta, error) in
                if error != nil{
                    print(error!)
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                        } else {
                            if let imageUrl = url {
                                values = ["name": name, "mail": email , "imageUrl" : "\(imageUrl)"]
                                self.addUserDataIntoDatabase(uid: uid, values: values)
                            }
                            
                        }
                    })
                }
            })
        }
    }
    
    
    func addUserDataIntoDatabase(uid: String, values: [String : String]) {
        
        let ref = Firebase.Database.database().reference().child("user").child(uid)
        
        ref.setValue(values)
    }
    
    
}
