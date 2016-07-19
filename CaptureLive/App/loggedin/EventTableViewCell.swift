//
//  CMEventTableViewCell.swift
//  Current
//
//  Created by Scott Jones on 2/24/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureModel

public let EventTableViewCellLabelWidth = ScreenSize.SCREEN_WIDTH - 60
public let EventTableViewCellBaseHeight = (ScreenSize.SCREEN_WIDTH * 0.562) - 20

class EventTableViewCell: UITableViewCell {

    static let Identifier                       = "EventTableViewCellIdentifier"
    static let StartString                      = NSLocalizedString("STARTS",    comment: "EventTableViewCell : starts   : subtitle")
    static let StartedString                    = NSLocalizedString("STARTED",    comment: "EventTableViewCell : started   : subtitle")
    static let JobPaysString                    = NSLocalizedString("JOB PAYS",  comment: "EventTableViewCell : job pays : subtitle")
    static let DistanceString                   = NSLocalizedString("DISTANCE",  comment: "EventTableViewCell : distance : subtitle")
   
    static let TitleFont = UIFont.proxima(.SemiBold, size: FontSizes.s14)
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    @IBOutlet weak var bannerImageView:UIImageView?
    @IBOutlet weak var organizationLogoView:UIImageView?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var contractStatusView:UIView?
    @IBOutlet weak var appliedLabel:UILabel?
    @IBOutlet weak var titleHieghtConstraint:NSLayoutConstraint?
    @IBOutlet weak var leftDataButton:JobDataButton?
    @IBOutlet weak var centerDataButton:JobDataButton?
    @IBOutlet weak var rightDataButton:JobDataButton?
    @IBOutlet weak var buttonContainerView:UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel?.numberOfLines               = 0
        titleLabel?.font                        = EventTableViewCell.TitleFont
        titleLabel?.textColor                   = UIColor.bistre()
        subTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s12)
        subTitleLabel?.textColor                = UIColor.taupeGray()

        bannerImageView?.contentMode            = .ScaleAspectFill
        bannerImageView?.clipsToBounds          = true
        
        organizationLogoView?.clipsToBounds     = true
        organizationLogoView?.layer.cornerRadius = ((ScreenSize.SCREEN_WIDTH - 20) * 0.168) / 2
        organizationLogoView?.layer.borderColor = UIColor.whiteColor().CGColor
        organizationLogoView?.layer.borderWidth = 2
        organizationLogoView?.backgroundColor   = UIColor.whiteColor()
        
        let appliedText                         = NSLocalizedString("YOU'VE APPLIED!", comment: "EventTableViewCell : appliedLabel : text")
        appliedLabel?.text                      = appliedText
        appliedLabel?.font                      = UIFont.proxima(.Bold, size: FontSizes.s12)
        appliedLabel?.textColor                 = UIColor.whiteColor()
        
        containerView?.backgroundColor          = UIColor.whiteColor()
        containerView?.layer.shadowOpacity      = 0.5
        containerView?.layer.shadowOffset       = CGSizeMake(0, 0.2)
        containerView?.layer.shadowRadius       = 0.5
        containerView?.layer.cornerRadius       = 2
        
        buttonContainerView?.backgroundColor    = UIColor.platinum()
        
        contentView.backgroundColor             = UIColor.clearColor()
        backgroundColor                         = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func update(viewmodel:EventTableCellViewModel) {

        CMImageCache.defaultCache().imageForPath(viewmodel.organizationLogoPath, complete: { [weak self] error, image in
            if error == nil {
                self?.organizationLogoView?.image   = image
            } else {
                self?.organizationLogoView?.image   = nil
            }
        })
        bannerImageView?.image = nil
        CMImageCache.defaultCache().imageForPath(viewmodel.bannerImagePath, complete: { [weak self] error, image in
            if error == nil {
                self?.bannerImageView?.image        = image
            } else {
                self?.bannerImageView?.image        = nil
            }
        })
        
        
        titleLabel?.text                            = viewmodel.titleString
        titleHieghtConstraint?.constant             = viewmodel.titleHeight + 20
        
        let subTitleText = NSLocalizedString("Posted by %@", comment: "EventTableViewCell : subtitleText")
        subTitleLabel?.text                         = String(NSString(format: subTitleText, viewmodel.organizationNameString))
 
        if viewmodel.hasStartedBool {
            leftDataButton?.setText(EventTableViewCell.StartedString, title: viewmodel.startDateString, forState: .Normal)
        } else {
            leftDataButton?.setText(EventTableViewCell.StartString, title: viewmodel.startDateString, forState: .Normal)
        }
        centerDataButton?.setText(EventTableViewCell.JobPaysString, title: viewmodel.paymentString, forState: .Normal)
        rightDataButton?.setText(EventTableViewCell.DistanceString, title: viewmodel.distanceAwayString(), forState: .Normal)
       
        contractStatusView?.backgroundColor         = UIColor.bistre()
        appliedLabel?.hidden                        = true
        contractStatusView?.alpha                   = 1.0
        switch viewmodel.contractStatus {
        case .NONE:
            contractStatusView?.alpha               = 0.3
        case .APPLIED:
            appliedLabel?.hidden                    = false
        case .ACQUIRED:
            contractStatusView?.backgroundColor     = UIColor.mountainMeadow()
        case .EXPIRED:
            contractStatusView?.backgroundColor     = UIColor.mountainMeadow()
        }

    }
    
}

extension EventTableViewCell : ConfigurableCell {
    
    func configureForObject(object:EventTableCellViewModel) {
        update(object)
    }

}