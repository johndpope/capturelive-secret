//
//  File.swift
//  Current
//
//  Created by Scott Jones on 4/6/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func realVisibleViewController()->UIViewController? {
        let rootViewController                  = self
        if let presentedViewController = rootViewController.presentedViewController {
            if presentedViewController.isKindOfClass(UINavigationController) {
                if let navController = rootViewController.presentedViewController as? UINavigationController {
                    if let lastViewController = navController.viewControllers.last {
                        return lastViewController.realVisibleViewController()
                    }
                }
            }
            if presentedViewController.isKindOfClass(UITabBarController) {
                if let tabController = rootViewController.presentedViewController as? UITabBarController {
                    if let selectedViewController = tabController.selectedViewController {
                        return selectedViewController.realVisibleViewController()
                    }
                }
            }

            if presentedViewController.isKindOfClass(UIAlertController) {
                return nil
            }

            return presentedViewController.realVisibleViewController()
        }
        
        if rootViewController.isKindOfClass(UINavigationController) {
            if let navController = rootViewController as? UINavigationController {
                if let lastViewController = navController.viewControllers.last {
                    return lastViewController.realVisibleViewController()
                }
            }
        }
        
        if rootViewController.isKindOfClass(UITabBarController) {
            if let tabController = rootViewController as? UITabBarController {
                if let selectedViewController = tabController.selectedViewController {
                    return selectedViewController.realVisibleViewController()
                }
            }
        }


        if rootViewController.isKindOfClass(UIAlertController) {
            return nil
        }
    
    return rootViewController
    }

}