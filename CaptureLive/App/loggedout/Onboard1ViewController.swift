//
//  aaskedall@gmail.com jabari.bell@pxlflu.net jasonpmoreland@gmail.com jeff.deitrich@gmail.com matthew.stellato@gmail.swift
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

extension CYNavigationPush where Self : Onboard1ViewController {
    var seguePush:SeguePush {
        return {
            self.performSegueWithIdentifier(SegueIdentifier.ShowOnboard2Screen.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        if activeSegue == .ShowOnboard2Screen {
            return OnboardPushLeftAnimator()
        }
        return nil
    }
}
class Onboard1ViewController : UIViewController, RemoteAndLocallyServiceable, SegueHandlerType, CYNavigationPush {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    enum SegueIdentifier:String {
        case ShowOnboard2Screen = "showOnboard2Screen"
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
    var activeSegue:SegueIdentifier = .ShowOnboard2Screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = OnboardViewModel(
            imageNameString:"onboarding_image1"
            ,titleLabelString:NSLocalizedString("Apply to cover neaby events", comment:"OnboardViewModel : page1 : titleLabelString")
            ,bodyLabelString:NSLocalizedString("Let hiring companies know that you’re\navailable to live stream an event.", comment:"OnboardViewModel : page1 : bodyLabelString")
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
        activeSegue = .ShowOnboard2Screen
        addHandlers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        theView.coverView?.pageControl?.currentPage = 0
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
