//
//  PermissionsViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

extension CYNavigationPop where Self : PermissionsViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopBottomAnimator()
    }
}

enum PermissionsType: String {
    case PushNotifications = "push_notifications"
    case LocationServices = "location_services"
}

class PermissionsViewController: UIViewController, CYNavigationPop {

    var theView:PermissionsView {
        guard let v = self.view as? PermissionsView else { fatalError("Not a \(PermissionsView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<PermissionsViewController>
    private var dataSource:CollectionViewDataSource<PermissionsViewController, Data, ProfileCollectionCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        let items :[CellDecoratable] = [
            ProfileImageCompletedCellViewModel(
                type:PermissionsType.LocationServices.rawValue
                ,title:NSLocalizedString("LOCATION SERVICES", comment: "PermissionsViewController : locationsButton : title")
                ,imageNameEnabled:"icon_serviceenabled"
                ,imageNameDisabled:"icon_servicedisabled"
                ,completed:false
            )
            ,ProfileImageCompletedCellViewModel(
                type:PermissionsType.PushNotifications.rawValue
                ,title:NSLocalizedString("PUSH NOTIFICATIONS", comment: "PermissionsViewController : pushNotifications : title")
                ,imageNameEnabled:"icon_serviceenabled"
                ,imageNameDisabled:"icon_servicedisabled"
                ,completed:false
            )
        ]
        theView.collectionView?.delegate = self
        
        theView.didLoad()
        createDataProviders(items)
    }

    func createDataProviders(items:[CellDecoratable]) {
        dataProvider    = DefaultDataProvider(items:items, delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: Button Handlers
    func showLocationAlert() {
        let title               = NSLocalizedString("ACCEPT CAPTURELIVE LOCATION SERVICES", comment:"PermissionsViewController : locationsAlert : title")
        let alertViewController = CMAlertWithImageViewController(
            title:title,
            message:NSLocalizedString("This is dummy content ipsum this i dummy Lorim ipsum this i dummy", comment: "PermissionsViewController : locationsAlert : body"),
            imageName:"icon_locationservices"
        )

        let okButtonText        = NSLocalizedString("NEXT", comment:"PermissionsViewController : locationsAlert : buttontext")
        let okAction            = CMAlertAction(title:okButtonText, style: .Primary)
        alertViewController.addAction(okAction)
        
        CMAlert.presentViewController(alertViewController)
    }
    
    func showNotificationsAlert() {
        let title               = NSLocalizedString("ACCEPT CAPTURELIVE PUSH NOTIFICATIONS", comment:"PermissionsViewController : pushesAlert : title")
        let alertViewController = CMAlertWithImageViewController(
            title:title,
            message:NSLocalizedString("This is dummy content ipsum this i dummy Lorim ipsum this i dummy", comment: "PermissionsViewController : pushesAlert : body"),
            imageName:"icon_notifications"
        )
        
        let okButtonText        = NSLocalizedString("NEXT", comment:"PermissionsViewController : pushesAlert : buttontext")
        let okAction            = CMAlertAction(title:okButtonText, style: .Primary)
        alertViewController.addAction(okAction)
        
        CMAlert.presentViewController(alertViewController)
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