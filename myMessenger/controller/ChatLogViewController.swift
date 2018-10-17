//
//  ChatLogViewController.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/27/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//


import UIKit
import Firebase
import MobileCoreServices
import AVKit
import SDWebImage



class ChatLogViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var userViewModel : UserViewModel? {
        didSet{
            let titleView = NavigationBarTitleView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            if let url = userViewModel?.userProfileImageUrl {
                titleView.profileImageView.sd_setImage(with: url, completed: nil)
            }
            titleView.titleLabel.text = userViewModel?.name
            navigationItem.titleView = titleView
        }
    }
    
    var messagesViewModelArray : [MessageViewModel] = []
    
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
    var avPlayer : AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    var avPlayerLayer : AVPlayerLayer?
    var isRecording = false
    let avAudioSession = AVAudioSession.sharedInstance()
    let documentDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var audioRecordr : AVAudioRecorder?
    var avPlayerAssets : AVAsset?
    var timeObserverToken : Any?
    var isRecoreding : Bool = false
    
    //MARK:- these constrain used to animate inputsContainer View Buttons
    lazy var recordingButtonNewWidthAnchor : NSLayoutConstraint? = inputsContainerView.recordingButoon.widthAnchor.constraint(equalToConstant: 0)
    lazy var cameraButtonNewWidthAnchor : NSLayoutConstraint? = inputsContainerView.cameraButton.widthAnchor.constraint(equalToConstant: 0)
    lazy var sendButtonNewWidthAnchor : NSLayoutConstraint? = inputsContainerView.sendButton.widthAnchor.constraint(equalToConstant: 50)
    var charactersCountForTextFiled: Int?
    var previousRange : NSRange?
    var previousPreviousRange : NSRange?
    
    
    
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let uniqueID = NSUUID().uuidString
        let storageRef = Firebase.Storage.storage().reference()
        let metaData = StorageMetadata()
        var thumbnailUrl : String?
        var videoDownloadUrl : String?
        var imageWidth : NSNumber?
        var imageHeight : NSNumber?
        
        if let videoURL = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL{
            
            if let thumbnail = getThumbnailFromVideoURL(videoUrl: videoURL) {
                imageWidth = thumbnail.size.width as NSNumber
                imageHeight = thumbnail.size.height as NSNumber
                let thumbnailStorageRef = storageRef.child("videosThumbnails").child(uniqueID)
                uploadImage(originalImage: thumbnail, imageStorageRef: thumbnailStorageRef) { (imageUrl) in
                    thumbnailUrl = imageUrl
                }
            }
            
            let videoStorageRef = storageRef.child("videoMessages").child(uniqueID)
            metaData.contentType = "video/mp4"
            self.dismiss(animated: true, completion: nil)
            let uploadTask = videoStorageRef.putFile(from: videoURL, metadata: metaData) { (StorageMetaData, err) in
                if err != nil {
                    print(err!)
                } else {
                    videoStorageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!)
                        } else {
                            videoDownloadUrl = url?.absoluteString
                            let values : [String : Any] = ["videoDownloadUrl" : videoDownloadUrl ?? "", "thumbnailUrl" : thumbnailUrl ?? "", "imageWidth" : imageWidth ?? 0, "imageHeight" : imageHeight ?? 0]
                            self.sendMessageWithProperties(properties: values)
                        }
                    })
                }
            }
            uploadTask.observe(.progress) { (snapShot) in
                self.navigationItem.title = "\(ceil(100 * (snapShot.progress?.fractionCompleted)!))%"
            }
            uploadTask.observe(.success) { (snapShot) in
                self.navigationItem.title = "\((self.userViewModel?.name)!)%"
            }
        } else {
            if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                
                let imageStorageRef = storageRef.child("imageMessages").child(uniqueID)
                uploadImage(originalImage: originalImage, imageStorageRef: imageStorageRef) { imageUrl in
                    let values = ["imageUrl" : imageUrl, "imageWidth" : originalImage.size.width, "imageHeight" : originalImage.size.height] as [String : Any]
                    self.sendMessageWithProperties(properties: values)
                }
            }
        }
    }
    
    
    
    
    fileprivate func uploadImage(originalImage: UIImage, imageStorageRef: StorageReference, comletionHandler: @escaping (String)->() ) {
        self.dismiss(animated: true, completion: nil)
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
    
    
    func getThumbnailFromVideoURL(videoUrl : URL) -> UIImage? {
        let assets = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: assets)
        do {
            let cgimage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            let uiImage = UIImage(cgImage: cgimage)
            return uiImage
        } catch {
            print(error)
        }
        return nil
    }
    
    
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
    
    
    
    func timeObserverForAvPlayer(completionHandler : @escaping ((Float) -> ())){
        let interval = CMTimeMake(value: 1, timescale: 24)
        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { time in
            if let currentItem = self.avPlayer.currentItem {
                let duration = CMTimeGetSeconds(currentItem.duration).isNaN ? 1 : CMTimeGetSeconds(currentItem.duration)
                let currentTime = CMTimeGetSeconds((self.avPlayer.currentTime()))
                let percentage = Float(currentTime/duration)
                completionHandler(percentage)
            }
            
        })
    }
    
    func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            avPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    
    func grabMessages() {
        guard let toID = userViewModel?.id else { return }
        Networking.shared.grabPartnerMessagesLog(partnerID: toID) { (messageVM) in
            
            if self.userViewModel?.id == messageVM.partnerID {
                    self.messagesViewModelArray.append(messageVM)
                    self.messagesViewModelArray.sort(by: { return ($0.timeDoubleValue! < $1.timeDoubleValue!)})
                }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                let indexPath = IndexPath(item: self.messagesViewModelArray.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
            
        }
        
    }
    
    
    @objc func handleSend() {
        if let message = inputsContainerView.messageTextField.text, message.count > 0 {
            let value = ["text" : message ] as [String : Any]
            sendMessageWithProperties(properties: value)
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
    
    func sendMessageWithProperties(properties : [String : Any]) {
        let messageRef = Firebase.Database.database().reference().child("messages").childByAutoId()
        guard let fromID = Auth.auth().currentUser?.uid else { return }
        guard let toID = userViewModel?.id else { return }
        var values : [String : Any] = ["fromID" : fromID, "date" : Int(Date().timeIntervalSince1970), "toID" : toID]
        properties.forEach { (arg) in
            let (key, value) = arg
            values[key] = value
        }
        messageRef.updateChildValues(values) { (error, ref) in
            if let fromID = Auth.auth().currentUser?.uid, let toID = self.userViewModel?.id {
                let senderMesssageRef = Firebase.Database.database().reference().child("user-messages").child(fromID).child(toID)
                let messagesKey = [messageRef.key : 1]
                senderMesssageRef.updateChildValues(messagesKey)
                let reciverMessageRef = Firebase.Database.database().reference().child("user-messages").child(toID).child(fromID)
                reciverMessageRef.updateChildValues(messagesKey)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let messageVM = messagesViewModelArray[indexPath.row]
        if messageVM.isTextMessage {
            let height = messageVM.estimatHeightForText()?.height
            return CGSize(width: view.frame.width, height: height! + 16)
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
        return messagesViewModelArray.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellID", for: indexPath) as! ChatCell
        cell.chatLogVC = self
        let messageVM = messagesViewModelArray[indexPath.row]
        cell.messageVM = messageVM
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
            
            cell.playVideoClosure = {
                let controller = AVPlayerViewController()
                controller.player = AVPlayer(url: messageVM.videoDownloadUrl!)
                DispatchQueue.main.async {
                    self.present(controller, animated: true) {
                        controller.player?.play()
                    }
                }
            }
            
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
            
            cell.playSoundClosure = { [weak self] in
                if self?.avPlayer.timeControlStatus == .playing {
                    cell.audioPlayButton.setImage(UIImage(named: "audioPlay"), for: .normal)
                    self?.avPlayer.pause()
                } else if self?.avPlayer . timeControlStatus == .paused{
                    if isPlayingForTheFirstTime {
                        let localPlayerItem = AVPlayerItem(url: messageVM.audioUrl!)
                        self?.avPlayer.replaceCurrentItem(with: localPlayerItem)
                        isPlayingForTheFirstTime = false
                    }
                    cell.audioPlayButton.setImage(UIImage(named: "pause"), for: .normal)
                    self?.avPlayer.play()
                    self?.removePeriodicTimeObserver()
                    self?.timeObserverForAvPlayer(completionHandler: { (progress) in
                        DispatchQueue.main.async {
                            cell.audioProgressView.progress = progress
                        }
                    })
                }
            }
            cell.stopSoundClosure = { [weak self] in
                self?.avPlayer.pause()
            }
            
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
        if self.userViewModel?.id == messageVM.fromID {
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
//            let color = UIColor(r: 0, g: 120, b: 254)
            cell.bubbleView.backgroundColor = UIColor.flatGreen()
            cell.audioProgressView.progressTintColor = UIColor.flatGreenColorDark()
            cell.audioProgressView.trackTintColor = UIColor.flatGreen()
            cell.profileImageView.isHidden = true
            cell.bubViewRightAnchor?.isActive = true
            cell.bubViewleftAnchor?.isActive = false
            cell.textView.textColor = UIColor.white
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let messageVM = messagesViewModelArray[indexPath.item]
        if messageVM.isAudioMessage {
            let cell = collectionView.cellForItem(at: indexPath) as! ChatCell
            cell.isPlayingForTheFirstTime = true
            if avPlayer.timeControlStatus == .playing {
                cell.audioPlayButton.setImage(UIImage(named: "audioPlay"), for: .normal)
                avPlayer.pause()
            } else if avPlayer.timeControlStatus == .paused{
                if cell.isPlayingForTheFirstTime {
                    let localPlayerItem = AVPlayerItem(url: messageVM.audioUrl!)
                    avPlayer.replaceCurrentItem(with: localPlayerItem)
                    cell.isPlayingForTheFirstTime = false
                }
                cell.audioPlayButton.setImage(UIImage(named: "pause"), for: .normal)
                avPlayer.play()
                removePeriodicTimeObserver()
                timeObserverForAvPlayer(completionHandler: { (progress) in
                    DispatchQueue.main.async {
                        cell.audioProgressView.progress = progress
                    }
                })
            }
        }
    }

    
    @objc private func handleBackButton() {
        navigationController?.popViewController(animated: true)
        avPlayerLayer?.removeFromSuperlayer()
        avPlayer.pause()
        
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




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
