//
//  CMModalHiredViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class ModalHiredViewController: UIViewController {
    
    var theView:ModalHiredView {
        guard let v = self.view as? ModalHiredView else { fatalError("Not a ModalHiredView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
        
        let publisher = PublisherHiredViewModel(
            titleNameString         : "Theodore B."
            ,hiredYouString         : "from CNN Money hired you."
            ,avatarURLString        : "https://capture-media-staging.s3.amazonaws.com/uploads/user/avatar/10/retina_1369428127.jpg"
            ,callString             : "Call Theodore"
            ,textString             : "send a text"
        )
        
        let event = EventViewModel(
            titleString             : "Disney on Fire"
            ,startDateString        : NSDate().eventTime()
            ,endDateString          : NSDate().eventTime()
            ,hasStarted             : false
            ,exactAddressString     : "23 Creek Canyon"
            ,radiusDouble           : 2.5
            ,distanceAwayDouble     : 0.5
            ,contractStatus         : .APPLIED
            ,paymentAmountFloat     : 400.00
            ,descriptionString      : "FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! "
            ,publicUrl              : "http://whooooooo.com/sdfasd"
            ,hasSeenStartedBool     : false
            ,isFirstArrivalBool     : true
        )
        
        let team = TeamViewModel(
            nameString              :"CNN"
        )
        
        self.theView.populate(publisher: publisher, event: event, team:team)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.viewJobButton?.addTarget(self, action: #selector(showHasStartedEvent), forControlEvents: .TouchUpInside)
    }
    
    
    // MARK: button handlers
    func showHasStartedEvent() {
        self.theView.viewJobButton?.removeTarget(self, action: #selector(showHasStartedEvent), forControlEvents: .TouchUpInside)
        self.theView.viewJobButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        
        let publisher = PublisherHiredViewModel(
            titleNameString         : "Theodore B."
            ,hiredYouString         : "from CNN Money hired you."
            ,avatarURLString        : "https://capture-media-staging.s3.amazonaws.com/uploads/user/avatar/10/retina_1369428127.jpg"
            ,callString             : "Call Theodore"
            ,textString             : "send a text"
        )
        
        let event = EventViewModel(
            titleString             : "Disney on Fire"
            ,startDateString        : NSDate().eventTime()
            ,endDateString          : NSDate().eventTime()
            ,hasStarted             : true
            ,exactAddressString     : "23 Creek Canyon"
            ,radiusDouble           : 2.5
            ,distanceAwayDouble     : 0.5
            ,contractStatus         : .APPLIED
            ,paymentAmountFloat     : 400.00
            ,descriptionString      : "FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! FPO LOCALIZED DESCRIPTION SON! "
            ,publicUrl              : "http://whooooooo.com/sdfasd"
            ,hasSeenStartedBool     : false
            ,isFirstArrivalBool     : true
        )
        
        let team = TeamViewModel(
            nameString              :"CNN"
        )
        
        self.theView.populate(publisher: publisher, event: event, team:team)
    }
    
    func back() {
        self.theView.viewJobButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
