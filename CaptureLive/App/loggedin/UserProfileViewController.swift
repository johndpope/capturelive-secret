//
//  UserProfileViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync

private let ExperienceDefaultCellHeight:CGFloat = 205

extension UserProfileViewController : CYNavigationPush {
    var seguePush:SeguePush {
        return { [unowned self] in
            self.performSegueWithIdentifier(self.segue.rawValue, sender: self)
        }
    }
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return AddSideNavAnimator()
    }
}

class UserProfileViewController: UITableViewController, SegueHandlerType, RemoteAndLocallyServiceable, SideNavPopable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var segue:SegueIdentifier           = SegueIdentifier.ShowSideNav
    
    enum SegueIdentifier:String {
        case ShowSideNav                = "showSideNav"
        case ShowEditUserProfile        = "CMCreateProfileViewController@LoggedOut"
        case ShowEditReel               = "CMReelViewController@LoggedOut"
        case ShowEditDevice             = "CMEquipmentViewController@LoggedOut"
        case ShowEditExperience         = "CMExperienceViewController@LoggedOut"
        case ShowRefreshFacebook        = "CMFacebookAuthViewController@LoggedOut"
    }
    
    @IBOutlet weak var firstNameLabel:UILabel?
    @IBOutlet weak var firstNameField:UITextField?
    @IBOutlet weak var lastNameLabel:UILabel?
    @IBOutlet weak var lastNameField:UITextField?
    @IBOutlet weak var ageLimitLabel:UILabel?
    @IBOutlet weak var ageLimitField:UITextField?
    @IBOutlet weak var emailLabel:UILabel?
    @IBOutlet weak var emailField:UITextField?
    @IBOutlet weak var avatarButton:UIButton?
    @IBOutlet weak var yearsExperienceLabel:UILabel?
    @IBOutlet weak var bioTextView:UITextView?
    @IBOutlet weak var bioLabel:UILabel?
    @IBOutlet weak var reelTableView:UITableView?
    @IBOutlet weak var equipmentTableView:UITableView?
    @IBOutlet weak var experienceTableView:UITableView?
    
    var user :User!
    var facebookUser:FacebookUser?
    
//    private var equipmentDataSource: DisplayEquipmentTableViewSource!
//    private var reelDataSource: DisplayReelTableSource!
//    private var categoryDataSource: DisplayCategoryTableViewSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fnText = NSLocalizedString("First Name", comment: "UserProfileViewController : firstNameLabel : text")
        firstNameLabel?.text = fnText
        firstNameLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        firstNameLabel?.enabled = false
        
        let lnText = NSLocalizedString("Last Name", comment: "UserProfileViewController : lastNameLabel : text")
        lastNameLabel?.text = lnText
        lastNameLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        lastNameLabel?.enabled = false

        let ageText = NSLocalizedString("18 years or older", comment: "UserProfileViewController : ageNameLabel : text")
        ageLimitLabel?.text = ageText
        ageLimitLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        ageLimitLabel?.enabled = false

        let emailText = NSLocalizedString("Email", comment: "UserProfileViewController : emailNameLabel : text")
        emailLabel?.text = emailText
        emailLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        emailLabel?.enabled = false
        
        firstNameField?.font = UIFont.comfortaa(.Regular, size: 18)
        lastNameField?.font = UIFont.comfortaa(.Regular, size: 18)
        ageLimitField?.font = UIFont.comfortaa(.Regular, size: 18)
        ageLimitField?.enabled = false
        emailField?.font = UIFont.comfortaa(.Regular, size: 18)

        avatarButton?.clipsToBounds                    = true
        avatarButton?.layer.cornerRadius               = 40
        avatarButton?.setTitle("", forState: .Normal)
 
        guard let user = User.loggedInUser(self.managedObjectContext) else { fatalError("No logged in user!") }
        self.user = user
       
        let bioText = NSLocalizedString("Professional Bio:", comment: "UserProfileViewController : bioLabel : text")
        bioLabel?.text = bioText
        bioLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        bioLabel?.enabled = false

        bioTextView?.editable = false
        
