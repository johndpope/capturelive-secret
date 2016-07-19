//
//  EventInfoModalViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

typealias TextGenerator = (AppliedEventModuleView)->NSAttributedString

class EventInfoModalViewController: UIViewController {

    private typealias Data              = DefaultDataProvider<EventInfoModalViewController>
    private var dataSource: TableViewDataSource<EventInfoModalViewController, Data, EventInfoTableViewCell>!
    private var dataProvider: Data!
    
    var theView:EventInfoModalView {
        guard let v = self.view as? EventInfoModalView else { fatalError("Not a EventInfoModalView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theView.didLoad()
        populateWithPaymentInfo()
    }

    func populateWithInfo() {
        let modal                       = getInfo()
        theView.populate(modal)
        
        dataProvider                    = DefaultDataProvider(items:modal.tableDataArray, delegate :self)
        dataSource                      = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate     = self
    }
    
    func populateWithPaymentInfo() {
        let modal                       = getPaymentInfo()
        theView.populate(modal)
 
        dataProvider                    = DefaultDataProvider(items:modal.tableDataArray, delegate :self)
        dataSource                      = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate     = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func getInfo()->ModalInfo {
        return ModalInfo(
            navTitleString:NSLocalizedString("JOB Info", comment: "JobInfo : navtitle : text")
            ,titleString:getInfoAttributedTitle()
            ,tableDataArray:[
                EventIndexInfo(indexInt:1, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:2, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:3, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:4, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:5, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:6, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:true)
            ]
        )
    }

    func getInfoAttributedTitle()->NSAttributedString {
        let requirementsText = NSLocalizedString("\nThe Job Requirements\n", comment: "JobInfo : requirements : text")
        let boldAtt                 = [
            NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s17)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let attString               = NSMutableAttributedString(string:requirementsText, attributes:boldAtt)
        return attString
    }
   
    func getPaymentInfo()->ModalInfo {
        return ModalInfo(
             navTitleString:NSLocalizedString("JOB PAYS", comment: "JobPays : navtitle : text")
            ,titleString:getPaymentAttributedTitle()
            ,tableDataArray:[
                 EventIndexInfo(indexInt:1, dataString:NSLocalizedString("All payments will be made based on lorim ipsum...",       comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:2, dataString:NSLocalizedString("All payments will be made based on lorim ipsum...",       comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:3, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:4, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:5, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:true)
            ]
        )
    }
    
    func getPaymentAttributedTitle()->NSAttributedString {
        let titleText               = NSLocalizedString("Burning MAN 2015", comment: "JobPays : eventtitle : text")
        let thisJobText             = NSLocalizedString("This Job Pays:", comment: "JobPays : title : text")
        let paymentText             = NSLocalizedString("$75", comment: "JobPays : amountPay : text")
        let paymentDetailsText      = NSLocalizedString("Job Payment Details", comment: "JobPays : amountPay : text")
        
        let eventTitleAtt           = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size: FontSizes.s14)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let attString               = NSMutableAttributedString(string:titleText + "\n", attributes:eventTitleAtt)

        let thisJobAtt              = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size:FontSizes.s20)
            ,NSForegroundColorAttributeName : UIColor.mountainMeadow()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let thisJobString           = NSMutableAttributedString(string:"\n" + thisJobText + "\n", attributes:thisJobAtt)
        attString.appendAttributedString(thisJobString)
 
        let paymentAtt              = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size:FontSizes.s27)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let paymentString           = NSMutableAttributedString(string:paymentText + "\n", attributes:paymentAtt)
        attString.appendAttributedString(paymentString)
        
        let paymentDetailsAtt       = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size:FontSizes.s14)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let paymentDetailsString    = NSMutableAttributedString(string:paymentDetailsText, attributes:paymentDetailsAtt)
        attString.appendAttributedString(paymentDetailsString)
        return attString
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    func goBack() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
 
    func addEventHandlers() {
        theView.closeButton?.addTarget(self, action: #selector(submitApplication), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.closeButton?.removeTarget(self, action: #selector(submitApplication), forControlEvents: .TouchUpInside)
    }
    
    func submitApplication() {
        let alertView   = CMActionSheetController(title:"Event Info Modal", message: "Choose which scenario you would like to plug into the UI")
        let info     = CMAlertAction(title: "Info", style: .Primary) { [weak self] in
            self?.populateWithInfo()
        }
        let pInfo     = CMAlertAction(title: "Payment Info", style: .Primary) { [weak self] in
            self?.populateWithPaymentInfo()
        }
        let backAction     = CMAlertAction(title: "Exit", style: .Primary) { [weak self] in
            self?.goBack()
        }
        alertView.addAction(backAction)
        alertView.addAction(pInfo)
        alertView.addAction(info)
        
        CMAlert.presentViewController(alertView)
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EventInfoModalViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).cellHeight
    }
}

extension EventInfoModalViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<EventIndexInfo>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension EventInfoModalViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:EventIndexInfo) -> String {
        return EventInfoTableViewCell.Identifier
    }
}


