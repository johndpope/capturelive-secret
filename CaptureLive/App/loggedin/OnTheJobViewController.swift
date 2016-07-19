//
//  CMEventBossViewController.swift
//  Current
//
//  Created by Scott Jones on 3/16/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers
import CaptureUI

extension CYNavigationPop where Self : OnTheJobViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class OnTheJobViewController: UIViewController, CYNavigationPop, SegueHandlerType, NavGesturable, RemoteAndLocallyServiceable {
   
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var mapController:MapController!
    var backgroundUploader = CMS3BackgroundUploader.shared
    var uploaderModel: ContractUploadModel! = nil
    
    enum SegueIdentifier:String {
        case ShowCamera                 = "pushStreamRequest"
        case PushToCompletedJobReceipt  = "pushCompletedJobReceipt"
        case ShowInfo                   = "showInfo"
        case ShowPayInfo                = "showPayInfo"
    }
    
    var theView:OnTheJobView {
        guard let v = self.view as? OnTheJobView else { fatalError("Not a OnTheJobView!") }
        return v
    }
   
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
            contractObserver = ManagedObjectObserver(object: contract) { [unowned self] type in
                guard type == .Update else {
                    return
                }
                self.updateContractResponse()
            }
        }
    }
    
    func updateEventResponse() {}
    
    func updateContractResponse() {
        if Contract.notMarkedForRemoteVerificationPredicate.evaluateWithObject(contract)
            && Contract.isNotOpenPredicate.evaluateWithObject(contract) {
            if contract.resolutionStatus == .Completed {
                contractObserver = nil
                theView.showCompletedAlert()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
        
        guard let user = User.loggedInUser(self.managedObjectContext), let avatar = user.avatar else { fatalError("No logged in user!") }
        let currentLoc                      = CMUserMovementManager.shared.currentLocation
        mapController                       = MapController(mapView: theView.mapView!, currentCoordinate:currentLoc, eventCoordinate:event.locationCoordinate(), avatarPathString:avatar)
        mapController.didLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        repopulateView()
        managedObjectContext.performChanges { [unowned self] in
            self.event.contract?.markNotificationAsRead(.Hired)
            self.event.contract?.markNotificationAsRead(.JobStartsIn24Hours)
            self.event.contract?.markNotificationAsRead(.JobStartsIn1Hour)
            self.event.contract?.markNotificationAsRead(.Arrived)
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }

        if contract.hasStartedUpload {
            attemptToAutomaticallyRestartUpload()
        }
    }
   
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            theView.showLandscape()
        } else {
            theView.showPortrait()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
        repopulateView()
        navGesturer?.removeGestureRecognizers()
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
        let nc                      = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(repopulateView), name:UIApplicationDidBecomeActiveNotification, object:nil)
        nc.addObserver(self, selector: #selector(locationUpdated), name:CMUserMovementManager.CMLocationUpdated, object:nil)
        
        theView.backButton?.addTarget(self, action: #selector(backButtonHit), forControlEvents: .TouchUpInside)
        theView.cameraButton?.addTarget(self, action: #selector(startLiveStreamCamera), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.noButton?.addTarget(self, action: #selector(dismissDecision), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.yesButton?.addTarget(self, action: #selector(startUploading), forControlEvents: .TouchUpInside)
        theView.jobCompletedAlertView?.viewJobReceiptButton?.addTarget(self, action: #selector(popToCompleteReceipt), forControlEvents: .TouchUpInside)
        
        theView.toggleButtonTop?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobPaysButton?.addTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.jobInfoButtonsModuleView?.infoButton?.addTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.contactButton?.addTarget(self, action: #selector(showContactAlert), forControlEvents:.TouchUpInside)
    }
    
    func removeEventHandlers() {
        let nc                      = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UIApplicationDidBecomeActiveNotification, object:nil)
        nc.removeObserver(self, name:CMUserMovementManager.CMLocationUpdated, object:nil)
        
        theView.backButton?.removeTarget(self, action: #selector(backButtonHit), forControlEvents: .TouchUpInside)
        theView.cameraButton?.removeTarget(self, action: #selector(startLiveStreamCamera), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.noButton?.removeTarget(self, action: #selector(dismissDecision), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.yesButton?.removeTarget(self, action: #selector(startUploading), forControlEvents: .TouchUpInside)
        theView.jobCompletedAlertView?.viewJobReceiptButton?.removeTarget(self, action: #selector(popToCompleteReceipt), forControlEvents: .TouchUpInside)

        theView.toggleButtonTop?.removeTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.removeTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobPaysButton?.removeTarget(self, action: #selector(showPayInfoModal), forControlEvents:.TouchUpInside)
        theView.jobInfoButtonsModuleView?.infoButton?.removeTarget(self, action: #selector(showInfoModal), forControlEvents:.TouchUpInside)
        theView.contactButton?.removeTarget(self, action: #selector(showContactAlert), forControlEvents:.TouchUpInside)
    }
    
    func repopulateView() {
        theView.populate(contract:contract.onTheJobModel(), hiredModel:contract.hiredModel())
        theView.addAttachments(contract.unUploadedAttachmentCollectionModels.reverse())
    }
   
    
    //MARK: Button handlers
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func backButtonHit() {
        if contract.hasStartedUpload {
            showUploadCancelAlert()
        } else {
            back()
        }
    }
    
    func toggleModal() {
        theView.togglePublisherInfo()
    }
    
    func toggleJobDetails() {
        theView.toggleJobDetails()
    }
  
    func showPayInfoModal() {
        performSegue(.ShowPayInfo)
    }
    
    func showInfoModal() {
        performSegue(.ShowInfo)
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
    
    func startLiveStreamCamera() {
        CMLiveStreamEngine.shouldTryToAccessMediaInputs { [weak self] granted in
            dispatch_async(dispatch_get_main_queue()) {
                if granted == true {
                    self?.performSegue(.ShowCamera)
                }
            }
        }
    }
    
    func dismissDecision() {
        theView.keepFilming()
    }
   
    func startUploading() {
        configureUploader()
        start()
    }
    
    func popToCompleteReceipt() {
        performSegue(.PushToCompletedJobReceipt)
    }
    
    func attemptToAutomaticallyRestartUpload() {
        let title                   = NSLocalizedString("Finish uploading?", comment:"CMUploadingContract : finishUploading : alertTitle")
        let alertViewController     = CMAlertController(title:title)
        
        let cancelTitle             = NSLocalizedString("NO", comment:"CMUploadingContract : finishUploading : cancekTitle")
        let cancelAction = CMAlertAction(title:cancelTitle, style: .Primary) { [unowned self] in
            self.navigationController?.popViewControllerAnimated(true)
        }
        let resumeTitle             = NSLocalizedString("YES", comment:"CMUploadingContract : finishUploading : resumeTitle")
        let resumeAction = CMAlertAction(title:resumeTitle, style: .Primary) { [unowned self] in
            self.startUploading()
        }
        alertViewController.addAction(resumeAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
    
    @IBAction func unwindFromStream(sender:UIStoryboardSegue) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @IBAction func unwindFromHiredModal(sender:UIStoryboardSegue) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    // MARK: Contract Cancelation
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
    
    func cancelContractForEvent() {
        self.removeEventHandlers()
        self.theView.startActivityIndicator()
        
        managedObjectContext.performChanges {
            self.contract.resolutionStatus = .UserCanceled
            self.contract.markForNeedsRemoteVerification()
        }
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowCamera:
            guard let liveVC = segue.destinationViewController as? LiveStreamViewController else { fatalError("Wrong view controller type") }
            let currentLoc                              = CMUserMovementManager.shared.currentLocation
            var attachment:Attachment!                  = nil
            managedObjectContext.performChangesAndWait { [unowned self] in
                attachment = Attachment.insertAttachment(contract:self.contract, directory:NSFileManager.documents, location:currentLoc, managedObjectContext: self.managedObjectContext)
            }
            liveVC.attachment                           = attachment
            liveVC.contract                             = contract
            liveVC.managedObjectContext                 = managedObjectContext
            liveVC.remoteService                        = remoteService
        case .PushToCompletedJobReceipt:
            guard let receiptVC = segue.destinationViewController as? JobReceiptViewController else { fatalError("Wrong view controller type") }
            receiptVC.event                             = event
            receiptVC.managedObjectContext              = managedObjectContext
            receiptVC.remoteService                     = remoteService
        case .ShowInfo:
            guard let modal                             = segue.destinationViewController as? EventInfoModalViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            modal.modalInfo                             = event.modalInfo()
        case .ShowPayInfo:
            guard let modal                             = segue.destinationViewController as? EventInfoModalViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            modal.modalInfo                             = event.paymentModalInfo()
        }
    }
    
    
    // MARK: Location
    func locationUpdated() {
        let currentLoc                      = CMUserMovementManager.shared.currentLocation
        mapController.update(currentLoc)
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
