//
//  AgreementCollectionViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class AgreementCollectionViewCell: UICollectionViewCell {
    
    static var Identifier           = "AgreementCollectionViewCellIdentifier"
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var descriptionLabel:UILabel?
    @IBOutlet weak var checkbox:CMCheckbox?
 
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame               = self.bounds
        contentView.autoresizingMask    = [.FlexibleWidth, .FlexibleHeight]
        backgroundColor                 = UIColor.whiteColor()
        
        let title                       = NSLocalizedString("I AGREE", comment: "AgreementCollectionViewCell : titleLabel : text")
        titleLabel?.textColor           = UIColor.mountainMeadow()
        titleLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s12)
        titleLabel?.text                = title
        titleLabel?.userInteractionEnabled = false
       
        descriptionLabel?.textColor     = UIColor.dimGray()
        descriptionLabel?.font          = UIFont.proxima(.Regular, size: FontSizes.s12)
        descriptionLabel?.numberOfLines = 0
        descriptionLabel?.userInteractionEnabled = false

        checkbox?.userInteractionEnabled = false
        contentView.layer.borderColor   = UIColor.munsell().CGColor
        contentView.layer.borderWidth   = 1
        layoutIfNeeded()
    }
    
}


extension AgreementCollectionViewCell : ConfigurableCell {
    
    func configureForObject(object:AgreementNode) {
        descriptionLabel?.text          = object.descriptionString
        checkbox?.selected              = object.hasAgreedBool
    }
    
}