//
//  CMPhoneLoginViewController.swift
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

extension PhoneLoginViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}
class PhoneLoginViewController: UIViewController, RemoteAndLocallyServiceable, NavGesturable, SegueHandlerType {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    
    enum SegueIdentifier:String {
        case AuthorizeCode          = "pushToAuthorizationCode"
        case AuthorizeCodeNoAnimate = "pushToAuthorizationCodeNoAnimate"
        case ShowCreateProfile      = "showCreateProfile"
    }

    var theView:PhoneLoginView {
        guard let v = self.view as? PhoneLoginView else { fatalError("Not a \(PhoneLoginView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext.performChanges { [unowned self] in
            self.managedObjectContext.allowOnboardingByPass()
        }
        
        theView.didLoad()
        
//        theView.phoneNumberField?.becomeFirstResponder()
        theView.phoneNumberField?.delegate   = self
//        theView.phoneNumberField?.text       = ""
        hasEnoughToByPassPhoneLogin(self) { [unowned self] in
            self.performSegue(.AuthorizeCodeNoAnimate)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addEventHandlers()
        
        if let lastUserNumber = managedObjectContext.lastUsedNumber {
            theView.phoneNumberField?.text                     = CMValidator.formatPhoneNumber(lastUserNumber)
            areFieldsPopulated()
        }
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        navGesturer?.statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
    }
   
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.loginButton?.addTarget(self, action:#selector(loginWarning), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.addTarget(self, action:#selector(goBack), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(areFieldsPopulated), name:UITextFieldTextDidChangeNotification,      object:nil)
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification,   object:nil)
        nc.addObserver(self, selector:#selector(willResignActive), name: UIApplicationWillResignActiveNotification,  object:nil)
    }
    
    func removeEventHandlers() {
        self.theView.loginButton?.removeTarget(self, action:#selector(loginWarning), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.removeTarget(self, action:#selector(goBack), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UITextFieldTextDidChangeNotification,          object:nil)
        nc.removeObserver(self, name:UIKeyboardWillShowNotification,                object:nil)
        nc.removeObserver(self, name:UIApplicationWillResignActiveNotification,     object:nil)
    }
    
    
    // MARK: Notification handlers
    func keyboardWillShow(notification:NSNotification) {
        let keyboardValues = UIView.keyboardNotificationValues(notification)
        theView.animateForKeyBoardIn(CGFloat(keyboardValues.height))
    }
    
    func willResignActive() {
        theView.animateForKeyBoardOut()
        theView.phoneNumberField?.resignFirstResponder()
    }
    
    func areFieldsPopulated() {
        theView.loginButton?.enabled                       = false
        if theView.phoneNumberField!.text!.characters.count >= 10 {
            let validNumber                                 = CMValidator.isValidPhoneNumber(theView.phoneNumberField!.text)
            if validNumber == false {
                return
            }
        } else {
            return
        }
        theView.loginButton?.enabled                       = true
    }
    
    
    // MARK: button handlers
    func goBack() {
        willResignActive()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func loginRequested() {
        theView.startActivityIndicator()
        let phoneNumber                                 = CMValidator.unFormatPhoneNumber(theView.phoneNumberField!.text)
        remoteService.requestAuthorizationCode(phoneNumber) { [unowned self] error in
            guard let e = error else {
                self.theView.stopActivityIndicator()
                self.managedObjectContext.setLastUsedNumber(phoneNumber)
                self.navigateToAuthorizationCodeViewController()
                return
            }
            self.theView.stopActivityIndicator()
            self.registrationError(e)
        }
    }
    
    func loginWarning() {
        theView.animateForKeyBoardOut()
        theView.phoneNumberField?.resignFirstResponder()
        
        self.removeEventHandlers()
        
        let title                                       = NSLocalizedString("We are going to send a text with a verification code to this number:", comment:"CMPhoneAuthorization : loginWarning : alertTitle")
        let alertViewController                         = CMAlertController(title:title, message:self.theView.phoneNumberField!.text!)
        alertViewController.titleLabel?.font            = UIFont.proxima(.Regular, size: FontSizes.s14)
        alertViewController.titleLabel?.textColor       = UIColor.taupeGray()
        alertViewController.messageLabel?.font          = UIFont.proxima(.Regular, size: FontSizes.s18)
        alertViewController.messageLabel?.textColor     = UIColor.mountainMeadow()
        alertViewController.readdData()
        
        let okButtonText                                = NSLocalizedString("OK", comment:"CMPhoneAuthorization : okButton : titleText")
        let okAction = CMAlertAction(title:okButtonText, style: .Primary) { [weak self] in
            self?.loginRequested()
        }
        alertViewController.addAction(okAction)
        
        let cancelButtonText                            = NSLocalizedString("Cancel", comment:"CMPhoneAuthorization : cancelButton : titleText")
        let cancelAction = CMAlertAction(title:cancelButtonText, style: .Secondary) {[weak self] in
            self?.addEventHandlers()
        }
        alertViewController.addAction(cancelAction)
        
        CMAlert.presentViewController(alertViewController)
    }

    func navigateToAuthorizationCodeViewController() {
        self.performSegue(.AuthorizeCode)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }

    // MARK: Error
    func registrationError(error:NSError) {
        removeEventHandlers()
        textFieldShouldReturn(self.theView.phoneNumberField!)

        let title                                       = NSLocalizedString("Login Error", comment:"CMPhoneAuthorization : backEndValidationWarning : alertTitle")
        let message                                     = NSLocalizedString("Sorry, looks like this phone number is invalid.", comment:"CMPhoneAuthorization : backEndValidationWarning : alertMessage")
        let alertViewController                         = CMAlertController(title:title, message:message)

        let okButtonText                                = NSLocalizedString("OK", comment:"CMPhoneAuthorization : okButton : titleText")
        let okAction = CMAlertAction(title:okButtonText, style: .Primary) { [weak self] in
            self?.addEventHandlers()
            self?.theView.phoneNumberField?.becomeFirstResponder()
        }
        alertViewController.addAction(okAction)
        
        CMAlert.presentViewController(alertViewController)
    }
    
}

extension PhoneLoginViewController : UITextFieldDelegate {
    
    //MARK: TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        theView.animateForKeyBoardOut()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField == theView.phoneNumberField!) {
            let returnOrValue:AnyObject!                = CMValidator.formatPhoneNumber(textField.text, withRange:range)
            if returnOrValue as? NSString == REACHED_MAX_LENGTH {
                return false;
            } else {
                textField.text                          = returnOrValue as? String
                return true
            }
        }
        return true
    }
    
}












