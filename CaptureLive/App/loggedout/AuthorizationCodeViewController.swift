//
//  CMAuthorizationCodeViewController.swift
//  Current-Tools
//
//  Created by Scott Jones on 1/26/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CaptureUI

//extension AuthorizationCodeViewController : CYNavigationPop {
//    var popAnimator:UIViewControllerAnimatedTransitioning? {
//        return PopRightAnimator()
//    }
//}
class AuthorizationCodeViewController: UIViewController, RemoteAndLocallyServiceable, NavGesturable, SegueHandlerType {
   
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    enum SegueIdentifier:String {
        case FacebookAuth               = "pushToFacebookAuth"
        case FacebookAuthNoAnimate      = "pushToFacebookAuthNoAnimate"
    }
    
    var theView:AuthorizationCodeView {
        return self.view as! AuthorizationCodeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        theView.didLoad()
        theView.authCodeField?.delegate   = self
        
        if let lastUserNumber = managedObjectContext.lastUsedNumber {
            let formatted = CMValidator.formatPhoneNumber(lastUserNumber)
            theView.addPhoneNumber(formatted)
        } else {
            theView.addPhoneNumber(" ")
        }
        hasEnoughToByPassPhoneLogin(self) { [unowned self] in
            self.performSegue(.FacebookAuthNoAnimate)
            return
        }

        addEventHandlers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addEventHandlers()
        areFieldsPopulated()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.removeEventHandlers()
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
//        showReachiblity()
    }
    
    override func viewDidLayoutSubviews() {
        self.theView.stopActivityIndicator()
        super.viewDidLayoutSubviews()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.loginButton?.enabled                       = true
        self.theView.loginButton?.addTarget(self, action: #selector(loginRequested), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.addTarget(self, action: #selector(goBack), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(areFieldsPopulated), name:UITextFieldTextDidChangeNotification,      object:nil)
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification,   object:nil)
        nc.addObserver(self, selector:#selector(keyboardWillDisappear), name:UIKeyboardWillHideNotification,   object:nil)
        nc.addObserver(self, selector:#selector(willResignActive), name: UIApplicationWillResignActiveNotification,  object:nil)
    }
    
    func removeEventHandlers() {
        self.theView.loginButton?.enabled                       = false
        self.theView.loginButton?.removeTarget(self, action: #selector(loginRequested), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.removeTarget(self, action: #selector(goBack), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UITextFieldTextDidChangeNotification,          object:nil)
        nc.removeObserver(self, name:UIKeyboardWillShowNotification,                object:nil)
        nc.removeObserver(self, name:UIKeyboardWillHideNotification,                object:nil)
        nc.removeObserver(self, name:UIApplicationWillResignActiveNotification,     object:nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let keyboardValues = UIView.keyboardNotificationValues(notification)
        theView.animateForKeyBoardIn(CGFloat(keyboardValues.height))
    }
    
    func keyboardWillDisappear() {
        theView.animateForKeyBoardOut()
    }
    
    func willResignActive() {
        theView.animateForKeyBoardOut()
        theView.authCodeField?.resignFirstResponder()
    }
    
    func areFieldsPopulated() {
        theView.loginButton?.enabled                       = false
        if theView.authCodeField!.text!.characters.count >= 6 {

        } else {
            return
        }
        theView.loginButton?.enabled                       = true
    }
    
    // MARK: button handlers
    func loginRequested() {
        if theView.loginButton?.alpha < 1 {
            return
        }
        removeEventHandlers()
        
        guard let numberInStore = self.managedObjectContext.lastUsedNumber,
            phoneNumber = CMValidator.unFormatPhoneNumber(numberInStore) else {
            fatalError("There is saved phone number in the persistance layer")
        }
        
        guard let code = self.theView.authCodeField?.text else {
            fatalError("There is no text in the textfield")
        }
        
        self.theView.startActivityIndicator()
        self.remoteService.fetchAuthorizationCode(phoneNumber, code:code) { [unowned self] error in
            guard let e = error else {
                self.theView.stopActivityIndicator()
                self.managedObjectContext.saveOrRollback()
                self.fetchUser()
                return
            }
            self.addEventHandlers()
            self.theView.stopActivityIndicator()
            if e.localizedDescription == "The operation couldn’t be completed. Response status code was unacceptable: 401" {
                self.theView.showInvalidCode()
            } else {
                self.theView.showError(e.localizedDescription)
            }
            print("\(e.localizedDescription)")
        }
    }
    
    func fetchUser() {
        self.remoteService.fetchLoggedInUser { [unowned self] remoteUser, error in
            if let e = error {
                print("failed to fetch user with error : \(e.localizedDescription)")
                self.addEventHandlers()
                self.theView.stopActivityIndicator()
                self.theView.showError(e.localizedDescription)
                return
            }
            
            print("Logged in user : \(remoteUser!.self)")
            guard let user = remoteUser else {
                fatalError("fetchLoggedInUser request return returned wrong type : \(remoteUser!.self)")
            }
            self.textFieldShouldReturn(self.theView.authCodeField!)
            self.attempToLogin(user)
        }
    }
    
    func attempToLogin(user:RemoteUser) {
        let attemptLoginUser = user.insertIntoContext(self.managedObjectContext)
        self.managedObjectContext.performChangesAndWait {
            attemptLoginUser.setAsAttemptingLoginUser()
        }
        proceedToNextScreen(attemptLoginUser)
    }
    
    func proceedToNextScreen(user:User) {
        // has Accepted terms and done app has seen permissions
        if hasAcceptedTermsAndBeenAskedForPermissions(self) {
            self.loginUser(user)
        } else {
            navigateToFacebookAuth()
        }
    }
    
    func goBack() {
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.managedObjectContext.preventScreenByPass()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }
    
    override func segueForUnwindingToViewController(toViewController:UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue? {
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
    }
    
    func navigateToFacebookAuth() {
        theView.animateOut { [weak self] in
            self?.performSegue(.FacebookAuth)
        }
    }
    
    func loginUser(loggedInUser:User) {
        self.managedObjectContext.performChanges {
            loggedInUser.setAsLoggedInUser()
        }
        theView.animateOut {
            // send login notification
            NSNotificationCenter.defaultCenter().postNotificationName(CaptureAppNotification.Login.rawValue, object: nil)
        }
    }
    
    @IBAction func unwindToAuthCode(sender:UIStoryboardSegue) {
        
    }


}

extension AuthorizationCodeViewController : UITextFieldDelegate {
    
    //MARK: TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        theView.animateForKeyBoardOut()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.setNeedsStatusBarAppearanceUpdate()
    }

}