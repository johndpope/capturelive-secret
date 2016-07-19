//
//  ExperienceCategoriesView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class ExperienceCategoriesView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var subLabel:UILabel?
    
}

extension ExperienceCategoriesView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        collectionView?.backgroundColor = UIColor.isabelline()
        let layout                  = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                       = UIScreen.mainScreen().bounds.size.width
        layout.itemSize             = CGSizeMake(w * 0.33, w * 0.33)
        
        let titleText               = NSLocalizedString("I'VE FILMED", comment: "ExperienceCategoriesView : title : text")
        titleLabel?.text            = titleText
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s14)
        titleLabel?.textColor       = UIColor.bistre()
        
        let bodyText                = NSLocalizedString("Choose as many of the event types\nthat you’ve filmed in the past", comment: "ExperienceCategoriesView : body : text")
        bodyLabel?.text             = bodyText
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
        
        let subText                 = NSLocalizedString("(select at least one)", comment: "ExperienceCategoriesView : sublabel : text")
        subLabel?.text              = subText
        subLabel?.font              = UIFont.proxima(.RegularItalic, size: FontSizes.s12)
        subLabel?.textColor         = UIColor.bistre()
        subLabel?.numberOfLines     = 0
    }
    
}