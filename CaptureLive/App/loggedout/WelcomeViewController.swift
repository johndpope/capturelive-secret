//
//  CMWelcomeViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureSync
import CaptureCore

extension CYNavigationPush where Self : WelcomeViewController {
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return PushTopAnimator()
    }
    var seguePush:SeguePush {
        return {
            self.performSegueWithIdentifier(SegueIdentifier.PushToExperience.rawValue, sender: self)
        }
    }
}
class WelcomeViewController: UIViewController, SegueHandlerType, CYNavigationPush, CreateProfileNavControllerChild, RemoteAndLocallyServiceable {
  
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var user:User!
 
    var theView:WelcomeView {
        guard let v = self.view as? WelcomeView else { fatalError("Not a \(WelcomeView.self)!") }
        return v
    }
    
    enum SegueIdentifier:String {
        case PushToExperience                 = "pushToExperienceScreen"
    }
    
    var profile : ProfileTableCellInfo {
        guard let avatar = user.avatar else { fatalError("User has not avatar") }
        return ProfileTableCellInfo(
            title:NSLocalizedString("Your Profile", comment: "ProfileTableViewCell : titleLabel : text")
            ,type:.PROFILE
            ,roundButtons:[
                SocialImageCellViewModel(
                    avatarPath:avatar
                    ,icon:""
                )
            ]
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user                = navContainer.user

        self.theView.didLoad()
        
        theView.addUserName(user.firstNameLastLetter)
        CMImageCache.defaultCache().imageForPath(user.avatar, complete: { [weak self] error, image in
            if error == nil {
                self?.theView.imageView?.image = image
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    func addHandlers() {
        removeHandlers()
        theView.nextButton?.addTarget(self, action: #selector(nextButtonHit), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.nextButton?.removeTarget(self, action: #selector(nextButtonHit), forControlEvents: .TouchUpInside)
    }
    
    func pushToExperience() {
        seguePush()
    }
    
    //MARK: Button handlers
    func nextButtonHit() {
        navContainer.pushExperience(self.profile)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }

}
