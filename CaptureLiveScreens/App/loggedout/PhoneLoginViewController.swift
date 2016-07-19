//
//  CMPhoneLoginViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class PhoneLoginViewController: UIViewController {
    
    var theView:PhoneLoginView {
        guard let v = self.view as? PhoneLoginView else { fatalError("Not a \(PhoneLoginView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()

//        theView.phoneNumberField?.becomeFirstResponder()
        theView.phoneNumberField?.delegate   = self
//        theView.phoneNumberField?.text       = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.loginButton?.addTarget(self, action:#selector(loginWarning), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.addTarget(self, action:#selector(loginRequested), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(areFieldsPopulated), name:UITextFieldTextDidChangeNotification,      object:nil)
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification,   object:nil)
        nc.addObserver(self.theView, selector:#selector(willResignActive), name: UIApplicationWillResignActiveNotification,  object:nil)

    }
    
    func removeEventHandlers() {
        self.theView.loginButton?.removeTarget(self, action:#selector(loginWarning), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.removeTarget(self, action:#selector(loginRequested), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UITextFieldTextDidChangeNotification,          object:nil)
        nc.removeObserver(self, name:UIKeyboardWillShowNotification,                object:nil)
        nc.removeObserver(self, name:UIApplicationWillResignActiveNotification,                object:nil)
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
//            let validNumber                                 = CMValidator.isValidPhoneNumber(self.phoneNumberField!.text)
//            if validNumber == false {
//                return
//            }
        } else {
            return
        }
        theView.loginButton?.enabled                       = true
    }

    
    
    // MARK: button handlers
    func loginRequested() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func loginWarning() {
        theView.animateForKeyBoardOut()
        theView.phoneNumberField?.resignFirstResponder()

        self.removeEventHandlers()
        
        let title                                       = NSLocalizedString("We are going to send a text with a verification code to this number:", comment:"CMPhoneAuthorization : loginWarning : alertTitle")
        let alertViewController                         = CMAlertController(title:title, message:self.theView.phoneNumberField!.text!)
        
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
       
        alertViewController.titleLabel?.font            = UIFont.proxima(.Regular, size: FontSizes.s14)
        alertViewController.titleLabel?.textColor       = UIColor.taupeGray()
        alertViewController.messageLabel?.font          = UIFont.proxima(.Regular, size: FontSizes.s18)
        alertViewController.messageLabel?.textColor     = UIColor.mountainMeadow()
        
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
//        if (textField == theView.phoneNumberField!) {
//            let returnOrValue:AnyObject!                = CMValidator.formatPhoneNumber(textField.text, withRange:range)
//            if returnOrValue as? NSString == REACHED_MAX_LENGTH {
//                return false;
//            } else {
//                textField.text                          = returnOrValue as? String
//                return true
//            }
//        }
        return true
    }

}
