//
//  CMAlertView.swift
//  Current-Tools
//
//  Created by Scott Jones on 11/4/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public protocol CMAlertViewProtocol {
    var titleLabel:UILabel?                 { get set }
    var messageLabel:UILabel?               { get set }
    var getWidth:CGFloat                    { get set }
    var textFieldHorizotalPadding:CGFloat   { get set }
    var buttonsVerticalPadding:CGFloat      { get set }
    var textToButtonsPadding:CGFloat        { get set }
    var titleTopPadding:CGFloat             { get set }
    var messageTopPadding:CGFloat           { get set }
    var buttonHeight:CGFloat                { get set }
    
    func didLoad()
    func addData(titleString:String, messageString:String)
    func addButtons(buttonArray:[UIButton])
    func removeButtons()
    func present()
    func dismiss()
    func layoutIfNeeded()
}

extension CMAlertViewProtocol {
    func readdData() {
        guard let t = titleLabel?.text, m = messageLabel?.text else { return }
        self.addData(t, messageString: m)
    }
}

class CMAlertView: UIView, CMAlertViewProtocol {

    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var messageLabel:UILabel?
    @IBOutlet weak var butttonContainerView:UIView?
    @IBOutlet weak var alertViewContainer:UIView?
    @IBOutlet weak var widthConstraint:NSLayoutConstraint?
    @IBOutlet weak var heightConstraint:NSLayoutConstraint?
    @IBOutlet weak var titleTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var messageTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var butttonViewHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var titleLabelHeight:NSLayoutConstraint?
    @IBOutlet weak var messageLabelHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var centerYConstraint:NSLayoutConstraint?
    @IBOutlet weak var centerXConstraint:NSLayoutConstraint?

    internal var getWidth:CGFloat                        = min(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height) - 40
    internal var textFieldHorizotalPadding:CGFloat       = 20
    internal var buttonsVerticalPadding:CGFloat          = 20
    internal var textToButtonsPadding:CGFloat            = 10
    internal var titleTopPadding:CGFloat                 = 30
    internal var messageTopPadding:CGFloat               = 20
    internal var buttonHeight:CGFloat                    = 65
 
    var doubleTextFieldHorizontalPadding:CGFloat {
        get {
            return self.textFieldHorizotalPadding * 2
        }
    }
    
    func didLoad() {
        self.backgroundColor                    = UIColor.blackCurrent(0.7)
        self.titleLabel?.font                   = UIFont.proxima(.Bold, size: 20)
        self.titleLabel?.textColor              = UIColor.bistre()
        self.titleLabel?.numberOfLines          = 0
        
        self.messageLabel?.font                 = UIFont.proxima(.Regular, size: 14)
        self.messageLabel?.textColor            = UIColor.dimGray()
        self.messageLabel?.numberOfLines        = 0
        
        self.alertViewContainer?.layer.cornerRadius = 5
        self.alertViewContainer?.clipsToBounds  = true
    }
    
    func addData(titleString:String, messageString:String) {
        self.widthConstraint?.constant          = self.getWidth
        
        if titleString.characters.count == 0 {
            self.titleLabelHeight!.constant     = 0
            self.titleTopConstraint!.constant   = 0
        } else {
            self.titleTopConstraint!.constant   = self.titleTopPadding
            self.titleLabel?.text               = titleString
            self.titleLabelHeight!.constant     = ceil(self.titleLabel!.font.sizeOfString(titleString, constrainedToWidth:Double(self.widthConstraint!.constant - self.doubleTextFieldHorizontalPadding)).height)
        }

        if messageString.characters.count == 0 {
            self.messageLabelHeightConstraint!.constant = 0
            self.messageTopConstraint!.constant = 0
        } else {
            self.messageTopConstraint!.constant = self.messageTopPadding
            self.messageLabel?.text             = messageString
            self.messageLabelHeightConstraint!.constant = ceil(self.messageLabel!.font.sizeOfString(messageString, constrainedToWidth:Double(self.widthConstraint!.constant - self.doubleTextFieldHorizontalPadding)).height)
        }
        
        self.heightConstraint?.constant         = self.butttonViewHeightConstraint!.constant + self.titleLabelHeight!.constant + self.messageLabelHeightConstraint!.constant + self.titleTopConstraint!.constant + self.messageTopConstraint!.constant + self.textToButtonsPadding
        self.layoutIfNeeded()
    }
    
    internal func addButtons(buttonArray:[UIButton]) {
        self.removeButtons()
        self.butttonContainerView?.translatesAutoresizingMaskIntoConstraints = false
        self.butttonViewHeightConstraint?.constant = CGFloat(CGFloat(buttonArray.count) * self.buttonHeight)
        self.heightConstraint?.constant         = self.butttonViewHeightConstraint!.constant + self.titleLabelHeight!.constant + self.messageLabelHeightConstraint!.constant + self.titleTopConstraint!.constant + self.messageTopConstraint!.constant + self.textToButtonsPadding
       
        var lastButton:UIButton?                = nil
        for button in buttonArray {
            self.butttonContainerView?.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            let heightConstraint                = NSLayoutConstraint(item:button, attribute:.Height, relatedBy:.Equal, toItem:nil, attribute:.NotAnAttribute, multiplier:1, constant:35.0)
            self.butttonContainerView?.addConstraint(heightConstraint)
            
            let trailingConstraint              = NSLayoutConstraint(item:button, attribute:.Trailing, relatedBy:.Equal, toItem:self.butttonContainerView!, attribute:.Trailing, multiplier:1, constant:-self.buttonsVerticalPadding)
            self.butttonContainerView?.addConstraint(trailingConstraint)
            
            let leadingConstraint               = NSLayoutConstraint(item:button, attribute:.Leading, relatedBy:.Equal, toItem:self.butttonContainerView!, attribute:.Leading, multiplier:1, constant:self.buttonsVerticalPadding)
            self.butttonContainerView?.addConstraint(leadingConstraint)
            
            var bottomConstraint                = NSLayoutConstraint(item:button, attribute:.Bottom, relatedBy:.Equal, toItem:self.butttonContainerView!, attribute:.Bottom, multiplier:1, constant:-self.buttonsVerticalPadding)
            if let bottomView = lastButton {
                bottomConstraint                = NSLayoutConstraint(item:button, attribute:.Bottom, relatedBy:.Equal, toItem:bottomView, attribute:.Top, multiplier:1, constant:-self.buttonsVerticalPadding)
            }
            self.butttonContainerView?.addConstraint(bottomConstraint)
            lastButton                          = button
        }
        self.layoutIfNeeded()
    }
    
    func removeButtons() {
        let subViews                            = self.butttonContainerView!.subviews
        for subview in subViews as [UIView] {
            subview.removeFromSuperview()
        }
    }
    
    func present() {
        // pulse animation thanks to:  http://delackner.com/blog/2009/12/mimicking-uialertviews-animated-transition/
        self.alertViewContainer?.transform = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.alertViewContainer?.transform = CGAffineTransformMakeScale(1.07, 1.07)
            
            }) { (fin:Bool) -> Void in
                
                UIView.animateWithDuration(1.0/15.0, animations: { () -> Void in
                    self.alertViewContainer?.transform = CGAffineTransformMakeScale(0.96, 0.96)
                    
                    }) { (fin:Bool) -> Void in
                        
                        UIView.animateWithDuration(1.0/7.5, animations: { () -> Void in
                            self.alertViewContainer?.transform = CGAffineTransformIdentity
                            
                            }) { (fin:Bool) -> Void in
                                
                        }
                }
        }
    }

    func dismiss() {
    
    }
    
}










