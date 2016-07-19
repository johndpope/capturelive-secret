//
//  CMPermissionsManager.swift
//  Capture-Live
//
//  Created by hatebyte on 6/29/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CoreLocation

enum Permissions : Int {
    case NONE                   = 0
    case LocationTracking       = 1
    case PushNotifications      = 2
    case ALL                    = 3
}

enum PermissionAlerts : String {
    case LocationTracking       = "LocationTracking"
    case PushNotifications      = "PushNotifications"
}

public typealias Accepted = ()->()
public typealias Denied = ()->()

public class CMPermissionsManager: NSObject {

    static let DEVICE_TOKEN                         = "com.capturemedia.user.device.token"

    var accepted:Accepted!
    var denied:Denied!
    
    let persistanceLayer:ApplicationRememberable!
    
    public init(persistanceLayer:ApplicationRememberable) {
        self.persistanceLayer = persistanceLayer
        super.init()
    }
    
    func hasAcceptedSettings()->Bool {
        return (hasLocationSettingsTurnedOn() == true && hasNotificationsTurnedOn() == true)
    }
    
    public func hasLocationSettingsTurnedOn()->Bool {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            return false
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted {
            return false
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            return false
        }
        return true
    }
    
    public func hasNotificationsTurnedOn()->Bool {
//        let application                         = UIApplication.sharedApplication()
        var enabled                             = false
//        if #available(iOS 8.0, *) {
            let notifSettings                   = UIApplication.sharedApplication().currentUserNotificationSettings()!
            enabled                             = (notifSettings.types != UIUserNotificationType.None)
//        } else {
//            let types                           = application.enabledRemoteNotificationTypes()
//            enabled                             = !(types == UIRemoteNotificationType.None)
//        }
        return enabled
    }
    
    func areThereNotificationSettings()->Bool {
//        if #available(iOS 8.0, *) {
            if let _ = UIApplication.sharedApplication().currentUserNotificationSettings() {
                return true
            }
//        }
        return false
    }
    
    func askForLocationPermission() {
        CMUserMovementManager.shared.startSemiPreciseLocation { (location, transportation) -> () in }
    }
    
    func askForPushPermission() {
        if  hasNotificationsTurnedOn() == true && hasDeviceToken() {
            return
        }

//        if #available(iOS 8.0, *) {
            let settings                            = UIUserNotificationSettings(forTypes:([UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge]), categories: nil)
            print(UIApplication.sharedApplication())
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
//        } else {
//            let types: UIRemoteNotificationType                               = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert]
//            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
//        }
    }
    
    
    func permissions()->Permissions {
        var p = Permissions.NONE
        
        if hasLocationSettingsTurnedOn() == true {
            p = Permissions.LocationTracking
        }
        if hasNotificationsTurnedOn() == true {
            p = (p == Permissions.LocationTracking) ? Permissions.ALL : Permissions.PushNotifications
        }
        
        return p
    }

    func navigateToSettings() {
//        if #available(iOS 8.0, *) {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
//        } else {
//            print("Can't open Settings URL. Not available in this SDK")
//        }
    }

//    func checkSettingStatus(viewController:UIViewController) {
//        // check permissions
//        let hasBothPermissions                      = self.hasAcceptedSettings()
//        
//        let controllerName                          = NSStringFromClass(viewController.dynamicType)
//        if controllerName == self.modalName && hasBothPermissions == true {
//            // remove controller
//            viewController.dismissViewControllerAnimated(true, completion: nil)
//        }
//       
//        if controllerName != self.modalName && hasBothPermissions == false {
//            // add controller
//            let vc = CMPermissionsBlockModalViewController(nibName:"CMPermissionsBlockModalViewController", bundle:nil)
//            viewController.navigationController?.presentViewController(vc, animated: true, completion: nil)
//        }
//    }

//    func saveDeviceToken(data:NSData) {
//        let tokenChars                              = UnsafePointer<CChar>(data.bytes)
//        var deviceToken                             = ""
//        
//        for var i = 0; i < data.length; i++ {
//            deviceToken += String(format: "%02.2hhx", arguments: [tokenChars[i]])
//        }
//        persistanceLayer.setDevicePushToken(deviceToken)
//    }
    
    func hasDeviceToken()->Bool {
        return persistanceLayer.pushToken != nil
    }

   
    //MARK: Alert 
    func attemptToNavigateUserToSettings() {
        print("TODO : Add navigate to setttings!!!!!!!! CMPermissionsManager - line 157")
//        let title                       = NSLocalizedString("PERMISSIONS ALERT", comment: "PermissionsScreen : promptToUserSettingsAlert : title")
//        let message                     = NSLocalizedString("You must enable all permissions in order to get jobs.", comment: "PermissionsScreen : promptToUserSettingsAlert : title")
//        let okButton                    = NSLocalizedString("GO TO SETTINGS", comment: "PermissionsScreen : promptToUserSettingsAlert : okButtonTitle")
//        let cancelButton                = NSLocalizedString("NO THANKS", comment: "PermissionsScreen : promptToUserSettingsAlert : cancelButtonTitle")
//        
//        let alertView                   = CMAlertController(title:title, message: message)
//        let settingsAction = CMAlertAction(title:okButton, style: .Primary) { () -> () in
//            CMPermissionsManager.shared.navigateToSettings()
//        }
//        
//        let cancelAction = CMAlertAction(title:cancelButton, style: .Secondary, handler:nil)
//        
//        alertView.addAction(cancelAction)
//        alertView.addAction(settingsAction)
//        
//        CMAlert.presentViewController(alertView)
    }
    
}
