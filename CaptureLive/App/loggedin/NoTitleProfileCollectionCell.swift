//
//  NoTitleProfileCollectionCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

let NoTitleProfileCollectionCellIdentifier = "NoTitleProfileCollectionCellIdentifier"
class NoTitleProfileCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var button:RoundProfileButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        backgroundColor             = UIColor.isabelline()
        contentView.backgroundColor = UIColor.isabelline()
        
        button?.userInteractionEnabled = false
        button?.layer.shadowRadius  = 0.4
        button?.layer.shadowColor   = UIColor.blackColor().CGColor
        button?.layer.shadowOffset  = CGSizeMake(0.0, 0.5)
        button?.layer.shadowOpacity = 0.3
    }
    
}

extension NoTitleProfileCollectionCell : ConfigurableCell {
    
    func configureForObject(object:RoundButtonDecoratable) {
        button?.reset()
        object.decorate(button!)
    }
    
}
