//
//  CMCropAvatarViewController.swift
//  Capture-Live
//
//  Created by hatebyte on 6/2/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

class CMCropAvatarViewController: UIViewController, UINavigationControllerDelegate{
    
    // MARK: Properties
    let bounds:CGRect! = UIScreen.mainScreen().bounds;
    
    @IBOutlet var backButton:UIButton?
    @IBOutlet var cropImageButton:CMPrimaryButton?
    @IBOutlet var cropContainerView:UIView?
    @IBOutlet var activityIndicator:UIActivityIndicatorView?
    
    var containerHeight:CGFloat!
    var containerWidth:CGFloat!
    var editorScrollView:EditorScrollView!
    var map:UIView!
    var combinedImage:UIImage!
    var offset:CGPoint! = CGPointZero
    var zoomScale:CGFloat! = 0
    var kropView:UIImageView!
    
    @IBOutlet var navTitleLabel:UILabel?
    @IBOutlet var navTitleView:UIView?
    @IBOutlet var descriptionLabel:UILabel?
    
    @IBOutlet var textBottom:NSLayoutConstraint?
    @IBOutlet var textHeight:NSLayoutConstraint?
    var circleView:CMCircleMaskView!
    // MARK: UIViewController Overrides
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:"CMCropAvatarViewController", bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
   
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButton?.setImage(UIImage.iconBackArrowBlack(), forState: UIControlState.Normal)
        
        let editTitle                                           = NSLocalizedString("EDIT PHOTO", comment:"CMTakeAvatarViewController : navigationTitleText")
        self.navTitleLabel?.font                                = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        self.navTitleLabel?.text                                = editTitle

        let descriptionText                                     = NSLocalizedString("Drag to move your photo.\nPinch and expand to scale.", comment:"CMTakeAvatarViewController : descriptionText")
        self.descriptionLabel?.font                             = UIFont.sourceSansPro(.Regular, size: .Large)
        self.descriptionLabel?.numberOfLines                    = 0
        self.descriptionLabel?.text                             = descriptionText

        self.view.backgroundColor                               = UIColor.whiteColor()
        self.automaticallyAdjustsScrollViewInsets               = false
        self.view.autoresizesSubviews                           = false
        
        self.cropImageButton!.setTitle(NSLocalizedString("SAVE", comment:"CMCropAvatar : cropImageButton : titleText"), forState: UIControlState.Normal)
        
        let h                                                   = UIScreen.mainScreen().bounds.height
        switch h {
        case 480:
            self.textBottom?.constant                           = -1
            self.textHeight?.constant                           = 40
            self.descriptionLabel?.font                         = UIFont.sourceSansPro(.Regular, size: .Small)
        default:
            self.textBottom?.constant                           = 18
            self.descriptionLabel?.font                         = UIFont.sourceSansPro(.Regular, size: .Large)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addButtonHandlers()
        
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.hidden                          = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded();
        self.containerHeight                                    = self.cropContainerView!.frame.size.height
        self.containerWidth                                     = self.cropContainerView!.frame.size.width
        
        self.createKropView()
        self.createEditorScrollView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeButtonHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.destroyEditorScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    // MARK: Add/Remove Handlers
    private func addButtonHandlers() {
        self.cropImageButton!.addTarget(self, action: #selector(CMCropAvatarViewController.kropImageToFrame), forControlEvents: UIControlEvents.TouchUpInside)
        self.backButton!.addTarget(self, action: #selector(CMCropAvatarViewController.pop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    private func removeButtonHandlers() {
        self.cropImageButton!.removeTarget(self, action: #selector(CMCropAvatarViewController.kropImageToFrame), forControlEvents: UIControlEvents.TouchUpInside)
        self.backButton!.removeTarget(self, action: #selector(CMCropAvatarViewController.pop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: Create/Destroy
    func createKropView() {
        if self.kropView != nil {
            return
        }
        
        self.cropContainerView!.clipsToBounds                   = false;
        self.cropContainerView!.userInteractionEnabled          = false;

        self.circleView                                         = CMCircleMaskView(frame:CGRectMake(0, 0, self.cropContainerView!.frame.size.width, self.cropContainerView!.frame.size.height))
        self.circleView.clipsToBounds                           = true
        self.circleView.radius                                  = UIScreen.mainScreen().bounds.size.width * 0.848
        self.circleView.alpha                                   = 0.78
        self.circleView.reCenter(CGPointMake(self.cropContainerView!.frame.size.width * 0.5, self.cropContainerView!.frame.size.height * 0.5))
        self.cropContainerView!.addSubview(circleView)
        self.circleView.open()
    }
    
    func createEditorScrollView() {
        if self.editorScrollView == nil {
            let height                                          = self.bounds.size.width * 0.848
            let width                                           = self.bounds.size.width * 0.848
            
            let x                                               = (self.containerWidth - CGFloat(width)) * 0.5
            let y                                               = (self.containerHeight - CGFloat(height)) * 0.5
            
            let frame                                           = CGRectMake(x, y, CGFloat(width), CGFloat(height))
            self.editorScrollView                               = EditorScrollView(frame :frame)
            self.editorScrollView.image                         = NSFileManager.defaultManager().getRawImage()
            self.editorScrollView.backgroundColor               = UIColor.clearColor()
            self.editorScrollView.frame                         = frame
            self.view.insertSubview(self.editorScrollView, atIndex:0)
            if (self.zoomScale > 0) {
                self.editorScrollView.zoomScale                 = self.zoomScale;
                self.editorScrollView.contentOffset             = self.offset;
            }
            self.editorScrollView.clipsToBounds                 = false
            self.editorScrollView.frame                         = self.editorScrollView.frame
            self.editorScrollView.center                        = self.cropContainerView!.center
            self.editorScrollView.layoutSubviews()
        }
    }
    
    func destroyEditorScrollView() {
        self.zoomScale                                          = self.editorScrollView.zoomScale
        self.offset                                             = self.editorScrollView.contentOffset
        
        self.combinedImage                                      = nil
        self.editorScrollView.zoomView.image                    = nil
        self.editorScrollView.zoomView                          = nil
        self.editorScrollView.removeFromSuperview()
        self.editorScrollView                                   = nil
    }
    
    func resetKrop() {
        self.destroyEditorScrollView()
        
        self.createKropView()
        self.createEditorScrollView()
    }
    
    private func finish() {
        self.removeButtonHandlers()
        let avNav                                               = self.navigationController as? CMAvatarNavigationController
        avNav?.dismissSuccess()
    }
    
    // MARK: Button handlers
    func pop(sender:UIButton) {
        self.removeButtonHandlers()
        let avNav                                               = self.navigationController as? CMAvatarNavigationController
        avNav?.dismissCancel()
    }
    
    func kropImageToFrame() {
        self.cropContainerView?.addSubview(self.activityIndicator!)
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.hidden                          = false
        
        self.removeButtonHandlers()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            let kroppedImage:UIImage!                           = self.editorScrollView.kroppedImage()
//            let size:CGFloat                                    = 0.4 * self.kropView.image!.size.width
//            let centerSq:UIImage!                               = self.kropView.image!.getCenterSquare(size, alpha:1)
//            let combinedImage:UIImage!                          = centerSq.combineAsTop(kroppedImage, atSize:centerSq.size)
            
            let data                                            = NSData(data:UIImageJPEGRepresentation(kroppedImage, 0.2)!)
            NSFileManager.defaultManager().saveCroppedImage(data)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.finish()
            })
        })
    }
    
    
}