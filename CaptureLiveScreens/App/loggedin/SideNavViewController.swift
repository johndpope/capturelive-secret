//
//  CMSettingsViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class SideNavViewController: UIViewController {
    
    var theView:SideNavView {
        guard let v = self.view as? SideNavView else { fatalError("Not a \(SideNavView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<SideNavViewController>
    private var dataSource:TableViewDataSource<SideNavViewController, Data, SideNavTableViewCell>!
    private var dataProvider: Data!
   
    let navModels:[SideNavViewModel] = [
        SideNavViewModel(
             iconNameString:"bttn_livejobs"
            ,titleString:NSLocalizedString("LIVE Jobs", comment: "SideNav : livejobs : titleString")
        )
        ,SideNavViewModel(
             iconNameString:"bttn_jobhistory"
            ,titleString:NSLocalizedString("Job History", comment: "SideNav : job history : titleString")
        )
        ,SideNavViewModel(
             iconNameString:"bttn_notifications"
            ,titleString:NSLocalizedString("Notifications", comment: "SideNav : notifications : titleString")
            ,indicatorCount:1
        )
        ,SideNavViewModel(
             iconNameString:"bttn_payments"
            ,titleString:NSLocalizedString("Payments", comment: "SideNav : payments : titleString")
        )
        ,SideNavViewModel(
             iconNameString:"bttn_support"
            ,titleString:NSLocalizedString("Support", comment: "SideNav : support : titleString")
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
      
        theView.didLoad()
        automaticallyAdjustsScrollViewInsets = true
        
        dataProvider    = DefaultDataProvider(items:navModels, delegate :self)
        dataSource      = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        
        theView.tableView?.delegate = self
        
        theView.nameLabel?.text         = "Theodore S."
        CMImageCache.defaultCache().imageForPath("https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200", complete: { [weak self] error, image in
            if error == nil {
                self?.theView.avatarView?.image = image
                self?.theView.layoutSubviews()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        theView.layoutSubviews()
        theView.updateTableViewHeight(navModels.count)
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
//        self.settingsView.profileButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
//        self.settingsView.profileButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
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


extension SideNavViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SideNavTableViewCell.SideNavTableViewCellHeight
    }
   
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
        back()
    }
    
}

extension SideNavViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<SideNavViewModel>]?) {
    }
}

extension SideNavViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:SideNavViewModel) -> String {
        return SideNavTableViewCellCellIdentifier
    }
}
