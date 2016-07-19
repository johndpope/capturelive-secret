//
//  HDFileEncoder.swift
//  Capture-Live
//
//  Created by hatebyte on 4/8/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AVFoundation

typealias CloseFile = (String)->()
typealias UpdateAssetWriter = ()->()

@objc protocol CMHDFileEncoderErrorDelegate {
    func hdFileEncoderError(error:NSError)
//    func didStartNewFile()
}

enum CMHDFileEncoderErrorCode : Int {
    case CantApplyOutputSettings
    case CantAddInput                   
    case AVAssetWriterStatusFailed
    case CantWriteFile
}

@objc class CMHDFileEncoder: NSObject {
    
    static let Domain                                                       = "com.capturemedia.ios.cmhdfilencoder"
    
    let size:CGSize!
    var updateAssetWriter:UpdateAssetWriter?
    private var mainAssetWriter:AVAssetWriter!
    var defaultFileName:String!
    var defaultDirectory:String!
    let highResEncoderQueue                                                 = dispatch_queue_create("HighResEncoderQueue", DISPATCH_QUEUE_CONCURRENT);
    var errorDelegate:CMHDFileEncoderErrorDelegate?
    private var sampleTime                                                  = CMSampleTime()
    var currentFileTime                                                     = CMTime()
    
    init(fileName:String, directory:String, size:CGSize) {
        self.defaultFileName                                                = fileName
        self.defaultDirectory                                               = directory
        self.size                                                           = size
        
        super.init()
        self.updateAssetWriter = {
            self.mainAssetWriter                                                = try! AVAssetWriter(URL:self.fileURL, fileType:AVFileTypeMPEG4)
            self.mainAssetWriter.addInput(self.videoInputWriter)
            self.mainAssetWriter.addInput(self.audioInputWriter)
        }
        
    }
    
    func shutDown() {
        self.mainAssetWriter                                                = nil
    }
    
    func cutTime(startTime:CMTime)->Int {
        return self.sampleTime.cutTime(startTime)
    }
   
    func stopRecordering() {
        self.sampleTime.pause()
    }
    
    func startRecordering() {
        self.sampleTime.resume()
    }
    
    func isVideoLongerThan(seconds:UInt)->Bool {
        return self.sampleTime.isVideoLongerThan(seconds * 1000)
    }
    
    var fileURL:NSURL {
        get {
//            let docPath                                                     = CMFileManager.defaultManager().createMp4FilePathInDirectory(self.defaultDirectory, fileName: self.defaultFileName)
            let docPath = NSFileManager.defaultManager().createIndexedPath(defaultDirectory, fileName:defaultFileName, ext:"mp4")
            print(docPath)
            return NSURL.fileURLWithPath(docPath)
        }
    }
    
    lazy private var videoInputWriter: AVAssetWriterInput = {
        var temporaryVWriter = self.createVideoInputWriter()!
        return temporaryVWriter
    }()

    lazy private var audioInputWriter: AVAssetWriterInput = {
        var temporaryAWriter = self.createAudioInputWriter()!
        return temporaryAWriter
    }()

    func finishWritingWithComplete(complete:()->()) {
        if let _ = self.mainAssetWriter {
            if self.mainAssetWriter.status == .Writing  {
                self.videoInputWriter.markAsFinished()
                self.audioInputWriter.markAsFinished()
                self.mainAssetWriter.finishWritingWithCompletionHandler({ () -> Void in
                    complete()
                })
            }
        }
    }
    
    func cutRecording(complete:CloseFile) {
        weak var weakSelf: CMHDFileEncoder? = self
        let path                            = self.mainAssetWriter.outputURL.path!;
        dispatch_barrier_async(self.highResEncoderQueue, {
            weakSelf?.finishWritingWithComplete { () -> () in
                self.updateAssetWriter?()
                dispatch_async(dispatch_get_main_queue(), {
                    complete(path)
                })
            }
        })
    }
    
    func finishRecording(complete:CloseFile) {
        self.updateAssetWriter = nil
        weak var weakSelf:CMHDFileEncoder?                                  = self
        let path                                                            = self.mainAssetWriter.outputURL.path!;
        dispatch_barrier_async(self.highResEncoderQueue, {
            weakSelf?.finishWritingWithComplete { () -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    complete(path)
                })
            }
        })
    }
    
    func encodeSampleBuffer(sampleBuffer:CMSampleBuffer, isVideo:Bool) {
        dispatch_barrier_async(self.highResEncoderQueue, {
            if self.mainAssetWriter == nil {
                self.updateAssetWriter?()
            }
        })

        dispatch_sync(self.highResEncoderQueue, {
            if self.sampleTime.isPaused == true {
                return
            }
            let rawTime                                                     = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
            self.sampleTime.saveTime(rawTime)

            var sampleCopy                                                  = sampleBuffer
            self.sampleTime.adjustTime(&sampleCopy, isVideo:isVideo)
            
            let testBool:Bool                                               = CMSampleBufferDataIsReady(sampleCopy) != false
            if testBool == true {
                let currentTime                                             = CMSampleBufferGetOutputPresentationTimeStamp(sampleCopy);
                
                if let aw = self.mainAssetWriter {
                    if aw.status == AVAssetWriterStatus.Unknown {
                        aw.startWriting()
                        aw.startSessionAtSourceTime(currentTime)
                    }
                    if aw.status == AVAssetWriterStatus.Failed {
                        print("AVAssetWriterStatus.Failed \(aw.status.rawValue) \(aw.error!.localizedDescription)");
                        // call high res error
                        // should inform the user some how
                        let error                                           = NSError(domain:CMHDFileEncoder.Domain, code:CMHDFileEncoderErrorCode.AVAssetWriterStatusFailed.rawValue, userInfo:nil)
                        self.errorDelegate?.hdFileEncoderError(error)
                    } else {
                        if isVideo == true {
                            if self.videoInputWriter.readyForMoreMediaData == true  {
                                let worked = self.videoInputWriter.appendSampleBuffer(sampleCopy);
                                if worked == false {
                                    print("_mainAssetWriter.status \(aw.status.rawValue)");
                                }
                            }
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                                self.queryVideoTimeLimitReached(currentTime)
                            })
                        } else {
                            if self.audioInputWriter.readyForMoreMediaData == true {
                                let worked = self.audioInputWriter.appendSampleBuffer(sampleCopy);
                                if worked == false {
                                    print("_mainAssetWriter.status \(aw.status.rawValue)");
                                }
                            }
                        }
                    }
                }
            }
            
        })
    }
    
    func queryVideoTimeLimitReached(currentTime:CMTime) {
        if self.currentFileTime.isValid == true {
            let shouldCutVideo                                              = CMSampleTime.timeLimitReach(self.currentFileTime, endTime:currentTime)
            if shouldCutVideo == true {
                self.currentFileTime                                        = currentTime;
                self.cutRecording({ (path:String) -> () in
                })
            }
        } else {
            self.currentFileTime                                            = currentTime
        }
    }
    
    
    // TEMP, DELETE WHEN DONE
