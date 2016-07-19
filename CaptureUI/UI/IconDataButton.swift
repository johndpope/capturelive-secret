//
//  IconDataButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class ImageTitleButton: UIButton {
    
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
        contentVerticalAlignment = .Center
        titleLabel?.font            = UIFont.proxima(.Bold, size:FontSizes.s10)
    }
    
    public func setText(imageName:String, titleString:String, forState state: UIControlState) {
        setTitle(titleString, forState: state)
        setTitleColor(UIColor.bistre(), forState:state)
        setImage(UIImage(named:imageName), forState: state)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        guard var titleLabelFrame = titleLabel?.frame else { fatalError("IconDataButton titleLabel has no frame") }
        guard let labelSize = titleLabel?.sizeThatFits(CGSizeMake(CGRectGetWidth(contentRectForBounds(bounds)), CGFloat.max)) else {
            fatalError("IconDataButton titleLabel has no size")
        }
        guard var imageFrame = imageView?.frame else { fatalError("IconDataButton imaveView has no frame") }
        
        let kTextTopPadding:CGFloat     = frame.height * 0.15
        let fitBoxSize                  = CGSizeMake(max(imageFrame.size.width, labelSize.width), labelSize.height + kTextTopPadding + imageFrame.size.height)
        let fitBoxRect                  = CGRectInset(bounds, (bounds.size.width - fitBoxSize.width) / 2, (bounds.size.height - fitBoxSize.height) / 2)
        
        imageFrame.origin.y             = fitBoxRect.origin.y
        imageFrame.origin.x             = CGRectGetMidX(fitBoxRect) - (imageFrame.size.width/2)
        imageView?.frame                = imageFrame
        
        titleLabelFrame.size.width      = labelSize.width
        titleLabelFrame.size.height     = labelSize.height
        titleLabelFrame.origin.x        = (frame.size.width / 2) - (labelSize.width / 2)
        titleLabelFrame.origin.y        = fitBoxRect.origin.y + imageFrame.size.height + kTextTopPadding
        titleLabel?.frame               = titleLabelFrame
        titleLabel?.textAlignment       = .Center
    }

}
