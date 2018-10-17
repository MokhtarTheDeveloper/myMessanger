//
//  ChatLogVC+SendRecordedFiles.swift
//  myMessenger
//
//  Created by Ahmed Mokhtar on 8/21/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

extension ChatLogViewController :  AVAudioRecorderDelegate {
    
    
    func prepareAVAudioSession() {
        
        do {
            try avAudioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: .default)
            try avAudioSession.setActive(true)
            avAudioSession.requestRecordPermission({ [weak self] (bool) in
                DispatchQueue.main.async {
                    if bool {
                        self?.inputsContainerView.recordingButoon.isHidden = false
                    } else {
                        self?.inputsContainerView.recordingButoon.isHidden = true
                    }
                }
            })
        } catch {}
    }

    
    @objc func handelRecording() {
        
        prepareAVAudioSession()
        
        if isRecording {
            stopRecoring()
            inputsContainerView.recordingButoon.tintColor = .black
            isRecording = false
        } else {
            startRecording()
            inputsContainerView.recordingButoon.tintColor = .flatRed()
            isRecording = true
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
    
    
    func uploadAudioFile(url : URL) {
        let audioID = UUID().uuidString
        var audioURL : String?
        let storageRef = Firebase.Storage.storage().reference().child("AudioFiles").child(audioID).child("record.m4a")
        
        let metaData = StorageMetadata()
        metaData.contentType = "MPEG4/AAC"
        storageRef.putFile(from: url, metadata: metaData) { (meta, err) in
            if err == nil {
                storageRef.downloadURL(completion: { (url, err) in
                        audioURL = url?.absoluteString
                    let values = ["audioUrl" : audioURL ?? ""] as [String : Any]
                        self.sendMessageWithProperties(properties: values)
                })
            }
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
