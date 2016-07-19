//
//  ModalCanceledViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

class ModalCancelledViewController: UIViewController, RemoteAndLocallyServiceable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    private var observer:ManagedObjectObserver?
    
    var theView:ModalCancelledView {
        guard let v = self.view as? ModalCancelledView else { fatalError("Not a ModalCancelledView!") }
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
            guard let e = notification.eventSource else { fatalError("Notification has no event") }
            event           = e
            guard let c = notification.contractSource else { fatalError("Notification has no contract") }
            contract        = c
        }
    }
    var event:Event!
    var contract:Contract!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
        self.theView.populate(event:event.viewModel())
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
        guard let _ = notification.readAt else { return }
        killAndPopOut()
    }
    
    func killAndPopOut() {
        observer                        = nil
        if let nc = self.navigationController {
            nc.popViewControllerAnimated(true)
        } else {
            performSegueWithIdentifier("unwindFromCancelledModal", sender: self)
        }
    }
    
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.dismissButton?.addTarget(self, action: #selector(exitAlertModal), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.dismissButton?.removeTarget(self, action: #selector(exitAlertModal), forControlEvents: .TouchUpInside)
    }
 

    //MARK: Button handlers
    func exitAlertModal() {
        managedObjectContext.performChanges { [unowned self] in
            self.contract.markAllNotificationsAsRead()
            self.event.markAllNotificationsAsRead()
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }
        if let _ = notification.readAt {
            killAndPopOut()
        }
    }
    
}
