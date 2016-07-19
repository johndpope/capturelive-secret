//
//  CMS3TransferWrapper.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 4/22/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AWSS3
import AWSCore

@objc public class CMS3FileTransfer: NSObject, CMS3Protocol {

    public var delegate:CMS3Delegate?      = nil
    var contentType:String          = "mp4"
    public var s3Bucket:String!
    var uploadRequest:AWSS3TransferManagerUploadRequest?
    var index:Int                   = 0
    
    required public init(key:String, secret:String, bucket:String, region:AWSRegionType) {
        self.s3Bucket               = bucket
        let credentialsProvider     = AWSStaticCredentialsProvider(accessKey:key, secretKey: secret)
        let configuration           = AWSServiceConfiguration(region:region, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
    
    public func end() {

    }

    private func killRequest() {
        if let _ = self.uploadRequest {
            self.uploadRequest = nil
        }
    }
    
    private func sendDelegateFailed(error:NSError) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let d = self.delegate {
                d.failedUpload(error)
            }
        })
    }
    
    private func sendDelegatePaused() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let d = self.delegate {
                d.pausedUpload()
            }
        })
    }
    
    private func sendDelegateCancelled() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let d = self.delegate {
                d.cancelledUpload()
            }
        })
    }
    
    private func sendDelegateResumed() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let d = self.delegate {
                d.resumedUpload()
            }
        })
    }
    
    private func sendDelegateCompleted() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let d = self.delegate {
                d.completedUpload("https://s3.amazonaws.com/\(self.uploadRequest!.bucket!)/\(self.uploadRequest!.key!)", index:self.index)
                d.completedUpload()
            }
            self.index += 1
        })
    }
    
    private func sendDelegateProgress(bytesUploaded:UInt64, bytesTotal:UInt64) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let d = self.delegate {
                d.progress(bytesUploaded, bytesTotal: bytesTotal)
            }
        })
    }
    
    private func upload(request: AWSS3TransferManagerUploadRequest) {
        let transferManager         = AWSS3TransferManager.defaultS3TransferManager()
        
        request.uploadProgress      = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
            self.sendDelegateProgress(UInt64(totalBytesSent), bytesTotal: UInt64(totalBytesExpectedToSend))
        }
        
        transferManager.upload(request).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled:
                            self.sendDelegateCancelled()
                            break;
                        case .Paused:
                            self.sendDelegatePaused()
                            break;
                        default:
                            print("upload() failed: [\(error)]")
                            self.sendDelegateFailed(error);
                            break;
                        }
                    } else {
                        print("upload() failed: [\(error)]")
                        self.sendDelegateFailed(error);
                    }
                } else {
                    print("upload() failed: [\(error)]")
                    self.sendDelegateFailed(error);
                }
            }
            
            if let exception = task.exception {
                print("upload() failed: [\(exception)]")
                let err = NSError(domain: "", code: 0, userInfo: nil)
                self.sendDelegateFailed(err);
            }
            
            if task.result != nil {
                self.sendDelegateCompleted()
            }
            return nil
        }
    }
    
    public func start(filePath:String, s3Path key:String) {
        print("DOCUMENTS CORE : \(NSFileManager.documents)")
        let request         = AWSS3TransferManagerUploadRequest()
        request.body        = NSURL(fileURLWithPath: filePath)
        request.key         = key
        request.bucket      = self.s3Bucket
        self.uploadRequest  = request
        
        upload(self.uploadRequest!)
    }

    public func cancel() {
        if let request = self.uploadRequest {
            let shouldSendFromBlock = (request.state == AWSS3TransferManagerRequestState.Paused)
            request.cancel().continueWithBlock({ (task) -> AnyObject! in
                if let error = task.error {
                    print("cancel() failed: [\(error)]")
                }
                if let exception = task.exception {
                    print("cancel() failed: [\(exception)]")
                }
                if shouldSendFromBlock == true {
                    self.sendDelegateCancelled()
                }
                return nil
            })
        }
    }
    
    public func pause() {
        if let request = self.uploadRequest {
            request.pause().continueWithBlock({ (task) -> AnyObject! in
                if let error = task.error {
                    print("pause() failed: [\(error)]")
                }
                if let exception = task.exception {
                    print("pause() failed: [\(exception)]")
                }
                return nil
            })
        }
    }
    
    public func resume() {
        if let request = self.uploadRequest {
            switch (request.state) {
            case .Paused:
                upload(request)
            case .NotStarted:
                upload(request)
            default:
                break;
            }

        }
    }
    
}
