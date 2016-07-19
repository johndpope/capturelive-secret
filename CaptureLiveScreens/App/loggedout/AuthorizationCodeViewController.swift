//
//  CMAuthorizationCodeViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class AuthorizationCodeViewController: UIViewController {
    
    var theView:AuthorizationCodeView {
        guard let v = self.view as? AuthorizationCodeView else { fatalError("Not a \(AuthorizationCodeView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        theView.addPhoneNumber("(908) 581-8600")
        theView.authCodeField?.delegate   = self
        addEventHandlers()
//        theView.authCodeField?.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addEventHandlers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeEventHandlers()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.removeEventHandlers()
        self.theView.loginButton?.addTarget(self, action:#selector(showInvalidCode), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.addTarget(self, action:#selector(loginRequested), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(areFieldsPopulated), name:UITextFieldTextDidChangeNotification,      object:nil)
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification,   object:nil)
        nc.addObserver(self, selector:#selector(keyboardWillDisappear), name:UIKeyboardWillHideNotification,   object:nil)
        nc.addObserver(self, selector:#selector(willResignActive), name: UIApplicationWillResignActiveNotification,  object:nil)
    }
    
    func removeEventHandlers() {
        self.theView.loginButton?.removeTarget(self, action:#selector(showInvalidCode), forControlEvents: UIControlEvents.TouchUpInside)
        self.theView.closeButton?.removeTarget(self, action:#selector(loginRequested), forControlEvents: UIControlEvents.TouchUpInside)
        let nc                                      = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UITextFieldTextDidChangeNotification,          object:nil)
        nc.removeObserver(self, name:UIKeyboardWillShowNotification,                object:nil)
        nc.removeObserver(self, name:UIKeyboardWillHideNotification,                object:nil)
        nc.removeObserver(self, name:UIApplicationWillResignActiveNotification,     object:nil)

    }
    
    
    // MARK: Notification handlers
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
    
    func showInvalidCode() {
//        theView.showInvalidCode()
        theView.animateOut { [unowned self] in
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
}

extension AuthorizationCodeViewController : UITextFieldDelegate {
    
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
