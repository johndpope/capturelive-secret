//
//  ProfileTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/11/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureUI

let ProfileTableViewCellIdentifier          = "ProfileTableViewCellIdentifier"

class ProfileTableViewCell : UITableViewCell, ConfigurableCell {
    
    static var ProfileTableViewCellHeight:CGFloat {
        return ScreenSize.SCREEN_HEIGHT * 0.088
    }
    
    private typealias Data = DefaultDataProvider<ProfileTableViewCell>
    private var dataSource:CollectionViewDataSource<ProfileTableViewCell, Data, ProfileTableCellCollectionCell>!
    private var dataProvider: Data!
   
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var collectionView:UICollectionView?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle                 = .None
        
        collectionView?.backgroundColor     = UIColor.clearColor()
        collectionView?.transform           = CGAffineTransformMakeScale(-1, 1)
        collectionView?.userInteractionEnabled = false
        
        let layout                          = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let h                               = ScreenSize.SCREEN_HEIGHT * 0.07
        layout.itemSize                     = CGSizeMake(h, h)
        
        titleLabel?.font                    = UIFont.proxima(.Regular, size: FontSizes.s12)
        titleLabel?.textColor               = UIColor.bistre()
        
        containerView?.backgroundColor      = UIColor.platinum()
        containerView?.layer.shadowColor    = UIColor.blackColor().CGColor
        containerView?.layer.shadowOpacity  = 0.3
        containerView?.layer.shadowOffset   = CGSizeMake(0, 0.3)
        containerView?.layer.shadowRadius   = 0.5
        
        contentView.backgroundColor         = UIColor.isabelline()
        backgroundColor                     = UIColor.isabelline()
    }
    
    func configureForObject(object: ProfileTableCellInfo) {
        titleLabel?.text = object.title
        updateProfile(object.roundButtons)
    }
    
    func updateProfile(roundButtons:[RoundButtonDecoratable]) {
        dataProvider    = DefaultDataProvider(items:roundButtons, delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:collectionView!, dataProvider: dataProvider, delegate:self)
    }
}

extension ProfileTableViewCell : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<RoundButtonDecoratable>]?) {
    }
}

extension ProfileTableViewCell : DataSourceDelegate {
    func cellIdentifierForObject(object:RoundButtonDecoratable) -> String {
        return ProfileTableCellCollectionCellIdentifier
    }
}