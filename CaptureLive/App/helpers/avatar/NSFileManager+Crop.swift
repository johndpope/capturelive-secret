//
//  CMFileManager.swift
//  Capture-Live
//
//  Created by hatebyte on 6/1/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

enum FileManagerImageName : String {
    case Raw                                        = "raw"
    case Cropped                                    = "cropped"
}

extension NSFileManager {
    
    func saveRawImage(data:NSData) {
        self.saveImageNamed(FileManagerImageName.Raw.rawValue, ext:"jpg", data:data)
    }
    
    func getRawImage()->UIImage? {
        return self.getImageNamed(FileManagerImageName.Raw.rawValue, ext:"jpg")
    }
   
    func deleteRawImage() {
        self.clearImageNamed(FileManagerImageName.Raw.rawValue, ext:"jpg")
    }
    
    func saveCroppedImage(data:NSData) {
        self.saveImageNamed(FileManagerImageName.Cropped.rawValue, ext:"jpg", data:data)
    }
    
    func getCroppedImage()->UIImage? {
        return self.getImageNamed(FileManagerImageName.Cropped.rawValue, ext:"jpg")
    }
    
    func saveImageNamed(name:String, ext:String, data:NSData) {
        let fileURL                                 = self.tmpDirURL().URLByAppendingPathComponent(name).URLByAppendingPathExtension(ext)
        data.writeToURL(fileURL, atomically: true)
    }
    
    func clearImageNamed(name:String, ext:String) {
        let fileURL                                 = self.tmpDirURL().URLByAppendingPathComponent(name).URLByAppendingPathExtension(ext)
        do {
            try self.removeItemAtURL(fileURL)
        } catch let error as NSError {
            print("OMFG COULDNT REMOVE IMAGE : \(error.localizedDescription)")
        }
    }
    
    func getImageNamed(name:String, ext:String)->UIImage? {
        let fileURL                                 = self.tmpDirURL().URLByAppendingPathComponent(name).URLByAppendingPathExtension(ext)
        return UIImage(contentsOfFile: fileURL.path!)
    }
    
    func tmpDirURL()->NSURL {
        return NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true);
    }
    
    func croppedURL()->NSURL {
        return self.tmpDirURL().URLByAppendingPathComponent(FileManagerImageName.Cropped.rawValue).URLByAppendingPathExtension("jpg")
    }
    
}