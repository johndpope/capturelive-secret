//
//  CMS3.swift
//  Capture-Live
//
//  Created by hatebyte on 6/10/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import Foundation
import AWSCore

public typealias S3UploadComplete = ()->()

// MARK: Upload Protocol and Delegates
public protocol CMS3Protocol {
    var delegate:CMS3Delegate?  { get set }
    var s3Bucket:String!  { get set }
    init(key:String, secret:String, bucket:String, region:AWSRegionType)
    func start(filePath:String, s3Path key:String)
    func cancel()
    func pause()
    func resume()
    func end()
}

public protocol CMS3Delegate {
   func startedUpload()
   func pausedUpload()
   func resumedUpload()
   func cancelledUpload()
   func completedUpload()
   func completedUpload(path:String, index:Int)
   func failedUpload(_: NSError)
   func progress(bytesUploaded:UInt64, bytesTotal:UInt64)
}

// MARK: Cycling Upload Protocol and Delegates
public protocol CMS3CyclingUploaderModelProtocol {
    var identifier:String {get}
    var totalBytes:UInt64  {get}
    var totalBytesUploaded:UInt64 {get}
    var s3FilePath:String {get}
    var s3Key:String {get}
    var s3Secret:String {get}
    var s3Bucket:String {get}
    var s3Region:AWSRegionType {get}
    var libraryAlbumName:String? {get}
    var nextLocalPath:String? { get }
    func updateByteValuesWithFileCompletion()
    func updateUploadedByteValues(bytesUploaded: UInt64)
    func end()
//    func didComplete()
    func startFromWake(uploadFinished:()->(), uploadContinue:()->())
}

public typealias WakeCompletion      = (isTotallyFinished:Bool)->()
public protocol CMS3CyclingUploaderProtocol {
    func createS3Protocol()->CMS3Protocol
//    func untie()
//    func end()
//    func start()
//    func pause()
//    func resume()
//    func cancel()
//    func startFromWake(complete:WakeCompletion)
}

public protocol CMS3CyclingUploaderDelegate:CMS3Delegate  {
    func percentUploaded(percent:Float)
    func allFilesCompletedUpload()
    func errorSavingToLibrary()
    func completedUpload(path:String, index:Int, complete:S3UploadComplete)
}

// MARK: Background Protocol and Delegates
public typealias Complete      = (AnyObject?)->()
public typealias Fail          = (NSError)->()


public protocol CMS3BackgroundUploaderProtocol {
    var cyclingUploader:CMS3CyclingUploader { get }
    func untie()
    func end()
    func start(success:Complete, failure:Fail)
    func pause(success:Complete, failure:Fail)
    func resume(success:Complete, failure:Fail)
    func cancel(success:Complete, failure:Fail)
    func startFromWake(complete:WakeCompletion, failure:Fail)
    func isUploading()->Bool
}

public protocol CMS3BackgroundUploaderDelegate {
    func percentUploaded(percent:Float)
    func allFilesCompletedUpload()
    func errorSavingToLibrary()
    func failedUpload(_: NSError)
    func completedUpload(path:String, index:Int, complete:S3UploadComplete)
}

