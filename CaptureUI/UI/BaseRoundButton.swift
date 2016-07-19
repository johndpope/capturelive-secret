//
//  BaseRoundButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation


public class BaseRoundButton: UIButton {
    
    public var backgroundColorActive:UIColor!
    public var backgroundColorInactive:UIColor!
    public var backgroundColorSelected:UIColor!

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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.layer.cornerRadius = bounds.size.width / 2
        self.layer.cornerRadius         = bounds.size.width / 2
    }
    
    func decorate() {
        self.titleLabel?.numberOfLines  = 0
        self.titleLabel?.textAlignment  = .Center
        self.titleLabel?.font           = UIFont.sourceSansPro(.Regular, size:FontSizes.s18)
        self.backgroundColor            = backgroundColorActive
        
        self.layer.masksToBounds        = false
    }
    
    public func setTitle(title:String, subTitle:String, forState state: UIControlState) {
        setTitle(title, subTitle: subTitle, titleSize: FontSizes.s18, subTitleSize: FontSizes.s10, forState:state)
    }
    
    public func setTitle(title:String, subTitle:String, titleSize:CGFloat, subTitleSize:CGFloat, forState state: UIControlState) {
        let boldAtt             = [
             NSFontAttributeName            : UIFont.proxima(.Bold, size:titleSize)
            ,NSForegroundColorAttributeName : UIColor.blackCurrent()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let titleString         = NSMutableAttributedString(string:title, attributes: boldAtt )
        let lightAtt            = [
             NSFontAttributeName            : UIFont.proxima(.Light, size:subTitleSize)
            ,NSForegroundColorAttributeName : UIColor.blackCurrent()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let subString           = NSMutableAttributedString(string:subTitle, attributes:lightAtt )
        titleString.appendAttributedString(subString)
        self.setAttributedTitle(titleString, forState:state)
    }
    
    public override var selected: Bool {
        willSet(newValue) {
            super.selected = newValue;
            if newValue == true {
                self.backgroundColor = backgroundColorSelected
                
            } else {
                self.backgroundColor = backgroundColorActive
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
                
            } else {
                self.backgroundColor = backgroundColorActive
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
            } else {
                self.backgroundColor = backgroundColorInactive
            }
        }
        
        didSet {
            
        }
    }
    
}
