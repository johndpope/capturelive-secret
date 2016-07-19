//
//  BioView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class BioView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var subLabel:UILabel?
    @IBOutlet weak var bioTextView:UITextView?
    @IBOutlet weak var saveButton:CMPrimaryButton?
    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var charactersLabel:UILabel?
    @IBOutlet weak var textViewContainer:UIView?
    @IBOutlet weak var contentsHeightConstraint:NSLayoutConstraint?
    
    func adjustKeyboardHeightForKeyboard(height:CGFloat) {
        contentsHeightConstraint?.constant = UIScreen.mainScreen().bounds.size.height - height
    }
    
}

extension BioView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        
        closeButton?.setImage(UIImage.iconCloseXBlack(), forState: .Normal)
        
        let titleText               = NSLocalizedString("MY BIO", comment: "BioView : title : text")
        titleLabel?.text            = titleText
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s15)
        titleLabel?.textColor       = UIColor.bistre()
        
        let bodyText                = NSLocalizedString("Tell us about your skill in\nshooting photos or videos.", comment: "BioView : body : text")
        bodyLabel?.text             = bodyText
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
        
        let subText                 = NSLocalizedString("Minimum 100 characters\nMaximum 500 characters", comment: "BioView : sublabel : text")
        subLabel?.text              = subText
        subLabel?.font              = UIFont.proxima(.RegularItalic, size: FontSizes.s12)
        subLabel?.textColor         = UIColor.bistre()
        subLabel?.numberOfLines     = 0
        
        bioTextView?.font           = UIFont.proxima(.Regular, size: FontSizes.s14)
        bioTextView?.textColor      = UIColor.dimGray()
        bioTextView?.backgroundColor = UIColor.whiteColor()
        
        charactersLabel?.font       = UIFont.proxima(.Regular, size: FontSizes.s15)
        charactersLabel?.textColor  = UIColor.dimGray()
        
        let saveText                = NSLocalizedString("SAVE", comment: "BioView : saveButton : text")
        saveButton?.setTitle(saveText, forState: .Normal)
    }
    
}