//
//  OnboardAnimators.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

public class OnboardPopRightAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let fVC                     = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView                = fVC.view
        let tVC                     = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView                  = tVC.view
        
        guard let fv = fVC.view as? OnboardCoverable, fcoverView = fv.coverView else {
            fatalError("fromView is not a OnboardCoverable")
        }
        guard let tv = tVC.view as? OnboardCoverable, tcoverView = tv.coverView else {
            fatalError("fromView is not a OnboardCoverable")
        }

        tcoverView.hidden           = true
        let b                       = context.containerView()!.bounds
        let screenWidth             = b.size.width
        let screenHeight            = b.size.height
        
        fromView.frame              = b
        toView.frame                = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)
        toView.clipsToBounds        = false
 
        context.containerView()!.addSubview(fromView)
        context.containerView()!.insertSubview(toView, aboveSubview:fromView)
        context.containerView()!.addSubview(fcoverView)
        fcoverView.translatesAutoresizingMaskIntoConstraints = true
        fcoverView.frame            = b
        
        toView.layoutIfNeeded()

        tcoverView.translatesAutoresizingMaskIntoConstraints = true
        
        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            toView.frame            = b
            fromView.frame          = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
 
        }) { (Finished:Bool) -> Void in
            self.navAnimatorDelegate?.enable()
            tcoverView.hidden       = false
            tcoverView.frame = b
            toView.addSubview(tcoverView)
            if !context.transitionWasCancelled() {
                fcoverView.removeFromSuperview()
            }
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

public class OnboardPushLeftAnimator: NSObject, UIViewControllerAnimatedTransitioning, NavigationAnimatorIgnorable {
    
    public var navAnimatorDelegate:NavigationAnimatable?
    
    public func transitionDuration(context: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let fVC                     = context.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView                = fVC.view
        let tVC                     = context.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView                  = tVC.view
        
        guard let fv = fVC.view as? OnboardCoverable, fcoverView = fv.coverView else {
            fatalError("fromView is not a OnboardCoverable")
        }
        guard let tv = tVC.view as? OnboardCoverable, tcoverView = tv.coverView else {
            fatalError("fromView is not a OnboardCoverable")
        }
        
        let b                       = UIScreen.mainScreen().bounds
        let screenWidth             = b.size.width
        let screenHeight            = b.size.height
        
        toView.frame                = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
        fromView.frame              = b
        
        context.containerView()!.addSubview(fromView)
        context.containerView()!.insertSubview(toView, aboveSubview:fromView)
        
        context.containerView()!.addSubview(fcoverView)
        fcoverView.translatesAutoresizingMaskIntoConstraints = true
        fcoverView.frame            = b
        
        tcoverView.hidden           = true
        navAnimatorDelegate?.disable()
        UIView.animateWithDuration(self.transitionDuration(context), animations: { () -> Void in
            toView.frame            = b
            fromView.frame          = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)

        }) { (Finished) -> Void in
            self.navAnimatorDelegate?.enable()
            tcoverView.hidden       = false
            fromView.addSubview(fcoverView)
            context.completeTransition(!context.transitionWasCancelled())
        }
    }
    
}

