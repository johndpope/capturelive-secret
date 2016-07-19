//
//  CompletedJobViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class CompletedJobViewController: UIViewController {

    let eventModel = EventTableCellViewModel(
         urlHash                : "barf"
        ,titleString            : "Burning MAN 2016 Opening Ceremony"
        ,organizationNameString : "The Huffington Post"
        ,organizationLogoPath   : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        ,bannerImagePath        : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        ,startDateString        : NSDate().hoursFromNow(11).timeTilString()
        ,hasStartedBool         : true
        ,radiusDouble           : 2.5
        ,distanceAwayDouble     : 2.0
        ,contractStatus         : .ACQUIRED
        ,paymentAmountFloat     : 100.00
        ,paymentStatusString    : "PAID"
        ,isCancelledBool        : false
        ,completionDate         : NSDate()
    )
    
    let stats:[[TitleAndData]] = [
        [
             TitleAndData(titleString:"Number of streams",   dataString:"2")
            ,TitleAndData(titleString:"Length of video",     dataString:"12:43")
            ,TitleAndData(titleString:"Total file size",     dataString:"41.32 MB")
        ]
        ,
        [
             TitleAndData(titleString:"Hiring Company",      dataString:"The Huffington Post")
            ,TitleAndData(titleString:"Hiring Employee",     dataString:"Juan")
        ]
        ,
        [
             TitleAndData(titleString:"Payment Status",      dataString:"PAID")
            ,TitleAndData(titleString:"Amount Paid",         dataString:"$100")
        ]
    ]
   
    private typealias Data = DefaultSectionableDataProvider<CompletedJobViewController>
    private var dataSource: TableViewDataSource<CompletedJobViewController, Data, JobDataTableViewCell>!
    private var dataProvider: Data!
    
    var theView:CompletedJobView {
        guard let v = self.view as? CompletedJobView else { fatalError("Not a CompletedJobView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        theView.didLoad()
        theView.populate(eventModel)
        
        dataProvider                        = DefaultSectionableDataProvider(items:stats, delegate :self)
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate         = self
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
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /*
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension CompletedJobViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return JobDataTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return JobDataTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
}

extension CompletedJobViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<TitleAndData>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension CompletedJobViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:TitleAndData) -> String {
        return JobDataTableViewCell.Identifier
    }
}
