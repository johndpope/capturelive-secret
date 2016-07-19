//
//  ProfileCellCollectionCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/10/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

let ProfileCollectionCellIdentifier = "ProfileCollectionCellIdentifier"
class ProfileCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var button:RoundProfileButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        backgroundColor             = UIColor.isabelline()
        contentView.backgroundColor = UIColor.isabelline()
        
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s10)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textColor       = UIColor.bistre()
        
        button?.userInteractionEnabled = false
        button?.layer.shadowRadius  = 0.4
        button?.layer.shadowColor   = UIColor.blackColor().CGColor
        button?.layer.shadowOffset  = CGSizeMake(0.0, 0.5)
        button?.layer.shadowOpacity = 0.3
    }
    
}

extension ProfileCollectionCell : ConfigurableCell {
    
    func configureForObject(object:CellDecoratable) {
        titleLabel?.text            = object.title
        button?.reset()
        object.decorate(button!)
    }
    
}
