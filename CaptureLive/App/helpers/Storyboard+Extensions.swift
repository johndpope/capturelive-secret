//
//  Storyboard+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

extension UIStoryboard {
    
    static var loggedOutStoryBoard:UIStoryboard {
        return UIStoryboard(name:"LoggedOut", bundle:nil)
    }
    
    static var loggedInStoryBoard:UIStoryboard {
        return UIStoryboard(name:"LoggedIn", bundle:nil)
    }
    
    static func onboardViewControllers()->[UIViewController] {
        return [loggedOutStoryBoard.instantiateViewControllerWithIdentifier("Onboard1ViewController")]
    }

    static func loginViewControllers()->[UIViewController] {
        return [
             loggedOutStoryBoard.instantiateViewControllerWithIdentifier("Onboard1ViewController")
            ,loggedOutStoryBoard.instantiateViewControllerWithIdentifier("Onboard2ViewController")
            ,loggedOutStoryBoard.instantiateViewControllerWithIdentifier("Onboard3ViewController")
            ,loggedOutStoryBoard.instantiateViewControllerWithIdentifier("Onboard4ViewController")
            ,loggedOutStoryBoard.instantiateViewControllerWithIdentifier("PhoneLoginViewController")
        ]
    }
   
    static func loggedInViewControllers(managedObjectContext moc:NSManagedObjectContext)->[UIViewController] {
        var vc = [
            loggedInStoryBoard.instantiateViewControllerWithIdentifier("EventsListViewController")
        ]
        if let activeContract = Contract.fetchActiveContract(moc)  {
            let onJobScreen                 = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("OnTheJobViewController") as! OnTheJobViewController
            onJobScreen.contract            = activeContract
            onJobScreen.event               = activeContract.event
            vc.append(onJobScreen)
        }
        return vc
    }

}