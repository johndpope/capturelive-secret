//
//  CMNotificationsViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class NotificationsViewController: UIViewController {

    var notifications :[NotificationTableCellViewModel]!
    
    var theView:NotificationsView {
        guard let v = self.view as? NotificationsView else { fatalError("Not a NotificationsView!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<NotificationsViewController>
    private var dataSource:TableViewDataSource<NotificationsViewController, Data, NotificationTableCell>!
    private var dataProvider: Data!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        let note1Text = "You've been hired"
        let note2Text = "You've been cancelled homes"
        let note3Text = "An unreasonably long message that is guaranteed to be longer than one line. GUARANTEED!"

        notifications = [
            NotificationTableCellViewModel(
                 isReadBool         : false
                ,logoUrlString      : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,eventTitleString   : "Babes in the park"
                ,messageString      : note1Text
                ,createdAtDate      : NSDate().hoursFromNow(0.0)
                ,jobIconNameString  : "icon_jobsuccess"
                ,font               : CMFontProxima.Bold
            )
           ,
            NotificationTableCellViewModel(
                 isReadBool         : true
                ,logoUrlString      : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,eventTitleString   : "Whooo! Stuff to get paid for dude!"
                ,messageString      : note2Text
                ,createdAtDate      : NSDate().hoursFromNow(-3.0)
                ,jobIconNameString  : "icon_cancelledjob"
                ,font               : CMFontProxima.Regular
            )
            ,
            NotificationTableCellViewModel(
                 isReadBool         : true
                ,logoUrlString      : "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,eventTitleString   : "Whooo! Stuff to get paid for dude!"
                ,messageString      : note3Text
                ,createdAtDate      : NSDate().hoursFromNow(-3.0)
                ,jobIconNameString  : "icon_jobname_star_blksmall"
                ,font               : CMFontProxima.Regular
            )
        ]
       
        theView.didLoad()
        dataProvider    = DefaultDataProvider(items:notifications, delegate :self)
        dataSource      = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        
        theView.tableView?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    func addHandlers() {
        removeHandlers()
        theView.backButton?.addTarget(self, action:#selector(goback), forControlEvents:.TouchUpInside)
    }
    
    func removeHandlers() {
        theView.backButton?.removeTarget(self, action:#selector(goback), forControlEvents:.TouchUpInside)
    }

    //MARK: Button handlers
    func goback() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

extension NotificationsViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return notifications[indexPath.row].cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
//        back()
    }
    
}

extension NotificationsViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<NotificationTableCellViewModel>]?) {
    }
}

extension NotificationsViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:NotificationTableCellViewModel) -> String {
        return NotificationTableCell.Identifier
    }
}
//extension NotificationsViewController : UITableViewDataSource {
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return notifications[indexPath.row].cellHeight
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return notifications.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCellWithIdentifier(NotificationTableCell.Identifier, forIndexPath: indexPath) as? NotificationTableCell else { fatalError("No tablecell with identifier to NotificationTableCell") }
//        let notification = notifications[indexPath.row]
//        cell.prepareForUse(notification)
//        return cell
//    }
//    
//}
//
//extension NotificationsViewController : UITableViewDelegate {
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    }
//    
//}

//extension String {
//    
//    public func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
//        let constraintRect = CGSize(width: width, height: CGFloat.max)
//        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
//        return boundingBox.height
//    }
//
//}
