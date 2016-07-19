//
//  CMS3CyclingUploadTask.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 6/11/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import Foundation

public class CMS3CyclingUploadTask: CMS3CyclingUploader {
   
    public override func setup(model:CMS3CyclingUploaderModelProtocol) {
        super.setup(model)
    
        let s3sessionUpload                     = self.s3Protocol as! CMS3SessionUpload
        s3sessionUpload.getTasksWithCompletionHandler { (tasks:[AnyObject]!) -> () in
            var tasksmutable                    = tasks
            if tasksmutable.count > 0 {
                if let task = tasksmutable.first as? NSURLSessionDataTask {
                    if task.state == NSURLSessionTaskState.Running {
                        s3sessionUpload.uploadTask = tasksmutable.removeAtIndex(0) as? NSURLSessionDataTask
                    }
                }
                for t in tasksmutable as! [NSURLSessionDataTask] {
                    t.cancel()
                }
            }
        }
        self.s3Protocol.delegate                = self
    }
    
    public override func createS3Protocol()->CMS3Protocol {
        let key                                 = self.model.s3Key
        let secret                              = self.model.s3Secret
        let bucket                              = self.model.s3Bucket
        let region                              = self.model.s3Region
        let sessionUpload                       = CMS3SessionUpload(key:key, secret: secret, bucket: bucket, region: region)
        sessionUpload.createSessionManager(self.model.identifier)
        return sessionUpload
    }
    
}
