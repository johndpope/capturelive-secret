//
//  OnboardView.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

struct OnboardCoverViewModel {
    let logoNameString:String
    var pageNumberInt:Int
    let totalPageNumberInt:Int
    let skipButtonTitleString:String
}
struct OnboardViewModel {
    let imageNameString:String
    let titleLabelString:String
    let bodyLabelString:String
}
protocol OnboardCoverable {
    var coverView:OnboardCoverView? { get }
}

class OnboardCoverView: UIView {
    
    @IBOutlet weak var logoView:UIImageView?
    @IBOutlet weak var pageControl:UIPageControl?
    @IBOutlet weak var skipButton:CMPrimaryButton?
    
    func setUp(viewmodel:OnboardCoverViewModel) {
        skipButton?.layer.cornerRadius  = 0
        skipButton?.setTitle(viewmodel.skipButtonTitleString, forState: .Normal)
       
        pageControl?.numberOfPages      = viewmodel.totalPageNumberInt
        pageControl?.currentPage        = viewmodel.pageNumberInt
        logoView?.image                 = UIImage(named:viewmodel.logoNameString)
        logoView?.contentMode           = .ScaleAspectFit
        logoView?.backgroundColor       = UIColor.clearColor()
    }
    
}
extension OnboardCoverView : CMViewProtocol {
    func didLoad() {
        pageControl?.pageIndicatorTintColor        = UIColor.silver()
        pageControl?.currentPageIndicatorTintColor = UIColor.mountainMeadow()
    }
}

class OnboardView: UIView, OnboardCoverable {

    @IBOutlet weak var coverView:OnboardCoverView?
    @IBOutlet weak var titleLabel:UILabel?
    @IBOutlet weak var bodyLabel:UILabel?
    @IBOutlet weak var imageView:UIImageView?
    
    func setUp(viewmodel:OnboardViewModel, coverViewModel:OnboardCoverViewModel) {
        coverView?.setUp(coverViewModel)
        
        imageView?.image                = UIImage(named:viewmodel.imageNameString)
        
        titleLabel?.text                = viewmodel.titleLabelString
        bodyLabel?.text                 = viewmodel.bodyLabelString
        
        let attBT                       = NSMutableAttributedString(string: viewmodel.bodyLabelString)
        let paragraphStyle              = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing      = 8
        paragraphStyle.alignment        = .Center
        attBT.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attBT.length))
        bodyLabel?.attributedText       = attBT
    }
    
}
extension OnboardView : CMViewProtocol {
    func didLoad() {
        coverView?.didLoad()
        
        titleLabel?.font                = UIFont.proxima(.SemiBold, size: FontSizes.s22)
        titleLabel?.textColor           = UIColor.bistre()
        titleLabel?.adjustsFontSizeToFitWidth = true
        
        bodyLabel?.font                 = UIFont.proxima(.Regular, size: FontSizes.s14)
        bodyLabel?.textColor            = UIColor.taupeGray()
        bodyLabel?.numberOfLines        = 0
    }
}
