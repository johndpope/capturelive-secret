//
//  ExperienceLevelView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class ExperienceLevelView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    
}

extension ExperienceLevelView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        collectionView?.backgroundColor = UIColor.isabelline()
        let layout                  = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                       = UIScreen.mainScreen().bounds.size.width
        layout.itemSize             = CGSizeMake(w * 0.33, w * 0.33)
        
        let titleText               = NSLocalizedString("MY EXPERIENCE", comment: "ExperienceLevelView : title : text")
        titleLabel?.text            = titleText
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s14)
        titleLabel?.textColor       = UIColor.bistre()
        
        let bodyText                = NSLocalizedString("Choose based on the number of\nyears you’ve worked in photograph", comment: "ExperienceLevelView : body : text")
        bodyLabel?.text             = bodyText
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s14)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
    }
    
}