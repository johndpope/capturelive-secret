//
//  CMLiveStreamViewController.swift
//  Current-Tools
//
//  Created by Scott Jones on 9/9/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers
import CoreData

typealias FinishClosure = ()->()

class LiveStreamViewController: UIViewController, RemoteAndLocallyServiceable {
    
    var theView:LiveStreamView {
        return self.view as! LiveStreamView
    }
    
    let config                                              = CMRTSPConnectionModel()
    var liveStreamEngine                                    = CMLiveStreamEngine()
    var backgroundTask:UIBackgroundTaskIdentifier?
    var tapped:Bool = false
    var videoView:CMVideoView!
    private var camera:CMVideoRecorder!
    private var audioRecorder:CMAudioRecorder!
    private var focusTapRecongnizer:UITapGestureRecognizer!
    private var rotationClosure:FinishClosure?
    private var group:dispatch_group_t!
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var attachment: Attachment!
    var contract: Contract!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets           = false
        self.view.autoresizesSubviews                       = true
        self.view.backgroundColor                           = UIColor.blackColor()
        
        self.theView.didLoad()

        self.theView.populate(contract.hiredModel())
        let connectionModel                                 = contract.connectionModel()
        self.camera                                         = CMVideoRecorder()
        self.audioRecorder                                  = CMAudioRecorder()
        self.videoView                                      = CMVideoView(previewLayer:self.camera.previewLayer)
        self.theView.addCMVideoView(self.videoView)
 
        self.liveStreamEngine.startUp(
            self.camera,
            audioRecorder:self.audioRecorder,
            connectionModel:connectionModel,
            directoryPath:"\(NSFileManager.documents)/\(attachment.directory)")
        
        self.liveStreamEngine.delegate                      = self
        
        self.focusTapRecongnizer                            = UITapGestureRecognizer(target: self, action:#selector(focusTap))
        self.focusTapRecongnizer.cancelsTouchesInView       = true
        self.focusTapRecongnizer.numberOfTouchesRequired    = 1
        self.focusTapRecongnizer.delegate                   = self
        self.view.addGestureRecognizer(self.focusTapRecongnizer)
        
        self.theView.startActivityIndicator()

        self.rotationClosure = {
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                self.leaveDispatchGroup()
            } else {
                self.enterDispatchGroup()
            }
        }
        self.group                                          = dispatch_group_create()
        self.enterDispatchGroup() // for turn landscape
        dispatch_group_notify(self.group, dispatch_get_main_queue()) {
            self.rotationClosure                            = nil
            self.theView.transitionToCameraView()
            self.theView.stopActivityIndicator()
            self.liveStreamEngine.startRecording()
        }
        
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            self.leaveDispatchGroup()
        }
       
        #if MOBILE
            self.theView.intentionalCrashButton?.hidden     = true
            self.theView.intentionalCrashButton?.enabled    = false
        #endif
    }
    
    func leaveDispatchGroup() {
        dispatch_group_leave(self.group);
    }
    
    func enterDispatchGroup() {
        dispatch_group_enter(self.group);
    }
    
    func bitrateChanged(bitrate:Int) {
        let bitNum                                          = CMBitrate(rawValue: bitrate)!
        switch bitNum {
        case .Medium:
            theView.showMediumNetwork()
        case .Normal:
            theView.showGoodNetwork()
        case .Low:
            theView.showBadNetwork()
        }
    }
    
    func acceptStreamMessage(message:NSString) {
        self.theView.onActionStreamMessage(message as String)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        liveStreamEngine.startStreaming()
        theView.onConnected()
        addButtonHandlers()
    }
    
    override func viewWillDisappear(animated:Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        UIView.setAnimationsEnabled(false)
        liveStreamEngine.setOrientation()
        theView.setOrientation()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.rotationClosure?()
        self.setNeedsStatusBarAppearanceUpdate()
        UIView.setAnimationsEnabled(true)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    private func addButtonHandlers() {
        let nc                                              = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(WillResignActive),    name:UIApplicationWillResignActiveNotification,     object:nil)
        nc.addObserver(self, selector:#selector(willEnterForeground),    name:UIApplicationDidBecomeActiveNotification,      object:nil)
//        nc.addObserver(self, selector:Selector("noNetwork"),              name:CMNetworkSettings.NotReachable,                object: nil)
//        nc.addObserver(self, selector:Selector("reDoConnections"),        name:CMNetworkSettings.Changed,                     object: nil)
        
        theView.stopButton?.addTarget(self, action: #selector(exit), forControlEvents: .TouchUpInside)
    }
    
    private func removeButtonHandlers() {
        let nc                                              = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: UIApplicationWillResignActiveNotification,    object:nil)
        nc.removeObserver(self, name: UIApplicationDidBecomeActiveNotification,     object:nil)
//        nc.removeObserver(self, name:CMNetworkSettings.NotReachable,                object: nil)
//        nc.removeObserver(self, name:CMNetworkSettings.Changed,                     object: nil)
    
        theView.stopButton?.removeTarget(self, action: #selector(exit), forControlEvents: .TouchUpInside)
    }
    
    // MARK: buttonhandler
    func exit() {
        removeButtonHandlers()
        theView.transitionToSavingFiles()
        let sb = liveStreamEngine.lastVideoSampleBuffer
        UIImage.imageFromSampleBuffer(sb) { [weak self] image in
            if let img = image {
                self?.theView.freezOnFrame(img)
            }
            self?.liveStreamEngine.finishStreamAndSaveFile()
        }
    }
    
    func startRecording() {
    
    }
    
    func stopRecording() {
        
    }
   
    func focusTap() {
        liveStreamEngine.setFocusMode(AVCaptureFocusMode.AutoFocus)
    }
    
    @IBAction func intentionalCrash() {
        #if MOBILE
            assert(false, "User forced crash detected!!!!")
        #endif
    }
    
    // MARK: InteruptionHandlers
    func WillResignActive() {
        backgroundTask                                      = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            
        });
        self.exit()
    }
    
    func willEnterForeground() {
        if let bt = self.backgroundTask {
            if bt != UIBackgroundTaskInvalid {
                UIApplication.sharedApplication().endBackgroundTask(bt)
                self.backgroundTask                         = UIBackgroundTaskInvalid;
            }

        }
    }
    
}

