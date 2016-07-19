//
//  CMSampleTime.swift
//  Capture-Live
//
//  Created by hatebyte on 4/17/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

// Has 3 seperate responsiblities
// 1. Calculate a 'cutTime',  the amount of time in the front where there is only video, no audio.
//
//    You do this by initializing with a 'startTime' from the first video samplebuffer 
//    Then update the 'recordingStartTime' and the 'recordingEndTime' with the 'saveTime' method with every sample buffers CMTime afterward
//    When it is over, call 'cutTime' to get the total nanoseconds to send to wowza
//
// 2. Calculate the interval of 2 CMTimes against a threshold
//    'timeLimitReach' and 'hasValidInterval' are self explainitory here
//
// 3. Adjust a CMSampleBuffers time struct after an interruption of the recording process.
//    Pass the sampleBuffer to 'adjustTime' and indicate whether it is audio or video and it will be adjusted the to offset.
//    For this to work, you must call 'pause' and 'resume' where you want you cuts to start and stop
//

import UIKit
import AVFoundation

@objc class CMSampleTime : NSObject {

    var startTime               = CMTime()
    var recordingStartTime      = CMTime()
    var recordingEndTime        = CMTime()
   
    private var lastVideoTime   = CMTime()
    private var lastAudioTime   = CMTime()
    private var timeOffset      = CMTime()
    private var isDiscontinued  = false
    var isPaused                = false
    
    static func timeLimitReach(startTime:CMTime, endTime:CMTime)->Bool {
        let maxVideoLength                          = UInt64(300 * 1000)        // 5 mins in milliseconds
//        let maxVideoLength                          = UInt64(60 * 1000)        // 60 seconds in milliseconds
//        let maxVideoLength                          = UInt64(5 * 1000)       // 5 seconds in milliseconds
//        let maxVideoLength                          = UInt64(180 * 1000)     // 3 mins in milliseconds
        return CMSampleTime.hasValidInterval(startTime, endTime:endTime, value:maxVideoLength)
    }
    
    static func hasValidInterval(startTime:CMTime, endTime:CMTime, value:UInt64)->Bool {
        let totalVideo                              = CMTimeSubtract(endTime, startTime);
        let echoTime                                = UInt64(CMTimeGetSeconds(totalVideo));
        let total                                   = UInt64(1000 * echoTime);
        return value < total
    }
    
    override init() {
        
    }
   
    func saveTime(lastTime:CMTime) {
        if self.recordingStartTime.isValid == false {
            self.recordingStartTime                 = lastTime
        }
        self.recordingEndTime                       = lastTime
    }
   
    func currentTime(currentTime:CMTime)->Int {
        if self.recordingStartTime.isValid {
            let recordedTime                        = CMTimeSubtract(currentTime, self.recordingStartTime);
            return Int(CMTimeGetSeconds(recordedTime) * 1000)
        }
        return 0
    }
    
    func cutTime(startTime:CMTime)->Int {
        print(self.recordingStartTime)
        print(self.recordingEndTime)
        print(startTime)
        let recordedTime                            = CMTimeSubtract(self.recordingEndTime, self.recordingStartTime);
        let streamedTime                            = CMTimeSubtract(self.recordingEndTime, startTime);
        let cutTime                                 = CMTimeSubtract(streamedTime, recordedTime);
        let cutTimeMilliseconds                     = Int(CMTimeGetSeconds(cutTime) * 1000)
//        
//        println("recordedTime           : \(CMTimeGetSeconds(recordedTime))")
//        println("streamedTime           : \(CMTimeGetSeconds(streamedTime))")
//        println("cutTime                : \(CMTimeGetSeconds(cutTime))")
//        println("cutTimeMilliseconds    : \(cutTimeMilliseconds)")

        return cutTimeMilliseconds
    }
   
    func isVideoLongerThan(milliseconds:UInt)->Bool {
        if self.recordingStartTime.isValid && self.lastVideoTime.isValid {
            return CMSampleTime.hasValidInterval(self.recordingStartTime, endTime:self.lastVideoTime, value:UInt64(milliseconds))
        }
        return false
    }
    
