//
//  ExperienceView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class ExperienceView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var nextButton:UIButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var myExperienceLabel:UILabel?
    @IBOutlet weak var iveFilmedLabel:UILabel?
    @IBOutlet weak var lineView:UIView?
    
}

extension ExperienceView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        collectionView?.backgroundColor = UIColor.isabelline()
        let layout                  = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                       = UIScreen.mainScreen().bounds.size.width
        layout.itemSize             = CGSizeMake(w * 0.33, w * 0.33)
 
        let titleText               = NSLocalizedString("Your Photography Experience", comment: "ExperienceView : title : text")
        titleLabel?.text            = titleText
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s15)
        titleLabel?.textColor       = UIColor.bistre()
        
        let bodyText                = NSLocalizedString("This is dummy copy. This is is lorim\nThis is dummy his is is lorim", comment: "ExperienceView : body : text")
        bodyLabel?.text             = bodyText
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
        
        lineView?.backgroundColor   = UIColor.taupeGray()
        lineView?.alpha             = 0.6
       
        nextButton?.layer.cornerRadius = 20
        nextButton?.setBackgroundImage(UIImage.profileNextButtonEnabled(), forState:.Normal)
        nextButton?.setBackgroundImage(UIImage.profileNextButtonDisabled(), forState:.Disabled)
        
        layoutIfNeeded()
    }
 
}

