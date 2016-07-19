//
//  CMCreateProfileViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

extension CreateProfileViewController : CYNavigationPush {
    var seguePush:SeguePush {
        return { [unowned self] in
            self.performSegueWithIdentifier(self.segue.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        if self.segue == .ShowSideNav {
            return AddSideNavAnimator()
        }
        return nil
    }
}

class CreateProfileViewController: UIViewController, SegueHandlerType, SideNavPopable, NavGesturable, RemoteAndLocallyServiceable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var user:User!
    var segue:SegueIdentifier                   = SegueIdentifier.ShowSideNav
    
    private typealias Data = CreateProfileDataProvider<CreateProfileViewController>
    private var dataSource:TableViewDataSource<CreateProfileViewController, Data, ProfileTableViewCell>!
    private var dataProvider: Data!
    private var observer:ManagedObjectObserver?
 
    var theView:CreateProfileView {
        guard let v = self.view as? CreateProfileView else { fatalError("Not a \(CreateProfileView.self)!") }
        return v
    }
    
    enum SegueIdentifier:String {
        case ShowSideNav                        = "showSideNav"
        case EmbedNavigation                    = "embedNavigationSegue"
        case ShowVerifiedScreen                 = "showVerifiedScreen"
    }
   
    var defaultUserDictionary:[String:ProfileTableCellInfo] = [:]
    var defaultProfile : ProfileTableCellInfo {
        guard let avatar = formNavigationController.user.avatar else { fatalError("User has not avatar") }
        return ProfileTableCellInfo(
            title:NSLocalizedString("Your Profile", comment: "ProfileTableViewCell : titleLabel : text")
            ,type:.PROFILE
            ,roundButtons:[
                SocialImageCellViewModel(
                    avatarPath:avatar
                    ,icon:""
                )
            ]
        )
    }
    
    var formNavigationController:ProfileCreationNavController! {
        didSet {
            formNavigationController.managedObjectContext        = managedObjectContext
            formNavigationController.remoteService               = remoteService
            if !formNavigationController.isAttemptingUser {
                let storyboard = UIStoryboard(name:"LoggedOut", bundle:nil)
                formNavigationController.viewControllers = [storyboard.instantiateViewControllerWithIdentifier("ExperienceViewController")]
                self.defaultUserDictionary = [ProfileTableCellType.PROFILE.rawValue:defaultProfile]
            } else {
                let storyboard = UIStoryboard(name:"LoggedOut", bundle:nil)
                formNavigationController.viewControllers = [storyboard.instantiateViewControllerWithIdentifier("WelcomeViewController")]
                self.defaultUserDictionary = [:]
            }
            
            formNavigationController.createProfileDelegate      = self
            formNavigationController.viewWillAppear(false)
            guard let firstVC = formNavigationController.viewControllers.first as? RemoteAndLocallyServiceable else {
                fatalError("The formNavigationController does not have a root view controller that is RemoteAndLocallyServiceable")
            }
            firstVC.managedObjectContext                        = managedObjectContext
            firstVC.remoteService                               = remoteService
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        user                = formNavigationController.user
        automaticallyAdjustsScrollViewInsets = true
        theView.didLoad()
        theView.tableView?.delegate = self
 
        dataProvider        = CreateProfileDataProvider(userDictionary:defaultUserDictionary, delegate:self)
        dataSource          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addHandlers()
        if user.isAttemptingLogin {
            segue = .ShowVerifiedScreen
            navGesturer?.denyGestures()
        } else {
            theView.activityIndicator?.hidden = true
        }
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        navGesturer?.statusBarStyle     = .Default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !user.isAttemptingLogin {
            managedObjectContext.saveOrRollback()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    override func viewDidLayoutSubviews() {
        theView.updateTableViewHeight(dataProvider.numberOfItemsInSection(0))
        super.viewDidLayoutSubviews()
    }
    
    func addHandlers() {
        removeHandlers()
        theView.backButton?.addTarget(self, action:#selector(goBack), forControlEvents:.TouchUpInside)
    }
    
    func removeHandlers() {
        theView.backButton?.removeTarget(self, action:#selector(goBack), forControlEvents:.TouchUpInside)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .EmbedNavigation:
            guard let nav = segue.destinationViewController as? ProfileCreationNavController else {
                fatalError("not a UINavigationController")
            }
            self.formNavigationController = nav
        default:
            guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            vc.managedObjectContext = managedObjectContext
            vc.remoteService        = remoteService
        }
    }
    
    func goBack() {
        if user.isAttemptingLogin {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            segue = .ShowSideNav
            performSeguePush()
        }
    }

    func popToExperience() {
        dataProvider.popToExperience()
        formNavigationController.popToExperience()
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
    }
    
    func popToWork() {
        dataProvider.popToWork()
        formNavigationController.popToWork()
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
    }
    
    func popToPhotoExtras() {
        dataProvider.popToPhotoExtras()
        formNavigationController.popToPhotoExtras()
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
    }
   
    var predicateForLocallyTrackedElements:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [User.hasNoValidationErrorPredicate, User.markedForRemoteVerificationPredicate ])
    }
    
    //MARK : Observer response
    func updateResponse() {
        print(self.user)
        if User.hasValidationErrorPredicate.evaluateWithObject(self.user){
            print("DO NOT PROCEEED EVEN!!!!!!!!!!")
            self.theView.profileUpdate(self.user.validationError!)
            theView.unblockInteraction()
            observer = nil
            theView.stopActivityIndicator()
            return
        }

        if User.notMarkedForRemoteVerificationPredicate.evaluateWithObject(user) {
            if User.hasAcceptedTermsAndConditionsPredicate.evaluateWithObject(user) {
                print("PROCEEED EVEN!!!!!!!!!!")
                theView.stopActivityIndicator()
                theView.unblockInteraction()
                observer = nil
                performSeguePush()
            }
        }
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}

extension CreateProfileViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
        let object = self.dataProvider.objectAtIndexPath(indexPath)
        switch object.type {
        case .PROFILE:
            break
        case .EXPERIENCE:
            popToExperience()
        case .WORK:
            popToWork()
        case .PHOTOEXTRAS:
            popToPhotoExtras()
        }
        theView.layoutIfNeeded()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ProfileTableViewCell.ProfileTableViewCellHeight
    }
    
}

extension CreateProfileViewController : CreateProfileNavControllable {
   
    func addProfile(info:ProfileTableCellInfo) {
        dataProvider.addProfile(info)
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
        theView.layoutIfNeeded()
    }
    
    func addExperience(info:ProfileTableCellInfo) {
        dataProvider.addExperience(info)
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
        theView.layoutIfNeeded()
    }
    
    func addWork(info:ProfileTableCellInfo) {
        dataProvider.addWork(info)
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
        theView.layoutIfNeeded()
    }
    
    func addPhotoExtras(info:ProfileTableCellInfo) {
        dataProvider.addPhotoExtras(info)
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
        theView.layoutIfNeeded()
    }
   
    func addPermissions(info:ProfileTableCellInfo) {
        dataProvider.addPhotoExtras(info)
        theView.animateUpdateTableViewHeight(dataProvider.numberOfItemsInSection(0))
        theView.layoutIfNeeded()
    }
    
    func profileCreationComplete() {
        theView.startActivityIndicator()
        theView.blockInteraction()
        observer = ManagedObjectObserver(object:user) { [unowned self] type in
            guard type == .Update else {
                return
            }
            self.updateResponse()
        }
        managedObjectContext.performChanges { [unowned self] in
            self.user.validationError         = nil
            self.user.needsRemoteVerification = true
            self.user.acceptTermsAndConditions()
        }
    }
    
}

extension CreateProfileViewController : DataProviderDelegate {
    
    func dataProviderDidUpdate(updates:[DataProviderUpdate<ProfileTableCellInfo>]?) {
        dataSource.processUpdates(updates)
    }

}

extension CreateProfileViewController : DataSourceDelegate {
    
    func cellIdentifierForObject(object:ProfileTableCellInfo) -> String {
        return ProfileTableViewCellIdentifier
    }

}

