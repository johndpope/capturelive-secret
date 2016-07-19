//
//  CMTakeAvatarViewController.swift
//  Capture-Live
//
//  Created by hatebyte on 6/2/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import AVFoundation

class CMTakeAvatarViewController: UIViewController, CMVideoRecorderStillImageDelegate {
    
    // MARK: Properties
    let bounds                                              = UIScreen.mainScreen().bounds
    let camera:CMStillCamera!
    
    @IBOutlet var captureButton:CMPrimaryButton?
    @IBOutlet var cropContainerView:UIView?
    @IBOutlet var activityIndicator:UIActivityIndicatorView?
    @IBOutlet var backButton:UIButton?
    @IBOutlet var navTitleLabel:UILabel?
    @IBOutlet var navTitleView:UIView?
    @IBOutlet var descriptionLabel:UILabel?
    
    var containerHeight:CGFloat!
    var containerWidth:CGFloat!
    var kropView:UIImageView!

    var circleView:CMCircleMaskView!
    
    // MARK: UIViewController Overrides
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.camera                                         = CMStillCamera()
        super.init(nibName: "CMTakeAvatarViewController", bundle: nil)
        
        self.camera.delegate                                = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets           = false
        self.view.autoresizesSubviews                       = true;
        self.view.backgroundColor                           = UIColor.whiteColor();
        
        self.backButton?.setImage(UIImage.iconBackArrowBlack(), forState: UIControlState.Normal)
        
        let editTitle                                       = NSLocalizedString("EDIT PHOTO", comment:"CMTakeAvatarViewController : navigationTitleText")
        self.navTitleLabel?.font                            = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        self.navTitleLabel?.text                            = editTitle
        
        self.captureButton!.setTitle(NSLocalizedString("TAKE", comment:"CMTakeAvatar : captureButton : titleText"), forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.camera.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded();
        
        self.populateCameraPreview()
        self.createKropView()
        self.addCameraControls()
        self.addButtonHandlers()

//        self.setBackButtonArrow()

        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.hidden                      = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.circleView.reveal()
 
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeButtonHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.hidden                      = true
        self.camera.stopRunning()
        self.destroyCameraPreview()
        self.destroyCameraControls()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    // MARK: Add/Remove Handlers
    private func addButtonHandlers() {
        self.captureButton!.addTarget(self, action: #selector(takeImage), forControlEvents: UIControlEvents.TouchUpInside)
        self.backButton!.addTarget(self, action: #selector(pop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    private func removeButtonHandlers() {
        self.captureButton!.removeTarget(self, action: #selector(takeImage), forControlEvents: UIControlEvents.TouchUpInside)
        self.backButton!.removeTarget(self, action: #selector(pop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: Create/Destroy
    private func populateCameraPreview() {
        self.camera.previewLayer.masksToBounds              = true
        self.camera.previewLayer.frame                      = self.cropContainerView!.bounds
        self.cropContainerView!.layer.insertSublayer(self.camera.previewLayer, atIndex:0)
    }
    
    private func destroyCameraPreview() {
        self.camera.previewLayer.removeFromSuperlayer()
    }
    
    func addCameraControls() {

    }
    
    func destroyCameraControls() {

    }
    
    func createKropView() {
        if self.kropView != nil {
            return
        }

        self.cropContainerView!.clipsToBounds                = false;
        self.cropContainerView!.userInteractionEnabled       = false;
       
        self.circleView                                      = CMCircleMaskView(frame:CGRectMake(0, 0, self.cropContainerView!.frame.size.width, self.cropContainerView!.frame.size.height))
        self.circleView.clipsToBounds                        = true
        self.circleView.radius                               = UIScreen.mainScreen().bounds.size.width * 0.848
        self.circleView.alpha                                = 0.78
        self.circleView.reCenter(CGPointMake(self.cropContainerView!.frame.size.width * 0.5, self.cropContainerView!.frame.size.height * 0.5))
        self.cropContainerView!.addSubview(circleView)
    }
    
    private func navigateToEditor() {
        let cropController                                  =  CMCropAvatarViewController(nibName:"CMCropAvatarViewController", bundle: nil)
        self.navigationController?.pushViewController(cropController, animated:false)
    }
    
    // MARK: Button handlers
    func pop(sender:UIButton) {
        self.removeButtonHandlers()
        let avNav                                               = self.navigationController as? CMAvatarNavigationController
        avNav?.dismissCancel()
    }
    
    func takeImage() {
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.hidden                          = false
        self.removeButtonHandlers()
        self.camera.captureStillImage()
    }
    
    func flashChanged() {

    }
    
    func toggleCamera() {
        self.camera.toggleCameraDevice()
    }
    
    // MARK:
    func captureStillImage(error:NSError?, sampleBuffer:CMSampleBufferRef?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let data                                    = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            NSFileManager.defaultManager().saveRawImage(data)
            dispatch_async(dispatch_get_main_queue(), {
                self.navigateToEditor()
            })
        })
    }
    
}