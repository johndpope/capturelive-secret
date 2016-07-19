//
//  AppliedEventModule.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class AppliedEventModuleView: UIView {

    @IBOutlet weak var jobStatusModuleView:JobStatusModuleView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var descriptionLabel:UILabel?
    @IBOutlet weak var eventTitleLabel:UILabel?
    @IBOutlet weak var urlButton:UIButton?
    @IBOutlet weak var containerView:UIView?
    @IBOutlet weak var heightConstraint:NSLayoutConstraint?

    func populate(viewModel:EventApplicationModel) {
        let eventTitleText          = NSLocalizedString("\"%@\" VIDEO CAN BE FOUND HERE", comment: "AppliedEventModuleView : eventTitleLabel : text")
        eventTitleLabel?.text       = String(NSString(format:eventTitleText, viewModel.titleString))
        
        guard let publicUrl         = viewModel.publicUrl else { return }
        switch viewModel.contractStatus {
        case .ACQUIRED:
            showHired(publicUrl)
        case .EXPIRED:
            showExpired(publicUrl)
        case .NONE:
            break
        case .APPLIED:
            showApplied(publicUrl)
        }
        
        if viewModel.displayExpired {
            showExpired(publicUrl)
        }
    }
   
    func showApplied(url:String) {
        let eventLabeltext          = NSLocalizedString("THIS JOB CAN BE FOUND HERE", comment: "AppliedEventModuleView : eventTitleLabel : Appliedtext")
        eventTitleLabel?.text       = eventLabeltext

        let titleText               = NSLocalizedString("WHAT HAPPENS NEXT?", comment: "AppliedEventModuleView : titleLabel : Appliedtext")
        titleLabel?.text            = titleText

        let descText                = NSLocalizedString("You’re all set! Someone on CaptureLive.com will be contacting you once you get hired! You’re all set! Someone on CaptureLive.com will be contacting you once you get hired!", comment: "AppliedEventModuleView : descriptionLabel : Appliedtext")
        descriptionLabel?.text      = descText

        setupAttributedButton(eventLabeltext, url: url)
        jobStatusModuleView?.showApplied()
    }
    
    func showExpired(url:String) {
        let eventLabeltext               = NSLocalizedString("THIS JOB CAN BE FOUND HERE", comment: "AppliedEventModuleView : eventTitleLabel : Expiredtext")
        eventTitleLabel?.text       = eventLabeltext

        let titleText               = NSLocalizedString("WHAT HAPPENED?", comment: "AppliedEventModuleView : titleLabel : Expiredtext")
        titleLabel?.text            = titleText
        
        let descText                = NSLocalizedString("This job is no longer available. be contacting you once you get hired! You’re all set! Someone on CaptureLive.com will be contacting you once you get hired!", comment: "AppliedEventModuleView : descriptionLabel : Expiredtext")
        descriptionLabel?.text      = descText

        setupAttributedButton(eventLabeltext, url: url)
        jobStatusModuleView?.showExpired()
    }
    
    func showHired(url:String) {
        let titleText               = NSLocalizedString("WHAT HAPPENS NEXT?", comment: "AppliedEventModuleView : titleLabel : Hiredtext")
        titleLabel?.text            = titleText
        
        let descText                = NSLocalizedString("This job is no longer available. be contacting you once you get hired! You’re all set! Someone on CaptureLive.com will be contacting you once you get hired!", comment: "AppliedEventModuleView : descriptionLabel : Hiredtext")
        descriptionLabel?.text      = descText

        setupAttributedButton(titleText, url: url)
        jobStatusModuleView?.showHired()
    }

    func setupAttributedButton(title:String, url:String) {
        let boldAtt                 = [
            NSFontAttributeName            : UIFont.proxima(.Bold, size: FontSizes.s12)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let boldString              = NSMutableAttributedString(string:title + "\n", attributes:boldAtt)
        
        let lightAtt                = [
            NSFontAttributeName            : UIFont.proxima(.Regular, size:FontSizes.s12)
            ,NSForegroundColorAttributeName : UIColor.mountainMeadow()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let lightString             = NSMutableAttributedString(string:url, attributes:lightAtt)
        boldString.appendAttributedString(lightString)
        urlButton?.setAttributedTitle(boldString, forState:.Normal)
    }
}

extension AppliedEventModuleView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor             = UIColor.isabelline()
      
        containerView?.layer.masksToBounds = false
        containerView?.layer.cornerRadius  = 2
        containerView?.layer.shadowColor   = UIColor.bistre().CGColor
        containerView?.layer.shadowOpacity = 0.5
        containerView?.layer.shadowOffset  = CGSizeMake(0, 0.5)
        containerView?.layer.shadowRadius  = 0.8
        
        titleLabel?.font            = UIFont.proxima(.Bold, size: FontSizes.s12)
        titleLabel?.textColor       = UIColor.bistre()
        
        descriptionLabel?.font      = UIFont.proxima(.Regular, size: FontSizes.s12)
        descriptionLabel?.textColor = UIColor.taupeGray()
        descriptionLabel?.numberOfLines = 0
       
        eventTitleLabel?.font       = UIFont.proxima(.Bold, size: FontSizes.s12)
        eventTitleLabel?.textColor  = UIColor.bistre()

        urlButton?.setTitleColor(UIColor.mountainMeadow(), forState: .Normal)
        urlButton?.titleLabel?.font = UIFont.proxima(.Regular, size: FontSizes.s12)
        urlButton?.titleLabel?.numberOfLines = 0
        urlButton?.titleLabel?.textAlignment = .Center
        
        jobStatusModuleView?.didLoad()
    }

}