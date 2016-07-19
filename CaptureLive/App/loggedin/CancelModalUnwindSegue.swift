//
//  CancelModalUnwindSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/11/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class CancelModalUnwindSegue: UIStoryboardSegue {

    override func perform() {
        let modalCancelVC                   = self.sourceViewController as! ModalCancelledViewController
        let historyList                     = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("JobHistoryViewController") as! JobHistoryViewController

        historyList.managedObjectContext    = modalCancelVC.managedObjectContext
        historyList.remoteService           = modalCancelVC.remoteService
        
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.navigationController.viewControllers = [historyList]
        modalCancelVC.dismissViewControllerAnimated(true) {

        }
    }
    
}
