//
//  CMLiveStreamEngine.swift
//  Capture-Live
//
//  Created by hatebyte on 5/4/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol CMLiveStreamEngineDelegate {
    func recordingHasClosed()
    func engine(engine:CMLiveStreamEngine, connectionStatus:StreamConnectionState)
    func fileRecordingError(error:NSError)
    func updateTime(time:AnyObject)
    func connection(status:Int)
    func bitrateChanged(bitrate:Int)
    func onFramerate(framerate:Int)
}

private let BITRATE = "BITRATE"

public class CMLiveStreamEngine: NSObject, CMVideoRecorderRenderDelegate, CMAudioRecoredSampleBufferDelegate, CMAudioRecorderAACAudioDelegate, CMHDFileEncoderErrorDelegate, CMStreamRTSPClientDelegate {
   
    static let IS_IPHONE_6_OR_GREATER = UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().bounds.height >= 667.0
    
    private let engineQueue                             = dispatch_queue_create("com.capturemedia.livestreamengine.queue",      DISPATCH_QUEUE_CONCURRENT);
//    public var lastTime                                  = ""
//    var cutTime:UInt                                     = 0
    private weak var camera:CMVideoRecorder!
    private weak var audioRecorder:CMAudioRecorder!
    private var fileWriter:CMHDFileEncoder?
    private var timeParser:TimeParser?
    private var videoEncoder:AVEncoder?
    private var rtspClient:CMStreamRTSPClient?
    private var fileLocalDirectory:String!
    private var bitrateManager:CMBitrateManager?
    private var connectionModel:CMRTSPConnectionModel!
    private var directoryPath:String!

    public var delegate:CMLiveStreamEngineDelegate!
    public var lastVideoSampleBuffer:CMSampleBuffer?
    public var startTime                                = CMTime()
    
    public static func shouldTryToAccessMediaInputs(handler:((Bool) -> Void)!) {
        CMAudioRecorder.shouldTryToAccessMicrophone { (granted:Bool) -> Void in
            if granted == true {
                CMVideoRecorder.shouldTryToAccessCamera(handler)
            } else {
                handler(false)
            }
        }
    }
    
    public var hasWrittenFile:Bool {
        get {
            if let _ = self.fileWriter {
                return true
            } else {
                return false
            }
        }
    }

    public lazy var previewLayer:AVCaptureVideoPreviewLayer? = {
        if let cam = self.camera {
            return cam.previewLayer
        }
        return nil
    }()
   
    public var hasMeetStreamRequirements:Bool {
        get {
            if let fw = self.fileWriter {
                return fw.isVideoLongerThan(1)
            } else {
                return false
            }
        }
    }

    public func cameraSize()->CGSize {
        if let cam = self.camera {
            return CGSize(width:CGFloat(cam.videoWidth), height:CGFloat(cam.videoHeight))
        }
        return UIScreen.mainScreen().bounds.size
    }
    
    public func startUp(camera:CMVideoRecorder, audioRecorder:CMAudioRecorder, connectionModel:CMRTSPConnectionModel, directoryPath:String) {
        let defaults                                    = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSNumber(longLong: Int64(CMBitrate.Low.rawValue )), forKey:BITRATE)
        defaults.synchronize()
        
        self.connectionModel                            = connectionModel
        self.connectionModel.rstp_audioChannel          = CMAudioRecorder.Channel()
        self.connectionModel.rstp_audioFrequencyIndex   = CMAudioRecorder.FrequencyIndex()
        self.connectionModel.rstp_audioProfile          = CMAudioRecorder.Profile()
        
        self.directoryPath                              = directoryPath
        self.createBitrateManager()
        
        self.camera                                     = camera
        self.camera?.renderDelegate                     = self

