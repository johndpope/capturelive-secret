//
//  JobReceiptViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobReceiptViewController: UIViewController {
    
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
    
    let descriptionStrings:[String] = [
         "2 Video Streams"
        ,"14:32 total length of video"
        ,"9.7 MB total file size"
    ]
   
    let attachments:[AttachmentCollectionViewModel] = [
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
    
    private typealias Data = DefaultDataProvider<JobReceiptViewController>
    private var dataSource: TableViewDataSource<JobReceiptViewController, Data, JobReceiptTableViewCell>!
    private var dataProvider: Data!
    
    var theView:JobReceiptView {
        guard let v = self.view as? JobReceiptView else { fatalError("Not a JobReceiptView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        theView.didLoad()
        theView.populate(eventModel, attachments:attachments)
        
        dataProvider                        = DefaultDataProvider(items:descriptionStrings, delegate :self)
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
        theView.jobSummaryButton?.addTarget(self, action:#selector(back), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.jobSummaryButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}

extension JobReceiptViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return JobReceiptTableViewCellHeight
    }
    
}

extension JobReceiptViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<String>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension JobReceiptViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:String) -> String {
        return JobReceiptTableViewCell.Identifier
    }
}
