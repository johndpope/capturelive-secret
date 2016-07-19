//
//  ReminderModal24HoursUnwindSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/7/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class ReminderModal24HoursUnwindSegue: UIStoryboardSegue {

    override func perform() {
        let modalHiredVC                    = self.sourceViewController as! ModalReminder24HoursViewController
        let eventsList                      = self.destinationViewController as! EventsListViewController
        guard let contract = modalHiredVC.contract else {
            fatalError("The hired modal doesnt have a contract")
        }
        
        let event                           = contract.event
        var jobScreen:UIViewController!
        if event.startTime.hasPassed() {
            let onJobScreen                 = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("OnTheJobViewController") as! OnTheJobViewController
            onJobScreen.managedObjectContext = modalHiredVC.managedObjectContext
            onJobScreen.remoteService       = modalHiredVC.remoteService
            onJobScreen.contract            = contract
            onJobScreen.event               = contract.event
            jobScreen                       = onJobScreen
        } else {
            let getToJobScreen              = UIStoryboard(name:"LoggedIn", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
            getToJobScreen.managedObjectContext = modalHiredVC.managedObjectContext
            getToJobScreen.remoteService    = modalHiredVC.remoteService
            getToJobScreen.contract         = contract
            getToJobScreen.event            = contract.event
            jobScreen                       = getToJobScreen
        }
        
        eventsList.managedObjectContext     = modalHiredVC.managedObjectContext
        eventsList.remoteService            = modalHiredVC.remoteService
        
        let appDelegate                     = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.navigationController.viewControllers = [eventsList, jobScreen]
        modalHiredVC.dismissViewControllerAnimated(true) {
            eventsList.hiredSelectedNoAnimate()
        }
    }
    
}
