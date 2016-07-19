//
//  JobInfoTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

let JobInfoTableViewCellBaseHeight      = ScreenSize.SCREEN_WIDTH * 0.1629
let JobInfoDataLabelWidth               = ((ScreenSize.SCREEN_WIDTH - 20) * 0.67) - 18

class JobInfoTableViewCell: UITableViewCell {
   
    static let Identifier               = "JobInfoTableViewCellIdentifier"
    static let dataLabelFont            = UIFont.proxima(.Regular, size: FontSizes.s12)
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var dataLabel:UILabel?
    @IBOutlet weak var dataLabelHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var seperatorView:UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.font                = UIFont.proxima(.Regular, size: FontSizes.s12)
        titleLabel?.textColor           = UIColor.blackColor()
        
        dataLabel?.font                 = JobInfoTableViewCell.dataLabelFont
        dataLabel?.textColor            = UIColor.bistre()
        dataLabel?.numberOfLines        = 0
 
        seperatorView?.backgroundColor  = UIColor.munsell()
//        contentView.backgroundColor     = UIColor.greenColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }

}


extension JobInfoTableViewCell : ConfigurableCell {
    
    func configureForObject(object:TitleAndData) {
        titleLabel?.text                = object.titleString
        dataLabel?.text                 = object.dataString
        
        dataLabelHeightConstraint?.constant = object.heightForJobDataText
        
        seperatorView?.hidden           = object.hideSeparatorView
    }
    
}