        self.audioRecorder                              = audioRecorder
        self.audioRecorder.sampleBufferDelegate         = self
        self.audioRecorder.aacDelegate                  = self
    }
  
    public func reconnect() {
        if let rtsp = self.rtspClient {
            rtsp.reconnect()
        }
    }
    
    public func stopStreaming() {
        self.destroyVideoEncoder()
        self.finishStreamAndSaveFile()
        self.destroyStreamClient()
    }
    
    public func shutDown() {
        self.destroyVideoEncoder()
        self.destroyStreamClient()
        self.destroyBitrateManager()
        self.finishStreamAndSaveFile()
        self.destroyFileWriter()
    }
    
    public func startStreaming() {
        self.createVideoEncoder()
        self.bitrateManager?.onFrameRate                = self.delegate.onFramerate
        if let cam = self.camera {
            cam.startRunning()
        }
    }
    
    public func startRecording() {
        dispatch_barrier_async(self.engineQueue, {
            self.createFileWriter()
            self.timeParser                             = TimeParser()
            if let ar = self.audioRecorder {
                ar.startRecordering()
            }
        });
    }
    
    public func pauseStreaming() {
        if let cam = self.camera {
            cam.stopRunning()
        }
        if let ar = self.audioRecorder {
            ar.stopRecordering()
        }
        if let fw = self.fileWriter {
            fw.stopRecordering()
        }
    }
    
    public func resumeStreaming() {
        if let fw = self.fileWriter {
            fw.startRecordering()
        }
        if let ar = self.audioRecorder {
            ar.startRecordering()
        }
        if let cam = self.camera {
            cam.startRunning()
        }
    }
    
    public func adjustBitrate(bitrate:CMBitrate) {
        self.bitrateManager?.updateFrameRate(bitrate)

        dispatch_barrier_async(self.engineQueue, {
            self.videoEncoder?.shutDown()
            self.videoEncoder                           = self.getVideoEncoder()
            if let ve = self.videoEncoder {
                ve.encodeWithBlock({ (data:[AnyObject]!, pts:Double) -> Int32 in
                    if let rtspCt = self.rtspClient {
                        rtspCt.onVideoData(data, time:pts)
                    }
                    return 0
                    
                    }, onParams: { (data:NSData!) -> Int32 in
                        return 0
                })
            }
        })

        dispatch_async(dispatch_get_main_queue(), {
            self.delegate.bitrateChanged(bitrate.rawValue)
        })
    }
   
    public func adjustBitrateForOldPhones(bitrate:CMBitrate) {
        self.bitrateManager?.updateFrameRate(bitrate)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate.bitrateChanged(bitrate.rawValue)
        })
    }
    
    public func setBitrateAutomatic() {
        self.bitrateManager?.setBitrateAutomatic()
    }
    
    public func setBitrate(bitrate:CMBitrate) {
        self.bitrateManager?.setBitrate(bitrate)
    }
    
    public func finishStreamAndSaveFile() {
        if let fw = self.fileWriter {
            weak var weakSelf               = self
            fw.finishRecording { (path:String) -> () in
                weakSelf?.destroyFileWriter()
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf?.delegate?.recordingHasClosed()
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.delegate?.recordingHasClosed()
            })
        }
        self.destroyStreamClient()
    }
    
    public func setFocusMode(mode:AVCaptureFocusMode) {
        if let cam = self.camera {
            cam.setFocusMode(mode)
        }
    }
    
//    func useTorch:(AVCaptureTorchMode)torchMode() {}
    
