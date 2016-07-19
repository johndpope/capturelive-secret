//
//  CMEventBossViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class OnTheJobViewController: UIViewController {
    
    var theView:OnTheJobView {
        guard let v = self.view as? OnTheJobView else { fatalError("Not a OnTheJobView!") }
        return v
    }
   
    let eventModel = EventApplicationModel(
        urlHash                : "barf"
        ,titleString            : "Burning MAN 2016 Opening Ceremony"
        ,organizationNameString : "The Huffington Post"
        ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        ,exactAddressString     : "2415 Pershing Square St\nBlack Rock County, NV 53598"
        ,startDateString        : NSDate().hoursFromNow(11).timeTilString()
        ,displayExpired         : false
        ,contractStatus         : .ACQUIRED
        ,paymentAmountFloat     : 100.00
        ,publicUrl              : "capturelive.com/39uklsg"
        ,titlesAndData          : [
            TitleAndData(titleString:EventApplicationModel.eventTitle,         dataString:"Burning MAN 2016 Opening Ceremony")
            ,TitleAndData(titleString:EventApplicationModel.startTitle,         dataString:NSDate().hoursFromNow(11).timeTilString())
            ,TitleAndData(titleString:EventApplicationModel.addressTitle,       dataString:"2415 Pershing Square St\nBlack Rock County, NV 53598")
            ,TitleAndData(titleString:EventApplicationModel.detailsTitle,       dataString:"We are looking for something and if you can do that then we would want it and be sure to film this is dummy co.")
        ]
    )
    var hiredModel: EventHiredModel!

    var mapController:MapController!
    var attachments:[AttachmentCollectionViewModel]!
   
    var timer:NSTimer?
    var inc:Double = 0
    var total:Double = 120
    var prog:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        let ecoordinate                     = CLLocationCoordinate2D(latitude:42.6525, longitude:-73.7572)
        let currentLoc                      = CLLocationCoordinate2D(latitude: 40.72190579999999, longitude: -73.99938750000001)
        mapController                       = MapController(mapView: theView.mapView!, currentCoordinate:currentLoc, eventCoordinate:ecoordinate, avatarPathString: "https://s3.amazonaws.com/capture-static/default-avatar.png")
        mapController.didLoad()
        
        theView.didLoad()
        hiredModel = EventHiredModel(
            eventModel              : eventModel
            ,publisherNameString    :"Larry Storch"
            ,publisherAvatarString  :"https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        )
        var empty:[AttachmentCollectionViewModel] = []
        let startAs:[AttachmentCollectionViewModel] = [
             AttachmentCollectionViewModel(
                thumbnailPathString : "https://s3.amazonaws.com/capture-media-mobile/uploads/streams/3888799C-7446-4A19-91CD-FE9D173A5A4E/hdthumbnail/neZVFRplOzbB.jpg"
                ,durationString     : "3 mins"
                ,size               : 601342544214
                ,isUploaded         : false
            )
            ,
             AttachmentCollectionViewModel(
                thumbnailPathString : "https://s3.amazonaws.com/capture-media-mobile/uploads/streams/0EC585F4-5606-4641-9B45-8817306CACBE/hdthumbnail/SC2GT2f3LrTT.jpg"
                ,durationString     : "1 min"
                ,size               : 601342544214
                ,isUploaded         : false
            )
            ,
             AttachmentCollectionViewModel(
                thumbnailPathString : "https://s3.amazonaws.com/capture-media-mobile/uploads/streams/3EDDED05-65B0-47E1-8952-82FFF13C4DAB/hdthumbnail/FUO1sQJYPLQF.jpg"
                ,durationString     : "23 secs"
                ,size               : 6043416013420
                ,isUploaded         : true
            )
        ]
        
        for _ in 0..<20 {
            empty += startAs
        }
        attachments                         = empty
       
        showGetToLocation()
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
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        theView.backButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.cameraButton?.addTarget(self, action: #selector(showAlertList), forControlEvents: .TouchUpInside)

        theView.toggleButtonTop?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.noButton?.addTarget(self, action: #selector(showArrived), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.yesButton?.addTarget(self, action: #selector(showUploading), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.pauseButton?.addTarget(self, action: #selector(pauseUpload), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobCompletedAlertView?.viewJobReceiptButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.cameraButton?.removeTarget(self, action: #selector(showAlertList), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.noButton?.removeTarget(self, action: #selector(showArrived), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.yesButton?.removeTarget(self, action: #selector(showUploading), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.pauseButton?.removeTarget(self, action: #selector(pauseUpload), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobCompletedAlertView?.viewJobReceiptButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    // MARK: Button handlers
    func showAlertList() {
        let alertView               = CMActionSheetController(title:"On The Job", message: "Choose which scenario you would like to plug into the UI")
        let showGetToLocation       = CMAlertAction(title: "Show Get To Location", style: .Primary) { [weak self] in
            self?.showGetToLocation()
        }
        let showArrived             = CMAlertAction(title: "Show Arrived", style: .Primary) { [weak self] in
            self?.showArrived()
        }
        let showDecision            = CMAlertAction(title: "Show Decision", style: .Primary) { [weak self] in
            self?.showDecision()
        }
        let showUploading           = CMAlertAction(title: "Show Uploading", style: .Primary) { [weak self] in
            self?.showUploading()
        }
//        let showAfterRecording      = CMAlertAction(title: "Show After Recording", style: .Primary) { [weak self] in
//            self?.showAfterRecording()
//        }
//        let showNotDoneRecordMore       = CMAlertAction(title: "Show Not Done Record More", style: .Primary) { [weak self] in
//            self?.showNotDoneRecordMore()
//        }
//        alertView.addAction(showNotDoneRecordMore)
//        alertView.addAction(showAfterRecording)
        alertView.addAction(showUploading)
        alertView.addAction(showDecision)
        alertView.addAction(showArrived)
        alertView.addAction(showGetToLocation)
        
        CMAlert.presentViewController(alertView)
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func toggleModal() {
        theView.togglePublisherInfo()
    }
    
    func toggleJobDetails() {
        theView.toggleJobDetails()
    }
    
    // MARK: Location
    func locationUpdated() {
        let currentLoc                              = CLLocationCoordinate2D(latitude: 40.72190579999999, longitude: -73.99938750000001)
        mapController.update(currentLoc)
    }
   
    // MARK: Button handlers 
    func pauseUpload() {
        timerStop()
        theView.pauseUploading()
    }
}

extension OnTheJobViewController {
    
    func showGetToLocation() {
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : false
            ,isUploadingBool                : false
            ,distanceAwayDouble             : 100.0
            ,numUnuploadedAttachmentsInt    : 0
            ,numUploadedAttachmentsInt      : 0
        )
        theView.populate(contract:contractModel, hiredModel:hiredModel)
    }
    
    func showArrived() {
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : true
            ,isUploadingBool                : false
            ,distanceAwayDouble             : 0.2
            ,numUnuploadedAttachmentsInt    : 0
            ,numUploadedAttachmentsInt      : 0
        )
        theView.populate(contract:contractModel, hiredModel:hiredModel)
    }
    
    func showDecision() {
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : true
            ,isUploadingBool                : false
            ,distanceAwayDouble             : 0.2
            ,numUnuploadedAttachmentsInt    : 3
            ,numUploadedAttachmentsInt      : 0
        )
        theView.populate(contract:contractModel, hiredModel:hiredModel)
        theView.addAttachments(attachments)
    }
   
    func showUploading() {
        timerStart()
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : true
            ,isUploadingBool                : true
            ,distanceAwayDouble             : 0.2
            ,numUnuploadedAttachmentsInt    : 3
            ,numUploadedAttachmentsInt      : 0
        )
        theView.populate(contract:contractModel, hiredModel:hiredModel)
        theView.addAttachments(attachments)
    }
    
    func showDoneUploading() {
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : true
            ,isUploadingBool                : true
            ,distanceAwayDouble             : 0.2
            ,numUnuploadedAttachmentsInt    : 3
            ,numUploadedAttachmentsInt      : 3
        )
        theView.populate(contract:contractModel, hiredModel:hiredModel)
        theView.addAttachments(attachments)
        theView.showUploadingVideos(3, totalNumVideos: 3, progress:CGFloat(prog))
        theView.showCompletedAlert()
    }
    
    func showNotDoneRecordMore() {
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : true
            ,isUploadingBool                : false
            ,distanceAwayDouble             : 0.2
            ,numUnuploadedAttachmentsInt    : 3
            ,numUploadedAttachmentsInt      : 3
        )
        theView.populate(contract:contractModel, hiredModel:hiredModel)
        theView.addAttachments(attachments)
    }
    
    func timerStart() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(increment), userInfo: nil, repeats: true)
    }
    
    func timerStop() {
        timer?.invalidate()
    }
    
    func increment() {
        inc = inc + 1
        prog = Double(inc / total)
        if prog >= 1 {
            timerStop()
            showDoneUploading()
        } else {
            theView.showUploadingVideos(1, totalNumVideos: 3, progress:CGFloat(prog))
        }
    }

}

