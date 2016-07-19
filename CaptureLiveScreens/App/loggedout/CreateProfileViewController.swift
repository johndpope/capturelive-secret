//
//  CMCreateProfileViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class CreateProfileViewController: UIViewController, SegueHandlerType {

    private typealias Data = CreateProfileDataProvider<CreateProfileViewController>
    private var dataSource:TableViewDataSource<CreateProfileViewController, Data, ProfileTableViewCell>!
    private var dataProvider: Data!
    
    var theView:CreateProfileView {
        guard let v = self.view as? CreateProfileView else { fatalError("Not a \(CreateProfileView.self)!") }
        return v
    }
    
    enum SegueIdentifier:String {
        case EmbedNavigation = "embedNavigationSegue"
    }
    
    var formNavigationController:ProfileCreationNavController! {
        didSet {
            let storyboard = UIStoryboard(name:"LoggedOut", bundle:nil)
            formNavigationController.viewControllers = [storyboard.instantiateViewControllerWithIdentifier("ExperienceViewController")]
            self.defaultUserDictionary = [ProfileTableCellType.PROFILE.rawValue:defaultProfile]
            formNavigationController.createProfileDelegate = self
            formNavigationController.onlyUpdate = true
            formNavigationController.viewWillAppear(false)
        }
    }
    
    var defaultUserDictionary:[String:ProfileTableCellInfo] = [:]
    let defaultProfile = ProfileTableCellInfo(
        title:NSLocalizedString("Your Profile", comment: "ProfileTableViewCell : titleLabel : text")
        ,type:.PROFILE
        ,roundButtons:[
            SocialImageCellViewModel(
                avatarPath:"https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,icon:""
            )
        ]
    )
 
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        theView.updateTableViewHeight(dataProvider.numberOfItemsInSection(0))
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
        }
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
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

