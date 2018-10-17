//
//  LogoutViewController+Handlers.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/22/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

extension LoginLogoutViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker : UIImagePickerController {
        let pc = UIImagePickerController()
        pc.delegate = self
        pc.sourceType = .photoLibrary
        pc.allowsEditing = true
        return pc
    }
    
    @objc func handleProfileImagePicker() {
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
            userProfileImageView.image = editedImage
        } else {
            if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                userProfileImageView.image = originalImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handelLoginLogout() {
        if segmantedController.selectedSegmentIndex == 1 {
            handleRegestiration()
        } else{
            handleLogin()
        }
    }
    
    
    func handleLogin() {
        guard let email = mailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error!)
            } else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func handleRegestiration() {
        guard let email = mailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (response, error) in
            if error != nil{
                print("Faild to login to firebase")
            } else{
                print("Successed to login to firebase")
                self.dismiss(animated: true, completion: nil)
            }
            
            guard let uid = response?.user.uid else { return }
            var values = [ String : String ]()
            let storageRef = Firebase.Storage.storage().reference().child(uid).child("profileImage.jpeg")
            let metaData = StorageMetadata()
            guard let imageData = self.userProfileImageView.image!.jpegData(compressionQuality: 0.9) else { return }
            
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
