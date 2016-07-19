//
//  CMSettingsViewController.swift
//  Current
//
//  Created by Scott Jones on 1/22/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync

extension SideNavViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return RemoveSideNavAnimator()
    }
}
extension SideNavViewController: SideNavStoryBoardable {
}

enum SideNavTypes:Int {
    case LIVEJobs
    case JobHistory
    case Notifications
    case Payments
    case Support
}
class SideNavViewController: UIViewController, SegueHandlerType, RemoteAndLocallyServiceable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var loggedInUser: User!
    var desiredStoryBoard:String    = "LoggedIn"
    var desiredScreen:String        = "CMEventsListViewController"
 
    var gestureNavigationController:CMNavigationController? {
        return self.navigationController as? CMNavigationController
    }

    var theView:SideNavView {
        guard let v = self.view as? SideNavView else { fatalError("Not a \(SideNavView.self)!") }
        return v
    }
    
    private typealias Data          = DefaultDataProvider<SideNavViewController>
    private var dataSource: TableViewDataSource<SideNavViewController, Data, SideNavTableViewCell>!
    private var dataProvider: Data!
    
    var navModels:[SideNavViewModel]!
    enum SegueIdentifier:String {
        case SideNavSegueDynamicScreen  = "sideNavSegueDynamicScreen"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let lUser = User.loggedInUser(managedObjectContext) else {
            fatalError("No login user")
        }
        loggedInUser                = lUser
        
        theView.didLoad()
        theView.tableView?.delegate         = self
        automaticallyAdjustsScrollViewInsets = true
        
        theView.nameLabel?.text             = loggedInUser.firstNameLastLetter
        CMImageCache.defaultCache().imageForPath(loggedInUser.avatar, complete: { [weak self] error, image in
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
      
        let numUnreadNotifcations           = Notification.fetchTotalNumberOfUnread(managedObjectContext)
        navModels = [
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
                    ,indicatorCount:numUnreadNotifcations
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
        dataProvider            = DefaultDataProvider(items:navModels, delegate :self)
        dataSource              = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        desiredStoryBoard       = "LoggedIn"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addHandlers()
       
//        self.showReachiblity()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    func addHandlers() {
        self.removeHandlers()
        self.theView.logOutButton?.addTarget(self, action: #selector(goToLogout), forControlEvents: .TouchUpInside)
        self.theView.profileButton?.addTarget(self, action: #selector(goToMyAccount), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        self.theView.logOutButton?.removeTarget(self, action: #selector(goToLogout), forControlEvents: .TouchUpInside)
        self.theView.profileButton?.removeTarget(self, action: #selector(goToMyAccount), forControlEvents: .TouchUpInside)
    }

    //MARK: Button handlers
    func goToEventsList() {
        desiredScreen       = "EventsListViewController"
        performSegue(.SideNavSegueDynamicScreen)
    }
   
    func goToJobHistory() {
        desiredScreen       = "JobHistoryViewController"
        performSegue(.SideNavSegueDynamicScreen)
    }
    
    func goToMyAccount() {
        desiredScreen       = "CreateProfileViewController"
        performSegue(.SideNavSegueDynamicScreen)
    }

    func goToNotifications() {
        desiredScreen       = "NotificationsViewController"
        performSegue(.SideNavSegueDynamicScreen)
    }
    
    func goToPaypal() {
        desiredScreen       = "PaypalViewController"
        performSegue(.SideNavSegueDynamicScreen)
    }
    
    func goToSupport() {
        desiredScreen       = "SupportViewController"
        performSegue(.SideNavSegueDynamicScreen)
    }
    
    func goToLogout() {
        let title                                       = NSLocalizedString("Log out", comment:"CMSettings : logoutWarning : alertTitle")
        let messages                                    = NSLocalizedString("Are you sure you want to log out?", comment:"CMSettings : logoutWarning : alertTitle")
        let alertViewController                         = CMAlertController(title:title, message:messages)
        
        let okButtonText                                = NSLocalizedString("Log out", comment:"CMSettingsLogoutAlert : okButton : titleText")
        let okAction = CMAlertAction(title:okButtonText, style: .Primary) { () -> () in
            self.logout()
        }
        
        let cancelButtonText                            = NSLocalizedString("Cancel", comment:"CMSettingsLogoutAlert : cancelButton : titleText")
        let cancelAction = CMAlertAction(title:cancelButtonText, style: .Secondary) { () -> () in
        }

        alertViewController.addAction(okAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
    
    // MARK: navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }
   
    func showEventHired() {
//        self.performSegue(.ShowHiredModal)
    }
    
    // MARK: button handlers
    func logout() {
        removeHandlers()
        gestureNavigationController?.disable()
        theView.startActivityIndicator()
        
        remoteService.logoutUser{ [unowned self] error in
            guard let e = error else {
                self.theView.stopActivityIndicator()
                self.gestureNavigationController?.enable()
                self.managedObjectContext.performChanges {
                    self.loggedInUser.logOut()
                }

                NSNotificationCenter.defaultCenter().postNotificationName(CaptureAppNotification.Logout.rawValue, object: nil)
                return
            }
            
            self.gestureNavigationController?.enable()
            self.theView.stopActivityIndicator()
            self.addHandlers()
            self.logoutError(e)
        }
    }

    func logoutError(error:NSError) {
        let logoutError                                 = NSLocalizedString("Sorry, could not connect to the network to log you out.", comment:"CMSettingsView : logoutError : text")
        theView.banner                        = CMMicroBanner(style: .Error)
        theView.banner?.message(logoutError)
        theView.banner?.topView               = self.view
        theView.banner?.show()
    }
    
}

extension SideNavViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SideNavTableViewCell.SideNavTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
        guard let navType = SideNavTypes(rawValue: indexPath.row) else { fatalError("No nav type for \(indexPath.row)") }
        switch navType {
        case .LIVEJobs:
            goToEventsList()
        case .JobHistory:
            goToJobHistory()
        case .Notifications:
            goToNotifications()
        case .Payments:
            goToPaypal()
        case .Support:
            goToSupport()
        }
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