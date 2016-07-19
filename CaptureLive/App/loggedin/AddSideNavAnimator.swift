//
//  AddSideNavAnimator.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/24/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class AddSideNavAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let fromVC              = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromVCView          = fromVC.view
        guard let sideVC = context.viewControllerForKey(UITransitionContextToViewControllerKey)! as? SideNavViewController else {
            fatalError("Not ment for SideNav animation. fix your segue")
        }
        guard let sideVCView = sideVC.view as? SideNavView else {
            fatalError("Not ment for SideNav animation. fix your segue")
        }
        let b                   = context.containerView()!.bounds
        let screenWidth         = b.size.width
        let screenHeight        = b.size.height
        let leftoverY           = screenWidth * 0.72

        context.containerView()!.insertSubview(fromVCView, atIndex: 0)
        context.containerView()!.insertSubview(sideVCView, aboveSubview: fromVCView)
        
        sideVCView.translatesAutoresizingMaskIntoConstraints = true
        fromVCView.translatesAutoresizingMaskIntoConstraints = true
        sideVCView.blackBackgroundView?.frame = CGRectMake(0, 0, screenWidth * 2, screenHeight)
        sideVCView.blackBackgroundView?.alpha = 0

        fromVCView.frame        = b
        sideVCView.frame        = CGRectMake(-leftoverY, 0, screenWidth, screenHeight)
        sideVCView.clipsToBounds = false
 
        navAnimatorDelegate?.disable()
        let image               = fromVCView.makeImage()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            sideVCView.frame    = b
            fromVCView.frame    = CGRectMake(0, 0, screenWidth, screenHeight)
            sideVCView.blackBackgroundView?.alpha  = 0.72
            
        }) { [unowned self] (Finished:Bool) -> Void in
            self.navAnimatorDelegate?.enable()

            if !context.transitionWasCancelled() {
                sideVCView.bkImageView?.image = image
            }
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}