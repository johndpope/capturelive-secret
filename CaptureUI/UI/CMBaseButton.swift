//
//  CMBaseButton.swift
//  Current
//
//  Created by Scott Jones on 8/31/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class CMBaseButton: UIButton {

    var foregroundColorActive:UIColor!
    var backgroundColorActive:UIColor!
    var strokeColorActive:UIColor?

    var foregroundColorInactive:UIColor!
    var backgroundColorInactive:UIColor!
    var strokeColorInactive:UIColor?

    var foregroundColorSelected:UIColor!
    var backgroundColorSelected:UIColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.assignColors()
        self.decorate()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.assignColors()
        self.decorate()
    }
    
    func assignColors() {
        fatalError("assignColors() must be overridden in subclass")
    }
    
    internal func decorate() {
        self.titleLabel?.font           = UIFont.proxima(.Bold, size: FontSizes.s15)
        self.layer.masksToBounds        = true
        self.layer.cornerRadius         = 2
        self.setTitleColor(foregroundColorActive, forState: UIControlState.Normal)
        self.setTitleColor(foregroundColorSelected, forState: UIControlState.Highlighted)
        self.setTitleColor(foregroundColorSelected, forState: UIControlState.Selected)
        self.setTitleColor(foregroundColorInactive, forState: UIControlState.Disabled)
        self.backgroundColor            = backgroundColorActive
        
        if let sa = self.strokeColorActive {
            self.layer.borderColor      = sa.CGColor
            self.layer.borderWidth      = 1
        }
    }
    
    public override var selected: Bool {
        willSet(newValue) {
            super.selected = newValue;
            if newValue == true {
                self.backgroundColor = backgroundColorSelected
                if let sa = self.strokeColorActive {
                    self.layer.borderColor      = sa.CGColor
                }

            } else {
                self.backgroundColor = backgroundColorActive
                if let sa = self.strokeColorInactive {
                    self.layer.borderColor      = sa.CGColor
                }
            }
        }
        
        didSet {
            
        }
    }
    
    override public var highlighted: Bool {
        willSet(newValue) {
            if self.enabled == false {
                return
            }
            super.highlighted = newValue;
            if newValue == true {
                self.backgroundColor = backgroundColorSelected
                if let sa = self.strokeColorActive {
                    self.layer.borderColor      = sa.CGColor
                }
                
            } else {
                self.backgroundColor = backgroundColorActive
                if let sa = self.strokeColorInactive {
                    self.layer.borderColor      = sa.CGColor
                }
            }
        }
        
        didSet {
            
        }
    }
    
    public override var enabled: Bool {
        willSet(newValue) {
            super.enabled = newValue;
            if newValue == true {
                self.backgroundColor = backgroundColorActive
                if let sa = self.strokeColorActive {
                    self.layer.borderColor      = sa.CGColor
                }
            } else {
                self.backgroundColor = backgroundColorInactive
                if let sa = self.strokeColorInactive {
                    self.layer.borderColor      = sa.CGColor
                }
            }
        }
        
        didSet {
            
        }
    }

}


public enum CMBaseButtonStyle : Int {
    case Primary
    case Secondary
    case Onboarding
    case Activate
    case Loading
    case Cancel
}

extension CMBaseButtonStyle {
   
    func create(style:CMBaseButtonStyle)->CMBaseButton {
        return self.create(style, title:nil)
    }
    
    func create(style:CMBaseButtonStyle, title:String?)->CMBaseButton {
        var but:CMBaseButton!
        switch self {
        case .Primary:
            but             = CMPrimaryButton(frame:CGRectZero)
        case .Secondary:
            but             = CMSecondaryButton(frame:CGRectZero)
        case .Onboarding:
            but             = CMOnboardingButton(frame:CGRectZero)
        case .Activate:
            but             = CMActivatedButton(frame:CGRectZero)
        case .Loading:
            but             = CMLoadingButton(frame:CGRectZero)
        case .Cancel:
            but             = CMCancelButton(frame:CGRectZero)
        }
        if let t = title {
            but.setTitle(t, forState: UIControlState.Normal)
        }
        return but
    }
    
}



extension CMBaseButton {
    
    static func create(style:CMBaseButtonStyle, title:String?)->CMBaseButton {
        var but:CMBaseButton!
        switch style {
        case .Primary:
            but = CMPrimaryButton(frame:CGRectZero)
        case .Secondary:
            but = CMSecondaryButton(frame:CGRectZero)
        case .Onboarding:
            but = CMOnboardingButton(frame:CGRectZero)
        case .Activate:
            but = CMActivatedButton(frame:CGRectZero)
        case .Loading:
            but = CMLoadingButton(frame:CGRectZero)
        case .Cancel:
            but = CMCancelButton(frame:CGRectZero)
        }
    
        if let t = title {
            but.setTitle(t, forState: UIControlState.Normal)
        }
        return but
    }
    
}

























