//
//  JobDataButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/31/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class JobDataButton: UIButton {

    public var subTitleTextColor    = UIColor.bistre()
    public var titleTextColor       = UIColor.taupeGray()
    public var titleFont            = UIFont.proxima(.Bold, size:FontSizes.s14)
    public var subTitleFont         = UIFont.proxima(.Bold, size:FontSizes.s10)
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        stylize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        stylize()
    }
    
    func stylize() {
        backgroundColor             = UIColor.whiteColor()
        titleLabel?.numberOfLines   = 0
        titleLabel?.textAlignment   = .Center
    }

    public func setText(subTitle:String, title:String, forState state: UIControlState) {
        let lightAtt                = [
            NSFontAttributeName            : subTitleFont
            ,NSForegroundColorAttributeName : subTitleTextColor
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let subTitleString          = NSMutableAttributedString(string:"\(subTitle)\n", attributes: lightAtt )
        let boldAtt                 = [
            NSFontAttributeName            : titleFont
            ,NSForegroundColorAttributeName : titleTextColor
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let titleString             = NSMutableAttributedString(string:title, attributes:boldAtt )
        subTitleString.appendAttributedString(titleString)
        self.setAttributedTitle(subTitleString, forState:state)
    }
}
