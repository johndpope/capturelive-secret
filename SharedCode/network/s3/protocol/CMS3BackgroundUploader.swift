//
//  CMS3BackgroundUploader.swift
//  Capture-Live
//
//  Created by hatebyte on 6/18/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import Foundation

public class CMS3BackgroundUploader: NSObject, CMS3BackgroundUploaderProtocol, CMS3CyclingUploaderDelegate {

    private var activeSuccess:Complete?
    private var activeFailure:Fail?
    private var progressTimer:NSTimer!
    private var currentProgressTask:NSURLSessionDataTask!
    public var delegate:CMS3BackgroundUploaderDelegate?
   
    public var model:CMS3CyclingUploaderModelProtocol!
    public var cyclingUploader:CMS3CyclingUploader
 
    public class var shared :CMS3BackgroundUploader {
        struct Singleton {
            static let instance                     = CMS3BackgroundUploader()
        }
        return Singleton.instance
    }
    
    public override init() {
        self.cyclingUploader                        = CMS3CyclingUploadTask()
        super.init()
    }
    
    public func setup(model:CMS3CyclingUploaderModelProtocol) {
        self.model = model
        self.cyclingUploader.setup(self.model)
    }
    
    public func end() {
        self.delegate                               = nil
        self.cyclingUploader.end()
    }
    
    public func startFromWake(complete:WakeCompletion, failure:Fail) {
        dispatch_async(dispatch_get_main_queue(), {
            self.cyclingUploader.startFromWake(complete)
        })
    }
   
    internal func start() {
        self.cyclingUploader.delegate               = self
        self.cyclingUploader.start()
    }
   
    public func untie() {
        self.delegate                               = nil
        self.cyclingUploader.untie()
    }

    public func isUploading()->Bool {
        var uploading                               = false
        let semaphore                               = dispatch_semaphore_create(0);
        if let s3sessionUpload = self.cyclingUploader.s3Protocol as? CMS3SessionUpload {
            s3sessionUpload.getTasksWithCompletionHandler { (tasks:[AnyObject]!) -> () in
                var tasksmutable                    = tasks
                if tasksmutable.count > 0 {
                    if let task = tasksmutable.first as? NSURLSessionDataTask {
                        if task.state == NSURLSessionTaskState.Running {
                            s3sessionUpload.uploadTask = tasksmutable.removeAtIndex(0) as? NSURLSessionDataTask
                            uploading               = true
                        }
                    }
                    for t in tasksmutable as! [NSURLSessionDataTask] {
                        t.cancel()
                    }
                }
                dispatch_semaphore_signal(semaphore);
            }
            let timeoutTime :dispatch_time_t        = dispatch_time(DISPATCH_TIME_NOW, Int64(100 * Double(NSEC_PER_SEC)))
            dispatch_semaphore_wait(semaphore, timeoutTime)
        }
        return uploading
    }
    
    public func start(success:Complete, failure:Fail) {
        activeSuccess = success
        activeFailure = failure
        start()
    }
    
    public func pause(success:Complete, failure:Fail) {
        activeSuccess = success
        activeFailure = failure
        cyclingUploader.pause()
    }
    
    public func resume(success:Complete, failure:Fail) {
        activeSuccess = success
        activeFailure = failure
        cyclingUploader.resume()
    }
    
    public func cancel(success:Complete, failure:Fail) {
        activeSuccess = success
        activeFailure = failure
        cyclingUploader.cancel()
    }
    
    
    // MARK: CMS3CyclingUploaderDelegate
    public func startedUpload() {
        let nullNum = 0
        if let success = activeSuccess {
            success(nullNum)
        }
    }
    
    public func pausedUpload() {
        let nullNum = 0
        if let success = activeSuccess {
            success(nullNum)
        }
    }
    
    public func resumedUpload() {
        let nullNum = 0
        if let success = activeSuccess {
            success(nullNum)
        }
    }
    
    public func cancelledUpload() {
        let nullNum = 0
        if let success = activeSuccess {
            success(nullNum)
        }
        self.end()
    }
    
    public func completedUpload(path:String, index:Int, complete:S3UploadComplete) {
        print("Completed Upload : \(path)")
        self.startFromWake({ (isTotallyFinished:Bool) -> () in
            if isTotallyFinished == false {
                if let d = self.delegate {
                    d.completedUpload(path, index:index, complete:complete)
                }
            } else {
                if let d = self.delegate {
                    d.allFilesCompletedUpload()
                }
            }
            
        }) { (error:NSError) -> () in
            if let d = self.delegate {
                d.failedUpload(error)
            }
            
        }
    }
    
    public func percentUploaded(percent:Float) {
        if let d = self.delegate {
            d.percentUploaded(percent)
        }
    }
    
    public func allFilesCompletedUpload() {
        if let d = self.delegate {
            d.allFilesCompletedUpload()
        }

        self.end()
    }
    
    public func errorSavingToLibrary() {
        print("There was a error saving to the library")
    }
    
    public func failedUpload(error: NSError) {
       if let failure = activeFailure {
            failure(error)
        } else {
            if let d = delegate {
                d.failedUpload(error)
            }
        }
        self.end()
    }

    public func completedUpload() {}
    public func completedUpload(path:String, index:Int) {}
    public func progress(bytesUploaded:UInt64, bytesTotal:UInt64) {}

}
