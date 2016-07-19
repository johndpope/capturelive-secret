//
//  HomeNavigationGestureRecognizer.swift
//  Current
//
//  Created by Scott Jones on 1/20/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

public final class GestureNavigatorRecognizer:UIPanGestureRecognizer {
    
    public static func SwipeRightNavigatorRecognizer(navigationAnimatable:NavigationAnimatable)->GestureNavigatorRecognizer {
        return GestureNavigatorRecognizer(navigationAnimatable: navigationAnimatable, direction: SwipeDirection(vertex:.X, magnitude:.Positive))
    }
    public static func SwipeLeftNavigatorRecognizer(navigationAnimatable:NavigationAnimatable)->GestureNavigatorRecognizer {
        return GestureNavigatorRecognizer(navigationAnimatable: navigationAnimatable, direction: SwipeDirection(vertex:.X, magnitude:.Negative))
    }
    public static func SwipeUpNavigatorRecognizer(navigationAnimatable:NavigationAnimatable)->GestureNavigatorRecognizer {
        return GestureNavigatorRecognizer(navigationAnimatable: navigationAnimatable, direction: SwipeDirection(vertex:.Y, magnitude:.Negative))
    }
    public static func SwipeDownNavigatorRecognizer(navigationAnimatable:NavigationAnimatable)->GestureNavigatorRecognizer {
        return GestureNavigatorRecognizer(navigationAnimatable: navigationAnimatable, direction: SwipeDirection(vertex:.Y, magnitude:.Positive))
    }
    
    public var navigationAnimatable:NavigationAnimatable
    public var gestureRecognizer:UIGestureRecognizer { return self }
    
    public var direction:SwipeDirection!
    public init(navigationAnimatable:NavigationAnimatable, direction:SwipeDirection) {
        self.navigationAnimatable   = navigationAnimatable
        self.direction              = direction
        super.init(target:nil, action:nil)
        
        self.addTarget(self, action:#selector(gestureFired(_:)))
        self.delegate               = self
        self.navigationAnimatable.navigationController.view.addGestureRecognizer(self)
    }
    
    deinit {
        untie()
    }
    
    public func denyGestures() {
        self.removeTarget(self, action:#selector(gestureFired(_:)))
    }
    
    public func acceptGestures() {
        self.addTarget(self, action:#selector(gestureFired(_:)))
    }
    
}

extension GestureNavigatorRecognizer : NavGestureProtocol {
    
    public func gestureFired(recognizer:UIPanGestureRecognizer) {
        self.handleFiredGesture(recognizer)
    }
    
    public func beginInteractiveTransition(recognizer:UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        if recognizer != self.gestureRecognizer {
            return
        }
        let velocity = recognizer.velocityInView(view)
        if direction.wrongDirection(velocity) {
            return
        }
        navigationAnimatable.interactionController = UIPercentDrivenInteractiveTransition()
        if direction.pushPlaneBroken(velocity) {
            navigationAnimatable.pushViewController()
        } else {
            navigationAnimatable.popViewController()
        }
    }
    
    public func updateInteractiveTransition(recognizer:UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        guard let ic = navigationAnimatable.interactionController else { return }
        let translation                     = recognizer.translationInView(view)
        let percent = direction.percent(translation, view: view)
        if navigationAnimatable.isPopping {
            if !direction.popPercentBroken(percent) { return }
        } else {
            if !direction.pushPercentBroken(percent) { return }
        }
        let abspercent                      = fabs(percent)
        ic.updateInteractiveTransition(abspercent)
    }
    
    public func endInteractiveTransition(recognizer:UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        let translation                         = recognizer.translationInView(view)
        let percent                             = direction.percent(translation, view: view)
        let abpercent                           = fabs(percent)
        guard let ic = navigationAnimatable.interactionController else { return }
        if navigationAnimatable.isPopping {
            if direction.popPercentBroken(percent) {
                if abpercent > 0.10 {
                    if direction.popPlaneBroken(recognizer.velocityInView(view)) {
                        ic.finishInteractiveTransition()
                        navigationAnimatable.interactionController          = nil
                        return
                    }
                }
            }
        } else {
            if direction.pushPercentBroken(percent) {
                if abpercent > 0.10 {
                    if direction.pushPlaneBroken(recognizer.velocityInView(view)) {
                        ic.finishInteractiveTransition()
                        navigationAnimatable.interactionController          = nil
                        return
                    }
                }
            }
        }
        ic.cancelInteractiveTransition()
        navigationAnimatable.interactionController          = nil
    }
    
}

extension GestureNavigatorRecognizer : UIGestureRecognizerDelegate  {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}