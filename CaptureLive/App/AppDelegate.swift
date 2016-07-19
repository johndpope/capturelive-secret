//
//  AppDelegate.swift
//  Current
//
//  Created by Scott Jones on 3/7/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers
import FBSDKCoreKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let hockeyApp                                        = BITHockeyManager.sharedHockeyManager()

    var navigationController:CMNavigationController!
    var notificationManager:NotificationManager!
    var managedObjectContext: NSManagedObjectContext!
    var apiService:CaptureLiveRemoteType!
    var syncCoordinator:SyncCoordinator!
    let locationManager                                 = LocationFrequencyGateway.shared
    let userMovementManager                             = CMUserMovementManager.shared
    var backgroundUploader                              = CMS3BackgroundUploader.shared
    var launchReactor:Reactor!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIFont.loadAssetFonts()
        PayPalMobile.initializeWithClientIdsForEnvironments([
             PayPalEnvironmentProduction                : NSBundle.CoreBundle.clientId
            ,PayPalEnvironmentSandbox                   : NSBundle.CoreBundle.sandboxClientId
        ])

        let hockeyAppIdentifier                         = NSBundle.AppBundle.hockeyAppId
        #if PRODUCTION
            PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentProduction)
            hockeyApp.configureWithIdentifier(hockeyAppIdentifier, delegate: self)
        #elseif STAGING
            PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentSandbox)
            hockeyApp.configureWithIdentifier(hockeyAppIdentifier, delegate: self)
        #elseif MOBILE
            PayPalMobile.preconnectWithEnvironment(PayPalEnvironmentSandbox)
        #endif
        
        hockeyApp.authenticator.authenticateInstallation()
        hockeyApp.crashManager.crashManagerStatus       = BITCrashManagerStatus.AutoSend
        hockeyApp.disableUpdateManager                  = false
        hockeyApp.startManager()
        
        guard let context                               = createCurrentMainContext() else { fatalError("BIG PROBLEMS OUT THE DOOR!!!") }
        managedObjectContext                            = context
        
        apiService                                      = CaptureLiveAlamoFireService(persistanceLayer:managedObjectContext)
        locationManager.locationGateway                 = LocationAPIGateway(remote:apiService)
        locationManager.managedObjectContext            = managedObjectContext
        
        syncCoordinator                                 = SyncCoordinator(mainManagedObjectContext:self.managedObjectContext, remote:self.apiService)
        userMovementManager.locationRetrievable         = managedObjectContext
        
        navigationController                            = findNavigationController()
        if let _ = User.loggedInUser(managedObjectContext) {
            loginHeard()
        } else {
            logoutHeard()
        }
      
        self.window                                     = UIWindow(frame:UIScreen.mainScreen().bounds)
        self.window?.rootViewController                 = navigationController
        self.window?.frame                              = UIScreen.mainScreen().bounds
        self.window?.makeKeyAndVisible()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(loginHeard), name:CaptureAppNotification.Login.rawValue, object:nil)
        nc.addObserver(self, selector:#selector(logoutHeard), name:CaptureAppNotification.Logout.rawValue, object:nil)
        nc.addObserver(self, selector:#selector(didFetchRemoteData), name:CoordinaterDidFetchNewRemoteDataNotification, object: syncCoordinator)
       
        notificationManager                             = NotificationManager(navigationController: navigationController, managedObjectContext: managedObjectContext)
 
        // reactors
        let lo:NSDictionary?                            = launchOptions
        let locationInfo: NSNumber?                     = lo?.objectForKey(UIApplicationLaunchOptionsLocationKey) as? NSNumber
        if locationInfo?.boolValue == true {
            self.locationManager.trackSignificantLocation()
        }
        
        launchReactor                                    = Reactor(execution:notificationManager.checkForNotifiables)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        if let info = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
            managedObjectContext.cacheNotification(info)
        }
 
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
//        managedObjectContext.batchDeleteObjectsMarkedForLocalDeletion()
        if #available(iOS 8.3, *) {
            managedObjectContext.refreshAllObjects()
        }
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        if #available(iOS 8.3, *) {
            managedObjectContext.refreshAllObjects()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        if let _ = User.loggedInUser(managedObjectContext) {
            launchReactor.reset()
            locationManager.trackLocation()
            application.registerForRemoteNotifications()
            application.updateBadgeNumberForUnreadNotifications(managedObjectContext)
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {}
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        print(userInfo)
        launchReactor.reset()
        if application.applicationState == .Inactive || application.applicationState == .Background {
            managedObjectContext.cacheNotification(userInfo)
        }
        syncCoordinator.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        managedObjectContext.decryptDevicePushToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
        print("didRegisterUserNotificationSettings")
    }
    
    func findNavigationController()->CMNavigationController {
        guard let navController = UIStoryboard(name:"LoggedOut", bundle: nil).instantiateInitialViewController() as? CMNavigationController
            else { fatalError("The storyboard has the wrong type of navigation controller") }
        return navController
    }
    
    func logoutHeard() {
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.managedObjectContext.allowScreenByPass()
        }
        let vcs = (managedObjectContext.canByPassOnboarding) ? UIStoryboard.loginViewControllers() : UIStoryboard.onboardViewControllers()
        for vc in vcs {
            setAsRemoteAndLocallyServiceable(vc)
        }
        self.navigationController.viewControllers       = vcs
        self.navigationController?.usePushRightPopLeftGestureRecognizer()
    }
    
    func loginHeard() {
        let vcs = UIStoryboard.loggedInViewControllers(managedObjectContext:managedObjectContext)
        for vc in vcs {
            setAsRemoteAndLocallyServiceable(vc)
        }
        self.navigationController.viewControllers       = vcs
        self.navigationController?.usePushLeftPopRightGestureRecognizer()
    }
    
    func setAsRemoteAndLocallyServiceable(vc:UIViewController) {
        guard let servicableVC                          = vc as? RemoteAndLocallyServiceable else { fatalError("Does not conform to RemoteAndLocallyServiceable") }
        servicableVC.managedObjectContext               = managedObjectContext
        servicableVC.remoteService                      = apiService
    }
    
    // MARK: Check for hirings and firings
    func didFetchRemoteData() {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            if let _ = User.loggedInUser(self.managedObjectContext) {
                self.launchReactor?.goIfPlausible()
            }
        }
    }
    
    // MARK: Rotation
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if let win = UIApplication.sharedApplication().keyWindow {
            if window != win {
                return UIInterfaceOrientationMask.AllButUpsideDown
            } else {
                if let _ = User.loggedInUser(self.managedObjectContext) {
                    if let presentedController              = self.navigationController.visibleViewController {
                        return presentedController.supportedInterfaceOrientations()
                    }
                }
                return UIInterfaceOrientationMask.Portrait
            }
        } else {
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    
    //MARK: Resourcel URL
    func application(application: UIApplication,
                     openURL url: NSURL,
                             sourceApplication: String?,
                             annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

    
    //MARK: Background Uploader
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        self.backgroundUploader.startFromWake({ [unowned self] isTotallyFinished in
            if isTotallyFinished == true {
                print("OMFG FINISHED IN THE BACKGROUND EVEN!!!!!!!!!!!!!!!!!!!")
                guard let onTheJobVC = self.navigationController.viewControllers.last as? OnTheJobViewController else {
                    completionHandler()
                    return
                }
                onTheJobVC.allFilesCompletedUploadFromBackground(completionHandler)
            } else {
                completionHandler()
            }
            
        }) { error in
            completionHandler()
        }
    }
    
}


