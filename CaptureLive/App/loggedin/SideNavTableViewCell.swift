//
//  SideNavTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/23/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

struct SideNavViewModel {
    let iconNameString:String
    let titleString:String
    let indicatorCount:Int?
    init(iconNameString:String, titleString:String, indicatorCount:Int? = nil) {
        self.iconNameString = iconNameString
        self.titleString    = titleString
        self.indicatorCount = indicatorCount
    }
}

let SideNavTableViewCellCellIdentifier              = "SideNavTableViewCellCellIdentifier"

class SideNavTableViewCell : UITableViewCell {
    
    static var SideNavTableViewCellHeight:CGFloat {
        return ScreenSize.SCREEN_HEIGHT * 0.088
    }

    @IBOutlet weak var navButton:CMNavButton?
    @IBOutlet weak var indicatorLabel:UILabel?
    @IBOutlet weak var indicatorLabelWidthConstraint:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navButton?.userInteractionEnabled           = false
        navButton?.preservesSuperviewLayoutMargins  = false;
        
        indicatorLabel?.backgroundColor             = UIColor.bistre()
        indicatorLabel?.textColor                   = UIColor.whiteColor()
        indicatorLabel?.font                        = UIFont.proxima(.Regular, size:FontSizes.s12)
        
        indicatorLabel?.clipsToBounds               = true
        indicatorLabel?.layer.cornerRadius          = floor(ScreenSize.SCREEN_HEIGHT * 0.025)
        
        contentView.backgroundColor                 = UIColor.mountainMeadow()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        navButton?.highlighted                      = highlighted
        indicatorLabel?.backgroundColor             = UIColor.bistre()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        navButton?.selected                         = selected
        indicatorLabel?.backgroundColor             = UIColor.bistre()
    }

}

extension SideNavTableViewCell : ConfigurableCell {
    
    func configureForObject(object:SideNavViewModel) {
        separatorInset                              = UIEdgeInsetsZero
        layoutMargins                               = UIEdgeInsetsZero

        navButton?.setImage(UIImage(named:object.iconNameString), forState: .Normal)
        navButton?.setImage(UIImage(named:object.iconNameString), forState: .Highlighted)
        navButton?.setTitle(object.titleString, forState: .Normal)
        
        guard let count = object.indicatorCount where count > 0 else {
            indicatorLabel?.hidden                  = true
            return
        }
        indicatorLabel?.hidden                      = false
        let countText                               = "\(count)"
        indicatorLabelWidthConstraint?.constant     = countText.widthWithConstrainedHeight(indicatorLabel!.frame.size.height, font:indicatorLabel!.font!) + 34
        indicatorLabel?.text                        = countText
    }
    
}













