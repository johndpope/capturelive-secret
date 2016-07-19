//
//  CompletedJobTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/2/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

public let EndedJobTableViewCellHeight = (ScreenSize.SCREEN_WIDTH * 0.562)
public let MaxTitleWidth = ScreenSize.SCREEN_WIDTH - 80
    
class EndedJobTableViewCell: UITableViewCell {
    
    static let Identifier                       = "EndedJobTableViewCellIdentifier"
    @IBOutlet weak var containerView:EndJobView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView?.didLoad()
        
        contentView.backgroundColor             = UIColor.clearColor()
        backgroundColor                         = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(viewModel:EventTableCellViewModel) {
        containerView?.update(viewModel)
       
    }
    
}

extension EndedJobTableViewCell : ConfigurableCell {
    
    func configureForObject(object:EventTableCellViewModel) {
        update(object)
    }
    
}