//
//  CMEventDetailViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class EventDetailViewController: UIViewController {
    
    var theView:EventDetailView {
        guard let v = self.view as? EventDetailView else { fatalError("Not a EventDetailView!") }
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
             TitleAndData(titleString:EventApplicationModel.startTitle,         dataString:NSDate().hoursFromNow(11).timeTilString())
            ,TitleAndData(titleString:EventApplicationModel.addressTitle,        dataString:"2415 Pershing Square St\nBlack Rock County, NV 53598")
            ,TitleAndData(titleString:EventApplicationModel.detailsTitle,    dataString:"We are looking for something and if you can do that then we would want it and be sure to film this is dummy co.")
        ]
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theView.stopActivityIndicator()
        theView.didLoad()
        theView.populate(eventModel)
        theView.layoutShort()
        theView.showUnapplied()
        
        addUnappliedHandlers()
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
    
    func addEventHandlers() {
        theView.backButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func addUnappliedHandlers() {
        theView.unappliedEventModuleView?.applyButton?.addTarget(self, action: #selector(showApplication), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.closeButton?.addTarget(self, action: #selector(hideApplication), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.submitButton?.addTarget(self, action: #selector(submitApplication), forControlEvents:.TouchUpInside)
    }
    func removeUnappliedHandlers() {
        theView.unappliedEventModuleView?.applyButton?.removeTarget(self, action: #selector(showApplication), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.closeButton?.removeTarget(self, action: #selector(hideApplication), forControlEvents:.TouchUpInside)
        theView.agreementFormModuleView?.submitButton?.removeTarget(self, action: #selector(submitApplication), forControlEvents:.TouchUpInside)
    }
   
    func addAppliedHandlers() {
        theView.appliedInfoModuleView?.jobDetailsButton?.addTarget(self, action: #selector(toggleShowDetails), forControlEvents:.TouchUpInside)
    }
    
    func removeAppliedHandlers() {
        theView.appliedInfoModuleView?.jobDetailsButton?.removeTarget(self, action: #selector(toggleShowDetails), forControlEvents:.TouchUpInside)
    }
    
    func showApplication() {
        theView.showApplication()
    }
    
    func hideApplication() {
        theView.hideApplication()
    }
    
    func toggleShowDetails() {
        theView.toggleShowDetails()
    }

    func submitApplication() {
        removeUnappliedHandlers()
        addAppliedHandlers()
        let alertView   = CMActionSheetController(title:"Event Detail", message: "Choose which scenario you would like to plug into the UI")
        let applied     = CMAlertAction(title: "Reveal Applied", style: .Primary) { [weak self] in
            self?.applied()
        }
        let expired     = CMAlertAction(title: "Reveal Expired", style: .Primary) { [weak self] in
            self?.expired()
        }
        let hired       = CMAlertAction(title: "Reveal Hired", style: .Primary) { [weak self] in
            self?.hired()
        }
        alertView.addAction(hired)
        alertView.addAction(expired)
        alertView.addAction(applied)
        
        CMAlert.presentViewController(alertView)
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func toggleCheckBox() {
        
    }
    
    //MARK : Event types
    func applied() {
        let eventModel = EventApplicationModel(
            urlHash                : "barf"
            ,titleString            : "Burning MAN 2016 Opening Ceremony"
            ,organizationNameString : "The Huffington Post"
            ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
            ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
            ,exactAddressString     : "2415 Pershing Square St\nBlack Rock County, NV 53598"
            ,startDateString        : NSDate().hoursFromNow(11).timeTilString()
            ,displayExpired         : false
            ,contractStatus         : .APPLIED
            ,paymentAmountFloat     : 100.00
            ,publicUrl              : "capturelive.com/39uklsg"
            ,titlesAndData          : [
                TitleAndData(titleString:EventApplicationModel.startTitle,         dataString:NSDate().hoursFromNow(11).timeTilString())
                ,TitleAndData(titleString:EventApplicationModel.addressTitle,        dataString:"2415 Pershing Square St\nBlack Rock County, NV 53598")
                ,TitleAndData(titleString:EventApplicationModel.detailsTitle,    dataString:"We are looking for something and if you can do that then we would want it and be sure to film this is dummy co.")
            ]
        )
        theView.populate(eventModel)
        theView.revealApplied()
    }
    
    func expired() {
        let eventModel = EventApplicationModel(
            urlHash                : "barf"
            ,titleString            : "Burning MAN 2016 Opening Ceremony"
            ,organizationNameString : "The Huffington Post"
            ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
            ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
            ,exactAddressString     : "2415 Pershing Square St\nBlack Rock County, NV 53598"
            ,startDateString        : NSDate().hoursFromNow(11).timeTilString()
            ,displayExpired         : true
            ,contractStatus         : .EXPIRED
            ,paymentAmountFloat     : 100.00
            ,publicUrl              : "capturelive.com/39uklsg"
            ,titlesAndData          : [
                TitleAndData(titleString:EventApplicationModel.startTitle,         dataString:NSDate().hoursFromNow(11).timeTilString())
                ,TitleAndData(titleString:EventApplicationModel.addressTitle,        dataString:"2415 Pershing Square St\nBlack Rock County, NV 53598")
                ,TitleAndData(titleString:EventApplicationModel.detailsTitle,    dataString:"We are looking for something and if you can do that then we would want it and be sure to film this is dummy co.")
            ]
        )
        theView.populate(eventModel)
        theView.revealApplied()
    }
    
    func hired() {
        let eventModel = EventApplicationModel(
            urlHash                 : "barf"
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
                TitleAndData(titleString:EventApplicationModel.startTitle,         dataString:NSDate().hoursFromNow(11).timeTilString())
                ,TitleAndData(titleString:EventApplicationModel.addressTitle,        dataString:"2415 Pershing Square St\nBlack Rock County, NV 53598")
                ,TitleAndData(titleString:EventApplicationModel.detailsTitle,    dataString:"We are looking for something and if you can do that then we would want it and be sure to film this is dummy co.")
            ]
        )
        theView.populate(eventModel)
        theView.revealApplied()
    }
    
}
