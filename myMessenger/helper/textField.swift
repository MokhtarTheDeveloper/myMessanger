//
//  textField.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/28/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//
/*
import Foundation
import UIKit

class controller{
    
    var activeField : UITextField?
func registerForKeyboardNotifications(){
    //Adding notifies on keyboard appearing
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
}

func deregisterFromKeyboardNotifications(){
    //Removing notifies on keyboard appearing
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
}

func keyboardWasShown(notification: NSNotification){
    //Need to calculate keyboard exact size due to Apple suggestions
    self.scrollView.isScrollEnabled = true
    var info = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
    
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    
    var aRect : CGRect = self.view.frame
    aRect.size.height -= keyboardSize!.height
    if let activeField = self.activeField {
        if (!aRect.contains(activeField.frame.origin)){
            self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
}

func keyboardWillBeHidden(notification: NSNotification){
    //Once keyboard disappears, restore original positions
    var info = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    self.view.endEditing(true)
    self.scrollView.isScrollEnabled = false
}

func textFieldDidBeginEditing(_ textField: UITextField){
    activeField = textField
}

func textFieldDidEndEditing(_ textField: UITextField){
    activeField = nil
}
}
 */
