//
//  ZeroStateView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class ZeroStateView: UIView {

    @IBOutlet weak var messageLabel:UILabel?
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var messageLabelHeightConstraint:NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func populate(title:String, imageName:String) {
        backgroundColor                 = UIColor.isabelline()
        messageLabel?.font              = UIFont.proxima(.Bold, size:FontSizes.s22)
        messageLabel?.textColor         = UIColor.bistre()
        messageLabel?.numberOfLines     = 0
        
        messageLabel?.text              = title
        messageLabelHeightConstraint?.constant = title.heightWithConstrainedWidth(ScreenSize.SCREEN_WIDTH * 0.7, font: messageLabel!.font)
        iconImageView?.image            = UIImage(named:imageName)
    }

    public func animateIn() {
        hidden                          = false
        alpha                           = 1
    }
    
    public func animateOut() {
       hidden                           = true
       alpha                            = 0
    }
    
}
