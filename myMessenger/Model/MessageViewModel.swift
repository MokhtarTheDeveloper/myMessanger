//
//  UserModelView.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 8/17/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

class MessageViewModel {
    
    var partnerID : String?
    var partnerName : String?
    var partnerImageURL : URL?
    var timeText : String?
    var timeDoubleValue : Double?
    var isTextMessage = false
    var isImageMessage = false
    var isVideoMessage = false
    var isAudioMessage = false
    var messageText : String?
    var imageUrl : URL?
    var thumbnailUrl : URL?
    var videoDownloadUrl : URL?
    var audioUrl : URL?
    var imageHeight : Float?
    var imageWidth : Float?
    var fromID : String?
    
    
    init(message : Message) {
        self.fromID = message.fromID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let partnerID = uid == message.toID ? message.fromID : message.toID {
            self.partnerID = partnerID
            let ref = Firebase.Database.database().reference().child("user").child(partnerID)
            ref.observe(.value) { (dataSnap) in
                if let dict = dataSnap.value as? [String : Any] {
                    self.partnerName = dict["name"] as? String
                    self.partnerImageURL = URL(string: dict["imageUrl"]! as! String)!
                }
            }
        }
        
        if let timeInterval = message.date?.doubleValue {
            self.timeDoubleValue = timeInterval
            let date = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            self.timeText = formatter.string(from: date)
        }
        
        self.imageHeight = message.imageHeight?.floatValue
        self.imageWidth = message.imageWidth?.floatValue
        if let imageUrl = message.imageUrl {
            self.imageUrl = URL(string: imageUrl)
            self.isImageMessage = true
        }
        
        if let thumbnailUrl = message.thumbnailUrl, let videoURL = message.videoDownloadUrl {
            self.thumbnailUrl = URL(string: thumbnailUrl)
            self.videoDownloadUrl = URL(string: videoURL)
            self.isVideoMessage = true
        }
        
        if let messageText = message.text {
            self.messageText = messageText
            self.isTextMessage = true
        }
        
        if let audioUrlString = message.audioUrl {
            self.isAudioMessage = true
            let url = URL(string: audioUrlString)
            self.audioUrl = url
        }
        
    }
    
    
    func estimatHeightForText() -> CGRect? {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if let text = self.messageText {
            return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
        }
        return nil
    }
    
    
}
