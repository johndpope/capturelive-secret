//
//  AM.swift
//  CaptureMedia-Acme
//
//  Created by hatebyte on 9/24/14.
//  Copyright (c) 2014 capturemedia. All rights reserved.
//

import UIKit

extension UIView {

//    public func decoratedButton()->UIButton {
//        let button                          = UIButton(type:UIButtonType.Custom) as UIButton
//        self.decorateButton(button )
//        return button
//    }
//    
//    public func decoratedLabel()->UILabel {
//        let lb                              = UILabel()
//        self.decorateLabel(lb)
//        return lb
//    }
//    
//
//    public func decoratedTextField()->UITextField {
//        let tf                              = UITextField()
//        self.decorateTextField(tf)
//        return tf
//    }
//    
//    public func decorateTextField(field:UITextField) {
//        field.font                          = UIFont.sourceSansPro(.Light, size: .Large)
//        field.backgroundColor               = UIColor.whiteColor()
//        field.textColor                     = UIColor.blackColor()
//        field.layer.cornerRadius            = 0;
//        field.layer.borderColor             = UIColor.greyLightestCurrent().CGColor;
//        field.layer.borderWidth             = 1;
//    }
//    
//    public func paddTextField(field:UITextField) {
//        let paddingView                     = UIView(frame: CGRectMake(0, 0, 20, 54))
//        field.leftView                      = paddingView
//        field.leftViewMode                  = .Always
//        field.textAlignment                 = NSTextAlignment.Left
//    }
//    
//    public func decorateLabel(field:UILabel) {
//        field.font                          = UIFont(name:CMFontProxima.Regular.rawValue, size: CMFontSize.Large.rawValue);
//        field.backgroundColor               = UIColor.whiteColor()
//        field.textColor                     = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
//        field.textAlignment                 = NSTextAlignment.Center
////        field.layer.cornerRadius            = 0;
////        field.layer.borderColor             = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7).CGColor;
////        field.layer.borderWidth             = 1;
//    }
//
//    public func decorateButton(button:UIButton) {
//        button.titleLabel?.font             = UIFont(name:CMFontProxima.Regular.rawValue, size: CMFontSize.Large.rawValue)
//        button.layer.masksToBounds          = true
//        button.layer.cornerRadius           = 3
//        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
//        button.setTitleColor(UIColor.greyDarkCurrent(), forState: UIControlState.Selected)
//    }
    
    public func  heightPlusY(view: UIView)->CGFloat {
        return view.frame.size.height + view.frame.origin.y;
    }
    
    public func widthPlusX(view: UIView)->CGFloat {
        return view.frame.size.width + view.frame.origin.x;
    }

}

