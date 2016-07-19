//
//  PermissionsViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureModel
import CaptureSync
import CaptureCore
import CoreData

extension CYNavigationPop where Self : PermissionsViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopBottomAnimator()
    }
}

enum PermissionsType: String {
    case PushNotifications = "push_notifications"
    case LocationServices = "location_services"
}

class PermissionsViewController: UIViewController, CYNavigationPop, RemoteAndLocallyServiceable, SegueHandlerType, CreateProfileNavControllerChild {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var user:User!
    var permissionsManager:CMPermissionsManager!

    enum SegueIdentifier:String {
        case ShowTermsAndConditionScreen    = "showTermsAndConditionScreen"
    }
    
    var theView:PermissionsView {
        guard let v = self.view as? PermissionsView else { fatalError("Not a \(PermissionsView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<PermissionsViewController>
    private var dataSource:CollectionViewDataSource<PermissionsViewController, Data, ProfileCollectionCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user                                = navContainer.user
        
        permissionsManager                  = CMPermissionsManager(persistanceLayer: managedObjectContext)
        theView.didLoad()
        tryToEnableSubmitButton()
        theView.collectionView?.delegate    = self
        theView.checkbox?.selected          = (user.acceptedTNCDate != nil)
    }
   
    var locationPermissionsVM:CellDecoratable {
        let title = NSLocalizedString("LOCATION SERVICES", comment: "PermissionsViewController : locationsButton : title")
        if managedObjectContext.hasBeenAskedForLocationInformation {
            return ProfileImageCompletedCellViewModel(
                type:PermissionsType.LocationServices.rawValue
                ,title:title
                ,imageNameEnabled:"icon_serviceenabled"
                ,imageNameDisabled:"icon_servicedisabled"
                ,completed:permissionsManager.hasLocationSettingsTurnedOn()
            )
        } else {
            return ProfileImageCompletedCellViewModel(
                type:PermissionsType.LocationServices.rawValue
                ,title:title
                ,imageNameEnabled:"icon_tapForPrompt"
                ,imageNameDisabled:"icon_tapForPrompt"
                ,completed:false
            )
        }
    }
    
    var pushPermissionsVM:CellDecoratable {
        let title = NSLocalizedString("PUSH NOTIFICATIONS", comment: "PermissionsViewController : pushNotifications : title")
        if managedObjectContext.hasBeenAskedForPushNotifications {
            return ProfileImageCompletedCellViewModel(
                type:PermissionsType.PushNotifications.rawValue
                ,title:title
                ,imageNameEnabled:"icon_serviceenabled"
                ,imageNameDisabled:"icon_servicedisabled"
                ,completed:permissionsManager.hasNotificationsTurnedOn()
            )
        } else {
            return ProfileImageCompletedCellViewModel(
                type:PermissionsType.PushNotifications.rawValue
                ,title:title
                ,imageNameEnabled:"icon_tapForPrompt"
                ,imageNameDisabled:"icon_tapForPrompt"
                ,completed:false
            )
        }
    }

    func createDataProviders() {
        dataProvider    = DefaultDataProvider(items:[locationPermissionsVM, pushPermissionsVM], delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventHandlers()
        createDataProviders()
        tryToEnableSubmitButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
    }
    
    func addEventHandlers() {
        self.removeEventHandlers()
        self.theView.checkbox?.addTarget(self, action: #selector(checkboxTapped), forControlEvents: .TouchUpInside)
        self.theView.submitButton?.addTarget(self, action:#selector(submitButtonTap), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(createDataProviders), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func removeEventHandlers() {
        self.theView.checkbox?.removeTarget(self, action: #selector(checkboxTapped), forControlEvents: .TouchUpInside)
        self.theView.submitButton?.removeTarget(self, action: #selector(submitButtonTap), forControlEvents: .TouchUpInside)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
   
    func tryToEnableSubmitButton() {
        theView.submitButton?.enabled       = (user.acceptedTNCDate != nil && managedObjectContext.hasAcceptedPermissions)
    }
    
    func promptForPushNotifications() {
        permissionsManager.askForPushPermission(pushesActedOn, denied: pushesActedOn)
    }
    
    func pushesActedOn() {
        createDataProviders()
        tryToEnableSubmitButton()
    }
    
    func promptForLocationTracking() {
        permissionsManager.askForLocationPermission(locationsActedOn, denied: locationsActedOn)
        LocationFrequencyGateway.shared.trackLocation()
        LocationFrequencyGateway.shared.trackSignificantLocation()
    }
    
    func locationsActedOn() {
        createDataProviders()
        tryToEnableSubmitButton()
    }

    func termsCompleted(accepted:Bool) {
        theView.checkbox?.selected = accepted
        if accepted == true {
            managedObjectContext.performChangesAndWait { [unowned self] in
                self.user.acceptTermsAndConditions()
            }
        }
        tryToEnableSubmitButton()
    }
    
    // MARK: Button Handlers
    func submitButtonTap() {
        navContainer.tryToCompleteProfile()
    }
    
    func checkboxTapped() {
        if theView.checkbox!.selected { return }
        performSegue(.ShowTermsAndConditionScreen)
    }
    
    func showLocationAlert() {
        if managedObjectContext.hasBeenAskedForLocationInformation { return }
        let title               = NSLocalizedString("ACCEPT CAPTURELIVE LOCATION SERVICES", comment:"PermissionsViewController : locationsAlert : title")
        let alertViewController = CMAlertWithImageViewController(
            title:title,
            message:NSLocalizedString("This is dummy content ipsum this i dummy Lorim ipsum this i dummy", comment: "PermissionsViewController : locationsAlert : body"),
            imageName:"icon_locationservices"
        )
        
        let okButtonText        = NSLocalizedString("NEXT", comment:"PermissionsViewController : locationsAlert : buttontext")
        let okAction            = CMAlertAction(title:okButtonText, style: .Primary) { [unowned self] in
            self.managedObjectContext.performChangesAndWait { [unowned self] in
                self.managedObjectContext.saveHasBeenAskedForLocationInformation()
            }
            self.promptForLocationTracking()
        }
        alertViewController.addAction(okAction)
        
        CMAlert.presentViewController(alertViewController)
    }
    
    func showNotificationsAlert() {
        if managedObjectContext.hasBeenAskedForPushNotifications { return }
        let title               = NSLocalizedString("ACCEPT CAPTURELIVE PUSH NOTIFICATIONS", comment:"PermissionsViewController : pushesAlert : title")
        let alertViewController = CMAlertWithImageViewController(
            title:title,
            message:NSLocalizedString("This is dummy content ipsum this i dummy Lorim ipsum this i dummy", comment: "PermissionsViewController : pushesAlert : body"),
            imageName:"icon_notifications"
        )
        
        let okButtonText        = NSLocalizedString("NEXT", comment:"PermissionsViewController : pushesAlert : buttontext")
        let okAction            = CMAlertAction(title:okButtonText, style: .Primary) { [unowned self] in
            self.managedObjectContext.performChangesAndWait { [unowned self] in
                self.managedObjectContext.saveHasBeenAskForPushNotifications()
            }
            self.promptForPushNotifications()
        }
        alertViewController.addAction(okAction)
        
        CMAlert.presentViewController(alertViewController)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext = managedObjectContext
        vc.remoteService        = remoteService
        
        guard let termsVC = segue.destinationViewController as? TermsOfServiceRegistrationViewController else {
            fatalError("not a TermsOfServiceRegistrationViewController")
        }
        termsVC.termsCompleted = termsCompleted
    }
    
}


extension PermissionsViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject else { return }
        collectionView.deselectItemAtIndexPath(indexPath, animated:false)
        guard let type = PermissionsType(rawValue: object.type) else { return }
        switch type {
        case .LocationServices:
            showLocationAlert()
        case .PushNotifications:
            showNotificationsAlert()
        }
    }
}

extension PermissionsViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<CellDecoratable>]?) {
        dataSource.processUpdates(updates)
    }
}

extension PermissionsViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:CellDecoratable) -> String {
        return ProfileCollectionCellIdentifier
    }
}
