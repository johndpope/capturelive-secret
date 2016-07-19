//
//  NavStackAnimator.swift
//  NavTest
//
//  Created by Scott Jones on 5/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

public final class NavigationStackAnimator:NSObject {
    
    public var navigationController:UINavigationController
    public var interactionController:UIPercentDrivenInteractiveTransition?
    public var isPopping                               = false
    
    public init(nav:UINavigationController) {
        self.navigationController               = nav
        super.init()
        self.addToNavigationView()
    }
    
}

extension NavigationStackAnimator : NavigationAnimatable {
    public func navigationController(navigationController: UINavigationController,
                              animationControllerForOperation operation: UINavigationControllerOperation,
                                                              fromViewController fromVC: UIViewController,
                                                                                 toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.animator(animationControllerForOperation:operation, fromViewController:fromVC, toViewController:toVC)
    }
    
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
}
