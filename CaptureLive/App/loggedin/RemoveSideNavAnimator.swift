//
//  RemoveSideNavSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/24/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class RemoveSideNavAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let toVC              = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toVCView          = toVC.view
        guard let sideVC = context.viewControllerForKey(UITransitionContextFromViewControllerKey)! as? SideNavViewController else {
            fatalError("SideNavViewController : Not ment for SideNav animation. fix your segue")
        }
        guard let sideVCView = sideVC.view as? SideNavView else {
            fatalError("SideNavView : Not ment for SideNav animation. fix your segue")
        }

        let b                   = context.containerView()!.bounds
        let screenWidth         = b.size.width
        let screenHeight        = b.size.height
        let leftoverY           = screenWidth * 0.72

        sideVCView.blackBackgroundView?.alpha = 0.72

        sideVCView.frame        = b
        toVCView.frame          = CGRectMake(0, 0, screenWidth, screenHeight)
        context.containerView()!.insertSubview(toVCView, atIndex: 0)
        context.containerView()!.insertSubview(sideVCView, aboveSubview: toVCView)
        toVCView.layoutSubviews()
        
        sideVCView.bkImageView?.hidden = true
        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            sideVCView.frame    = CGRectMake(-leftoverY, 0, screenWidth, screenHeight)
            toVCView.frame      = b
            sideVCView.blackBackgroundView?.alpha  = 0
            
        }) { [unowned self] (Finished:Bool) -> Void in
            self.navAnimatorDelegate?.enable()
//            if context.transitionWasCancelled() {
//                sideVCView.bkImageView?.hidden = false
//            } else {
//                sideVCView.bkImageView?.image = nil
//            }
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}
