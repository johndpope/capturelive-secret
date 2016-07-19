//
//  CMSupportViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureCore
import CoreData
import CaptureSync

enum SupportScreenType:Int {
    case FAQs
    case HowItWorks
    case TermsConditions
    case PrivacyPolicy
}

extension SupportViewController : CYNavigationPush {
    var seguePush:SeguePush {
        return { [unowned self] in
            self.performSegueWithIdentifier(self.segue.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        if segue == .ShowSideNav {
            return AddSideNavAnimator()
        }
        return nil
    }
}
class SupportViewController: UIViewController, SegueHandlerType, SideNavPopable, NavGesturable, RemoteAndLocallyServiceable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var segue:SegueIdentifier               = SegueIdentifier.ShowSideNav
    
    enum SegueIdentifier:String {
        case ShowSideNav                    = "showSideNav"
        case ShowAbout                      = "pushToAboutScreen"
        case ShowTermsConditions            = "pushToTermsConditionsScreen"
        case ShowContact                    = "pushToContactScreen"
        case ShowPrivacyPolicy              = "pushToPrivacyScreen"
    }
    
    var theView:SupportView {
        guard let v = self.view as? SupportView else { fatalError("Not a CMSupportView!") }
        return v
    }
    
    private typealias Data                  = DefaultDataProvider<SupportViewController>
    private var dataSource: TableViewDataSource<SupportViewController, Data, SupportTableViewCell>!
    private var dataProvider: Data!
   
    let tableData:[String] = [
         NSLocalizedString("FAQs", comment: "CMSupportViewController : faqs : celltitle")
        ,NSLocalizedString("How it Works", comment: "CMSupportViewController : howitworks : celltitle")
        ,NSLocalizedString("Terms and Conditions", comment: "CMSupportViewController : termsconditions : celltitle")
        ,NSLocalizedString("Privacy Policy", comment: "CMSupportViewController : privacypolicy : celltitle")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        automaticallyAdjustsScrollViewInsets = true
        
        dataProvider                        = DefaultDataProvider(items:tableData, delegate :self)
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider:dataProvider, delegate:self)
        theView.tableView?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addHandlers()
//        self.showReachiblity()
        segue = .ShowSideNav
        navGesturer?.usePushLeftPopRightGestureRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        theView.layoutSubviews()
        theView.updateTableViewHeight(tableData.count)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func addHandlers() {
        self.removeHandlers()
        self.theView.backButton?.addTarget(self, action: #selector(showSideNav), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        self.theView.backButton?.removeTarget(self, action: #selector(showSideNav), forControlEvents: .TouchUpInside)
    }
   
    
    //MARK: Button handlers
    func goToFAQs() {
        UIApplication.sharedApplication().openURL(NSURL(string:"https://currenthelp.zendesk.com/hc/en-us")!)
    }
    
    func goToTerms() {
        segue = .ShowTermsConditions
        performSeguePush()
    }
   
    func goToPrivacyPolicy() {
        segue = .ShowPrivacyPolicy
        performSeguePush()
    }

    func goToHowItWorks() {
        segue = .ShowContact
        performSeguePush()
    }
   
    func showSideNav() {
        segue = .ShowSideNav
        performSeguePush()
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowSideNav:
            guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            vc.managedObjectContext                         = managedObjectContext
            vc.remoteService                                = remoteService
        default:
            break
        }
    }

}


extension SupportViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SupportTableViewCell.SupportTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
        guard let type = SupportScreenType(rawValue:indexPath.row) else { fatalError("No supportScreen type for \(indexPath.row)") }
        switch type {
        case .FAQs:
            goToFAQs()
        case .HowItWorks:
            goToHowItWorks()
        case .PrivacyPolicy:
            goToPrivacyPolicy()
        case .TermsConditions:
            goToTerms()
        }
    }
    
}

extension SupportViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<Title>]?) {
    }
}

extension SupportViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:Title) -> String {
        return SupportTableViewCellIdentifier
    }
}