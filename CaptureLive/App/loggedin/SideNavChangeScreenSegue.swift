//
//  SideNavChangeScreenSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

protocol SideNavStoryBoardable {
    var desiredStoryBoard:String { get }
    var desiredScreen:String { get }
}

protocol SideNavPopable:SegueHandlerType {
    var segue:SegueIdentifier { get }
}

class SideNavChangeScreenSegue: UIStoryboardSegue {
    
    static func sceneNamed(initalVC:String, storyBoard:String)->UIViewController {
        let storyBoard      = UIStoryboard(name: storyBoard, bundle: nil)
        return storyBoard.instantiateViewControllerWithIdentifier(initalVC)
    }
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        guard let uisource = source as? SideNavStoryBoardable else {
            fatalError("source UIViewController not StoryboardScreenable")
        }
        let storyBoard      = UIStoryboard(name:uisource.desiredStoryBoard, bundle:nil)
        super.init(
            identifier      : identifier,
            source          : source,
            destination     : storyBoard.instantiateViewControllerWithIdentifier(uisource.desiredScreen)
        )
    }
    
    override func perform() {
        let toVC                = destinationViewController
        let toVCView            = toVC.view
        guard let sideVC = sourceViewController as? SideNavViewController else {
            return
        }
        guard let nav = sideVC.navigationController else {
            return
        }
        guard let sideVCView = sideVC.view as? SideNavView else {
            return
        }
        
        let b                   = UIScreen.mainScreen().bounds
        let screenWidth         = b.size.width
        let screenHeight        = b.size.height
        let leftoverY           = screenWidth * 0.72
        
        sideVCView.blackBackgroundView?.alpha = 0.72
        
        sideVCView.frame        = b
        toVCView.frame          = CGRectMake(0, 0, screenWidth, screenHeight)
       
        let window = self.sourceViewController.view.window
        window!.insertSubview(toVCView, atIndex: 0)
        window!.insertSubview(sideVCView, aboveSubview: toVCView)
        
        toVCView.layoutSubviews()
        sideVCView.bkImageView?.image = nil
        sideVCView.bkImageView?.hidden = false
        sideVCView.bkImageView?.removeFromSuperview()
        UIView.animateWithDuration(0.3,  animations: { () -> Void in
            sideVCView.frame    = CGRectMake(-leftoverY, 0, screenWidth, screenHeight)
            toVCView.frame      = b
            sideVCView.blackBackgroundView?.alpha  = 0
            
        }) { (Finished:Bool) -> Void in

            nav.viewControllers = [toVC]
            guard let ng = nav.viewControllers.first as? NavGesturable else {
                fatalError("destinationViewController not NavGesturable")
            }
            ng.navGesturer?.usePushLeftPopRightGestureRecognizer()
        }
    }
    
}