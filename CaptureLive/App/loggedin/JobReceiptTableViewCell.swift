//
//  JobReceiptTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/21/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public let JobReceiptTableViewCellHeight:CGFloat = ScreenSize.SCREEN_WIDTH * 0.080
class JobReceiptTableViewCell: UITableViewCell {
    
    static let Identifier                       = "JobReceiptTableViewCellIdentifier"
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var checkImageView:UIImageView?
    @IBOutlet weak var strokeView:UIView?
    @IBOutlet weak var strokeViewHeightConstraint:NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor             = UIColor.whiteSmoke()
        
        titleLabel?.font                        = UIFont.proxima(.Regular, size: FontSizes.s14)
        titleLabel?.textColor                   = UIColor.taupeGray()
        
        checkImageView?.image                   = UIImage(named: "icon_greenchk_tight")
        
        strokeView?.backgroundColor             = UIColor.taupeGray()
        
        strokeViewHeightConstraint?.constant    = 0.5
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //        super.setSelected(selected, animated: animated)
    }
    
    func update(viewModel:String) {
        titleLabel?.text                        = viewModel
    }
    
}

extension JobReceiptTableViewCell : ConfigurableCell {
    
    func configureForObject(object:String) {
        update(object)
    }
    
}