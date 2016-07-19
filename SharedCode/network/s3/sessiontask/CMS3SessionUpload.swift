//
//  CMS3SessionUploadSwift.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 6/10/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore

public typealias CompletedTasks = ([AnyObject]!)->()

public enum CMS3SessionUploadErrorCode : Int {
    case NoFile
    case Failed
    case Cancelled
}

public class CMS3SessionUpload: NSObject, CMS3Protocol, NSURLSessionDelegate {
    
    public static let CMS3SessionIdentifier    = "com.current.upload.s3.session"
    public static let CMS3ErrorDomain:String   = "CMS3FileTransferDomain"
    
    public var delegate:CMS3Delegate?
    public var contentType:String              = "mp4"
    public var s3Bucket:String!
    public var uploadTask:NSURLSessionDataTask?
    public var sessionManager:NSURLSession!
    public var index:Int                       = 0
    public var isManualCancel                  = false
    public var preSignedReq:AWSS3GetPreSignedURLRequest?
    
    public func getTasksWithCompletionHandler(complete:CompletedTasks) {
        self.sessionManager.getTasksWithCompletionHandler { (dataTasks:[NSURLSessionDataTask], uploadTasks:[NSURLSessionUploadTask], downloadTasks:[NSURLSessionDownloadTask]) -> Void in
            complete(uploadTasks)
        }
    }
    
    public required init(key:String, secret:String, bucket:String, region:AWSRegionType) {
        super.init()
        self.s3Bucket                   = bucket
        let credentialsProvider         = AWSStaticCredentialsProvider(accessKey:key, secretKey: secret)
        let configuration               = AWSServiceConfiguration(region:region, credentialsProvider: credentialsProvider)
        configuration.maxRetryCount     = 100
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    }
   
    public func createSessionManager(identifier:String) {
        var sessionConfig:NSURLSessionConfiguration!        
//        if #available(iOS 8.0, *) {
            sessionConfig               = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
//        } else {
//            sessionConfig               = NSURLSessionConfiguration.backgroundSessionConfiguration(identifier)
//        }
        self.sessionManager             = NSURLSession(configuration:sessionConfig, delegate:self, delegateQueue: NSOperationQueue())
    }
    
    public func end() {
        self.sessionManager.invalidateAndCancel()
    }
    
    private func sendDelegateFailed(error:NSError) {
        if let d = self.delegate {
            d.failedUpload(error)
        }
    }
    
    private func sendDelegatePaused() {
        if let d = self.delegate {
            d.pausedUpload()
        }
    }
    
    private func sendDelegateCancelled() {
        if let d = self.delegate {
            d.cancelledUpload()
        }
    }
    
    private func sendDelegateResumed() {
        if let d = self.delegate {
            d.resumedUpload()
        }
    }
    
    private func sendDelegateCompleted() {
        if let d = self.delegate {
            d.completedUpload()
        }
        self.index += 1
    }
    
    private func sendDelegateProgress(bytesUploaded:UInt64, bytesTotal:UInt64) {
        if let d = self.delegate {
            d.progress(bytesUploaded, bytesTotal: bytesTotal)
        }
    }
    
    // MARK: CMS3Protocol
    public func start(filePath:String, s3Path key:String) {
        let fileURL                     = NSURL(fileURLWithPath: filePath)
        preSignedReq                    = AWSS3GetPreSignedURLRequest()
        preSignedReq?.bucket            = self.s3Bucket
        preSignedReq?.key               = key
        preSignedReq?.HTTPMethod        = AWSHTTPMethod.PUT
        preSignedReq?.contentType       = self.contentType;
        preSignedReq?.expires           = NSDate(timeIntervalSinceNow: 60 * 60)

        let urlBuilder                  = AWSS3PreSignedURLBuilder.defaultS3PreSignedURLBuilder()
        let bfTask:AWSTask              = urlBuilder.getPreSignedURL(preSignedReq!)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            bfTask.continueWithBlock({ (task) -> AnyObject! in
                if task.error != nil {
                    print("getPreSignedURL error: \(task.error)")
                    return nil;
                }
                
                let preSignedURL        = task.result as! NSURL
                let request             = NSMutableURLRequest(URL: preSignedURL)
                request.cachePolicy     = .ReloadIgnoringLocalCacheData
                
                // Make sure the content-type and http method are the same as in preSignedReq
                request.HTTPMethod      = "PUT"
                request.setValue(self.preSignedReq!.contentType, forHTTPHeaderField:"Content-Type")
               

                print(filePath)
                // NSURLSession background session does *not* support completionHandler, so don't set it.
                self.uploadTask         = self.sessionManager.uploadTaskWithRequest(request, fromFile:fileURL)
                self.uploadTask!.resume()

                print(self.delegate)
                if let d = self.delegate {
                    d.startedUpload()
                }
                return nil
            })
        })
    }
    
    public func cancel() {
        if let utask = self.uploadTask {
            if utask.state != .Canceling {
                utask.cancel()
                self.uploadTask         = nil
            }
        }
    }
    
    public func pause() {
        if let utask = self.uploadTask {
            if utask.state != .Suspended {
                utask.suspend()
                self.sendDelegatePaused()
            }
        }
    }
    
    public func resume() {
        if let utask = self.uploadTask {
            utask.resume()
            self.sendDelegateResumed()
        }
    }

    // MARK: NSURLSessionDelegate
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        do {
            if data.length > 0 {
                let userInfo = try NSJSONSerialization.JSONObjectWithData(data, options:[]) as? [String:AnyObject]
                if let message = userInfo?["Message"] as? String {
                    let error = NSError(domain:CMS3SessionUpload.CMS3ErrorDomain, code:CMS3SessionUploadErrorCode.Failed.rawValue, userInfo:[NSLocalizedDescriptionKey:message])
                    self.sendDelegateFailed(error)
                }
            }
        } catch {
            print("URLSession could not conform data to JSON : \(error))")
            self.sendDelegateFailed(error as NSError)
        }
    }
    
    public func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
//        print("didBecomeInvalidWithError : \(error)")
    }
    
    public func URLSession(session: NSURLSession,  task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let e = error {
//            print("didCompleteWithError : \(error)")
            if e.localizedDescription == "cancelled" {
                self.sendDelegateCancelled()
            } else if e.code == -1200 {
                let errord = NSError(domain:CMS3SessionUpload.CMS3ErrorDomain, code:CMS3SessionUploadErrorCode.Failed.rawValue, userInfo:[NSLocalizedDescriptionKey:e.localizedDescription])
                self.sendDelegateFailed(errord)
            }
        } else {
            self.uploadTask         = nil
            self.sendDelegateCompleted()
        }
    }
    
    public func URLSession(session: NSURLSession,  task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.sendDelegateProgress(UInt64(totalBytesSent), bytesTotal:UInt64(totalBytesExpectedToSend))
    }

}







































