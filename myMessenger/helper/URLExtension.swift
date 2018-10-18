//
//  URLExtension.swift
//  myMessenger
//
//  Created by Mokhtar on 10/18/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import AVKit

extension URL {
    
    func getThumbnailFromVideoURL() -> UIImage? {
        let assets = AVAsset(url: self)
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
}

