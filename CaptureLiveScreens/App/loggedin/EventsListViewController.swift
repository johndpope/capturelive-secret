//
//  CMEventsListViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit


class EventsListViewController: UIViewController {
    
    var theView:EventsListView {
        guard let v = self.view as? EventsListView else { fatalError("Not a EventsListView!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<EventsListViewController>
    private var dataSource: TableViewDataSource<EventsListViewController, Data, EventTableViewCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        let events = [
            EventTableCellViewModel(
                 urlHash                : "barf"
                ,titleString            : "Burning MAN 2016 Opening Ceremony"
                ,organizationNameString : "CNN"
                ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,startDateString        : NSDate().hoursFromNow(11).timeTilString()
                ,hasStartedBool         : true
                ,radiusDouble           : 2.5
                ,distanceAwayDouble     : 2.0
                ,contractStatus         : .NONE
                ,paymentAmountFloat     : 100.00
                ,paymentStatusString    : ""
                ,isCancelledBool        : false
                ,completionDate         : NSDate().hoursFromNow(-3)
            )
            ,EventTableCellViewModel(
                 urlHash                : "barf"
                ,titleString            : "NOW NOW NOW NOW"
                ,organizationNameString : "CNN"
                ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,startDateString        : NSDate().hoursFromNow(-1).timeTilString()
                ,hasStartedBool         : true
                ,radiusDouble           : 2.5
                ,distanceAwayDouble     : 2.0
                ,contractStatus         : .NONE
                ,paymentAmountFloat     : 100.00
                ,paymentStatusString    : ""
                ,isCancelledBool        : false
                ,completionDate         : NSDate().hoursFromNow(-3)
            )
            ,EventTableCellViewModel(
                 urlHash                : "barf"
                ,titleString            : "ALL DAY CHUGFEST, WITH A LONG ASS TITLE. WILL SURELY EFF THINGS UP FOR SURE. TURLEY EVENALL DAY CHUGFEST, WITH A LONG ASS TITLE. WILL SURELY EFF THINGS UP FOR SURE. TURLEY EVEN"
                ,organizationNameString : "CaptureLIVE"
                ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,startDateString        : NSDate().hoursFromNow(20).timeTilString()
                ,hasStartedBool         : true
                ,radiusDouble           : 2.5
                ,distanceAwayDouble     : 2.0
                ,contractStatus         : .APPLIED
                ,paymentAmountFloat     : 100.00
                ,paymentStatusString    : ""
                ,isCancelledBool        : false
                ,completionDate         : NSDate().hoursFromNow(-3)
            )
            ,EventTableCellViewModel(
                 urlHash                : "barf"
                ,titleString            : "Disney on Fire"
                ,organizationNameString : "CNN"
                ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,startDateString        : NSDate().hoursFromNow(40).timeTilString()
                ,hasStartedBool         : false
                ,radiusDouble           : 2.5
                ,distanceAwayDouble     : 1.0
                ,contractStatus         : .ACQUIRED
                ,paymentAmountFloat     : 100.00
                ,paymentStatusString    : ""
                ,isCancelledBool        : false
                ,completionDate         : NSDate().hoursFromNow(-3)
            )
        ]
        
        theView.didLoad()
        dataProvider                        = DefaultDataProvider(items:events, delegate :self)
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate         = self
       
        theView.zeroStateView?.animateOut()
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
        theView.backButton?.addTarget(self, action:#selector(back), forControlEvents: .TouchUpInside)
        theView.availableButton?.addTarget(self, action: #selector(availableSelected), forControlEvents: .TouchUpInside)
        theView.hiredButton?.addTarget(self, action: #selector(hiredSelected), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.availableButton?.removeTarget(self, action: #selector(availableSelected), forControlEvents: .TouchUpInside)
        theView.hiredButton?.removeTarget(self, action: #selector(hiredSelected), forControlEvents: .TouchUpInside)
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func hiredSelected() {
        theView.animateHiredSelected()
    }
    
    func availableSelected() {
        theView.animateAvailableSelected()
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}

extension EventsListViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
}

extension EventsListViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<EventTableCellViewModel>]?) {
       dataSource.processUpdates(updates)
    }
}

extension EventsListViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:EventTableCellViewModel) -> String {
        return EventTableViewCell.Identifier
    }
}
