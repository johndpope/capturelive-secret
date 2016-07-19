//
//  CMModalHiredView.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit
import CaptureUI

class ModalHiredView: UIView {
    
    @IBOutlet var viewJobButton:UIButton?
    @IBOutlet var titleLabel:UILabel?
    @IBOutlet var titleSubLabel:UILabel?
    @IBOutlet var avatarView:UIView?
    @IBOutlet var avatarImageView:UIImageView?
    @IBOutlet var publisherTitleLabel:UILabel?
    @IBOutlet var publisherNameLabel:UILabel?
    @IBOutlet var teamNameLabel:UILabel?
    @IBOutlet var hiredLabel:UILabel?
    @IBOutlet var eventTitleLabel:UILabel?

    @IBOutlet var activityIndicator:UIActivityIndicatorView?
    
    func populate(publisher publisher:PublisherHiredViewModel, event:EventViewModel, team:TeamViewModel) {
        CMImageCache.defaultCache().imageForPath(publisher.avatarURLString, complete: { [weak self] (error:NSError!, image:UIImage!) -> Void in
            if error == nil {
                self?.avatarImageView?.image = image
            }
        })
        
        publisherNameLabel?.text                = publisher.titleNameString
        let teamNameLabelText                   = NSLocalizedString("from %@", comment: "CMModalHiredView : teamNameLabel : text")
        teamNameLabel?.text                     = String(NSString(format:teamNameLabelText, team.nameString))
        eventTitleLabel?.text                   = event.titleString
        
        if event.hasStarted {
            let viewJobText                     = NSLocalizedString("Start The Job", comment: "CMModalHiredView : viewJobButton When Started : text")
            self.viewJobButton?.setTitle(viewJobText, forState: UIControlState.Normal)
        } else {
            let viewJobText                     = NSLocalizedString("View Job", comment: "CMModalHiredView : viewJobButton UnStarted : text")
            self.viewJobButton?.setTitle(viewJobText, forState: UIControlState.Normal)
        }
    }
}

extension ModalHiredView : CMViewProtocol {
    
    func didLoad() {
        self.backgroundColor                    = UIColor.whiteCurrent()

        let titleLabelText                      = NSLocalizedString("Woot!", comment: "CMModalHiredView : titleLabel : text")
        self.titleLabel?.textColor              = UIColor.greenCurrent()
        self.titleLabel?.numberOfLines          = 0
        self.titleLabel?.font                   = UIFont.comfortaa(.Regular, size:44)
        self.titleLabel?.text                   = titleLabelText
 
        let titleSubLabelText                   = NSLocalizedString("You got the job.", comment: "CMModalHiredView : titleSubLabel : text")
        self.titleSubLabel?.textColor           = UIColor.greenCurrent()
        self.titleSubLabel?.numberOfLines       = 0
        self.titleSubLabel?.font                = UIFont.comfortaa(.Regular, size:28)
        self.titleSubLabel?.text                = titleSubLabelText

        self.avatarView?.layer.cornerRadius     = 38
        self.avatarView?.clipsToBounds          = true
        self.avatarView?.backgroundColor        = UIColor.greyCurrent()

        let bossText                            = NSLocalizedString("BOSS", comment: "CMModalHiredView : publisherTitleLabel : text")
        self.publisherTitleLabel?.textColor     = UIColor.greenCurrent()
        self.publisherTitleLabel?.numberOfLines = 0
        self.publisherTitleLabel?.font          = UIFont.comfortaa(.Bold, size:12)
        self.publisherTitleLabel?.text          = bossText

        self.publisherNameLabel?.textColor      = UIColor.greyDarkCurrent()
        self.publisherNameLabel?.numberOfLines  = 0
        self.publisherNameLabel?.font           = UIFont.comfortaa(.Bold, size:12)

        self.teamNameLabel?.textColor           = UIColor.greyCurrent()
        self.teamNameLabel?.numberOfLines       = 0
        self.teamNameLabel?.font                = UIFont.comfortaa(.Regular, size:12)

        let hiredYouText                        = NSLocalizedString("hired you for", comment: "CMModalHiredView : hiredLabel : text")
        self.hiredLabel?.textColor              = UIColor.greyCurrent()
        self.hiredLabel?.numberOfLines          = 0
        self.hiredLabel?.font                   = UIFont.comfortaa(.Regular, size:12)
        self.hiredLabel?.text                   = hiredYouText

        self.eventTitleLabel?.textColor         = UIColor.blackCurrent()
        self.eventTitleLabel?.numberOfLines     = 0
        self.eventTitleLabel?.font              = UIFont.comfortaa(.Bold, size:14)
        
        self.viewJobButton?.setTitleColor(UIColor.whiteCurrent(), forState: UIControlState.Normal)
        self.viewJobButton?.backgroundColor     = UIColor.greenCurrent()
    }
    
}

