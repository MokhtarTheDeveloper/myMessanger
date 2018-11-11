//
//  ChatLog+TextFiledDelegate.swift
//  myMessenger
//
//  Created by Mokhtar on 10/14/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit

extension ChatLogViewController: UITextFieldDelegate {
    
    fileprivate func animateButtons(text: String, range : NSRange) {
        if (previousRange == nil ) || ( range.location > 0 ) || (range.location == 0 && previousRange?.location == 0 && previousPreviousRange?.location == 0){
            showSendButton()
        } else {
            hideSendButton()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        animateButtons(text: text, range: range)
        previousPreviousRange = previousRange
        previousRange = range
        return true
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("should begin editing")
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("should end editing")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func showSendButton() {
        inputsContainerView.cameraButtonWidthAnchor?.isActive = false
        inputsContainerView.recordingButoonWidthAnchor?.isActive = false
        recordingButtonNewWidthAnchor?.isActive = true

        cameraButtonNewWidthAnchor?.isActive = true
        sendButtonNewWidthAnchor?.isActive = true
        inputsContainerView.sendButtonWidthAnchor?.isActive = false
        UIView.animate(withDuration: 0.2, animations: {
            self.inputsContainerView.layoutIfNeeded()
        })
        
    }
    
    func hideSendButton() {
        inputsContainerView.cameraButtonWidthAnchor?.isActive = true
        inputsContainerView.recordingButoonWidthAnchor?.isActive = true
        inputsContainerView.sendButtonWidthAnchor?.isActive = true
        cameraButtonNewWidthAnchor?.isActive = false
        recordingButtonNewWidthAnchor?.isActive = false
        sendButtonNewWidthAnchor?.isActive = false
        UIView.animate(withDuration: 0.2) {
            self.inputsContainerView.layoutIfNeeded()
        }
    }
    
}