//    func saveAsset(path:String) {
//        let assetLib = ALAssetsLibrary()
//        assetLib.saveVideoUrl(NSURL(fileURLWithPath: path), toAlbum: "CaptureTests") { (asset:ALAsset!, error:NSError!) in
//            if (error != nil) {
//                println(error)
//            } else {
//                println("GREAT SUCCESS : \(path)")
//            }
//        }
//    }

//    - (void)queryVideoTimeLimitReached:(CMTime)currentTime {
//        if (!CMTIME_IS_VALID(self.currentFileTime)) {
//            _currentFileTime                                                        = currentTime;
//        } else {
//            BOOL shouldCutVideo                                                     = [CMSampleTime timeLimitReach:_currentFileTime endTime:currentTime];
//            if (shouldCutVideo) {
//                self.currentFileTime                                                = currentTime;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.hdFileEncoder cutRecording:^(NSString *path){
//                    
//                    }];
//                });
//            }
//        }
//    }
    
//    func logStreamDesc(description:AudioStreamBasicDescription) {
//        println("mBitsPerChannel    : \(description.mBitsPerChannel)");
//        println("mBytesPerFrame     : \(description.mBytesPerFrame)");
//        println("mBytesPerPacket    : \(description.mBytesPerPacket)");
//        println("mChannelsPerFrame  : \(description.mChannelsPerFrame)");
//        println("mFormatFlags       : \(description.mFormatFlags)");
//        println("mFormatID          : \(description.mFormatID)");
//        println("mFramesPerPacket   : \(description.mFramesPerPacket)\n\n");
//    }

    func createVideoInputWriter()->AVAssetWriterInput? {
        let numPixels                               = Int(self.size.width * self.size.height)
        let bitsPerPixel:Int                        = 11
        let bitRate                                 = Int64(numPixels * bitsPerPixel)
        let fps:Int                                 = 30
        let settings:[String : AnyObject]         = [
            AVVideoCodecKey                         : AVVideoCodecH264,
            AVVideoWidthKey                         : self.size.width,
            AVVideoHeightKey                        : self.size.height,
            AVVideoCompressionPropertiesKey         : [
                AVVideoAverageBitRateKey            : NSNumber(longLong: bitRate),
                AVVideoMaxKeyFrameIntervalKey       : NSNumber(integer: fps)
            ]
        ]

        var assetWriter:AVAssetWriterInput!
        if self.mainAssetWriter.canApplyOutputSettings(settings, forMediaType:AVMediaTypeVideo) {
            assetWriter                             = AVAssetWriterInput(mediaType:AVMediaTypeVideo, outputSettings:settings)
            assetWriter.expectsMediaDataInRealTime  = true
            if self.mainAssetWriter.canAddInput(assetWriter) {
                self.mainAssetWriter.addInput(assetWriter)
            }
        }
        return assetWriter;
    }
    
    func createAudioInputWriter()->AVAssetWriterInput? {
        let settings:[String : AnyObject]         = [
            AVFormatIDKey                           : NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey                   : 2,
            AVSampleRateKey                         : 44100,
            AVEncoderBitRateKey                     : 64000
        ]
        
        var assetWriter:AVAssetWriterInput!
        if self.mainAssetWriter.canApplyOutputSettings(settings, forMediaType:AVMediaTypeAudio) {
            assetWriter                             = AVAssetWriterInput(mediaType:AVMediaTypeAudio, outputSettings:settings)
            assetWriter.expectsMediaDataInRealTime  = true
            if self.mainAssetWriter.canAddInput(assetWriter) {
                self.mainAssetWriter.addInput(assetWriter)
            } else {
                let error = NSError(domain:CMHDFileEncoder.Domain, code:CMHDFileEncoderErrorCode.CantAddInput.rawValue, userInfo:nil)
                self.errorDelegate?.hdFileEncoderError(error)
            }
        } else {
            let error = NSError(domain:CMHDFileEncoder.Domain, code:CMHDFileEncoderErrorCode.CantApplyOutputSettings.rawValue, userInfo:nil)
            self.errorDelegate?.hdFileEncoderError(error)
        }
        return assetWriter
    }
    
}

