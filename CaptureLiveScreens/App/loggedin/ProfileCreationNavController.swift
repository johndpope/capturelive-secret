//
//  ProfileCreationNavController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI
import CaptureModel

public struct ProfileTableCellInfo {
    let title:String
    let type:ProfileTableCellType
    let roundButtons:[RoundButtonDecoratable]
}

public protocol CreateProfileNavControllable {
    func addProfile(info:ProfileTableCellInfo)
    func addExperience(info:ProfileTableCellInfo)
    func addWork(info:ProfileTableCellInfo)
    func addPhotoExtras(info:ProfileTableCellInfo)
    func addPermissions(info:ProfileTableCellInfo)
}

public protocol CreateProfileNavControllerChild:class {
    var navContainer:ProfileCreationNavController { get }
}

extension CreateProfileNavControllerChild where Self: UIViewController {
    var navContainer:ProfileCreationNavController {
        guard let nav = self.navigationController as? ProfileCreationNavController else {
            fatalError("Whoops, not a ProfileCreationNavController")
        }
        return nav
    }
}

public class ProfileCreationNavController: UINavigationController {
 
    var navAnimationManager:NavigationAnimatable!
    var createProfileDelegate:CreateProfileNavControllable?
    var onlyUpdate = false
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        navAnimationManager            = NavigationStackAnimator(nav:self)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let vc = viewControllers.first else { return }
        vc.viewWillAppear(animated)
        
//        guard let welcomeVC = fetchViewController(WelcomeViewController.self) as? WelcomeViewController else {
//            return
//        }
//        welcomeVC.viewWillAppear(false)
    }
    
    public func pushExperience(profile:ProfileTableCellInfo) {
        guard let profileVC = fetchViewController(WelcomeViewController.self) as? WelcomeViewController else {
            return
        }
        createProfileDelegate?.addProfile(profile)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            profileVC.pushToExperience()
        }
    }
    
    public func popToExperience() {
        guard let experienceVC = fetchViewController(ExperienceViewController.self) as? ExperienceViewController else {
            return
        }
        self.popToViewController(experienceVC, animated: true)
    }

    public func pushWork(experience:ProfileTableCellInfo) {
        guard let experienceVC = fetchViewController(ExperienceViewController.self) as? ExperienceViewController else {
            return
        }
        createProfileDelegate?.addExperience(experience)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            experienceVC.pushToWork()
        }
    }
    
    public func popToWork() {
        guard let workVC = fetchViewController(WorkViewController.self) as? WorkViewController else {
            return
        }
        self.popToViewController(workVC, animated: true)
    }
    
    public func pushPhotoExtras(work:ProfileTableCellInfo) {
        guard let workVC = fetchViewController(WorkViewController.self) as? WorkViewController else {
            return
        }
        createProfileDelegate?.addWork(work)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            workVC.pushToPhotoExtras()
        }
    }

    public func popToPhotoExtras() {
        guard let photoExtrasVC = fetchViewController(PhotoExtrasViewController.self) as? PhotoExtrasViewController else {
            return
        }
        self.popToViewController(photoExtrasVC, animated: true)
    }

    public func pushPermissions(photoExtras:ProfileTableCellInfo) {
        guard let photoExtrasVC = fetchViewController(PhotoExtrasViewController.self) as? PhotoExtrasViewController else {
            return
        }
        createProfileDelegate?.addPhotoExtras(photoExtras)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            photoExtrasVC.pushToPermissions()
        }
    }

    private func fetchViewController(aclass:AnyClass)->UIViewController? {
        return viewControllers.findFirstOccurence { $0.self.isKindOfClass(aclass) }
    }
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
