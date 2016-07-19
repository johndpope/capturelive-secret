//
//  CMAvatarUploaderModel.swift
//  Capture-Live
//
//  Created by hatebyte on 6/2/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AWSCore

public class CMAvatarUploaderModel: NSObject {

    public var pathOfFile:String!
    public var libraryAlbumName:String?
    public var tBytesUploaded:UInt64                   = 0
    
    public override init() {
        self.pathOfFile                         = "uploads/user/avatar/\(NSUUID().UUIDString)/avatar_retina"
    }
    
    public var mimetype:String { get { return "jpg" } }
   
    public var s3FilePath:String {
        get {
            return "\(self.pathOfFile).\(self.mimetype)"
        }
    }

    public var avatarPath:String {
        get {
            return NSFileManager.defaultManager().croppedURL().path!
        }
    }
    
    public var s3Key:String {
        get {
            return NSBundle(forClass: CaptureLiveAlamoFireService.self).s3Key
        }
    }
    
    public var s3Secret:String {
        get {
            return NSBundle(forClass: CaptureLiveAlamoFireService.self).s3Secret
        }
    }
    
    public var s3Bucket:String {
        get {
            return NSBundle(forClass: CaptureLiveAlamoFireService.self).s3Bucket
        }
    }
    
    public var s3Region:AWSRegionType {
        get {
            return AWSRegionType.USEast1
        }
    }

}
