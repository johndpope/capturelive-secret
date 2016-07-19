//
//  ProfileTableCellCollectionCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/11/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

let ProfileTableCellCollectionCellIdentifier = "ProfileTableCellCollectionCellIdentifier"

class ProfileTableCellCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var button:RoundProfileButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame               = self.bounds
        contentView.autoresizingMask    = [.FlexibleWidth, .FlexibleHeight]
        
        backgroundColor                 = UIColor.platinum()
        contentView.backgroundColor     = UIColor.platinum()
       
        button?.setTitle("", forState: .Normal)
        button?.userInteractionEnabled  = false
        button?.layer.shadowRadius      = 0.4
        button?.layer.shadowColor       = UIColor.blackColor().CGColor
        button?.layer.shadowOffset      = CGSizeMake(0.0, 0.2)
        button?.layer.shadowOpacity     = 0.2
    }
    
}

extension ProfileTableCellCollectionCell : ConfigurableCell {
    
    func configureForObject(object:RoundButtonDecoratable) {
        self.transform = CGAffineTransformMakeScale(-1, 1)
        button?.reset()
        object.decorate(button!)

    }
    
}