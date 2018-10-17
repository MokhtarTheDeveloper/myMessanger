//
//  ChatCell.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 8/4/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import AVFoundation

protocol ChatCellDelegate {
    func playSound(chatcell : ChatCell)
}

class ChatCell : UICollectionViewCell {
    
    var messageVM : MessageViewModel?
    var delegate : ChatCellDelegate?
    
    let textView : UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isHidden = true
        return tv
    }()
    
    lazy var playButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.tintColor = .flatWhite()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        return button
    }()
    
    var activitySpinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        return spinner
    }()
    
    
    var playVideoClosure : (()->())?
    var playSoundClosure : (()->())?
    var stopSoundClosure : (()->())?
    
    
    @objc func playVideo() {
        playVideoClosure?()
    }
    
    @objc func handlePlayButton() {
        playSoundClosure?()
    }

    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.chatImage.image = nil
        stopSoundClosure?()
    }
    
    
    var chatLogVC : ChatLogViewController?
    
    let bubbleView : UIView = {
        let bubView = UIView()
        bubView.translatesAutoresizingMaskIntoConstraints = false
        bubView.layer.cornerRadius = 16
        bubView.layer.masksToBounds = true
        bubView.backgroundColor = .clear
        return bubView
    }()
    
    let profileImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = 16
        imgView.layer.masksToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    
    lazy var chatImage : UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleZomingImage))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    let audioProgressView : UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        progressView.progressTintColor = .flatGreen()
        progressView.trackTintColor = .flatGray()
        progressView.isHidden = true
        return progressView
    }()
    
    
    lazy var audioPlayButton : UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setImage(UIImage(named: "audioPlay"), for: .normal)
        button.isHidden = true
        button.tintColor = .black
        button.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleZomingImage() {
        
        if messageVM?.videoDownloadUrl != nil {
            return
        }
        let tappedImageView = chatImage
        
        if let VC = chatLogVC {
            VC.handleZomingImageWithImageView(tappedImageView: tappedImageView)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                audioPlayButton.setImage(UIImage(named: "pause"), for: .normal)
            } else {
                audioPlayButton.setImage(UIImage(named: "audioPlay"), for: .normal)
                audioProgressView.progress = 0
            }
        }
    }
    
    var isPlayingForTheFirstTime = true
    var bubbleViewWidthAnchor : NSLayoutConstraint?
    var bubViewleftAnchor : NSLayoutConstraint?
    var bubViewRightAnchor : NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        
        bubViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant : -8)
        bubViewRightAnchor?.isActive = true
        
        bubViewleftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubViewleftAnchor?.isActive = false
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true

        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        bubbleView.addSubview(chatImage)
        chatImage.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        chatImage.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        chatImage.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        chatImage.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor).isActive = true
        
        bubbleView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        bubbleView.addSubview(activitySpinner)
        
        activitySpinner.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activitySpinner.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activitySpinner.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activitySpinner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bubbleView.addSubview(audioProgressView)
        audioProgressView.setupAnchorsWithConstant(top: bubbleView.topAnchor, bottom: bubbleView.bottomAnchor, left: bubbleView.leftAnchor, right: bubbleView.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
        
        audioProgressView.addSubview(audioPlayButton)
        audioPlayButton.setupAnchorsWithConstant(top: audioProgressView.topAnchor, bottom: audioProgressView.bottomAnchor, left: audioProgressView.leftAnchor, right: nil, topConstant: 0, bottomConstant: 0, leftConstant: 16, rightConstant: 0)
        audioPlayButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
}
