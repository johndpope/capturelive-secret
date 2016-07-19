//
//  EventInfoCollectionViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class EventInfoView: UIView {
    
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var button:RoundProfileButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor             = UIColor.clearColor()
        
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s10)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.textColor       = UIColor.bistre()
        titleLabel?.hidden          = true
        titleLabel?.alpha           = 0
 
        button?.userInteractionEnabled = false
        button?.layer.shadowRadius  = 0.4
        button?.layer.shadowColor   = UIColor.blackColor().CGColor
        button?.layer.shadowOffset  = CGSizeMake(0.0, 0.5)
        button?.layer.shadowOpacity = 0.3
    }
    
    func showLabels() {
        titleLabel?.hidden          = false
        UIView.animateWithDuration(0.3, delay: 0.2, options:[], animations: { [weak self] in
            self?.titleLabel?.alpha = 1
            }) {  fin in
        }
    }
    
    func hideLabels() {
        UIView.animateWithDuration(0.3, delay: 0.0, options:[], animations: { [weak self] in
            self?.titleLabel?.alpha = 0
        }) { [weak self] fin in
            self?.titleLabel?.hidden = true
        }
     }
    
    func configure(titleString:String, imagePathString:String) {
        titleLabel?.text            = titleString
        button?.reset()
        CMImageCache.defaultCache().imageForPath(imagePathString, complete: { [weak self] error, image in
            if error == nil {
                self?.button?.setImage(image, forState: .Normal)
            }
        })
    }
    
}