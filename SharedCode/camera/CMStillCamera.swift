//
//  CMStillCamera.swift
//  Capture-Live
//
//  Created by hatebyte on 6/1/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//


import UIKit
import AVFoundation

@objc protocol CMVideoRecorderStillImageDelegate {
    func captureStillImage(error:NSError?, sampleBuffer:CMSampleBufferRef?)
    optional func flashModeDidChange(flashMode:AVCaptureFlashMode)
    optional func devicePositionDidChange(devicePosition:AVCaptureDevicePosition)
}

class CMStillCamera: NSObject {
    
    var cameraSettings:CMStillCameraConfig!
    var captureDevice:AVCaptureDevice!
    var captureDeviceInput:AVCaptureDeviceInput!
    var stillImageOutput:AVCaptureStillImageOutput!
    var session:AVCaptureSession!
    var previewLayer:AVCaptureVideoPreviewLayer!
    
    var delegate:CMVideoRecorderStillImageDelegate!
    
    override init() {
        super.init()
        self.cameraSettings                         = NSUserDefaults.standardUserDefaults().stillCameraSettings()
        self.setup()
    }
    
    func startRunning() {
        self.session?.startRunning()
    }
    
    func stopRunning() {
        self.session?.stopRunning()
    }
    
    func setFlashMode(flashMode:AVCaptureFlashMode) {
        if self.captureDevice.isFlashModeSupported(flashMode) {
            
            do {
                try self.captureDevice.lockForConfiguration()
                self.captureDevice.flashMode        = flashMode
                self.captureDevice.unlockForConfiguration()
                self.delegate.flashModeDidChange?(self.captureDevice.flashMode)
                self.updateCameraSettings()
            } catch {
                
            }

        }
    }
    
    func toggleCameraDevice() {
        if self.hasMultipleCameras() {
            let oldInput                            = self.captureDeviceInput
            let currentPosition                     = self.captureDeviceInput.device.position
            var newInput:AVCaptureDeviceInput?
            if currentPosition == AVCaptureDevicePosition.Back {
                do {
                    try newInput = AVCaptureDeviceInput(device: self.subCamera())
                } catch _ { }
            } else if currentPosition == AVCaptureDevicePosition.Front {
                do {
                    try newInput = AVCaptureDeviceInput(device: self.mainCamera())
                } catch _ { }
            } else {
                return
            }

            
            self.session.beginConfiguration()
            self.session.removeInput(oldInput)
            if (session.canAddInput(newInput)) {
                session.addInput(newInput)
                self.captureDeviceInput             = newInput
            }
            self.session.commitConfiguration()
            self.delegate.devicePositionDidChange?(self.captureDeviceInput.device.position)
            self.updateCameraSettings()
        }
    }
    
    func hasMultipleCameras()->Bool {
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 1
    }
   
    private func updateCameraSettings() {
        self.cameraSettings.flashMode               = self.captureDevice.flashMode
        self.cameraSettings.devicePosition          = self.captureDeviceInput.device.position
        NSUserDefaults.standardUserDefaults().saveStillCameraSettings(self.cameraSettings)
    }
    
    private func setup() {
        self.createCaptureDevice()
        self.createCaptureDeviceInput()
        self.createImageOutput()
        self.createSession()
        self.createPreviewLayer();
    }
    
    // create previewLayer
    func createPreviewLayer() {
        self.previewLayer                           = AVCaptureVideoPreviewLayer(session:self.session)
        self.previewLayer.videoGravity              = AVLayerVideoGravityResizeAspectFill
    }
    
    // create session
    private func createSession() {
        self.session = AVCaptureSession()
        if self.session.canAddInput(self.captureDeviceInput) {
            self.session.addInput(self.captureDeviceInput)
        }
        if self.session.canAddOutput(self.stillImageOutput) {
            self.session.addOutput(self.stillImageOutput)
        }
        self.session.sessionPreset                  = AVCaptureSessionPresetPhoto
    }
    
    // create AVCaptureStillImageOutput
    private func createImageOutput() {
        let outputSettings                          = [AVVideoCodecJPEG: AVVideoCodecKey]
        self.stillImageOutput                       = AVCaptureStillImageOutput()
        self.stillImageOutput.outputSettings        = outputSettings
    }
    
    // create AVCaptureDeviceInput
    private func createCaptureDeviceInput() {
        do {
            try self.captureDeviceInput             = AVCaptureDeviceInput(device:self.captureDevice)
        } catch _ { }
    }
    
    // create AVCaptureDevice
    private func createCaptureDevice() {
        self.captureDevice                          = self.cameraWithPosition(self.cameraSettings.devicePosition)
    }
    
    // Camera position
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
    
    func captureStillImage() {
        var videoConnection:AVCaptureConnection!
        for connection:AVCaptureConnection in self.stillImageOutput!.connections as! [AVCaptureConnection] {
            for port:AVCaptureInputPort in connection.inputPorts as! [AVCaptureInputPort] {
                if port.mediaType == AVMediaTypeVideo {
                    videoConnection                 = connection
                }
            }
            if videoConnection != nil { break; }
        }
        videoConnection.videoOrientation            = AVCaptureVideoOrientation.Portrait
        if self.captureDeviceInput.device.position == AVCaptureDevicePosition.Front {
            videoConnection.videoMirrored           = true
        }
        
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer:CMSampleBufferRef!, error:NSError!) in
            if let d = self.delegate {
                if let _ = error {
                    d.captureStillImage(error, sampleBuffer:nil)
                } else {
                    d.captureStillImage(error, sampleBuffer:sampleBuffer)
                }
            }
        })
    }
    
}













