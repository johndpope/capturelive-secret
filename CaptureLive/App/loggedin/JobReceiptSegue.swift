//
//  JobReceiptSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/21/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobReceiptSegue: UIStoryboardSegue {

    override func perform() {
        let receiptVC                       = self.destinationViewController as! JobReceiptViewController
        let jobVC                           = self.sourceViewController as! OnTheJobViewController
        let firstVCView                     = jobVC.view
        
        let secondVCView                    = receiptVC.view
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
                nav.pushViewController(receiptVC, animated: false)
            }
        }
    }
    
}
