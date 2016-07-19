//
//  HowItWorksTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

struct HowItWorksViewModel {
    let titleString:String
    let subTitleString:String
    let descriptionString:String
    let showSeperator:Bool
}
extension HowItWorksViewModel {
    static var descriptionFont:UIFont {
        return UIFont.proxima(.Regular, size: FontSizes.s11)
    }
    
    var cellHieght:CGFloat {
        return descriptionHeight + 66
    }
    
    var descriptionHeight:CGFloat {
        let width = ScreenSize.SCREEN_WIDTH * 0.87
        return descriptionString.heightWithConstrainedWidth(width, font:HowItWorksViewModel.descriptionFont)
    }
}

let HowItWorksTableViewCellIdentifier              = "HowItWorksTableViewCellIdentifier"

class HowItWorksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var descriptionLabel:UILabel?
    @IBOutlet weak var subTitleLabel:UILabel?
    @IBOutlet weak var seperatorView:UIView?
    @IBOutlet weak var descriptionLabelHeightConstraint:NSLayoutConstraint?
 
    static var Height:CGFloat {
        return ScreenSize.SCREEN_HEIGHT * 0.15
    }

    override func awakeFromNib() {
        super.awakeFromNib()
       
        titleLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s12)
        titleLabel?.textColor           = UIColor.mountainMeadow()
        
        subTitleLabel?.font             = UIFont.proxima(.Bold, size: FontSizes.s17)
        subTitleLabel?.textColor        = UIColor.bistre()
        
        descriptionLabel?.font          = HowItWorksViewModel.descriptionFont
        descriptionLabel?.textColor     = UIColor.oldLavender()
        descriptionLabel?.numberOfLines = 0
        
        seperatorView?.backgroundColor  = UIColor.silver()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension HowItWorksTableViewCell : ConfigurableCell {
    
    func configureForObject(object:HowItWorksViewModel) {
        titleLabel?.text                = object.titleString
        subTitleLabel?.text             = object.subTitleString
        descriptionLabel?.text          = object.descriptionString
        seperatorView?.hidden           = !object.showSeperator
        descriptionLabelHeightConstraint?.constant = object.descriptionHeight
    }
    
}
