//
//  ReelView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class ReelView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var reelImageView:UIImageView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var copyTextField:UITextField?
    @IBOutlet weak var prefixLabel:UILabel?
    @IBOutlet weak var prefixLabelView:UIView?
    @IBOutlet weak var urlButton:UIButton?
    @IBOutlet weak var closeButton:UIButton?
    @IBOutlet weak var contentsHeightConstraint:NSLayoutConstraint?
 
    func adjustKeyboardHeightForKeyboard(height:CGFloat) {
        contentsHeightConstraint?.constant = UIScreen.mainScreen().bounds.size.height - height
    }
    
}

extension ReelView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        
        closeButton?.setImage(UIImage.iconCloseXBlack(), forState: .Normal)

        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s15)
        titleLabel?.textColor       = UIColor.bistre()
        
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
        
        prefixLabel?.font           = UIFont.proxima(.Regular, size: FontSizes.s14)
        prefixLabel?.textColor      = UIColor.taupeGray()
        prefixLabel?.backgroundColor = UIColor.platinum()
        prefixLabelView?.backgroundColor = UIColor.platinum()
       
        urlButton?.setImage(UIImage(named:"bttn_verifynumber_active" ), forState:.Normal)
        
        copyTextField?.font         = UIFont.proxima(.Regular, size: FontSizes.s14)
        copyTextField?.textColor    = UIColor.bistre()
        copyTextField?.autocorrectionType = .No
        copyTextField?.autocapitalizationType = .None
        copyTextField?.text          = nil
    }
    
}