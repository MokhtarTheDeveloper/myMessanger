//
//  UserModelView.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 8/17/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import Firebase

class Message {
    
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
    var toID : String?
    
    
    init(dictionary : [String : Any]) {
        
        self.fromID = dictionary["fromID"] as? String
        let toID = dictionary["toID"] as? String
        self.toID = toID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let partnerID = uid == toID ? fromID : toID {
            self.partnerID = partnerID
            let ref = Firebase.Database.database().reference().child("user").child(partnerID)
            ref.observe(.value) { (dataSnap) in
                if let dict = dataSnap.value as? [String : Any] {
                    self.partnerName = dict["name"] as? String
                    self.partnerImageURL = URL(string: dict["imageUrl"]! as! String)!
                }
            }
        }
        
        
        if let timeInterval = dictionary["date"] as? NSNumber {
            let timeDoubleValue = timeInterval.doubleValue
            self.timeDoubleValue = timeDoubleValue
            let date = Date(timeIntervalSince1970: timeDoubleValue)
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            self.timeText = formatter.string(from: date)
        }
        
        let imageWidth = dictionary["imageWidth"] as? NSNumber
        let imageHeight = dictionary["imageHeight"] as? NSNumber
        self.imageHeight = imageHeight?.floatValue
        self.imageWidth = imageWidth?.floatValue
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = URL(string: imageUrl)
            self.isImageMessage = true
        }
        
        if let thumbnailUrl = dictionary["thumbnailUrl"] as? String, let videoURL = dictionary["videoDownloadUrl"] as? String {
            self.thumbnailUrl = URL(string: thumbnailUrl)
            self.videoDownloadUrl = URL(string: videoURL)
            self.isVideoMessage = true
        }
        
        if let messageText = dictionary["text"] as? String {
            self.messageText = messageText
            self.isTextMessage = true
        }
        
        if let audioUrlString = dictionary["audioUrl"] as? String {
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