    func pause() {
        isPaused                                    = true
        isDiscontinued                              = true
    }
    
    func resume() {
        isPaused                                    = false
    }
    
    func adjustTime(inout sampleBuffer:CMSampleBufferRef, isVideo:Bool) {
        if self.isPaused == true {
            return
        }
        
        if self.isDiscontinued == true {
            if (isVideo == true) {
                return
            }
            self.isDiscontinued                     = false
            
            // make adjustment
            var cPresentationTime                   = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            var lastPresentationTime                = self.lastAudioTime
            if isVideo == true {
                lastPresentationTime                = self.lastVideoTime
            }
            
            if lastPresentationTime.isValid == true {
                if self.timeOffset.isValid == true {
                    // adjust the presentation with the current offset
                    cPresentationTime               = CMTimeSubtract(cPresentationTime, self.timeOffset)
                }
                // find the offset of the adjusted presentation time and the new offset
                let offset                          = CMTimeSubtract(cPresentationTime, lastPresentationTime)
                
                // save the difference in the new offset
                if (self.timeOffset.value == 0) {
                    self.timeOffset                 = offset
                } else {
                    self.timeOffset                 = CMTimeAdd(self.timeOffset, offset)
                }
            }
            self.lastVideoTime.flags                = CMTimeFlags()
            self.lastAudioTime.flags                = CMTimeFlags()
        }
        
        // adjust time if offset present
        if self.timeOffset.value > 0 {
            let sbuffer                             = CMSampleTimeObjc.adjustTime(sampleBuffer, by:self.timeOffset)
            sampleBuffer                            = sbuffer.takeRetainedValue()
        }
        
        // now that all offsets are taken care of, record lastest information
        var recentPresentationTime                  = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        let recentDuration                          = CMSampleBufferGetDuration(sampleBuffer);
        if recentDuration.value > 0 {
            recentPresentationTime                  = CMTimeAdd(recentPresentationTime, recentDuration);
        }
        if (isVideo) {
            self.lastVideoTime                      = recentPresentationTime;
        } else {
            self.lastAudioTime                      = recentPresentationTime;
        }
    }
   
    
    // DOES GNOT WOARK YET, sampleOut is null
//    private static func adjustTime(sampleBuffer:CMSampleBufferRef, offset:CMTime)->CMSampleBufferRef {
//        var itemCount:CMItemCount = 0
//        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, 0, nil, &itemCount)
//        
//        var pInfo                                   = UnsafeMutablePointer<CMSampleTimingInfo>.alloc(sizeof(CMSampleTimingInfo) * itemCount)
//        CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, itemCount, pInfo, &itemCount)
//        for i in 0..<itemCount {
//            pInfo[i].decodeTimeStamp                = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset)
//            pInfo[i].presentationTimeStamp          = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset)
//        }
//        
//        let cSample:UnsafeMutablePointer<Unmanaged<CMSampleBuffer>?> = UnsafeMutablePointer<Unmanaged<CMSampleBuffer>?>.alloc(1)
//        CMSampleBufferCreateCopyWithNewTiming(nil, sampleBuffer, itemCount, pInfo, cSample);
//        free(pInfo);
//        
//        let sampleOut                               = Unmanaged<CMSampleBuffer>.fromOpaque(COpaquePointer(cSample)).takeRetainedValue()
//        return sampleOut;
//    }

}

public typealias CoverageTime = (hours:String, minutes:String, seconds:String, milliseconds:String)

class TimeParser: NSObject {
    
    var startFileTime                               = CMTime()
    var seconds:Int                                 = 0
    var clockFormatter                              = CoverTimeFormatter(adjustment:3)
    
    func time(sampleBuffer:CMSampleBufferRef)->Box<CoverageTime> {
        if self.startFileTime.isValid == false {
            self.startFileTime                      = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        }
        
        let currentTime                             = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let recordedTime                            = CMTimeSubtract(currentTime, self.startFileTime);
        self.clockFormatter.time                    = CMTimeGetSeconds(recordedTime)
        return self.clockFormatter.coverageTime()
    }
    
}
