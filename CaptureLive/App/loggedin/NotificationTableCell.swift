//
//  NotificationTableCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public let NotificationTableViewCellLabelWidth = (ScreenSize.SCREEN_WIDTH - 40) - (ScreenSize.SCREEN_WIDTH * 0.18)
class NotificationTableCell: UITableViewCell {
    
    static let Identifier:String            = "NotificationTableCell"
    
    @IBOutlet weak var eventTitleLabel:UILabel?
    @IBOutlet weak var agoLabel:UILabel?
    @IBOutlet weak var messageLabel:UILabel?
    @IBOutlet weak var logoView:UIImageView?
    @IBOutlet weak var iconImageView:UIImageView?
    @IBOutlet weak var logoViewContainer:UIView?
    @IBOutlet weak var logoWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var logoHeightConstraint:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventTitleLabel?.font               = UIFont.proxima(.Regular, size: FontSizes.s12)
        eventTitleLabel?.textColor          = UIColor.bistre()
        
        messageLabel?.font                  = UIFont.proxima(.Regular, size: FontSizes.s12)
        messageLabel?.textColor             = UIColor.bistre()
        messageLabel?.numberOfLines         = 0
        
        agoLabel?.font                      = UIFont.proxima(.Regular, size: FontSizes.s12)
        agoLabel?.textColor                 = UIColor.taupeGray()
       
        logoViewContainer?.backgroundColor  = UIColor.clearColor()
        
        logoWidthConstraint?.constant       = ScreenSize.SCREEN_WIDTH * 0.18
        logoHeightConstraint?.constant      = ScreenSize.SCREEN_WIDTH * 0.18

        logoView?.backgroundColor           = UIColor.clearColor()
        logoView?.layer.cornerRadius        = floor(logoHeightConstraint!.constant / 2)
        logoView?.clipsToBounds             = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            contentView.backgroundColor = UIColor.isabelline()
        } else {
            contentView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if highlighted {
            contentView.backgroundColor = UIColor.isabelline()
        } else {
            contentView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func prepareForUse(object:NotificationTableCellViewModel) {
        configureForObject(object)
    }
    
}

extension NotificationTableCell : ConfigurableCell {
    
    func configureForObject(object:NotificationTableCellViewModel) {
        separatorInset                              = UIEdgeInsetsZero
        layoutMargins                               = UIEdgeInsetsZero
        logoView?.image                     = nil
        CMImageCache.defaultCache().imageForPath(object.logoUrlString, complete: { [weak self] error, image in
            if error == nil {
                self?.logoView?.image       = image
            }
        })
        iconImageView?.image                = UIImage(named:object.jobIconNameString)
        eventTitleLabel?.text               = object.eventTitleString
        messageLabel?.text                  = object.messageString
        agoLabel?.text                      = object.elapsedTimeString
        
        eventTitleLabel?.font               = UIFont.proxima(object.font, size: FontSizes.s12)
        messageLabel?.font                  = UIFont.proxima(object.font, size: FontSizes.s12)
    }

}