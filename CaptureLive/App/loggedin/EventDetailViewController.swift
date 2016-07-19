//
//  CMEventDetailViewController.swift
//  Current
//
//  Created by Scott Jones on 2/23/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CoreDataHelpers
import CaptureModel
import CaptureCore
import CaptureSync

extension EventDetailViewController : CYNavigationPop  {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class EventDetailViewController: UIViewController, NavGesturable, SegueHandlerType, RemoteAndLocallyServiceable {
  
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    enum SegueIdentifier:String {
        case ShowInfo                   = "showInfo"
        case ShowPayInfo                = "showPayInfo"
    }
    
    var segue:SegueIdentifier!          = .ShowInfo
    private var eventObserver:ManagedObjectObserver?
    var event:Event! {
        didSet {
            eventObserver = ManagedObjectObserver(object: event) { [unowned self] type in
                guard type == .Update else {
                    return
                }
                self.updateEventResponse()
            }
        }
    }
    private var contractObserver:ManagedObjectObserver?
    var contract:Contract? {
        didSet {
            guard let c = contract else { return }
            contractObserver = ManagedObjectObserver(object: c) { [unowned self] type in
                guard type == .Update else {
                    return
                }
                self.updateContractResponse()
            }
        }
    }
 
    var theView:EventDetailView {
        guard let v = self.view as? EventDetailView else { fatalError("Not a EventDetailView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        theView.stopActivityIndicator()

        theView.didLoad()
        theView.populate(event.applicationModel())

        
        switch event.contractStatus {
        case .EXPIRED: break
        case .NONE:
            theView.showUnapplied()
            theView.layoutShort()

        case .APPLIED:
            theView.showApplied()
            theView.layoutShortApplied()

        case .ACQUIRED:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.theView.populate(event.applicationModel())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
        navGesturer?.usePushRightPopLeftGestureRecognizer()
        managedObjectContext.performChanges { [unowned self] in
            self.event.contract?.markNotificationAsRead(.Hired)
            self.event.contract?.markNotificationAsRead(.JobStartsIn24Hours)
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        theView.backButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.unappliedEventModuleView?.applyButton?.addTarget(self, action: #selector(showApplication), forControlEvents:.TouchUpInside)
        theView.unappliedEventModuleView?.jobInfoModuleView?.jobPaysButton?.addTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobInfoModuleView?.jobPaysButton?.addTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.unappliedEventModuleView?.jobInfoModuleView?.infoButton?.addTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobInfoModuleView?.infoButton?.addTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.unappliedEventModuleView?.jobInfoModuleView?.directionsButton?.addTarget(self, action: #selector(navigateToGoogleMaps), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobInfoModuleView?.directionsButton?.addTarget(self, action: #selector(navigateToGoogleMaps), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.closeButton?.addTarget(self, action: #selector(hideApplication), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.submitButton?.addTarget(self, action: #selector(submitApplication), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobDetailsButton?.addTarget(self, action: #selector(toggleShowDetails), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.cancelButton?.addTarget(self, action: #selector(attemptToCancelContract), forControlEvents:.TouchUpInside)
        theView.appliedEventModuleView?.urlButton?.addTarget(self, action: #selector(navigateToEventUrl), forControlEvents:.TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.unappliedEventModuleView?.applyButton?.removeTarget(self, action: #selector(showApplication), forControlEvents:.TouchUpInside)
        theView.unappliedEventModuleView?.jobInfoModuleView?.jobPaysButton?.removeTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobInfoModuleView?.jobPaysButton?.removeTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.unappliedEventModuleView?.jobInfoModuleView?.infoButton?.removeTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobInfoModuleView?.infoButton?.removeTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.unappliedEventModuleView?.jobInfoModuleView?.directionsButton?.removeTarget(self, action: #selector(navigateToGoogleMaps), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobInfoModuleView?.directionsButton?.removeTarget(self, action: #selector(navigateToGoogleMaps), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.closeButton?.removeTarget(self, action: #selector(hideApplication), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.submitButton?.removeTarget(self, action: #selector(submitApplication), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.jobDetailsButton?.removeTarget(self, action: #selector(toggleShowDetails), forControlEvents:.TouchUpInside)
        theView.appliedInfoModuleView?.cancelButton?.removeTarget(self, action: #selector(attemptToCancelContract), forControlEvents:.TouchUpInside)
        theView.appliedEventModuleView?.urlButton?.removeTarget(self, action: #selector(navigateToEventUrl), forControlEvents:.TouchUpInside)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowInfo:
            guard let modal                             = segue.destinationViewController as? EventInfoModalViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            modal.modalInfo = event.modalInfo()
        case .ShowPayInfo:
            guard let modal                             = segue.destinationViewController as? EventInfoModalViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            modal.modalInfo = event.paymentModalInfo()
        }
    }
    
    //MARK: Button handlers
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showPayInfoModal() {
        performSegue(.ShowPayInfo)
    }
    
    func showInfoModal() {
        performSegue(.ShowInfo)
    }
    
    func navigateToGoogleMaps() {
        let travelMode                          = CMUserMovementManager.shared.transportationToGoogleTravelMode()
        let userCoordinate                      = CMUserMovementManager.shared.currentLocation
        CMMKSController.navigateToMapsApp(userCoordinate, endCoordinate: self.event.locationCoordinate(), travelMode: travelMode, address:self.event.exactAddress)
    }
    
    func showApplication() {
        theView.showApplication()
    }
    
    func hideApplication() {
        theView.hideApplication()
    }
    
    func toggleShowDetails() {
        theView.toggleShowDetails(event.contractStatus == .APPLIED)
    }
   
    //MARK: Act on event
    func submitApplication() {
        if Event.canMarkForCreateRemoteContractPredicate.evaluateWithObject(event) {
            managedObjectContext.performChanges { [unowned self] in
                self.event.markForNeedsRemoteContract()
            }
            theView.startProcessing()
            removeEventHandlers()
        } else {
            showSpecificAlert("Already accepted. Connect to network to sync...")
        }
    }
    
    func cancelContractForEvent() {
        removeEventHandlers()
        theView.startActivityIndicator()
        if let c = contract {
            managedObjectContext.performChanges {
                c.resolutionStatus = .UserCanceled
                c.markForNeedsRemoteVerification()
            }
        }
    }

    func navigateToEventUrl() {
        let url : NSURL = NSURL(string:event.publicUrl)!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK:Error
    func showAlert(error:NSError) {
        let alertTitle                          = NSLocalizedString("Uh oh", comment:"CMEventDetailViewController : alert : title")
        let alertView                           = CMAlertController(title:alertTitle, message:error.localizedDescription)
        let okTitle                             = NSLocalizedString("Ok", comment:"CMEventDetailViewController : okButton : ok")
        let okAction = CMAlertAction(title:okTitle, style: .Primary) { () -> () in
        }
        alertView.addAction(okAction)
        CMAlert.presentViewController(alertView)
    }
    
    func showSpecificAlert(reason:String) {
        let alertTitle                          = NSLocalizedString("Uh oh", comment:"CMEventDetailViewController : alert : title")
        let alertView                           = CMAlertController(title:alertTitle, message:reason)
        let okTitle                             = NSLocalizedString("Ok", comment:"CMEventDetailViewController : okButton : ok")
        let okAction = CMAlertAction(title:okTitle, style: .Primary) { () -> () in
        }
        alertView.addAction(okAction)
        CMAlert.presentViewController(alertView)
    }

    func attemptToCancelContract() {
        let title                   = NSLocalizedString("Are you sure you want to cancel?", comment:"CMEventBossView : attemptCancel : alertTitle")
        let buttonYesTitle          = NSLocalizedString("Yes", comment:"CMEventBossView : buttonYesTitle : Yes")
        let buttonNoTitle           = NSLocalizedString("No", comment:"CMEventBossView : buttonNoTitle : No")
        let alertViewController     = CMAlertController(title:title)
        let okAction                = CMAlertAction(title:buttonYesTitle, style: .Primary) { [unowned self] ()->Void in
            self.cancelContractForEvent()
        }
        let cancelAction            = CMAlertAction(title:buttonNoTitle, style: .Secondary) {
            
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        CMAlert.presentViewController(alertViewController)
    }

    // MARK: Observer
    func updateEventResponse() {
        if Event.contractIsNotNilPredicate.evaluateWithObject(self.event) &&
            event.needsToCreateRemoteContract == false {
            contract                = event.contract
            theView.stopProcessing()
            addEventHandlers()

            theView.populate(event.applicationModel())
            theView.revealApplied()
        }
    }
    
    func updateContractResponse() {
        if let c = contract {
            if Contract.notMarkedForRemoteVerificationPredicate.evaluateWithObject(c)
            && Contract.isNotOpenPredicate.evaluateWithObject(c) {
                if c.resolutionStatus == .UserCanceled || c.resolutionStatus == .PublisherCanceled {
                    self.back()
                }
            }
        }
    }

}
