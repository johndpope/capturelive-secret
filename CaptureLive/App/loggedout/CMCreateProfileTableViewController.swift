//
//  CMRegisterUserDescriptionViewController.swift
//  Current-Tools
//
//  Created by Scott Jones on 12/2/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureCore

typealias ProfileFormClosure = (NSError?)->()
typealias UpdateProfileFromClosure = (Bool)->()

class CMCreateProfileTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameLabel:UILabel?
    @IBOutlet weak var firstNameField:UITextField?
    @IBOutlet weak var lastNameLabel:UILabel?
    @IBOutlet weak var lastNameField:UITextField?
    @IBOutlet weak var ageLimitLabel:UILabel?
    @IBOutlet weak var ageLimitField:UITextField?
    @IBOutlet weak var emailLabel:UILabel?
    @IBOutlet weak var emailField:UITextField?
    @IBOutlet weak var avatarButton:UIButton?
   
    var doneClosure:ProfileFormClosure?
    var updateClosure:UpdateProfileFromClosure?
    var facebookUser:FacebookUser!
    var textFields:[TextfieldValidator]!
    var attrs                                                       = [NSString:AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let emailPH                                                     = NSLocalizedString("Email Address",comment:"CMCreateProfileTableViewController : emailTextField : placeholderText")
        let firstnamePH                                                 = NSLocalizedString("First name",   comment:"CMCreateProfileTableViewController : firstNameTextField : placeholderText")
        let lastnamePH                                                  = NSLocalizedString("Last name",    comment:"CMCreateProfileTableViewController : lastNameTextField : placeholderText");
        
        self.attrs[NSForegroundColorAttributeName]                  = UIColor.blueCurrent()
        self.attrs[NSFontAttributeName]                             = UIFont.sourceSansPro(.Light, size: .Large)
        
        let fnText = NSLocalizedString("First Name", comment: "CMCreateProfileTableViewController : firstNameLabel : text")
        self.firstNameLabel?.text = fnText
        self.firstNameLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        
        let lnText = NSLocalizedString("Last Name", comment: "CMCreateProfileTableViewController : lastNameLabel : text")
        self.lastNameLabel?.text = lnText
        self.lastNameLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        
        let ageText = NSLocalizedString("18 years or older", comment: "CMCreateProfileTableViewController : ageNameLabel : text")
        self.ageLimitLabel?.text = ageText
        self.ageLimitLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)
        
        let emailText = NSLocalizedString("Email", comment: "CMCreateProfileTableViewController : emailNameLabel : text")
        self.emailLabel?.text = emailText
        self.emailLabel?.font = UIFont.sourceSansPro(.Bold, size: 12)

        let ageYesText = NSLocalizedString("yes", comment: "CMCreateProfileTableViewController : yes : text")
        let ageNoText = NSLocalizedString("no", comment: "CMCreateProfileTableViewController : no : text")
        
        self.avatarButton?.setTitle("", forState: .Normal)
        
        self.firstNameField?.font = UIFont.comfortaa(.Regular, size: 18)
        self.firstNameField?.backgroundColor = UIColor.whiteCurrent()
        self.firstNameField?.delegate = self
 
        self.lastNameField?.font = UIFont.comfortaa(.Regular, size: 18)
        self.lastNameField?.backgroundColor = UIColor.whiteCurrent()
        self.lastNameField?.delegate = self
   
        self.ageLimitField?.font = UIFont.comfortaa(.Regular, size: 18)
        self.ageLimitField?.backgroundColor = UIColor.whiteCurrent()
        self.ageLimitField?.enabled = false
 
        self.emailField?.font = UIFont.comfortaa(.Regular, size: 18)
        self.emailField?.backgroundColor = UIColor.whiteCurrent()

        self.firstNameField?.text   = self.facebookUser.firstName ?? ""
        self.lastNameField?.text    = self.facebookUser.lastName ?? ""
        self.ageLimitField?.text = self.facebookUser.isOverAgeRange ? ageYesText : ageNoText
        self.emailField?.delegate = self
        self.emailField?.text       = self.facebookUser.email ?? ""

        self.firstNameField!.attributedPlaceholder              = NSAttributedString(string:firstnamePH, attributes: attrs as? [String:AnyObject])
        self.lastNameField!.attributedPlaceholder               = NSAttributedString(string:lastnamePH, attributes: attrs as? [String:AnyObject])
        self.emailField!.attributedPlaceholder                  = NSAttributedString(string:emailPH, attributes: attrs as? [String:AnyObject])
        
        textFields = [
            TextfieldValidator(textField:firstNameField!, label:firstNameLabel) { text in
                let validString = CMValidator.isFirstNameValid(text) as String
                return (isValid:VALID_INPUT == validString, reason:validString)
            },
            TextfieldValidator(textField:lastNameField!, label:lastNameLabel) { text in
                let validString = CMValidator.isLastNameValid(text) as String
                return (isValid:VALID_INPUT == validString, reason:validString)
            },
            TextfieldValidator(textField:emailField!, label:emailLabel) { text in
                let validString = CMValidator.isEmailValid(text) as String
                return (isValid:VALID_INPUT == validString, reason:validString)
            }
        ]
       
        self.avatarButton?.clipsToBounds                    = true
        self.avatarButton?.layer.cornerRadius               = 40
        guard let url = facebookUser.avatarPath else { return }
        print(url)
        CMImageCache.defaultCache().removeCachedFile(url)
        
        updateProfileUrl(url)
    }
  
    func updateProfileImage(image:UIImage) {
//        self.avatarButton?.setBackgroundImage(image, forState: .Normal)
    }
   
    func updateProfileUrl(url:String) {
        CMImageCache.defaultCache().imageForPath(url, complete: { [weak self] error, image in
            if error == nil {
                self?.avatarButton?.setBackgroundImage(image, forState: .Normal)
            }
        })
    }

    func clearKeyboard() {
        firstNameField?.resignFirstResponder()
        lastNameField?.resignFirstResponder()
        emailField?.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    func addNotificationHandlers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CMCreateProfileTableViewController.update), name:UITextFieldTextDidChangeNotification, object:nil)
    }
    func removeNotificationHandlers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UITextFieldTextDidChangeNotification, object:nil)
    }

    func update() {
        updateClosure?(areFieldsPopulated())
    }
    
    func attemptToSucceed() {
        doneClosure?(validateUserInfo())
    }
    
    func areFieldsPopulated()->Bool {
        let empty = textFields.reduce(false) { a, next in
            return a ? a : next.textField.text?.characters.count == 0
        }
        return empty
    }
   
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let t = textFields.filter { $0.textField == textField }
        guard let tf = t.first else { return true }
        tf.next(textFields)?.textField.becomeFirstResponder()
        
        if textField == self.emailField {
            attemptToSucceed()
            textField.resignFirstResponder()
        }
        return true
    }

    func validateUserInfo()->NSError? {
        let badField = textFields.reduce(VALID_INPUT) { string, next in
            next.label?.textColor = UIColor.blackCurrent()
            let v = next.runValidate()
            return string == VALID_INPUT ? v.reason : string
        }
        if badField == VALID_INPUT {
            return nil
        }
        return NSError(domain:"", code: 422, userInfo:[NSLocalizedDescriptionKey : badField])
    }
    
}


