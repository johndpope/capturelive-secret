//
//  ReelView.swift
//  Current
//
//  Created by Scott Jones on 4/12/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CaptureCore

class CMReelView: UIView, ActivityIndicatable {
    
    @IBOutlet weak var backButton:UIButton?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var navTitleLabel:UILabel?
   
    @IBOutlet weak var directionsLabel:UILabel?
    @IBOutlet weak var reelTextField:UITextField?
    @IBOutlet weak var reelTableView:UITableView?
    @IBOutlet weak var exampleReelTableView:UITableView?
    @IBOutlet weak var nextButton:UIButton?
    @IBOutlet weak var reelTableHeightConstraint:NSLayoutConstraint?
    
    func showForAttemptingLogin() {
        let nextButtonText              = NSLocalizedString("NEXT", comment: "CMReelView : nextButton : text")
        nextButton?.setTitle(nextButtonText, forState: .Normal)
    }

}

extension CMReelView : CMContractViewProtocol {
    
    func didLoad() {
        stopActivityIndicator()
       
        backButton?.setBackgroundImage(UIImage.iconBackArrow(), forState: .Normal)
        backButton?.setTitle("", forState: .Normal)
        
        let navTitleText                = NSLocalizedString("APPLICATION FORM", comment: "CMReelView : navTitleLabel : text")
        self.navTitleLabel?.text        = navTitleText
        self.navTitleLabel?.font        = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        self.navTitleLabel?.textColor   = UIColor.blackCurrent()

        
        let directionsText              = NSLocalizedString("Show off your work. Include any website link that showcases your experience. We welcome all levels ranging from your weekend instagramer, avid youtuber, or flickr professional. Share at least one.", comment: "CMReelView : directionsLabel : text")
        directionsLabel?.text           = directionsText
        directionsLabel?.font           = UIFont.sourceSansPro(.Regular, size: 14)
        directionsLabel?.numberOfLines  = 0
       
        reelTextField?.enabled          = false
        
        let nextButtonText              = NSLocalizedString("SAVE", comment: "CMReelView : saveButton : text")
        nextButton?.setTitle(nextButtonText, forState: .Normal)
        nextButton?.setTitleColor(UIColor.whiteCurrent(), forState: .Normal)
        nextButton?.setTitleColor(UIColor.greyLightCurrent(), forState: .Disabled)
        nextButton?.backgroundColor     = UIColor.greyCurrent()
        nextButton?.enabled             = false
        
        hideExamples()
    }
    
    func showExamples() {
        exampleReelTableView?.hidden = false
    }
    
    func hideExamples() {
        exampleReelTableView?.hidden = true
    }

    func adjustTableHeightForKeyboard(height:CGFloat){
        reelTableHeightConstraint?.constant = height
        layoutIfNeeded()
    }
    
}












