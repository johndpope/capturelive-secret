//
//  CMEventDetailAcceptedViewController.swift
//  Current
//
//  Created by Scott Jones on 3/15/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

extension GetToJobViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class GetToJobViewController: UIViewController, NavGesturable, RemoteAndLocallyServiceable, SegueHandlerType {

    enum SegueIdentifier:String {
        case ShowInfo                   = "showInfo"
        case ShowPayInfo                = "showPayInfo"
    }
    
    var managedObjectContext:NSManagedObjectContext!
    var remoteService:CaptureLiveRemoteType!
    var mapController:MapController!
    
    private var observer:ManagedObjectObserver?
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
    var contract:Contract! {
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

    var theView:GetToJobView {
        guard let v = self.view as? GetToJobView else { fatalError("Not a GetToJobView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        theView.populate(contract.hiredModel())
        
        guard let user = User.loggedInUser(self.managedObjectContext), let avatar = user.avatar else { fatalError("No logged in user!") }
        let currentLoc                      = CMUserMovementManager.shared.currentLocation
        mapController                       = MapController(mapView: theView.mapView!, currentCoordinate:currentLoc, eventCoordinate:event.locationCoordinate(), avatarPathString:avatar)
        mapController.didLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addEventHandlers()
        navGesturer?.usePushRightPopLeftGestureRecognizer()
        managedObjectContext.performChanges { [unowned self] in
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeEventHandlers()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(locationUpdated), name:CMUserMovementManager.CMLocationUpdated, object:nil)
    
        theView.backButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.navigateToMapsButton?.addTarget(self, action: #selector(navigateToGoogleMaps), forControlEvents:.TouchUpInside)
        
        theView.toggleButtonTop?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobPaysButton?.addTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.jobInfoButtonsModuleView?.infoButton?.addTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.contactButton?.addTarget(self, action: #selector(showContactAlert), forControlEvents:.TouchUpInside)
    }
    
    func removeEventHandlers() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:CMUserMovementManager.CMLocationUpdated, object:nil)
        
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.navigateToMapsButton?.addTarget(self, action: #selector(navigateToGoogleMaps), forControlEvents:.TouchUpInside)

        theView.toggleButtonTop?.removeTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.removeTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobPaysButton?.removeTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.jobInfoButtonsModuleView?.infoButton?.removeTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.contactButton?.removeTarget(self, action: #selector(showContactAlert), forControlEvents:.TouchUpInside)
    }
    
    // MARK: Notification handlers
    func locationUpdated() {
        let currentLoc                      = CMUserMovementManager.shared.currentLocation
        mapController.update(currentLoc)
    }
    
    // MARK: button handlers
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
   
    func showPayInfoModal() {
        performSegue(.ShowPayInfo)
    }
    
    func showInfoModal() {
        performSegue(.ShowInfo)
    }
    
    func toggleModal() {
        theView.togglePublisherInfo()
    }
    
    func toggleJobDetails() {
        theView.toggleJobDetails()
    }
    
    func deleteContractForEvent() {
        if Event.canMarkForDeleteRemoteContractPredicate.evaluateWithObject(event) {
            managedObjectContext.performChanges { [unowned self] in
                self.event.markForNeedsToDeleteRemoteContract()
            }
        } else {
            self.showSpecificAlert("Already deleted. Connect to network to sync...")
        }
    }

    func navigateToGoogleMaps() {
        let travelMode                          = CMUserMovementManager.shared.transportationToGoogleTravelMode()
        let userCoordinate                      = CMUserMovementManager.shared.currentLocation
        CMMKSController.navigateToMapsApp(userCoordinate, endCoordinate: self.event.locationCoordinate(), travelMode: travelMode, address:self.event.exactAddress)
    }

    func showContactAlert() {
        let callPublisher           = NSLocalizedString("CALL JOB MANAGER", comment:"GetToJobViewController : callPublisher : text")
        let textPublisher           = NSLocalizedString("MESSAGE JOB MANAGER", comment:"GetToJobViewController : textPublisher : text")
        let cancel                  = NSLocalizedString("Cancel", comment:"GetToJobViewController : cancelPublisherContact : text")
        let alertViewController     = CMAlertController(title:"")
        let callAction              = CMAlertAction(title:callPublisher, style: .Primary) { [unowned self] ()->Void in
            self.callPublisher()
        }
        let textAction              = CMAlertAction(title:textPublisher, style: .Primary) { [unowned self] ()->Void in
            self.textPublisher()
        }
        let cancelAction            = CMAlertAction(title:cancel, style: .Secondary) {
            
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(textAction)
        alertViewController.addAction(callAction)
        CMAlert.presentViewController(alertViewController)
    }
    
    // MARK: Observers
    func updateEventResponse() {
//        print("Detail : \(event.description)\n")
        if Event.contractIsNilPredicate.evaluateWithObject(self.event) &&
            self.event.needsToDeleteRemoteContract == false {
                self.back()
        }
    }
   
    func updateContractResponse() {
    
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

    
    func showAlert(error:NSError) {
        let alertTitle                          = NSLocalizedString("Uh oh", comment:"GetToJobViewController : Erroralert : title")
        let alertView                           = CMAlertController(title:alertTitle, message:error.localizedDescription)
        let okTitle                             = NSLocalizedString("Ok", comment:"GetToJobViewController : okButton : ok")
        let okAction = CMAlertAction(title:okTitle, style: .Primary) {  () -> () in
        }
        alertView.addAction(okAction)
        CMAlert.presentViewController(alertView)
    }
   
    func showSpecificAlert(reason:String) {
        let alertTitle                          = NSLocalizedString("Uh oh", comment:"GetToJobViewController : alert : title")
        let alertView                           = CMAlertController(title:alertTitle, message:reason)
        let okTitle                             = NSLocalizedString("Ok", comment:"GetToJobViewController : okButton : ok")
        let okAction = CMAlertAction(title:okTitle, style: .Primary) { () -> () in
        }
        alertView.addAction(okAction)
        CMAlert.presentViewController(alertView)
    }
    
    func attemptToCancelContract() {
        let title                   = NSLocalizedString("Are you sure?", comment:"GetToJobViewController : attemptCancel : alertTitle")
        let buttonYesTitle          = NSLocalizedString("Yes", comment:"GetToJobViewController : buttonYesTitle : Yes")
        let buttonNoTitle           = NSLocalizedString("No", comment:"GetToJobViewController : buttonNoTitle : No")
        let alertViewController     = CMAlertController(title:title)
        let okAction                = CMAlertAction(title:buttonYesTitle, style: .Primary) { [unowned self] ()->Void in
            self.deleteContractForEvent()
        }
        let cancelAction            = CMAlertAction(title:buttonNoTitle, style: .Secondary) {
            
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        CMAlert.presentViewController(alertViewController)
    }

    // MARK: Contact publisher
    func callPublisher() {
        guard let number = contract.publisher?.phoneNumber else {
            return
        }
        UIApplication.sharedApplication().dialNumber(number)
    }
    
    func textPublisher() {
        guard let number = contract.publisher?.phoneNumber else {
            return
        }
        UIApplication.sharedApplication().textNumber(number)
    }
}