//    func useFrontCamera(shouldUseFront:Bool) {}
    
    public func setOrientation() {
        if let cam = self.camera {
            cam.setOrientation()
        }
    }
    
  
    // MARK: AVEncoder
    private func createVideoEncoder() {
        self.videoEncoder                           = self.getVideoEncoder()
        if let ve = self.videoEncoder {
            ve.encodeWithBlock({ (data:[AnyObject]!, pts:Double) -> Int32 in
                if let rtspCt = self.rtspClient {
                    rtspCt.onVideoData(data, time:pts)
                }
                return 0
                
                }, onParams: { (data:NSData!) -> Int32 in
                    self.createStreamClient(data)
                    return 0
            })
        }
    }
    
    private func  destroyVideoEncoder() {
        if let ve = self.videoEncoder {
            ve.shutDown()
        }
        self.videoEncoder                           = nil
    }
    
    private func getVideoEncoder()->AVEncoder {
        let theSize                                 = cameraSize()
        return AVEncoder(forHeight:Int32(theSize.height), andWidth:Int32(theSize.width))
    }
    
    private func createBitrateManager() {
        if self.bitrateManager == nil {
            self.bitrateManager                     = CMBitrateManager(connectionModel: self.connectionModel)
        }
        if CMLiveStreamEngine.IS_IPHONE_6_OR_GREATER {
            self.bitrateManager?.bitrateChanged     = self.adjustBitrate
        } else {
            self.bitrateManager?.bitrateChanged     = self.adjustBitrateForOldPhones
            let defaults                            = NSUserDefaults.standardUserDefaults()
            defaults.setObject(NSNumber(longLong: Int64(CMBitrate.Normal.rawValue )), forKey:BITRATE)
            defaults.synchronize()
        }
    }
    
    private func destroyBitrateManager() {
        if let bm = self.bitrateManager {
            bm.destroy()
            bm.bitrateChanged                       = nil
            self.bitrateManager                     = nil
        }
    }
    

    // MARK: RTSPClient
    private func createStreamClient(data:NSData) {
        self.rtspClient                             = CMStreamRTSPClient.setupListener(data, andConfig:self.connectionModel, andDelegate:self)
    }

    private func destroyStreamClient() {
        if let sc = self.rtspClient {
            sc.shutDown()
        }
        self.rtspClient                             = nil
        self.destroyBitrateManager()
    }

    
    // MARK: CMHDFileWriter
    private func createFileWriter() {
        self.fileWriter                             = getFileWriter()
        if let fw = self.fileWriter {
            fw.errorDelegate                        = self
        }
    }
    
    private func destroyFileWriter() {
        if let fw = self.fileWriter {
            fw.errorDelegate                        = nil
            fw.shutDown()
        }
        self.fileWriter                             = nil
    }
    
    private func getFileWriter()->CMHDFileEncoder {
        let theSize                                 = cameraSize()
        let p                                       = (self.directoryPath as NSString)
        return CMHDFileEncoder(fileName:p.pathComponents.last!, directory:self.directoryPath, size:theSize)
    }
    
    // MARK: CMVideoRecorderDelegate
    func didRenderVideo(sampleBuffer:CMSampleBufferRef) {
        dispatch_sync(self.engineQueue, {
            if self.startTime.isValid == false {
                self.startTime                      = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
            }

            if let encoder = self.videoEncoder {
                encoder.encodeFrame(sampleBuffer)
            }
            
            if let fw = self.fileWriter {
                fw.encodeSampleBuffer(sampleBuffer, isVideo:true)
                if let tp = self.timeParser {
                    let time                                    = tp.time(sampleBuffer)
                    dispatch_async(dispatch_get_main_queue(), {
                        if let d = self.delegate {
                            d.updateTime(time)
                        }
                    });
                }
            }
        })
        self.lastVideoSampleBuffer                  = sampleBuffer
    }

    // MARK: CMAudioRecoredSampleBufferDelegate
    public func didRenderAudioSampleBuffer(sampleBuffer:CMSampleBuffer) {
        dispatch_sync(self.engineQueue, {
            if let fw = self.fileWriter {
                fw.encodeSampleBuffer(sampleBuffer, isVideo:false)
            }
        })
    }
    
    // MARK: CMAudioRecorderAACAudioDelegate
    public func didConvertAACData(data: NSData!, time:Double) {
        dispatch_sync(self.engineQueue, {
            if let rtspCt = self.rtspClient {
                rtspCt.onAudioData(data, time:time)
            }
        })
    }
    
    // MARK: CMHDFileEncoderErrorDelegate
    func hdFileEncoderError(error:NSError) {
        destroyFileWriter()
        dispatch_async(dispatch_get_main_queue(), {
            if let d = self.delegate {
                d.fileRecordingError(error)
            }
        })
    }
    
    // MARK: CMStreamRTSPClientDelegate
    public func rtspClient(client: CMStreamRTSPClient!, status state: StreamConnectionState) {
        dispatch_async(dispatch_get_main_queue(), {
            if let d = self.delegate {
                d.engine(self, connectionStatus: state)
            }
        })
    }
    
    public func connectionLost(client: CMStreamRTSPClient!) {
        dispatch_async(dispatch_get_main_queue(), {
            if let d = self.delegate {
                d.connection(0)
            }
        })
    }
 
    public func connectionRegained(client: CMStreamRTSPClient!) {
        dispatch_async(dispatch_get_main_queue(), {
            if let d = self.delegate {
                d.connection(1)
            }
        })
    }

}
