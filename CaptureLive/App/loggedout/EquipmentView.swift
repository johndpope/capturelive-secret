//
//  EquipmentView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class EquipmentView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    
}

extension EquipmentView : CMViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
        
        backgroundColor             = UIColor.isabelline()
        collectionView?.backgroundColor = UIColor.isabelline()
        let layout                  = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                       = UIScreen.mainScreen().bounds.size.width
        layout.itemSize             = CGSizeMake(w * 0.33, w * 0.33)
        
        let titleText               = NSLocalizedString("MY EQUIPMENT", comment: "EquipmentView : title : text")
        titleLabel?.text            = titleText
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s14)
        titleLabel?.textColor       = UIColor.bistre()
        
        let bodyText                = NSLocalizedString("Choose as many equipment items\nthat you personally own.", comment: "EquipmentView : body : text")
        bodyLabel?.text             = bodyText
        bodyLabel?.font             = UIFont.proxima(.Regular, size: FontSizes.s12)
        bodyLabel?.textColor        = UIColor.dimGray()
        bodyLabel?.numberOfLines    = 0
        
    }
    
}