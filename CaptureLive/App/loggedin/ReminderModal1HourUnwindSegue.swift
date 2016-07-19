//
//  ReminderModalSegue.swift
//  Current
//
//  Created by Scott Jones on 3/31/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import Foundation

class ReminderModal1HourUnwindSegue: UIStoryboardSegue {
    
    override func perform() {
        let modalHiredVC                    = self.sourceViewController as! ModalReminder1HourViewController
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