//        reelDataSource                  = DisplayReelTableSource(tableView:reelTableView!, reelDelegate:self)
//        equipmentDataSource             = DisplayEquipmentTableViewSource(tableView:equipmentTableView!, equipmentDelegate:self)
//        categoryDataSource              = DisplayCategoryTableViewSource(tableView:experienceTableView!, categoryDelegate:self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addEventHandlers()
        updateUser()
        segue = .ShowSideNav
    }
   
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeEventHandlers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        
    }
    
    func removeEventHandlers() {
    
    }

    func updateUser() {
        let ageYesText = NSLocalizedString("yes", comment: "UserProfileViewController : yes : text")
        let ageNoText = NSLocalizedString("no", comment: "UserProfileViewController : no : text")
        self.firstNameField?.text   = user.firstName ?? ""
        self.lastNameField?.text    = user.lastName ?? ""
        self.ageLimitField?.text    = user.isOverAgeRange ? ageYesText : ageNoText
        self.emailField?.text       = user.email ?? ""
       
        print(user.workReel)
//        reelDataSource.replaceReel(user.workReel)
//        equipmentDataSource.replaceEquip(user.equipment)
//        
//        guard let experience = user.experience else { fatalError("user has no experience") }
//        categoryDataSource.replaceOwnedCategories(experience.categories)
//        yearsExperienceLabel?.text = experience.level.localizedString
        bioTextView?.text = user.bio
        tableView.reloadData()
        
        guard let url = self.user.avatar else { return }
        CMImageCache.defaultCache().imageForPath(url, complete: { [weak self] error, image in
            if error == nil {
                self?.avatarButton?.backgroundColor = UIColor.blackColor()
                self?.avatarButton?.setBackgroundImage(image, forState: .Normal)
            }
        })
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext             = managedObjectContext
        vc.remoteService                    = remoteService
        
//        switch segueIdentifierForSegue(segue) {
//        case .ShowEditUserProfile:
//            guard let cprof = vc as? CMCreateProfileViewController else {
//                fatalError("Somehow not a CMCreateProfileViewController")
//            }
//            cprof.user                      = user
//            cprof.facebookUser              = self.facebookUser
//        case .ShowEditReel:
//            guard let reelVC = vc as? CMReelViewController else {
//                fatalError("Somehow not a CMReelViewController")
//            }
//            reelVC.user                     = user
//        case .ShowEditDevice:
//            guard let equipmentVC = vc as? CMEquipmentViewController else {
//                fatalError("Somehow not a CMEquipmentViewController")
//            }
//            equipmentVC.user                = user
//        case .ShowEditExperience:
//            guard let experienceVC = vc as? CMExperienceViewController else {
//                fatalError("Somehow not a CMExperienceViewController")
//            }
//            experienceVC.user               = user
//        case .ShowRefreshFacebook:
//            guard let experienceVC = vc as? CMFacebookAuthViewController else {
//                fatalError("Somehow not a CMFacebookAuthViewController")
//            }
//            experienceVC.user               = user
//        }
    }
    
    func sectionSelected(sender:UIButton) {
        print(sender.tag)
        switch sender.tag {
        case 1:
            performSegue(.ShowEditReel)
        case 2:
            performSegue(.ShowEditDevice)
        case 3:
            performSegue(.ShowEditExperience)
        default:
            self.requestFacebookAuthorization()
        }
    }
    
    //MARK: UITableSource
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 1 {
//            return reelDataSource.totalHeight
//        }
//        if indexPath.section == 2 {
//            return equipmentDataSource.totalHeight
//        }
//        if indexPath.section == 3 {
//            return categoryDataSource.totalHeight + ExperienceDefaultCellHeight
//        }
//        return super.tableView(tableView, heightForRowAtIndexPath:indexPath)
//    }
//    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 35
//    }
//
//    private let sectionTitles = [
//         NSLocalizedString("profile ",              comment:"UserProfileViewController : profileSectinLabel : text")
//        ,NSLocalizedString("work reel",             comment:"UserProfileViewController : workReelSectionLabel : text")
//        ,NSLocalizedString("smartphone equipment",  comment:"UserProfileViewController : smartPhoneSectionLabel : text")
//        ,NSLocalizedString("experience",            comment:"UserProfileViewController : experienceSectionLabel : text")
//    ]
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view                                            = UIView()
//        view.backgroundColor                                = UIColor.whiteColor()
//        let label                                           = UILabel()
//        label.text                                          = sectionTitles[section]
//        label.font                                          = UIFont.comfortaa(.Bold, size: 14)
//        label.textColor                                     = UIColor.greenCurrent()
//        label.translatesAutoresizingMaskIntoConstraints     = false
//
//        let button                                          = UIButton(type:.System)
//        button.translatesAutoresizingMaskIntoConstraints    = false
//        button.setTitle("->", forState: .Normal)
//        button.addTarget(self, action:#selector(sectionSelected(_:)), forControlEvents: .TouchUpInside)
//        button.tag                                          = section
//        
//        let views                                           = ["label": label, "button":button, "view": view]
//        view.addSubview(label)
//        view.addSubview(button)
//        let horizontallayoutContraints                      = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[label]-60-[button]-10-|", options: .AlignAllCenterY, metrics: nil, views: views)
//        view.addConstraints(horizontallayoutContraints)
//        
//        let verticalLayoutContraint                         = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
//        view.addConstraint(verticalLayoutContraint)
//        return view
//    }
//
}

extension UserProfileViewController : FacebookAuthAble {
    
    func fetchedFacebookUser(faceuser:FacebookUser) {
        self.facebookUser           = faceuser
        performSegue(.ShowEditUserProfile)
    }
    
    func fetchFacebookUserDidFail(error:NSError) {
        let alertViewController         = CMAlertController(title:"I can't believe you've done this.", message: error.localizedDescription)
        let whoopsAction                = CMAlertAction(title:"OK", style: .Primary, handler: nil)
        alertViewController.addAction(whoopsAction)
        CMAlert.presentViewController(alertViewController)
    }
    
}

//extension UserProfileViewController : EquipmentTableSourceProtocol {
//    func equipmentSelected(equipment:Equipment) {
//        performSegue(.ShowEditDevice)
//    }
//}
//
//extension UserProfileViewController : DisplayReelProtocol {
//    func selectedReel(reel:Reel) {
//        performSegue(.ShowEditReel)
//    }
//}
//
//extension UserProfileViewController : CategoryTableSourceProtocol {
//    func categorySelected(category:EventCategory) {
//        performSegue(.ShowEditExperience)
//    }
//}
