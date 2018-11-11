//
//  ChatLogViewController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/27/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//


import UIKit
import MobileCoreServices
import SDWebImage


class ChatLogViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate , UINavigationControllerDelegate, ChatLogPresenterDelegate {
    
    var presenter : ChatLogPresenter!
    
    func setupTitleView(userViewModel: UserViewModel) {
        let titleView = NavigationBarTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        if let url = userViewModel.userProfileImageUrl {
            titleView.profileImageView.sd_setImage(with: url, completed: nil)
        }
        titleView.titleLabel.text = userViewModel.name
        navigationItem.titleView = titleView
    }
    
    
    //MARK:- Setting up inputAccessoryView
    lazy var inputsContainerView : ChatInputsContainerView = {
        let view = ChatInputsContainerView()
        view.chatLogVC = self
        view.messageTextField.delegate = self
        return view
    }()
    
    var _inputAccessoryView : UIView!
    
    override var inputAccessoryView: UIView? {
        get {
            if _inputAccessoryView == nil {
                _inputAccessoryView = customView()
                _inputAccessoryView.backgroundColor = .flatWhite()
                _inputAccessoryView.addSubview(inputsContainerView)
                _inputAccessoryView.autoresizingMask = .flexibleHeight
                inputsContainerView.translatesAutoresizingMaskIntoConstraints = false
                inputsContainerView.bottomAnchor.constraint(equalTo: _inputAccessoryView.safeAreaLayoutGuide.bottomAnchor).isActive = true
                inputsContainerView.leftAnchor.constraint(equalTo: _inputAccessoryView.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
                inputsContainerView.rightAnchor.constraint(equalTo: _inputAccessoryView.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
                inputsContainerView.heightAnchor.constraint(equalTo: _inputAccessoryView.safeAreaLayoutGuide.heightAnchor).isActive = true
                
            }
            return _inputAccessoryView
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK:- AVKit dependent Properties
    
    
    //MARK:- these constrain used to animate inputsContainer View Buttons
    lazy var recordingButtonNewWidthAnchor : NSLayoutConstraint? = inputsContainerView.recordingButoon.widthAnchor.constraint(equalToConstant: 0)
    lazy var cameraButtonNewWidthAnchor : NSLayoutConstraint? = inputsContainerView.cameraButton.widthAnchor.constraint(equalToConstant: 0)
    lazy var sendButtonNewWidthAnchor : NSLayoutConstraint? = inputsContainerView.sendButton.widthAnchor.constraint(equalToConstant: 50)
    var charactersCountForTextFiled: Int?
    var previousRange : NSRange?
    var previousPreviousRange : NSRange?
    
    
    //MARK:- Sending photos and videos
    lazy var imagePicker : UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        return picker
    }()
    
    
    @objc func pickImageFromPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func takeAPhoto() {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL{
            presenter.uploadVideo(videoURL: videoURL)
            
        } else {
            if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
               presenter.uploadPhotos(originalImage: originalImage)
            }
        }
    }
    
    
    //MARK:- ViewController lifecycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        presenter.delegate = self
        setupTitleView(userViewModel: presenter.userViewModel)
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBackButton))
        navigationItem.leftBarButtonItem = backButton
        prepareCollectionView()
        addKeyboardDismessGesture()
    }
    
    
    fileprivate func prepareCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatCell.self, forCellWithReuseIdentifier: "cellID")
        collectionView?.bounces = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.keyboardDismissMode = .interactive
    }
    
    
        
    
    

    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            let indexPath = IndexPath(item: self.presenter.messagesViewModelArray.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func handelRecording() {
        presenter.prepareAVAudioSession()
        if presenter.isRecording {
            presenter.stopRecoring()
            inputsContainerView.recordingButoon.tintColor = .black
            presenter.isRecording = false
        } else {
            presenter.startRecording()
            inputsContainerView.recordingButoon.tintColor = .flatRed()
            presenter.isRecording = true
        }
    }
    
    
    @objc func handleSend() {
        if let message = inputsContainerView.messageTextField.text, message.count > 0 {
            let value = ["text" : message ] as [String : Any]
            guard let toID = presenter.userViewModel?.id else { return }
            Networking.shared.sendMessageWithProperties(properties: value, toID: toID)
            hideSendButton()
        }
        self.inputsContainerView.messageTextField.text = nil
    }
    
    
    fileprivate func addKeyboardDismessGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        collectionView.addGestureRecognizer(gesture)
    }
    
    
    @objc fileprivate func dismissKeyboard() {
        print("try")
        inputAccessoryView?.endEditing(true)
    }
    
    func present(controller: UIViewController) {
        present(controller, animated: true) {
            
        }
    }
    
    @objc private func handleBackButton() {
        navigationController?.popViewController(animated: true)
//        avPlayer.pause()
    }
    
    //MARK:- CollectionView DataSource and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let messageVM = presenter.messagesViewModelArray[indexPath.row]
        if messageVM.isTextMessage {
            let height = messageVM.estimatHeightForText()?.height
            return CGSize(width: view.frame.width, height: height! + 18)
        } else if messageVM.isAudioMessage {
            return CGSize(width: view.frame.width, height: 32)
        } else {
            let width = messageVM.imageWidth
            let height = messageVM.imageHeight
            let cellHeight = CGFloat(height! * 240 / width!)
            return CGSize(width: view.frame.width, height: cellHeight)
        }
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.messagesViewModelArray.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! ChatCell
        let messageVM = presenter.messagesViewModelArray[indexPath.row]
        cell.messageVM = messageVM
        cell.delegate = self
        setupCell(cell: cell, messageVM: messageVM)
        return cell
    }

    
    private func setupCell(cell: ChatCell, messageVM : MessageViewModel) {

        //seting up chat cell according to the type of the message
        
        if messageVM.isImageMessage {
            if let url = messageVM.imageUrl {
                cell.chatImage.sd_setImage(with: url, completed: nil)
            }
            cell.chatImage.isHidden = false
            cell.playButton.isHidden = true
            cell.audioProgressView.isHidden = true
            cell.audioPlayButton.isHidden = true
            cell.bubbleViewWidthAnchor?.constant = 240
            cell.textView.isHidden = true
            
        } else if messageVM.isVideoMessage {
            if let url = messageVM.thumbnailUrl {
                cell.chatImage.sd_setImage(with: url, placeholderImage: UIImage(named: "gray"))
            }
            cell.chatImage.isHidden = false
            cell.playButton.isHidden = false
            cell.audioProgressView.isHidden = true
            cell.audioPlayButton.isHidden = true
            cell.bubbleViewWidthAnchor?.constant = 240
            cell.textView.isHidden = true
        } else if cell.messageVM?.isAudioMessage == true {
            cell.audioProgressView.isHidden = false
            cell.audioPlayButton.isHidden = false
            cell.chatImage.isHidden = true
            cell.playButton.isHidden = true
            cell.bubbleView.backgroundColor = .gray
            cell.bubbleViewWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            cell.audioProgressView.progress = 0
            var isPlayingForTheFirstTime = true
        } else {
            cell.audioProgressView.isHidden = true
            cell.audioPlayButton.isHidden = true
            cell.chatImage.isHidden = true
            cell.playButton.isHidden = true
            cell.textView.text = messageVM.messageText
            let width = messageVM.estimatHeightForText()?.width
            cell.bubbleViewWidthAnchor?.constant = width! + 32
            cell.textView.isHidden = false
        }
        
        // Seting up the layout of the chat cell depending on weather the logged user is a sender or a reciever
        if self.presenter.userViewModel?.id == messageVM.fromID {
            let color = UIColor(r: 240, g: 240, b: 240)
            cell.bubbleView.backgroundColor = color
            cell.bubViewleftAnchor?.isActive = true
            cell.bubViewRightAnchor?.isActive = false
            if let url = messageVM.partnerImageURL {
                cell.profileImageView.sd_setImage(with: url, completed: nil)
            }
            cell.audioProgressView.progressTintColor = UIColor(r: 200, g: 200, b: 200)
            cell.audioProgressView.trackTintColor = color
            cell.textView.textColor = UIColor.black
        } else {
            //let color = UIColor(r: 0, g: 120, b: 254)
            cell.bubbleView.backgroundColor = UIColor.flatGreen()
            cell.audioProgressView.progressTintColor = UIColor.flatGreenColorDark()
            cell.audioProgressView.trackTintColor = UIColor.flatGreen()
            cell.profileImageView.isHidden = true
            cell.bubViewRightAnchor?.isActive = true
            cell.bubViewleftAnchor?.isActive = false
            cell.textView.textColor = UIColor.white
        }
    }
    
    var tappedImageFrame : CGRect?
    var blackBacground : UIView?
    
    
    func handleZomingImageWithImageView(tappedImageView: UIImageView) {
        let zomingImage = UIImageView(image: tappedImageView.image)
        
        tappedImageFrame = tappedImageView.superview?.convert(tappedImageView.frame, to: nil)
        zomingImage.frame = tappedImageFrame!
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(zommingOut))
        zomingImage.addGestureRecognizer(gesture)
        zomingImage.isUserInteractionEnabled = true
        
        if let window = UIApplication.shared.keyWindow {
            let windowFrame = window.frame
            blackBacground = UIView(frame: windowFrame)
            blackBacground?.backgroundColor = .black
            self.inputsContainerView.alpha = 1
            window.addSubview(blackBacground!)
            window.addSubview(zomingImage)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.inputsContainerView.alpha = 0
                self.blackBacground?.alpha = 1
                let height = (self.tappedImageFrame?.height)! * windowFrame.width / (self.tappedImageFrame?.width)!
                zomingImage.frame = CGRect(x: 0, y: 0, width: windowFrame.width, height: height)
                zomingImage.center = window.center
            }, completion: nil)
        }
    }
    
    
    
    
    @objc func zommingOut(gesture : UIPanGestureRecognizer) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            gesture.view?.frame = self.tappedImageFrame!
            self.blackBacground?.alpha = 0
            self.inputsContainerView.alpha = 1
        }) { (completed : Bool) in
            gesture.view?.removeFromSuperview()
        }
    }
    
    
}


extension ChatLogViewController : ChatCellDelegate {
    func playVideo(for cell : ChatCell) {
        presenter.indexPath = collectionView.indexPath(for: cell)
        presenter.playVideoAtIndexPath()
    }
    
    func playAudio(for cell : ChatCell) {
        presenter.indexPath = collectionView.indexPath(for: cell)
        presenter.playAudio()
    }
    
    func stopAudio() {
        
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


