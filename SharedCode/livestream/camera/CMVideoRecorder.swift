//
//  CMVideoRecorder.swift
//  Capture-Live
//
//  Created by hatebyte on 4/8/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AVFoundation

protocol CMVideoRecorderRenderDelegate {
//   func didRenderAudio(sampleBuffer:CMSampleBufferRef)
   func didRenderVideo(sampleBuffer:CMSampleBufferRef)
}

protocol CMVideoRecorderSettingsDelegate {
   func flashModeDidChange(flashMode:AVCaptureFlashMode)
   func devicePositionDidChange(devicePosition:AVCaptureDevicePosition)
}

enum CameraConfigKey : String {
    case DevicePosition                             = "com.capturemedia.ios.camera.devicecamera.deviceposition"
    case FlashMode                                  = "com.capturemedia.ios.camera.devicecamera.flashmode"
}

public struct CameraConfig {
    var devicePosition:AVCaptureDevicePosition
    var flashMode:AVCaptureFlashMode
    init(devicePosition:AVCaptureDevicePosition, flashMode : AVCaptureFlashMode) {
        self.devicePosition                         = devicePosition
        self.flashMode                              = flashMode
    }
}

public typealias CameraPreset = String
extension CameraPreset {
    
    public func size()->CGSize {
        if #available(iOS 9.0, *) {
            switch self {
            case AVCaptureSessionPresetHigh:
                return CGSizeMake(1280, 720)
            case AVCaptureSessionPresetMedium:
                return CGSizeMake(480, 360)
            case AVCaptureSessionPresetLow:
                return CGSizeMake(192, 144)
            case AVCaptureSessionPreset352x288:
                return CGSizeMake(352, 288)
            case AVCaptureSessionPreset640x480:
                return CGSizeMake(640, 480)
            case AVCaptureSessionPreset1280x720:
                return CGSizeMake(1280, 720)
            case AVCaptureSessionPreset1920x1080:
                return CGSizeMake(1920, 1080)
            case AVCaptureSessionPreset3840x2160:
                return CGSizeMake(3840, 2160)
            case AVCaptureSessionPresetiFrame1280x720:
                return CGSizeMake(1280, 720)
            default:
                return CGSizeMake(-1, -1)
            }
        } else {
            switch self {
            case AVCaptureSessionPresetHigh:
                return CGSizeMake(1280, 720)
            case AVCaptureSessionPresetMedium:
                return CGSizeMake(480, 360)
            case AVCaptureSessionPresetLow:
                return CGSizeMake(192, 144)
            case AVCaptureSessionPreset352x288:
                return CGSizeMake(352, 288)
            case AVCaptureSessionPreset640x480:
                return CGSizeMake(640, 480)
            case AVCaptureSessionPreset1280x720:
                return CGSizeMake(1280, 720)
            case AVCaptureSessionPreset1920x1080:
                return CGSizeMake(1920, 1080)
            case AVCaptureSessionPresetiFrame1280x720:
                return CGSizeMake(1280, 720)
            default:
                return CGSizeMake(-1, -1)
            }
        }
    }
    
}