extension LiveStreamViewController : CMLiveStreamEngineDelegate {

    // MARK: CMLiveStreamEngineDelegate
    func connection(status:Int) {
        
    }
    
    func onFramerate(framerate: Int) {
//        self.theView.wowzaFrames?.text = "framerate : \(framerate)"
    }
    
    func recordingHasClosed() {
        self.destroyLiveStreamEngine()
       
        let directory = "\(NSFileManager.documents)/\(attachment.directory)"
        let files = NSFileManager.defaultManager().contentsOfDirectory(directory)
        self.managedObjectContext.performChangesAndWait {
            self.attachment.completeMedia(directory, files:files)
        }
        
        let endBlock:(String?)->() = { [unowned self] thumbnailPath in
            self.managedObjectContext.performChangesAndWait {
                print("SAVIED LOCAL \(thumbnailPath)")
                self.attachment.localThumbnailPath = thumbnailPath
            }
            self.destroyLiveStreamEngine()
            self.performSegueWithIdentifier("unwindFromStream", sender: self)
        }

        guard let firstFile = files.first else {
            endBlock(nil)
            return
        }
       
        UIImage.saveThumbnailFromMp4("\(directory)/\(firstFile)", withKey:self.attachment.uuid, withComplete: endBlock)
    }
    
    func destroyLiveStreamEngine() {
        if let cam = self.camera {
            cam.shutdown()
        }
        if let ar = self.audioRecorder {
            if ar.isConfigured() {
                ar.stopRecordering()
            }
        }
        self.audioRecorder          = nil
        self.liveStreamEngine.delegate = nil
        self.liveStreamEngine.shutDown()
    }
    
    func engine(engine:CMLiveStreamEngine, connectionStatus:StreamConnectionState) {
        if connectionStatus.rawValue == 1 || connectionStatus.rawValue == 2 || connectionStatus.rawValue == 3  {
            print("connectionStatus : DISCONNECTED")
        } else {
            print("connectionStatus : CONNECTED")
        }
    }
    
    func fileRecordingError(error:NSError) {
        print(error)
    }
    
    func updateTime(time:AnyObject) {
        let t                   = time as! Box<CoverageTime>
        self.theView.updateTime(t.unbox)
    }

}

extension LiveStreamViewController : UIGestureRecognizerDelegate {

}