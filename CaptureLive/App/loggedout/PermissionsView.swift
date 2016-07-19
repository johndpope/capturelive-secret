//
//  PermissionsView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class PermissionsView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var legalLabel:UILabel?
    @IBOutlet weak var legalContainerView:UIView?
    @IBOutlet weak var checkbox:CMCheckbox?
    @IBOutlet weak var submitButton:CMPrimaryButton?
    
}

extension PermissionsView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        collectionView?.backgroundColor = UIColor.isabelline()
        let layout                  = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                       = UIScreen.mainScreen().bounds.size.width
        layout.itemSize             = CGSizeMake(w * 0.33, w * 0.33)
        
        let titleText               = NSLocalizedString("TERMS OF SERVICE", comment: "PermissionsView : title : text")
        titleLabel?.text            = titleText
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s15)
        titleLabel?.textColor       = UIColor.bistre()
      
        let iagreeText              = NSLocalizedString("I agree to CaptureLIVE", comment: "PermissionsView : I agree to CaptureLIVE : text")
        let termsText               = NSLocalizedString("Terms of use\nand Privacy Policy", comment: "PermissionsView : I agree to CaptureLIVE : text")
        
        let boldAtt                 = [
            NSFontAttributeName: UIFont.proxima(.Regular, size:FontSizes.s12)
            ,NSForegroundColorAttributeName: UIColor.dimGray()
            ,NSBackgroundColorAttributeName: UIColor.clearColor()
        ]
        let titleString             = NSMutableAttributedString(string:iagreeText, attributes: boldAtt )
        let lightAtt                = [
            NSFontAttributeName: UIFont.proxima(.Bold, size:FontSizes.s12)
            ,NSForegroundColorAttributeName: UIColor.mountainMeadow()
            ,NSBackgroundColorAttributeName: UIColor.clearColor()
        ]
        let subString               = NSMutableAttributedString(string:" \(termsText)", attributes:lightAtt )
        titleString.appendAttributedString(subString)

        let paragraphStyle          = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing  = 7
        titleString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, titleString.length))
        
        legalLabel?.attributedText  = titleString
        legalLabel?.numberOfLines   = 0
       
        legalContainerView?.layer.cornerRadius  = 2
        legalContainerView?.layer.shadowColor   = UIColor.blackColor().CGColor
        legalContainerView?.layer.shadowOpacity = 0.3
        legalContainerView?.layer.shadowOffset  = CGSizeMake(0, 0.3)
        legalContainerView?.layer.shadowRadius  = 0.5
       
        let submitText = NSLocalizedString("SUBMIT", comment: "PermissionsView : submitButton : text")
        submitButton?.setTitle(submitText, forState: .Normal)
//        submitButton?.enabled       = false
    }
    
}