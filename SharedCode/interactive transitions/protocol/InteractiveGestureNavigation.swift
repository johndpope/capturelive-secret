//
//  InteractiveGestureNavigation.swift
//  NavTest
//
//  Created by Scott Jones on 1/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

public protocol CYNavigationPop {
    func performSeguePop()
    var popAnimator:UIViewControllerAnimatedTransitioning? { get }
}

extension CYNavigationPop where Self : UIViewController {
    public func performSeguePop() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    var popAnimator:UIViewControllerAnimatedTransitioning? { return nil }
}

public typealias SeguePush = ()->()
public protocol CYNavigationPush {
    var seguePush:SeguePush { get }
    func performSeguePush()
    var pushAnimator:UIViewControllerAnimatedTransitioning? { get }
}

extension CYNavigationPush where Self : UIViewController {
    public var seguePush:SeguePush {
        return {
            self.performSegueWithIdentifier("viewControllerPush", sender: self)
        }
    }
    public func performSeguePush() {
        seguePush()
    }
    public var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

public protocol NavigationAnimatable:class, UINavigationControllerDelegate {
    var navigationController:UINavigationController { get set }
    var interactionController:UIPercentDrivenInteractiveTransition? { get set }
    var isPopping :Bool { get set }
    func animator(animationControllerForOperation operation: UINavigationControllerOperation,fromViewController fromVC: UIViewController,toViewController toVC: UIViewController)->UIViewControllerAnimatedTransitioning?
}

extension NavigationAnimatable {
    
    func addToNavigationView() {
        weak var weakSelf                       = self
        self.navigationController.delegate      = weakSelf
    }
    
    public func enable() {
        self.navigationController.view.userInteractionEnabled = true
    }
    
    public func disable() {
        self.navigationController.view.userInteractionEnabled = false
    }
    
    //MARK: Connect Animators
    public func animator(animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController)->UIViewControllerAnimatedTransitioning? {
        if operation == .Pop {
            return animatorForPop(fromVC)
        } else {
            return animatorForPush(fromVC)
        }
    }
    
    func animatorForPop(fromVC:UIViewController)->UIViewControllerAnimatedTransitioning? {
        guard let poper = fromVC as? CYNavigationPop else {
            print("View controller does not conform to CYNavigationPop protocol")
            return nil
        }
        let animator                = poper.popAnimator
        if var gAnimator = animator as? NavigationAnimatorIgnorable {
            gAnimator.navAnimatorDelegate  = self
        }
        return animator
    }
    
    func animatorForPush(fromVC:UIViewController)->UIViewControllerAnimatedTransitioning? {
        guard let pusher = fromVC as? CYNavigationPush else {
            print("View controller does not conform to CYNavigationPush protocol")
            return nil
        }
        let animator                = pusher.pushAnimator
        if var gAnimator = animator as? NavigationAnimatorIgnorable {
            gAnimator.navAnimatorDelegate  = self
        }
        return animator
    }
    
    //MARK: Connect To NavigationStack
    func popViewController() {
        guard let vc = self.navigationController.viewControllers.last, let currentVC = vc as? CYNavigationPop else {
            print("View controller does not conform to CYNavigationPop protocol")
            return
        }
        isPopping                   = true
        currentVC.performSeguePop()
    }
    
    func pushViewController() {
        guard let vc = self.navigationController.viewControllers.last, let currentVC = vc as? CYNavigationPush else {
            print("View controller does not conform to CYNavigationPush protocol")
            return
        }
        isPopping                   = false
        currentVC.performSeguePush()
    }
    
}

public protocol NavGestureProtocol:class {
    var navigationAnimatable:NavigationAnimatable { get set }
    var gestureRecognizer:UIGestureRecognizer { get }
    func gestureFired(recognizer:UIPanGestureRecognizer)
    func beginInteractiveTransition(recognizer:UIPanGestureRecognizer)
    func updateInteractiveTransition(recognizer:UIPanGestureRecognizer)
    func endInteractiveTransition(recognizer:UIPanGestureRecognizer)
    func denyGestures()
    func acceptGestures()
    func untie()
}
extension NavGestureProtocol {
    
    func handleFiredGesture(recognizer:UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            self.beginInteractiveTransition(recognizer)
        } else if recognizer.state == .Changed {
            self.updateInteractiveTransition(recognizer)
        } else if recognizer.state == .Ended {
            self.endInteractiveTransition(recognizer)
        }
    }
    
    public func untie() {
        self.gestureRecognizer.delegate = nil
        self.gestureRecognizer.removeTarget(nil, action:nil)
        self.gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }
    
}