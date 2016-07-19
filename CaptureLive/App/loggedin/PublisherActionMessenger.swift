//
//  PublisherActionMessenger.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/23/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
 typealias Completed = ()->()

class PublisherActionMessenger: UIView {

    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var messageLabel:UILabel?
    @IBOutlet weak var messageView:UIView?
    @IBOutlet weak var avatarView:UIImageView?
    @IBOutlet weak var widthConstraint:NSLayoutConstraint?
    @IBOutlet weak var messageWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var messageHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var carrotIconView:UIImageView?
    @IBOutlet weak var backgroundView:UIView?
    
    func animateIn() {
        let nameWidth = nameLabel?.text!.widthWithConstrainedHeight(12, font:nameLabel!.font) ?? 0
        let titleWidth = titleLabel?.text!.widthWithConstrainedHeight(9, font:titleLabel!.font) ?? 0
        
        UIView.animateWithDuration(0.7, animations: { [weak self] in
                        self?.widthConstraint?.constant     = max(nameWidth, titleWidth) + 35
                        self?.layoutIfNeeded()
                                    
            }, completion: { finished in
                UIView.animateWithDuration(0.7, animations: { [weak self] in
                        self?.nameLabel?.alpha              = 1
                        self?.titleLabel?.alpha             = 1
                        self?.avatarView?.transform         = CGAffineTransformMakeScale(1, 1)
                        
                    }, completion: { finished in
                        
                })
        })
    }
    
    func animateOut(complete:Completed?) {
        animateOutBubble {
            UIView.animateWithDuration(0.3,
                animations: { [weak self] in
                    self?.nameLabel?.alpha                  = 0
                    self?.titleLabel?.alpha                 = 0
                    self?.avatarView?.transform             = CGAffineTransformMakeScale(0, 0)
                    
                }, completion: { finished in
                    complete?()

            })
        }
    }
    
    func showMessage(message:String) {
        if messageWidthConstraint?.constant > 0 {
            animateOutBubble({ [weak self] in
                self?.messageLabel?.text                    = message
                self?.animateInBubble()
            })
        } else {
            messageLabel?.text                              = message
            animateInBubble()
        }
    }
    
    func animateOutBubble(complete:Completed?) {
        UIView.animateWithDuration(0.3,
                                   animations: { [weak self] in
                    self?.messageLabel?.alpha = 0
                                    
            }, completion: { finished in

                UIView.animateWithDuration(0.3,
                    animations: { [weak self] in
                        self?.messageWidthConstraint?.constant      = 0
                        self?.messageHeightConstraint?.constant     = 0
                        self?.layoutIfNeeded()
                        
                    }, completion: { finished in
                        complete?()
                        
                })
                
        })
 
    }
    
    private func animateInBubble() {
        let constraints         = messageConstraints(messageLabel!.text!)
        UIView.animateWithDuration(0.75,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.4,
                                   initialSpringVelocity:1.3,
                                   options: [],
                                   animations: { [weak self] in
                self?.messageWidthConstraint?.constant      = constraints.width
                self?.messageHeightConstraint?.constant     = constraints.height
                self?.layoutIfNeeded()
     
            }, completion: { finished in
                
        })
        UIView.animateWithDuration(0.3,
                                   delay: 0.3,
                                   options: [],
                                   animations: { [weak self] in
                self?.messageLabel?.alpha           = 1
                                    
            }, completion: { finished in
                
        })

    }
    
    private func messageConstraints(message:String)->(width:CGFloat, height:CGFloat) {
        let maxWidth            = ScreenSize.SCREEN_HEIGHT * 0.7
        let minHeight:CGFloat   = 30
        let widthForHeight      = message.widthWithConstrainedHeight(minHeight, font: messageLabel!.font)
        if widthForHeight > maxWidth {
            let height          = message.heightWithConstrainedWidth(maxWidth, font: messageLabel!.font)
            return (maxWidth + 20, height + 20)
        }
        return (widthForHeight + 20, minHeight + 20)
    }
    
    func populate(viewModel:EventHiredModel) {
        nameLabel?.text         = viewModel.publisherNameString
        CMImageCache.defaultCache().imageForPath(viewModel.publisherAvatarString, complete: { [weak self] error, image in
            if error == nil {
                self?.avatarView?.image     = image
            }
        })
    }
    
}

extension PublisherActionMessenger : CMViewProtocol {
    
    func didLoad() {
        nameLabel?.font                     = UIFont.proxima(.Bold, size: FontSizes.s11)
        nameLabel?.textColor                = UIColor.bistre()
        nameLabel?.alpha                    = 0
        
        titleLabel?.font                    = UIFont.proxima(.Bold, size: FontSizes.s8)
        titleLabel?.textColor               = UIColor.taupeGray()
        let titleText                       = NSLocalizedString("Job Manager", comment: "PublisherActionMessenger : titleLabel : text")
        titleLabel?.text                    = titleText
        titleLabel?.alpha                   = 0
        
        messageView?.layer.cornerRadius     = 2
        messageView?.clipsToBounds          = true
        messageView?.layer.shadowOpacity    = 0.8
        messageView?.layer.shadowOffset     = CGSizeMake(0, 0.5)
        messageView?.layer.shadowRadius     = 0.7
        
        messageLabel?.font                  = UIFont.proxima(.Bold, size: FontSizes.s12)
        messageLabel?.textColor             = UIColor.taupeGray()
        messageLabel?.numberOfLines         = 0

        messageWidthConstraint?.constant    = 0
        messageHeightConstraint?.constant   = 0
       
        backgroundView?.layer.cornerRadius  = 2
        backgroundView?.clipsToBounds       = true
        backgroundView?.layer.shadowOpacity = 0.8
        backgroundView?.layer.shadowOffset  = CGSizeMake(0, 0.5)
        backgroundView?.layer.shadowRadius  = 0.7
        
        widthConstraint?.constant           = -40
    
        avatarView?.transform               = CGAffineTransformMakeScale(0, 0)
        avatarView?.layer.cornerRadius      = 12
        avatarView?.clipsToBounds           = true
    }
    
}