public class CMVideoRecorder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    let videoQueue                                  = dispatch_queue_create("com.capturemedia.ios.camera.devicecamera.videoqueue", nil )
    let audioQueue                                  = dispatch_queue_create("com.capturemedia.ios.camera.devicecamera.audioqueue", nil )
 
    var cameraSettings:CameraConfig!
    var session:AVCaptureSession!
    public var previewLayer:AVCaptureVideoPreviewLayer!
    var settingsDelegate:CMVideoRecorderSettingsDelegate!
    var renderDelegate:CMVideoRecorderRenderDelegate!
    var videoHeight:Int = Int(UIScreen.mainScreen().bounds.height)
    var videoWidth:Int = Int(UIScreen.mainScreen().bounds.width)

    var videoDevice:AVCaptureDevice!
    var videoDeviceInput:AVCaptureDeviceInput!
    var videoDataOutput:AVCaptureVideoDataOutput!
    var videoConnection:AVCaptureConnection!
 
    var audioDevice:AVCaptureDevice!
    var audioDeviceInput:AVCaptureDeviceInput!
    var audioDataOutput:AVCaptureAudioDataOutput!
    var audioConnection:AVCaptureConnection!

    public static func shouldTryToAccessCamera(handler:((Bool) -> Void)!) {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler:handler)
        case .Restricted:
            handler(false)
        case .Denied:
            handler(false)
        case .Authorized:
            handler(true)
        }
    }
   
    public static func cameraPreset()->CameraPreset {
        let s = AVCaptureSession()
        if CMDevice.isLesserPhone() {
            if s.canSetSessionPreset(AVCaptureSessionPreset640x480) {
                return AVCaptureSessionPreset640x480
            } else if s.canSetSessionPreset(AVCaptureSessionPresetMedium) {
                return AVCaptureSessionPresetMedium
            } else {
                return AVCaptureSessionPresetLow
            }
        } else {
//            if #available(iOS 9.0, *) {
//                if s.canSetSessionPreset(AVCaptureSessionPreset3840x2160) {
//                    return AVCaptureSessionPreset3840x2160
//                }
//            }
//            if s.canSetSessionPreset(AVCaptureSessionPreset1920x1080) {
//                return AVCaptureSessionPreset1920x1080
//            } else
                if s.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                    return AVCaptureSessionPreset1280x720
                } else {
                    return AVCaptureSessionPresetHigh
            }
        }
    }
    
    public init(cameraSettings:CameraConfig) {
        super.init()
        self.cameraSettings                         = cameraSettings
        self.setup()
    }
    
    public override init() {
        super.init()
        self.cameraSettings                         = CameraConfig(devicePosition:AVCaptureDevicePosition.Back, flashMode: AVCaptureFlashMode.Off)
        self.setup()
    }
    
    public func shutdown() {
        self.stopRunning()
        self.previewLayer.removeFromSuperlayer()
        self.removeVideo()
        self.removeAudio()
    }
    
    public func startRunning() {
        self.session?.startRunning()
    }
    
    public func stopRunning() {
        self.session?.stopRunning()
    }
    
    func reconfigure() {
        session.beginConfiguration()
        setup()
        session.commitConfiguration()
    }
    
    public func updateOrientation() {
        session.beginConfiguration()
        setOrientation()
        session.commitConfiguration()
    }
    
    public func setFlashMode(flashMode:AVCaptureFlashMode) {
        if self.videoDevice.isFlashModeSupported(flashMode) {
            do {
                try self.videoDevice.lockForConfiguration()
                self.videoDevice.flashMode        = flashMode
                self.videoDevice.unlockForConfiguration()
                if let sd = self.settingsDelegate {
                    sd.flashModeDidChange(self.videoDevice.flashMode)
                }
            } catch {
                print("The flash mode can't be used : \(flashMode)")
            }
        }
    }
    
    public func setFocusMode(focusMode:AVCaptureFocusMode) {
        if let device = self.videoDevice {
            if device.isFocusModeSupported(focusMode) && (device.focusMode != focusMode) {
                do {
                    try device.lockForConfiguration()
                    device.focusMode = focusMode
                    device.unlockForConfiguration()
//                    if let sd = self.settingsDelegate {
//                    sd.focusModeDidChange!(self.videoDevice.focusMode)
//                    }
                } catch {
                    print("The captureDevice input cannot use thie device passed \(device)")
                }
            }
        }
    }
    
    public func toggleCameraDevice() {
        if self.hasMultipleCameras() {
            let oldInput                            = self.videoDeviceInput
            let currentPosition                     = self.videoDeviceInput.device.position
            var newInput:AVCaptureDeviceInput?
            if currentPosition == AVCaptureDevicePosition.Back {
                do {
                    try newInput = AVCaptureDeviceInput(device:self.subCamera())
                } catch _ { }
            } else if currentPosition == AVCaptureDevicePosition.Front {
                do {
                    try newInput = AVCaptureDeviceInput(device:self.mainCamera())
                } catch _ { }
            } else {
                return
            }
            
            self.session.beginConfiguration()
            self.session.removeInput(oldInput)
            if (session.canAddInput(newInput)) {
                session.addInput(newInput)
                self.videoDeviceInput      = newInput
            }
            self.session.commitConfiguration()
            if let sd = self.settingsDelegate {
                sd.devicePositionDidChange(self.videoDeviceInput.device.position)
            }
        }
    }
    
    public func hasMultipleCameras()->Bool {
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 1
    }
   
    
    func startAudio() {
        self.session.beginConfiguration()
        self.removeAudio()
        self.setUpAudio()
        self.session.commitConfiguration()
    }
    
    public func startVideo() {
        session.beginConfiguration()
        self.removeVideo()
        self.setUpVideo()
        self.setOrientation()
        session.commitConfiguration()
    }
    

    
    private func setup() {
        if let _ = self.session {
        } else {
            self.session = AVCaptureSession()
        }
        self.startVideo()
        self.createPreviewLayer();
    }
   
    private func setUpVideo() {
        self.createCaptureVideoDevice()
        self.createCaptureVideoDeviceInput()
        self.createCaptureVideoDataOutput()
        self.addVideoToSession()
        // do specific configs //////////////////////////////////////////////////////

        self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Cinematic

        self.setFocusMode(AVCaptureFocusMode.AutoFocus)
        /////////////////////////////////////////////////////////////////////////////
    }
    
    private func removeVideo() {
        self.removeVideoFromSession()
        self.removeCaptureVideoDeviceInput()
        self.removeCaptureVideoDataOutput()
    }
    
    private func setUpAudio() {
        self.createCaptureAudioDevice()
        self.createAudioDeviceInput()
        self.createAudioDataOutput()
        self.addAudioToSession()
    }
    
    private func removeAudio() {
        self.removeAudioFromSession()
        self.removeAudioDeviceInput()
        self.removeAudioDataOutput()
    }
    

    

    
    // create previewLayer
    private func createPreviewLayer() {
        self.previewLayer                           = AVCaptureVideoPreviewLayer(session:self.session)
        self.previewLayer.videoGravity              = AVLayerVideoGravityResizeAspectFill
    }
    
    
    // VIDEO ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func addVideoToSession() {
        if self.session.canAddInput(self.videoDeviceInput) {
            self.session.addInput(self.videoDeviceInput)
        }
        if self.session.canAddOutput(self.videoDataOutput) {
            self.session.addOutput(self.videoDataOutput)
        }
        if CMDevice.isLesserPhone() {
            if self.session.canSetSessionPreset(AVCaptureSessionPreset640x480) {
                self.session.sessionPreset = AVCaptureSessionPreset640x480
            } else if self.session.canSetSessionPreset(AVCaptureSessionPresetMedium) {
                self.session.sessionPreset = AVCaptureSessionPresetMedium
            } else {
                self.session.sessionPreset = AVCaptureSessionPresetLow
            }
        } else {
//            if self.session.canSetSessionPreset(AVCaptureSessionPreset1920x1080) {
//                self.session.sessionPreset = AVCaptureSessionPreset1920x1080
//            } else
            if self.session.canSetSessionPreset(AVCaptureSessionPreset1280x720) {
                self.session.sessionPreset = AVCaptureSessionPreset1280x720
            } else {
                self.session.sessionPreset = AVCaptureSessionPresetHigh
            }
        }
        
