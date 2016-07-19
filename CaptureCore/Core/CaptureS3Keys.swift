//
//  S3Keys.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import AWSCore

public protocol CaptureS3Keyable {
    var s3Key:String { get }
    var s3Secret:String { get }
    var s3Bucket:String { get }
    var s3Region:AWSRegionType { get }
}

extension NSBundle: CaptureS3Keyable {
    
    public var s3Key:String {
        return stringValue("S3AccessKey")
    }
    
    public var s3Secret:String {
        return stringValue("S3AccessSecret")
    }
    
    public var s3Bucket:String {
        return stringValue("S3Bucket")
    }
    
    public var s3Region:AWSRegionType {
        return AWSRegionType.USEast1
    }
    
}