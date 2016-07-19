//
//  CMLiveStreamViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

import AVFoundation
import AssetsLibrary

@objc class LiveStreamViewController: UIViewController, UIGestureRecognizerDelegate, CMLiveStreamEngineDelegate {
    
    var theView:LiveStreamView{
        return self.view as! LiveStreamView
    }
    
    let config                                      = CMRTSPConnectionModel()
    var liveStreamEngine                            = CMLiveStreamEngine()
    var videoView:CMVideoView!
    
    var fileLocalDirectory:String!
    var filePath:String!
    var backgroundTask:UIBackgroundTaskIdentifier?
    
    var triggerRecord:UITapGestureRecognizer!
    var tapped:Bool = false
    var triggerSaving:UITapGestureRecognizer!
    
    private var camera:CMVideoRecorder!
    private var audioRecorder:CMAudioRecorder!
   
    let messageArray = [
        "OMFG. LOOK AT THIS MESSAGE EVEN\nIT IS TOO LINEZ"
        ,"That's exactly the kind of revisionist claptrap I'd expect from a closet PFJ apologist"
        ,"It's important to remember that these groups represent two very different ideologies and that cohabitation or cooperation wasn't tangible in the long run. While they both strived for the total deconstruction of the imperialist Roman state and all its power structures, they vastly differed in their opinions on what the Romans really did for them. You could say that the PFJ was much more aware of the positive effects the Romans had on the Judean region. Don't be mistaken though, the truly hated the Romans. I mean, they didn't just hate them like everyone else, they hated them a lot. So despite their recognition of Roman improvements, they were still actively sabotaging the Roman government."
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let eventModel = EventApplicationModel(
            urlHash                : "barf"
            ,titleString            : "Burning MAN 2016 Opening Ceremony"
            ,organizationNameString : "The Huffington Post"
            ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
            ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
            ,exactAddressString     : "2415 Pershing Square St\nBlack Rock County, NV 53598"
            ,startDateString        : NSDate().hoursFromNow(11).timeTilString()
            ,displayExpired         : false
            ,contractStatus         : .ACQUIRED
            ,paymentAmountFloat     : 100.00
            ,publicUrl              : "capturelive.com/39uklsg"
            ,titlesAndData          : [
                TitleAndData(titleString:EventApplicationModel.eventTitle,         dataString:"Burning MAN 2016 Opening Ceremony")
                ,TitleAndData(titleString:EventApplicationModel.startTitle,         dataString:NSDate().hoursFromNow(11).timeTilString())
                ,TitleAndData(titleString:EventApplicationModel.addressTitle,       dataString:"2415 Pershing Square St\nBlack Rock County, NV 53598")
                ,TitleAndData(titleString:EventApplicationModel.detailsTitle,       dataString:"We are looking for something and if you can do that then we would want it and be sure to film this is dummy co.")
            ]
        )
        let hiredModel = EventHiredModel(
            eventModel              : eventModel
            ,publisherNameString    :"Larry Storch"
            ,publisherAvatarString  :"https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        )
        
        view.autoresizesSubviews                        = true
        
        filePath                                        = "VIEW SON"
        fileLocalDirectory                              = "\(NSFileManager.documents)/\(filePath)"
        NSFileManager.defaultManager().createDirectoryInDirectory(NSFileManager.documents, path: filePath)
        NSFileManager.defaultManager().deleteAllInDirectory(self.fileLocalDirectory)
        
        config.host                                     = "54.167.38.119"   // mobile wowza
        //        self.config.host                                    = "192.168.94.77"   // local wowza
        config.userName                                 = "publisher"
        //        self.config.password                                = "Merbull99"
        config.password                                 = "password"
        config.port                                     = 1935
        config.application                              = "capture"
        config.name                                     = "sample.mp4"
        config.url                                      = "/\(config.application)/\(config.name)"
        
        theView.didLoad()
        theView.populate(hiredModel)
        
        camera                                         = CMVideoRecorder()
        audioRecorder                                  = CMAudioRecorder()
        videoView                                      = CMVideoView(previewLayer:camera.previewLayer)
        theView.addCMVideoView(videoView)
        
        liveStreamEngine.startUp(
            camera,
            audioRecorder:audioRecorder,
            connectionModel:config,
            directoryPath:fileLocalDirectory
        )
        
        liveStreamEngine.delegate                      = self
        
        triggerSaving                                  = UITapGestureRecognizer(target: self, action:#selector(showMessage))
        triggerSaving.numberOfTouchesRequired          = 1
        triggerSaving.delegate                         = self
        theView.addGestureRecognizer(triggerSaving)
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
    
    func setLowBitrate(sender:UIButton) {
        self.liveStreamEngine.setBitrate(.Low)
    }
    
    func setMediumBitrate(sender:UIButton) {
        self.liveStreamEngine.setBitrate(.Medium)
    }
    
    func setNormalBitrate(sender:UIButton) {
        self.liveStreamEngine.setBitrate(.Normal)
    }
    
    func setAutoBitrate(sender:UIButton) {
        self.liveStreamEngine.setBitrateAutomatic()
        self.theView.autoButton?.selected = true
    }
    
    func bitrateChanged(bitrate:Int) {
//        self.theView.deselectButtons()
        let bitNum                                          = CMBitrate(rawValue: bitrate)!
        switch bitNum {
        case .Medium:
            theView.showMediumNetwork()
//            self.theView.mediumButton?.selected             = true
        case .Normal:
            theView.showGoodNetwork()
//            self.theView.normalButton?.selected             = true
        case .Low:
            theView.showBadNetwork()
//            self.theView.lowButton?.selected                = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let nc                                              = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(willEnterBackground), name:UIApplicationWillResignActiveNotification, object:nil)
        nc.addObserver(self, selector:#selector(willEnterForeground), name:UIApplicationDidBecomeActiveNotification, object:nil)
        theView.stopButton?.addTarget(self, action: #selector(exit), forControlEvents: .TouchUpInside)
        liveStreamEngine.startStreaming()
        theView.onConnected()
        addButtonHandlers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let nc                                              = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: UIApplicationWillResignActiveNotification, object:nil)
        nc.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object:nil)
        theView.stopButton?.removeTarget(self, action: #selector(exit), forControlEvents: .TouchUpInside)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeButtonHandlers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        UIView.setAnimationsEnabled(false)
        if theView.isRecording == false {
           theView.transitionToCameraView()
           theView.stopActivityIndicator()
           liveStreamEngine.startRecording()
        }
        liveStreamEngine.setOrientation()
        theView.setOrientation()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
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
        self.theView.lowButton?.addTarget(self,     action: #selector(setLowBitrate(_:)),     forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.mediumButton?.addTarget(self,  action: #selector(setMediumBitrate(_:)),  forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.normalButton?.addTarget(self,  action: #selector(setNormalBitrate(_:)),  forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.autoButton?.addTarget(self,    action: #selector(setAutoBitrate(_:)),    forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    private func removeButtonHandlers() {
        self.theView.lowButton?.removeTarget(self,     action: #selector(setLowBitrate(_:)),     forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.mediumButton?.removeTarget(self,  action: #selector(setMediumBitrate(_:)),  forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.normalButton?.removeTarget(self,  action: #selector(setNormalBitrate(_:)),  forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.autoButton?.removeTarget(self,    action: #selector(setAutoBitrate(_:)),    forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    // MARK: buttonhandler
    func saveUI() {
        let sb = liveStreamEngine.lastVideoSampleBuffer
        UIImage.imageFromSampleBuffer(sb) { (image:UIImage?) -> () in
            if let img = image {
                self.theView.freezOnFrame(img)
            }
        }
        shutDown()
        
        self.theView.transitionToSavingFiles()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.exit()
        }
    }
    
    func shutDown() {
        liveStreamEngine.finishStreamAndSaveFile()
    }
    
    func exit() {
        self.removeButtonHandlers()
        self.theView.transitionToSavingFiles()
        let sb = self.liveStreamEngine.lastVideoSampleBuffer
        UIImage.imageFromSampleBuffer(sb) { [unowned self] image in
            if let img = image {
                self.theView.freezOnFrame(img)
            }
            self.liveStreamEngine.finishStreamAndSaveFile()
        }
    }
   
    func showMessage() {
        let randomIndex = Int(arc4random_uniform(UInt32(messageArray.count)))
        theView.onActionStreamMessage(messageArray[randomIndex])
    }
    
    // MARK: CMLiveStreamEngineDelegate
    func onFramerate(framerate: Int) {
//        self.theView.wowzaFrames?.text = "framerate : \(framerate)"
    }
    
    func connection(status:Int) {
        
    }
    
    func recordingHasClosed() {
        self.destroyLiveStreamEngine()
        let delayTime                                       = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
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
        let alertController = UIAlertController(title: "HD FILE ERROR", message:
            "SWOMTHING BROKE EVEN!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateTime(time:AnyObject) {
        let t                   = time as! Box<CoverageTime>
        self.theView.updateTime(t.unbox)
    }
    
    // MARK: InteruptionHandlers
    func willEnterBackground() {
        backgroundTask                                      = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            
        });
        liveStreamEngine.pauseStreaming()
    }
    
    func willEnterForeground() {
        if let bt = self.backgroundTask {
            if bt != UIBackgroundTaskInvalid {
                UIApplication.sharedApplication().endBackgroundTask(bt)
                self.backgroundTask                         = UIBackgroundTaskInvalid;
            }
            liveStreamEngine.resumeStreaming()
        }
    }
    
}
