//
//  ChatLogPresenter.swift
//  myMessenger
//
//  Created by Mokhtar on 11/9/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation
import Firebase
import AVKit


protocol ChatLogPresenterDelegate: class {
    func setupTitleView(user: User)
    func reloadCollectionView()
    func dismiss()
    func present(controller: UIViewController)
    func setAudioProgressBar(percentage: Float)
    func setUpAudioPlayButton(isPlaying: Bool)
}

class ChatLogPresenter: NSObject {
    
    weak var delegate: ChatLogPresenterDelegate?
    let storageRef = Firebase.Storage.storage().reference()
    var messagesViewModelArray : [Message] = []
    var user : User!
    let avAudioSession = AVAudioSession.sharedInstance()
    let documentDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var audioRecordr : AVAudioRecorder?
    var isRecording : Bool = false
    var avPlayer : AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    var avPlayerAssets : AVAsset?
    var timeObserverToken : Any?
    var indexPath : IndexPath?
    var progress : Float?

    func grabMessages() {
        guard let toID = user?.id else { return }
        Networking.shared.grabPartnerMessagesLog(partnerID: toID) { (messageVM) in
            if self.user?.id == messageVM.partnerID {
                self.messagesViewModelArray.append(messageVM)
                self.messagesViewModelArray.sort(by: { return ($0.timeDoubleValue! < $1.timeDoubleValue!)})
            }
            self.delegate?.reloadCollectionView()
        }
    }
    
    
    func uploadVideo(videoURL: URL) {
        let uniqueID = NSUUID().uuidString
        let metaData = StorageMetadata()
        var thumbnailUrl : String?
        var videoDownloadUrl : String?
        var imageWidth : NSNumber?
        var imageHeight : NSNumber?
        guard let toID = user.id else { return }

        if let thumbnail = videoURL.getThumbnailFromVideoURL() {
            imageWidth = thumbnail.size.width as NSNumber
            imageHeight = thumbnail.size.height as NSNumber
            let thumbnailStorageRef = storageRef.child("videosThumbnails").child(uniqueID)
            Networking.shared.uploadImage(originalImage: thumbnail, imageStorageRef: thumbnailStorageRef) { (imageUrl) in
                thumbnailUrl = imageUrl
            }
        }
        
        let videoStorageRef = storageRef.child("videoMessages").child(uniqueID)
        metaData.contentType = "video/mp4"
        delegate?.dismiss()
        videoStorageRef.putFile(from: videoURL, metadata: metaData) { (StorageMetaData, err) in
            if err != nil {
                print(err!)
            } else {
                videoStorageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        videoDownloadUrl = url?.absoluteString
                        let values : [String : Any] = ["videoDownloadUrl" : videoDownloadUrl ?? "", "thumbnailUrl" : thumbnailUrl ?? "", "imageWidth" : imageWidth ?? 0, "imageHeight" : imageHeight ?? 0]
                        Networking.shared.sendMessageWithProperties(properties: values, toID: toID)
                    }
                })
            }
        }
    }
    
    
    func uploadPhotos(originalImage : UIImage) {
        guard let toID = user.id else { return }
        let uniqueID = NSUUID().uuidString
        let imageStorageRef = storageRef.child("imageMessages").child(uniqueID)
        delegate?.dismiss()
        Networking.shared.uploadImage(originalImage: originalImage, imageStorageRef: imageStorageRef) { imageUrl in
            
            let values = ["imageUrl" : imageUrl, "imageWidth" : originalImage.size.width, "imageHeight" : originalImage.size.height] as [String : Any]
            
            Networking.shared.sendMessageWithProperties(properties: values, toID: toID)
        }
    }
    
    func uploadAudioFile(url : URL) {
        let audioID = UUID().uuidString
        var audioURL : String?
        guard let toID = user?.id else { return }
        let storageRef = Firebase.Storage.storage().reference().child("AudioFiles").child(audioID).child("record.m4a")
        
        let metaData = StorageMetadata()
        metaData.contentType = "MPEG4/AAC"
        storageRef.putFile(from: url, metadata: metaData) { (meta, err) in
            if err == nil {
                storageRef.downloadURL(completion: { (url, err) in
                    audioURL = url?.absoluteString
                    let values = ["audioUrl" : audioURL ?? ""] as [String : Any]
                    Networking.shared.sendMessageWithProperties(properties: values, toID: toID)
                })
            }
        }
    }

}

extension ChatLogPresenter {
    
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
    
}

extension ChatLogPresenter : AVAudioRecorderDelegate {
    
    func prepareAVAudioSession() {
        
        do {
            try avAudioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: .default)
            try avAudioSession.setActive(true)
            avAudioSession.requestRecordPermission { (bool) in
                if !bool {
                    print("Permission declined")
                }
            }
        } catch let err{
            print(err)
        }
    }
    
    func startRecording() {
        
        let fileName = documentDirPath.appendingPathComponent("myRecording.m4a")
        let settings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey : 2,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecordr = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecordr?.delegate = self
            audioRecordr?.record()
            print("Recording")
            isRecording = true
        } catch {
            print("error recoring")
        }
    }
    
    
    func stopRecoring() {
        isRecording = false
        audioRecordr?.stop()
        audioRecordr = nil
        print("Recording Stoped")
        let fileName = documentDirPath.appendingPathComponent("myRecording.m4a")
        uploadAudioFile(url: fileName)
    }
    
    func playVideoAtIndexPath() {
        let controller = AVPlayerViewController()
        if let url = messagesViewModelArray[(indexPath?.item)!].videoDownloadUrl {
            controller.player = AVPlayer(url: url)
            delegate?.present(controller: controller)
            controller.player?.play()
        }
    }
    
    func playAudio() {
        
        if avPlayer.timeControlStatus == .playing {
            delegate?.setUpAudioPlayButton(isPlaying: true)
            avPlayer.pause()
        } else if avPlayer . timeControlStatus == .paused{
            let localPlayerItem = AVPlayerItem(url: messagesViewModelArray[(indexPath?.item)!].audioUrl!)
                avPlayer.replaceCurrentItem(with: localPlayerItem)
            delegate?.setUpAudioPlayButton(isPlaying: false)
            avPlayer.play()
            removePeriodicTimeObserver()
            timeObserverForAvPlayer(completionHandler: { (progress) in
                self.delegate?.setAudioProgressBar(percentage: progress)
            })
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
