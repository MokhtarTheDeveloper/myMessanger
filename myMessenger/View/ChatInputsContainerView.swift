
//
//  Chat.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 8/11/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit

class ChatInputsContainerView : UIView , UITextFieldDelegate {

    var chatLogVC : ChatLogViewController? {
        didSet  {
            sendButton.addTarget(chatLogVC, action: #selector(chatLogVC?.handleSend), for: .touchUpInside)
            sendImageButton.addTarget(chatLogVC, action: #selector(chatLogVC?.pickImageFromPhotoLibrary), for: .touchUpInside)
            cameraButton.addTarget(chatLogVC, action: #selector(chatLogVC?.takeAPhoto), for: .touchUpInside)
            
//            let recordingGesture = UITapGestureRecognizer(target: chatLogVC, action: #selector(chatLogVC?.handelRecording))
//            let gesture = UILongPressGestureRecognizer(target: chatLogVC, action: #selector(chatLogVC?.handelRecording))
//            recordingButoon.addGestureRecognizer(recordingGesture)
            recordingButoon.addTarget(chatLogVC, action: #selector(chatLogVC?.handelRecording), for: .touchUpInside)
        }
    }
    
    
    lazy var messageTextField : CustomTextField = {
        let textField = CustomTextField()
        textField.backgroundColor = .white
        textField.delegate = self
        textField.layer.cornerRadius = 18
        textField.layer.masksToBounds = true
        textField.layer.shadowRadius = 0.5
        textField.layer.shadowColor = UIColor.flatGray().cgColor
        textField.placeholder = "write message"
        return textField
    }()
    
    
    lazy var sendImageButton : UIButton = {
        var button = UIButton()
        button.setImage(UIImage(named: "gallery"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    
    lazy var recordingButoon : UIButton = {
        let butoon = UIButton(type: .system)
        let img = UIImage(named: "mic")
        butoon.setImage(img, for: .normal)
        butoon.imageView?.contentMode = .scaleAspectFit
        butoon.tintColor = .black
        return butoon
        }()
    
    
    let sendButton : UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
//        button.alpha = 0
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "paper-plane"), for: .normal)
        return button
    }()
    
    let cameraButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "camera"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogVC?.handleSend()
        return true
    }
    
    var sendButtonWidthAnchor : NSLayoutConstraint?
    var cameraButtonWidthAnchor : NSLayoutConstraint?
    var recordingButoonWidthAnchor : NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.flatWhite()
        
        addSubview(cameraButton)
        addSubview(messageTextField)
        addSubview(recordingButoon)
        addSubview(sendImageButton)
        addSubview(sendButton)
        
        cameraButton.setupAnchors(top: topAnchor, bottom: bottomAnchor, left: nil, right: rightAnchor)
        cameraButtonWidthAnchor = cameraButton.widthAnchor.constraint(equalToConstant: 50)
        cameraButtonWidthAnchor?.isActive = true
        
        sendButton.setupAnchors(top: topAnchor, bottom: bottomAnchor, left: nil, right: recordingButoon.leftAnchor)
        sendButtonWidthAnchor = sendButton.widthAnchor.constraint(equalToConstant: 0)
        sendButtonWidthAnchor?.isActive = true
        
        sendImageButton.setupAnchorsWithConstant(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: nil, topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: 0)
        sendImageButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        messageTextField.setupAnchorsWithConstant(top: nil, bottom: nil, left: sendImageButton.rightAnchor, right: sendButton.leftAnchor, topConstant: 8, bottomConstant: 0, leftConstant: 8, rightConstant: -8)
        messageTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        messageTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        recordingButoon.setupAnchorsWithConstant(top: topAnchor, bottom: bottomAnchor, left: nil, right: cameraButton.leftAnchor, topConstant: 8, bottomConstant: -8, leftConstant: 0, rightConstant: 0)
        recordingButoonWidthAnchor = recordingButoon.widthAnchor.constraint(equalToConstant: 44)
        recordingButoonWidthAnchor?.isActive = true
        let lineSeperator = UIView()
        lineSeperator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        addSubview(lineSeperator)
        lineSeperator.setupAnchorsWithConstant(top: topAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
        lineSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