//        if #available(iOS 9.0, *) {
//            if self.session.canSetSessionPreset(AVCaptureSessionPreset3840x2160) {
//                self.session.sessionPreset = AVCaptureSessionPreset3840x2160
//            }
//        }

        videoConnection                             = self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo)
    }
    
    private func removeVideoFromSession() {
        self.session.removeInput(self.videoDeviceInput)
        self.session.removeOutput(self.videoDataOutput)
    }

    //  MARK: AVaudioDeviceInput
    private func createCaptureVideoDeviceInput() {
        do {
            try self.videoDeviceInput = AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("The captureDevice input cannot use the device passed :  \(self.videoDeviceInput)")
        }
    }
    
    private func removeCaptureVideoDeviceInput() {
        session.removeInput(videoDeviceInput);
        videoDeviceInput                            = nil;
    }
    
    // create AVCaptureVideoDataOutput
    private func createCaptureVideoDataOutput() {
        self.videoDataOutput                        = AVCaptureVideoDataOutput() //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
//        self.videoDataOutput.videoSettings          = [kCVPixelBufferPixelFormatTypeKey:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
//        self.captureDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
    }
    
    //  MARK: AVCaptureVideoDataOutput
    private func removeCaptureVideoDataOutput() {
        session.removeOutput(videoDataOutput);
        videoDataOutput                             = nil;
    }

    private func createCaptureVideoDevice() {
        self.videoDevice                            = self.cameraWithPosition(self.cameraSettings.devicePosition)
    }
    
    // MARK: Camera position
    private func cameraWithPosition(position:AVCaptureDevicePosition)->AVCaptureDevice {
        let devices                                 = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device:AVCaptureDevice in devices as! [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        return self.cameraWithPosition(AVCaptureDevicePosition.Front)
    }
    
    private func subCamera()->AVCaptureDevice {
        return self.cameraWithPosition(AVCaptureDevicePosition.Front)
    }
    
    private func mainCamera()->AVCaptureDevice {
        return self.cameraWithPosition(AVCaptureDevicePosition.Back)
    }

    
    
    // AUDIO //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private func addAudioToSession() {
        if self.session.canAddInput(self.audioDeviceInput) {
            self.session.addInput(self.audioDeviceInput)
        }
        if self.session.canAddOutput(self.audioDataOutput) {
            self.session.addOutput(self.audioDataOutput)
        }
        
        audioConnection                             = self.audioDataOutput.connectionWithMediaType(AVMediaTypeAudio);
    }
    
    private func removeAudioFromSession() {
        self.session.removeInput(self.audioDeviceInput)
        self.session.removeOutput(self.audioDataOutput)
    }

    //  MARK: AVaudioDeviceInput
    private func createAudioDeviceInput() {
        if let audioDevice = self.audioDevice {
            do {
                try self.audioDeviceInput = AVCaptureDeviceInput(device: audioDevice)
            } catch {
                print("The AVCaptureDeviceInput input cannot use thie device passed \(audioDevice)")
            }
        } else {
            print("There is no audio device!")
        }
    }
    
    private func removeAudioDeviceInput() {
        session.removeInput(self.audioDeviceInput);
        audioDeviceInput                            = nil;
    }
    
    // create AVCaptureVideoDataOutput
    private func createAudioDataOutput() {
        self.audioDataOutput                        = AVCaptureAudioDataOutput()
        self.audioDataOutput.setSampleBufferDelegate(self, queue: self.audioQueue)
    }
    
    //  MARK: AVCaptureVideoDataOutput
    private func removeAudioDataOutput() {
        session.removeOutput(self.audioDataOutput);
        audioDataOutput                             = nil;
    }

    
    // MARK: Audio device on phone
    private func createCaptureAudioDevice() {
        let devices                                 = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio) as! [AVCaptureDevice]
        if devices.count > 0 {
            self.audioDevice                        = devices.first
        }
    }
    
    
    // MARK: orientation
    private func deviceOrientationDidChangeNotification()->AVCaptureVideoOrientation {
        let orientation = UIDevice.currentDevice().orientation;
        if orientation == UIDeviceOrientation.LandscapeLeft {
            return AVCaptureVideoOrientation.LandscapeRight;
        } else {
            return AVCaptureVideoOrientation.LandscapeLeft
        }
    }
    
    public func setOrientation() {
        videoConnection.videoOrientation            = deviceOrientationDidChangeNotification()
        updateCameraDimensions();
    }
    
    private func updateCameraDimensions() {
        let actual                                  = videoDataOutput.videoSettings;
        videoHeight                                 = actual["Height"] as! Int
        videoWidth                                  = actual["Width"] as! Int
    }

    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if connection == self.videoConnection {
            self.renderDelegate.didRenderVideo(sampleBuffer)
//        } else {
//            self.renderDelegate.didRenderAudio(sampleBuffer)
        }
    }
}













