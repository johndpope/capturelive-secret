//
//  Onboard3ViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync

extension Onboard3ViewController : CYNavigationPush {
    var seguePush:SeguePush {
        return {
            self.performSegueWithIdentifier(SegueIdentifier.ShowOnboard4Screen.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        if activeSegue == .ShowOnboard4Screen {
            return OnboardPushLeftAnimator()
        }
        return nil
    }
}
extension Onboard3ViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return OnboardPopRightAnimator()
    }
}

class Onboard3ViewController : UIViewController, RemoteAndLocallyServiceable, SegueHandlerType {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    enum SegueIdentifier:String {
        case ShowOnboard4Screen = "showOnboard4Screen"
        case SkipOnboarding     = "skipOnboarding"
    }

    
    var theView:OnboardView {
        guard let v = self.view as? OnboardView else { fatalError("Not a \(OnboardView.self)!") }
        return v
    }
    
    let coverViewModel = OnboardCoverViewModel(
        logoNameString:"capturelive_light_logo"
        ,pageNumberInt:0
        ,totalPageNumberInt:4
        ,skipButtonTitleString:NSLocalizedString("Enter your phone number", comment:"OnboardViewModel : page1 : skipButtonTitleString")
    )
    var activeSegue:SegueIdentifier = .ShowOnboard4Screen
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = OnboardViewModel(
            imageNameString:"onboarding_image3"
            ,titleLabelString:NSLocalizedString("No pro equipment necessary", comment:"OnboardViewModel : page4 : titleLabelString")
            ,bodyLabelString:NSLocalizedString("All jobs are streamed using an\niPhone or an Android device.", comment:"OnboardViewModel : page4 : bodyLabelString")
        )
        
        theView.didLoad()
        theView.setUp(model, coverViewModel: coverViewModel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activeSegue = .ShowOnboard4Screen
        addHandlers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        theView.coverView?.pageControl?.currentPage = 2
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    func addHandlers() {
        removeHandlers()
        theView.coverView?.skipButton?.addTarget(self, action: #selector(skipOnboarding), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.coverView?.skipButton?.removeTarget(self, action: #selector(skipOnboarding), forControlEvents: .TouchUpInside)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    //MARK: Button handlers
    func skipOnboarding() {
        activeSegue = .SkipOnboarding
        performSegue(.SkipOnboarding)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }
    
}
