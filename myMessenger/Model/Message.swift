//
//  Message.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 7/31/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import Foundation
import Firebase

class Message : NSObject {
    var toID : String?
    var text : String?
    var date : NSNumber?
    var fromID : String?
    var imageUrl : String?
    var imageWidth : NSNumber?
    var imageHeight : NSNumber?
    var videoDownloadUrl : String?
    var thumbnailUrl : String?
    var audioUrl : String?
    
    init(dictionary : [String : Any]) {
        super.init()
        self.toID = dictionary["toID"] as? String
        self.text = dictionary["text"] as? String
        self.date = dictionary["date"] as? NSNumber
        self.fromID = dictionary["fromID"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.videoDownloadUrl = dictionary["videoDownloadUrl"] as? String
        self.thumbnailUrl = dictionary["thumbnailUrl"] as? String
        self.audioUrl = dictionary["audioUrl"] as? String
    }

}
