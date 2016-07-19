//
//  SupportTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit


let SupportTableViewCellIdentifier              = "SupportTableViewCellIdentifier"

class SupportTableViewCell: UITableViewCell {
    
    static var SupportTableViewCellHeight:CGFloat {
        return ScreenSize.SCREEN_HEIGHT * 0.088
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textLabel?.font            = UIFont.proxima(.Regular, size: FontSizes.s14)
        self.textLabel?.textColor       = UIColor.bistre()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

typealias Title = String
extension SupportTableViewCell : ConfigurableCell {
        
    func configureForObject(object:Title) {
        separatorInset                              = UIEdgeInsetsZero
        layoutMargins                               = UIEdgeInsetsZero
        self.textLabel?.text = object
    }

}