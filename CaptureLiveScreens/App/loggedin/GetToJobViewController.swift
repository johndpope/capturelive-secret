//
//  CMEventDetailAcceptedViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class GetToJobViewController: UIViewController {
    
    var theView:GetToJobView {
        guard let v = self.view as? GetToJobView else { fatalError("Not a GetToJobView!") }
        return v
    }

//    var mapController:CMMKSController!
    var mapController:MapController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
       
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
        let hiredModel = EventHiredModel(
            eventModel              : eventModel
            ,publisherNameString    :"Larry Storch"
            ,publisherAvatarString  :"https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        )

        theView.populate(hiredModel)

        let ecoordinate                     = CLLocationCoordinate2D(latitude:42.6525, longitude:-73.7572)
        let currentLoc                      = CLLocationCoordinate2D(latitude: 40.72190579999999, longitude: -73.99938750000001)
        mapController                       = MapController(mapView: theView.mapView!, currentCoordinate:currentLoc, eventCoordinate:ecoordinate, avatarPathString: "https://s3.amazonaws.com/capture-static/default-avatar.png")
        mapController.didLoad()
        locationUpdated()
    
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            let currentLoc                              = CLLocationCoordinate2D(latitude: 40.6741727, longitude: -74.52491929999997)
            self?.mapController.update(currentLoc)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeEventHandlers()
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        theView.toggleButtonTop?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.addTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.backButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.addTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.toggleButtonTop?.removeTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.toggleButtonBottom?.removeTarget(self, action: #selector(toggleModal), forControlEvents: .TouchUpInside)
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.jobInfoButtonsModuleView?.jobDetailsButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
        theView.jobDetailsModuleView?.closeButton?.removeTarget(self, action: #selector(toggleJobDetails), forControlEvents: .TouchUpInside)
    }
    
    // MARK: button handlers
    func back() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func toggleModal() {
        theView.togglePublisherInfo()
    }
    
    func toggleJobDetails() {
        theView.toggleJobDetails()
    }
   
    // MARK: location
    func locationUpdated() {
        let currentLoc                              = CLLocationCoordinate2D(latitude: 40.72190579999999, longitude: -73.99938750000001)
        mapController.update(currentLoc)
    }
}
