//
//  ReelViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureModel

class ReelViewController: UIViewController {

    var theView:ReelView {
        guard let v = self.view as? ReelView else { fatalError("Not a \(ReelView.self)!") }
        return v
    }
    
    var reel:Reel?
    var reelSource:ReelSource!
    var reelCreated:ReelCreated?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theView.didLoad()
        theView.copyTextField?.becomeFirstResponder()
        
        theView.reelImageView?.image    = UIImage(named:reelSource.largeIconName)
        theView.titleLabel?.text        = reelSource.titleString
        theView.bodyLabel?.text         = reelSource.enterUrlString
        theView.prefixLabel?.text       = reelSource.prefixString
        theView.copyTextField?.delegate = self
        
        if let rl = reel {
            theView.copyTextField?.text = rl.value
        }
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
    
    func addEventHandlers() {
        theView.urlButton?.addTarget(self, action: #selector(checkReelIntegrity), forControlEvents:.TouchUpInside)
        theView.closeButton?.addTarget(self, action: #selector(goBack), forControlEvents:.TouchUpInside)
        let nc                              = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object:nil)
    }
    
    func removeEventHandlers() {
        theView.urlButton?.removeTarget(self, action: #selector(checkReelIntegrity), forControlEvents:.TouchUpInside)
        theView.closeButton?.removeTarget(self, action: #selector(goBack), forControlEvents:.TouchUpInside)
        let nc                              = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addReel() {
        if let text = theView.copyTextField?.text where text.characters.count > 0 {
            let reel = Reel(value: text, source:reelSource)
            reelCreated?(SourceWithReel(source:reelSource, reel:reel))
        } else {
            reelCreated?(SourceWithReel(source:reelSource, reel:nil))
        }
        
        theView.copyTextField?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showBadURLAlert() {
        let title                               = NSLocalizedString("Error", comment:"ReelViewController : failedToLoad : alertTitle")
        let message                             = NSLocalizedString("This is not a valid url", comment:"ReelViewController : failedToLoad : alertMessage")
        let buttonTitle                         = NSLocalizedString("Retry", comment:"ReelViewController : failedToLoad : retryButtonTitle")
        let alertViewController                 = CMAlertController(title:title, message:message)
        let dismiss = CMAlertAction(title:buttonTitle, style: .Primary) { () -> () in
        }
        alertViewController.addAction(dismiss)
        CMAlert.presentViewController(alertViewController)
    }

    // MARK: Notification handlers
    func keyboardWillShow(notification:NSNotification) {
        let keyboardValues = UIView.keyboardNotificationValues(notification)
        theView.adjustKeyboardHeightForKeyboard(CGFloat(keyboardValues.height))
    }
   
    //MARK: Button handlers
    func checkReelIntegrity() {
        guard let string = theView.copyTextField?.text else {
            return
        }
        guard let url = reelSource.url(string) else {
            showBadURLAlert()
            return
        }
        UIApplication.sharedApplication().openURL(url)
    }
    
    func goBack() {
        theView.copyTextField?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
 
    
}


extension ReelViewController : UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addReel()
        return true
    }
    
}






