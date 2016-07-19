//
//  StreamThumbnailUploader.swift
//  Current
//
//  Created by Scott Jones on 9/16/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

public typealias S3UploadSuccess                    = (String)->()
public typealias S3UploadFailure                    = (NSError)->()
import UIKit


public class S3ThumbnailUploader: NSObject, CMS3Delegate {

    var s3Transfer:CMS3Protocol!
    var model:CMS3ThumbnailUploaderModel!
    var completeWithPathBlock:S3UploadSuccess?
    var failBlock:Fail!

    init(model:CMS3ThumbnailUploaderModel) {
        self.model                                  = model
    }
    
    public func upload(keyable:CaptureS3Keyable, complete:S3UploadSuccess, error:S3UploadFailure) {
        self.completeWithPathBlock                  = complete
        self.failBlock                              = error
        self.startS3Upload(keyable)
    }
    
    private func startS3Upload(keyable:CaptureS3Keyable) {
        let key                                     = keyable.s3Key
        let secret                                  = keyable.s3Secret
        let bucket                                  = keyable.s3Bucket
        let region                                  = keyable.s3Region
        self.s3Transfer                             = CMS3FileTransfer(key:key, secret:secret, bucket:bucket, region:region)
        self.s3Transfer.delegate                    = self
        self.s3Transfer.start(self.model.thumbnailPath, s3Path:self.model.s3FilePath)
    }
    
    public func completedUpload(path:String, index:Int) {
        self.s3Transfer.delegate                    = nil
        self.s3Transfer                             = nil
        self.completeWithPathBlock?(path)
    }

    public func completedUpload() {}
    public func startedUpload() {}
    public func pausedUpload()  {}
    public func resumedUpload() {}
    public func cancelledUpload() {}
    public func progress(bytesUploaded:UInt64, bytesTotal:UInt64) {}
    
    public func failedUpload(error: NSError) {
        self.failBlock(error)
    }

}


class CMS3ThumbnailUploaderModel: NSObject {
    
    var localPathOfFile:String!
    var pathOfFile:String!
    var tBytesUploaded:UInt64                       = 0
    
    init(path:String, keyname:String = "test") {
        self.localPathOfFile                        = path
        self.pathOfFile                             = "uploads/attachments/\(keyname)/hdthumbnail/\(String.randomStringWithLength(12))"
    }
    
    var mimetype:String { get { return "jpg" } }
    
    var s3FilePath:String {
        get {
            return "\(self.pathOfFile).\(self.mimetype)"
        }
    }
    
    var thumbnailPath:String {
        get {
            return localPathOfFile
        }
    }
    
}

