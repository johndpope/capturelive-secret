//
//  CompletedJobViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

extension CompletedJobViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class CompletedJobViewController: UIViewController, RemoteAndLocallyServiceable, NavGesturable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    private typealias Data = DefaultSectionableDataProvider<CompletedJobViewController>
    private var dataSource: TableViewDataSource<CompletedJobViewController, Data, JobDataTableViewCell>!
    private var dataProvider: Data!
    
    private var emailDelegate:EmailDelegate?
    
    var theView:CompletedJobView {
        guard let v = self.view as? CompletedJobView else { fatalError("Not a CompletedJobView!") }
        return v
    }
    
    var event:Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        theView.didLoad()
        theView.populate(event.tableCellViewModel())
        
        dataProvider                        = DefaultSectionableDataProvider(items:event.recieptDataArray, delegate :self)
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
        navGesturer?.usePushRightPopLeftGestureRecognizer()
        
        managedObjectContext.performChanges { [unowned self] in
            self.event.markAllNotificationsAsRead()
            UIApplication.sharedApplication().updateBadgeNumberForUnreadNotifications(self.managedObjectContext)
        }
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
        theView.backButton?.addTarget(self, action:#selector(back), forControlEvents: .TouchUpInside)
        theView.helpButton?.addTarget(self, action:#selector(sendEmailHandler), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.helpButton?.removeTarget(self, action:#selector(sendEmailHandler), forControlEvents: .TouchUpInside)
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: button handlers
    func sendEmailHandler() {
        emailDelegate = EmailDelegate()
        guard let hash = event.contract?.urlHash else {
            fatalError("This event has not urlHash : event \(event.urlHash)")
        }
        let userInfo = EmailInfo(
             titleString:"Support For Contract : #\(hash)"
            ,messageString:""
            ,toRecipentsArray:["support@capture.com"]
        )
        emailDelegate?.emailSupport(self, info: userInfo) { [weak self] in
            self?.emailDelegate = nil
        }
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