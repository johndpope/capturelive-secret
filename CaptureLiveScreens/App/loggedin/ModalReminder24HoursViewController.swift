//
//  ModalReminder24HourViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/7/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class ModalReminder24HoursViewController: UIViewController {

    var theView:ModalReminder24HoursView {
        guard let v = self.view as? ModalReminder24HoursView else { fatalError("Not a ModalReminder24HoursView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
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
        self.theView.populate(event: event)
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
        self.theView.takeMeThereButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.takeMeThereButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        
    }
    
    // MARK: button handlers
    func back() {
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
