//
//  CMFacebookAuthViewController.swift
//  Current
//
//  Created by Scott Jones on 4/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
//import FBSDKCoreKit
//import FBSDKLoginKit

class FacebookAuthViewController: UIViewController, RemoteAndLocallyServiceable, SegueHandlerType, NavGesturable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var attemptingUser:User!

    enum SegueIdentifier:String {
        case CreateProfile             = "pushToCreateProfile"
        case CreateProfileNoAnimate    = "pushToCreateProfileNoAnimate"
    }

    var theView:FacebookAuthView {
        return self.view as! FacebookAuthView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let attemptUser = User.attemptingLoginUser(managedObjectContext) else {
            fatalError("No attempting login user")
        }
        attemptingUser = attemptUser
        self.theView.didLoad()
       
        hasEnoughToGetPastFaceBook(self) { [unowned self] in
            self.performSegue(.CreateProfileNoAnimate)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addHandlers()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        navGesturer?.statusBarStyle     = .LightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeHandlers()
    }
    
    // MARK: ADD/REMOVE handles
    func addHandlers() {
        removeHandlers()
        theView.whyButton?.addTarget(self, action: #selector(showOverlay), forControlEvents: .TouchUpInside)
        theView.revealCloseButton?.addTarget(self, action: #selector(hideOverlay), forControlEvents: .TouchUpInside)
        theView.authButton?.addTarget(self, action: #selector(tryToRequestFacebook), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.whyButton?.removeTarget(self, action: #selector(showOverlay), forControlEvents: .TouchUpInside)
        theView.revealCloseButton?.removeTarget(self, action: #selector(hideOverlay), forControlEvents: .TouchUpInside)
        theView.authButton?.removeTarget(self, action: #selector(tryToRequestFacebook), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? CreateProfileViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }

    
    //MARK: Button Handlers
    func pushToCreateProfile() {
        performSegue(.CreateProfile)
    }
    
   
    // MARK: Button handlers
    func showOverlay() {
        theView.revealOverlay()
    }
    
    func hideOverlay() {
        theView.dismisOverlay()
    }
    
    func tryToRequestFacebook() {
        requestFacebookAuthorization()
//        pushToCreateProfile()
    }

    func showError(error:NSError, callback:Completed?) {
        let alertViewController         = CMAlertController(title:"I can't believe you've done this.", message: error.localizedDescription)
        let whoopsAction                = CMAlertAction(title:"OK", style: .Primary, handler:callback)
        alertViewController.addAction(whoopsAction)
        CMAlert.presentViewController(alertViewController)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
}

extension FacebookAuthViewController : FacebookAuthAble {
    
    func fetchedFacebookUser(faceuser:FacebookUser) {
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.attemptingUser.mapFromFacebook(faceuser)
        }
        self.pushToCreateProfile()
    }
    
    func fetchFacebookUserDidFail(error:NSError) {
        self.showError(error) { [unowned self] in
            self.tryToRequestFacebook()
        }
    }
    
}



