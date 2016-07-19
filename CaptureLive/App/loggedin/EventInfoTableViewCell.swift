//
//  EventInfoTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit


let EventInfoTableViewCellBaseHeight    = ScreenSize.SCREEN_WIDTH * 0.18
let EventInfoNumLabelWidth              = ((ScreenSize.SCREEN_WIDTH - 20) * 0.1)
let EventInfoTableViewCellDataLabelWidth = (ScreenSize.SCREEN_WIDTH - (EventInfoNumLabelWidth + 70 ))

class EventInfoTableViewCell: UITableViewCell {

    static let Identifier               = "EventInfoTableViewCellIdentifier"
    static let DataLabelFont            = UIFont.proxima(.Regular, size: FontSizes.s14)
   
    @IBOutlet weak var numberLabel: UILabel?
    @IBOutlet weak var dataLabel: UILabel?
    @IBOutlet weak var seperatorView: UIView?
    @IBOutlet weak var dataTextHeightConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberLabel?.font               = UIFont.proxima(.Bold, size: FontSizes.s12)
        numberLabel?.textColor          = UIColor.bistre()
        numberLabel?.layer.borderColor  = UIColor.dimGray().CGColor
        numberLabel?.layer.borderWidth  = 1
        numberLabel?.textAlignment      = .Center
        numberLabel?.layer.cornerRadius = ((ScreenSize.SCREEN_WIDTH - 20) * 0.1) / 2
        
        dataLabel?.font                 = EventInfoTableViewCell.DataLabelFont
        dataLabel?.textColor            = UIColor.dimGray()
        dataLabel?.numberOfLines        = 0
        
        seperatorView?.backgroundColor  = UIColor.munsell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {}
    override func setHighlighted(highlighted: Bool, animated: Bool) {}
    
}

extension EventInfoTableViewCell : ConfigurableCell {
    
    func configureForObject(object:EventIndexInfo) {
        numberLabel?.text               = "\(object.indexInt)"
        dataLabel?.text                 = object.dataString
        seperatorView?.hidden           = object.hidesSeperatorBool
        dataTextHeightConstraint?.constant = object.dataLabelHeight
    }
    
}
