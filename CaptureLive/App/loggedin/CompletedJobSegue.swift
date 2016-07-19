//
//  CompletedJobSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class CompletedJobSegue: UIStoryboardSegue {

    override func perform() {
        let completedVC                     = self.destinationViewController as! CompletedJobViewController
        let jobReceiptVC                    = self.sourceViewController as! JobReceiptViewController
        let firstVCView                     = jobReceiptVC.view
        
        let secondVCView                    = completedVC.view
        let screenWidth                     = UIScreen.mainScreen().bounds.size.width
        let screenHeight                    = UIScreen.mainScreen().bounds.size.height
        secondVCView.frame                  = UIScreen.mainScreen().bounds
        firstVCView.frame                   = UIScreen.mainScreen().bounds
        let window                          = UIApplication.sharedApplication().keyWindow
        window?.addSubview(secondVCView)
        window?.insertSubview(firstVCView, aboveSubview:secondVCView)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            firstVCView.frame               = CGRectMake(0, screenHeight, screenWidth, screenHeight)
            
        }) { (Finished) -> Void in
            
            firstVCView.removeFromSuperview()
            secondVCView.removeFromSuperview()

            if let nav = self.sourceViewController.navigationController {
                let completedEventsVC         = UIStoryboard.loggedInStoryBoard.instantiateViewControllerWithIdentifier("JobHistoryViewController") as! JobHistoryViewController
                completedEventsVC.remoteService = jobReceiptVC.remoteService
                completedEventsVC.managedObjectContext = jobReceiptVC.managedObjectContext
                nav.viewControllers         = [completedEventsVC, completedVC]
            }
        }
    }

}
