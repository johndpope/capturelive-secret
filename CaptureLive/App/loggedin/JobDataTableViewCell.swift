//
//  JobDataTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public let JobDataTableViewCellHeight:CGFloat   = 20
class JobDataTableViewCell: UITableViewCell {

    static let Identifier                       = "JobDataTableViewCellIdentifier"
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var dataLabel:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.font                        = UIFont.proxima(.Regular, size: FontSizes.s14)
        titleLabel?.textColor                   = UIColor.taupeGray()
        
        dataLabel?.font                         = UIFont.proxima(.Bold, size: FontSizes.s14)
        dataLabel?.textColor                    = UIColor.bistre()
    }

    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
    }

    func update(viewModel:TitleAndData) {
        titleLabel?.text                        = viewModel.titleString
        dataLabel?.text                         = viewModel.dataString
    }
    
}

extension JobDataTableViewCell : ConfigurableCell {
    
    func configureForObject(object:TitleAndData) {
        update(object)
    }
    
}
