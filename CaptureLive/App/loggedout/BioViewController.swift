//
//  BioViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel

typealias BioCompleted  = (bio:String?)->()
let MAXCHARACTERS       = 500
let MINCHARACTERS       = 100

class BioViewController: UIViewController {
    
    var theView:BioView {
        guard let v = self.view as? BioView else { fatalError("Not a \(BioView.self)!") }
        return v
    }
    
    var bioCompleted:BioCompleted?
    var bio:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        theView.bioTextView?.becomeFirstResponder()
        theView.bioTextView?.delegate   = self
        theView.bioTextView?.text       = bio
        textView(theView.bioTextView!, shouldChangeTextInRange:NSMakeRange(0, 0), replacementText:"")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventHandlers()
        theView.bioTextView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
    }
    
    func addEventHandlers() {
        theView.saveButton?.addTarget(self, action: #selector(saveBio), forControlEvents:.TouchUpInside)
        theView.closeButton?.addTarget(self, action: #selector(goBack), forControlEvents:.TouchUpInside)
        let nc                              = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification,   object:nil)
    }
    
    func removeEventHandlers() {
        theView.saveButton?.removeTarget(self, action: #selector(saveBio), forControlEvents:.TouchUpInside)
        theView.closeButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        let nc                              = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
    }
    
    func updateCharacters() {
        if let b = theView.bioTextView?.text where b.characters.count > MINCHARACTERS && b.characters.count <= MAXCHARACTERS {
            theView.saveButton?.enabled = true
        } else {
            theView.saveButton?.enabled = false
        }
        
        let count = theView.bioTextView?.text.characters.count ?? 0
        if count > MAXCHARACTERS {
            theView.charactersLabel?.textColor = UIColor.redColor()
            theView.charactersLabel?.text = "\(MAXCHARACTERS - count) characters left"
        } else if count < MINCHARACTERS {
            theView.charactersLabel?.textColor = UIColor.taupeGray()
            theView.charactersLabel?.text = "\(count) characters"
        } else {
            theView.charactersLabel?.textColor = UIColor.mountainMeadow()
            theView.charactersLabel?.text = "\(MAXCHARACTERS - count) characters left"
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: Button handlers
    func saveBio() {
        bioCompleted?(bio:theView.bioTextView!.text)
        theView.bioTextView?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func goBack() {
        theView.bioTextView?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Notification handlers
    func keyboardWillShow(notification:NSNotification) {
        let keyboardValues = UIView.keyboardNotificationValues(notification)
        theView.adjustKeyboardHeightForKeyboard(CGFloat(keyboardValues.height))
    }
    
}


extension BioViewController : UITextViewDelegate {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        updateCharacters()
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        updateCharacters()
    }
    
}
