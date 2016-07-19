//
//  CMCyclingUploader.swift
//  Capture-Live
//
//  Created by hatebyte on 4/13/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class CMS3CyclingFileTransfer: CMS3CyclingUploader {

    public override func createS3Protocol()->CMS3Protocol {
        let key                                 = self.model.s3Key
        let secret                              = self.model.s3Secret
        let bucket                              = self.model.s3Bucket
        let region                              = self.model.s3Region
        return CMS3FileTransfer(key:key, secret: secret, bucket: bucket, region: region)
    }

}
