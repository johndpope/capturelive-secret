//
//  ImageCollectionViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/21/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

let ImageCollectionViewCellReuseIdentifier = "ImageCollectionViewCellReuseIdentifier"
class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.frame               = self.bounds
        contentView.autoresizingMask    = [.FlexibleWidth, .FlexibleHeight]
        
        imageView?.contentMode          = .ScaleAspectFill
        imageView?.clipsToBounds        = true
        
        contentView.backgroundColor     = UIColor.whiteColor()
    }
    
    private func update(viewmodel:AttachmentCollectionViewModel) {
        imageView?.image                = nil
        CMImageCache.defaultCache().imageForPath(viewmodel.thumbnailPathString, complete: { [weak self] error, image in
            if error == nil {
                self?.imageView?.image  = image
            }
        })
    }
    
}

extension ImageCollectionViewCell : ConfigurableCell {
    
    func configureForObject(object: AttachmentCollectionViewModel) {
        update(object)
    }
    
}

