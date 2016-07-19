//
//  Onboard2ViewController.swift
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

extension CYNavigationPush where Self: Onboard2ViewController {
    var seguePush:SeguePush {
        return {
            self.performSegueWithIdentifier(SegueIdentifier.ShowOnboard3Screen.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        if activeSegue == .ShowOnboard3Screen {
            return OnboardPushLeftAnimator()
        }
        return nil
    }

}
extension CYNavigationPop where Self: Onboard2ViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return OnboardPopRightAnimator()
    }
}

class Onboard2ViewController : UIViewController, RemoteAndLocallyServiceable, SegueHandlerType, CYNavigationPop, CYNavigationPush {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    enum SegueIdentifier:String {
        case ShowOnboard3Screen = "showOnboard3Screen"
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
    var activeSegue:SegueIdentifier = .ShowOnboard3Screen
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = OnboardViewModel(
            imageNameString:"onboarding_image2"
            ,titleLabelString:NSLocalizedString("Get hired by top companies", comment:"OnboardViewModel : page2 : titleLabelString")
            ,bodyLabelString:NSLocalizedString("Get notified when a media company\nhires you for a job.", comment:"OnboardViewModel : page2 : bodyLabelString")
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
        activeSegue = .ShowOnboard3Screen
        addHandlers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        theView.coverView?.pageControl?.currentPage = 1
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
