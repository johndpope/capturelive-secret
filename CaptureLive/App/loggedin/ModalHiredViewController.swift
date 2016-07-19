//
//  CMModalHiredViewController.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

class ModalHiredViewController : UIViewController, RemoteAndLocallyServiceable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    private var observer:ManagedObjectObserver?
    
    var theView:ModalHiredView {
        guard let v = self.view as? ModalHiredView else { fatalError("Not a ModalHiredView!") }
        return v
    }
   
    var notification:Notification! {
        didSet {
            observer = ManagedObjectObserver(object: notification) { [unowned self] type in
                guard type == .Update else {
                    return
                }
                self.updateResponse()
            }
            guard let c = notification.contractSource else { fatalError("Notification has no Contract") }
            contract        = c
        }
    }
    var contract:Contract!
 
    var hasEventStarted:Bool {
        return contract.event.startTime.hasPassed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.theView.didLoad()

        guard let team      = contract.team else { fatalError("Contract has no team") }
        guard let publisher = contract.publisher else { fatalError("Contract has no publisher") }
       
        let teamModel       = team.viewModel()
        let eventModel      = contract.event.viewModel()
        let publisherModel  = publisher.hiredViewModel()
        
        self.theView.populate(publisher: publisherModel, event: eventModel, team: teamModel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
   
    func updateResponse() {
        guard let _ = notification.readAt else {
            return
        }
        observer                        = nil
        performSegueWithIdentifier("unwindFromHiredModal", sender: self)
    }

    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.viewJobButton?.addTarget(self, action: #selector(exitAlertModal), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.viewJobButton?.removeTarget(self, action: #selector(exitAlertModal), forControlEvents: .TouchUpInside)
    }
   
    
    //MARK: Button handlers
    func exitAlertModal() {
        if let _ = notification.readAt {
            observer                        = nil
            managedObjectContext.performChangesAndWait { [unowned self] in
                if self.hasEventStarted {
                    self.contract.start()
                }
                UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
            }
            performSegueWithIdentifier("unwindFromHiredModal", sender: self)
        } else {
            managedObjectContext.performChanges { [unowned self] in
                self.contract.markNotificationAsRead(.Hired)
                if self.hasEventStarted {
                    self.contract.start()
                }
                UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
            }
        }
    }
    
    
}
