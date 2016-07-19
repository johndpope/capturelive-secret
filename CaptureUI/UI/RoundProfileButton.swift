//
//  TwoLineRoundButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation


public class RoundProfileButton: BaseRoundButton {
    
    override func assignColors() {
        backgroundColorActive               = UIColor.whiteColor()
        backgroundColorInactive             = UIColor.greyLightCurrent()
        backgroundColorSelected             = UIColor.greyLightCurrent()
        decorate()
    }
  
    public func reset() {
        titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        setImage(nil, forState: .Normal)
        setBackgroundImage(nil, forState: .Normal)
        setTitle(nil, forState: .Normal)
        setAttributedTitle(nil, forState: .Normal)
        backgroundColor                     = UIColor.whiteColor()
        contentMode                         = .Center
        contentHorizontalAlignment          = .Center
        contentVerticalAlignment            = .Center
    }
    
}