//MARK: - Hockey App Delegate
extension AppDelegate : BITHockeyManagerDelegate {

    func userIDForHockeyManager(hockeyManager: BITHockeyManager!, componentManager: BITHockeyBaseManager!) -> String! {
        if let user = User.loggedInUser(managedObjectContext) {
            return user.urlHash
        }
        if let user = User.attemptingLoginUser(managedObjectContext) {
            return user.urlHash
        }
        return "user not logged in"
    }
    
    func userNameForCrashManager(crashManager: BITCrashManager!) -> String! {
        if let user = User.loggedInUser(managedObjectContext) {
            if let fn = user.firstName, let ln = user.lastName {
                return "\(fn) \(ln)"
            }
        }
        if let user = User.attemptingLoginUser(managedObjectContext) {
            if let fn = user.firstName, let ln = user.lastName {
                return "\(fn) \(ln)"
            }
        }
        return "user not logged in"
    }
    
    func userNameForHockeyManager(hockeyManager: BITHockeyManager!, componentManager: BITHockeyBaseManager!) -> String! {
        if let user = User.loggedInUser(managedObjectContext) {
            if let fn = user.firstName, let ln = user.lastName {
                return "\(fn) \(ln)"
            }
        }
        if let user = User.attemptingLoginUser(managedObjectContext) {
            if let fn = user.firstName, let ln = user.lastName {
                return "\(fn) \(ln)"
            }
        }
        return "user not logged in"
    }
    
}
