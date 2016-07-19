//
//  CMPaypalViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/19/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

extension PaypalViewController : CYNavigationPush {
    var seguePush:SeguePush {
        return { [unowned self] in
            self.performSegueWithIdentifier(self.segue.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return AddSideNavAnimator()
    }
}
class PaypalViewController: UIViewController, SegueHandlerType, SideNavPopable, NavGesturable, RemoteAndLocallyServiceable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    private let payPalConfig = PayPalConfiguration()
    private var observer:ManagedObjectObserver?
    var user:User!
    var segue:SegueIdentifier           = SegueIdentifier.ShowSideNav
    
    enum SegueIdentifier:String {
        case ShowSideNav                = "showSideNav"
    }

    var theView:PaypalView {
        guard let v = self.view as? PaypalView else { fatalError("Not a PaypalView!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<PaypalViewController>
    private var dataSource:TableViewDataSource<PaypalViewController, Data, PaypalTableViewCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let luser = User.loggedInUser(managedObjectContext) else {
            fatalError("No attempting login user")
        }
        self.user = luser
        theView.didLoad()
     
        payPalConfig.languageOrLocale       = NSLocale.preferredLanguages()[0]
        payPalConfig.payPalShippingAddressOption = .PayPal;
        payPalConfig.merchantName           = "Capture Media Inc."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        observer = ManagedObjectObserver(object:user) { [unowned self] type in
            guard type == .Update else {
                return
            }
            self.updatePaypalInfo()
        }
        addHandlers()
        updatePaypalInfo()
        segue = .ShowSideNav
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
        observer = nil
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func addHandlers() {
        removeHandlers()
        theView.verifyButton?.addTarget(self, action: #selector(verifyPaypal), forControlEvents: .TouchUpInside)
        theView.backButton?.addTarget(self, action: #selector(showSideNav), forControlEvents: .TouchUpInside)
        theView.paypalLogoButton?.addTarget(self, action: #selector(resetPaypal), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.verifyButton?.removeTarget(self, action: #selector(verifyPaypal), forControlEvents: .TouchUpInside)
        theView.backButton?.removeTarget(self, action: #selector(showSideNav), forControlEvents: .TouchUpInside)
        theView.paypalLogoButton?.addTarget(self, action: #selector(resetPaypal), forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func resetPaypal() {
        managedObjectContext.performChanges { [unowned self] in
            self.user.resetPaypalExperience()
        }
    }
    
    func showSideNav() {
        segue = .ShowSideNav
        performSeguePush()
    }
    
    func verifyPaypal() {
        let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
        presentViewController(profileSharingViewController!, animated: true, completion: nil)
    }
    
    func updatePaypalInfo() {
        let viewModel = user.paypalModel()
        theView.populate(viewModel)
       
        if viewModel.hasPaypalEmailBool {
            let contracts                               = Contract.fetchPaidContracts(managedObjectContext)
            let models                                  = contracts.map { $0.paypalModel() }
            dataProvider                                = DefaultDataProvider(items:models, delegate :self)
            dataSource                                  = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
            theView.tableView?.delegate                 = self
        }
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }
}

extension PaypalViewController : PayPalProfileSharingDelegate {
    
    func userDidCancelPayPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController) {
        print("PayPal Profile Sharing Authorization Canceled")
        
        profileSharingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalProfileSharingViewController(profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [NSObject : AnyObject]) {
        print("PayPal Profile Sharing Authorization Success!")
        guard let aCode = profileSharingAuthorization["response"]?["code"] as? String else {
            fatalError("Paypal return didShare without temp code ")
        }
        managedObjectContext.performChanges { [weak self] in
            self?.user.paypalAccessCode = aCode
        }
 
        profileSharingViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            print(profileSharingAuthorization.description)
        })
    }

}


extension PaypalViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return PaypalTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
//        back()
    }
    
}

extension PaypalViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<PaypalViewModel>]?) {
    }
}

extension PaypalViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:PaypalViewModel) -> String {
        return PaypalTableViewCell.Identifier
    }
}