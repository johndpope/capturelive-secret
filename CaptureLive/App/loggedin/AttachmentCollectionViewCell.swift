//
//  AttachmentCollectionViewCell.swift
//  Current
//
//  Created by Scott Jones on 4/4/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

let AttachmentCollectionViewCellReuseIdentifier = "AttachmentCollectionViewCellReuseIdentifier"
class AttachmentCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var descriptionLabel:UILabel?
    @IBOutlet weak var descriptionLabelHeightConstraint:NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame               = self.bounds
        contentView.autoresizingMask    = [.FlexibleWidth, .FlexibleHeight]
       
        descriptionLabel?.font          = UIFont.sourceSansPro(.Regular, size:FontSizes.s12)
        descriptionLabel?.textColor     = UIColor.taupeGray()
        
        imageView?.contentMode          = .ScaleAspectFill
        imageView?.clipsToBounds        = true
        
        contentView.backgroundColor     = UIColor.whiteColor()
    }
    
    private func update(viewmodel:AttachmentCollectionViewModel) {
        imageView?.image                = nil
        CMImageCache.defaultCache().imageForPath(viewmodel.thumbnailPathString, complete: { [weak self] error, image in
            if error == nil {
                self?.imageView?.image  = image
            } else {
                print(error)
            }
        })
        descriptionLabel?.text          = viewmodel.detailString
    }
    
}

extension AttachmentCollectionViewCell : ConfigurableCell {

    func configureForObject(object: AttachmentCollectionViewModel) {
        update(object)
    }
    
}

