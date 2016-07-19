//
//  PaypalTableViewCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 7/1/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

public let PaypalTableViewCellHeight        = ScreenSize.SCREEN_HEIGHT * 0.16
class PaypalTableViewCell: UITableViewCell {
    
    static let Identifier:String            = "PaypalTableViewCell"
    
    @IBOutlet weak var paymentLabelTitle:UILabel?
    @IBOutlet weak var paymentLabelTitleWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var dateLabelTitle:UILabel?
    @IBOutlet weak var dateLabelTitleWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var receiptLabelTitle:UILabel?
    @IBOutlet weak var receiptLabelTitleWidthConstraint:NSLayoutConstraint?

    @IBOutlet weak var paymentLabelData:UILabel?
    @IBOutlet weak var paymentLabelDataWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var dateLabelData:UILabel?
    @IBOutlet weak var dateLabelDataWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var receiptLabelData:UILabel?
    @IBOutlet weak var receiptLabelDataWidthConstraint:NSLayoutConstraint?
 
    @IBOutlet weak var lineAmountView:DottedLineView?
    @IBOutlet weak var lineDateView:DottedLineView?
    @IBOutlet weak var lineIdView:DottedLineView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorInset                      = UIEdgeInsetsZero
        layoutMargins                       = UIEdgeInsetsZero
 
        accessoryType                       = .DisclosureIndicator
        accessoryView?.backgroundColor      = UIColor.whiteSmoke()
        contentView.superview?.backgroundColor = UIColor.whiteSmoke()
        contentView.backgroundColor         = UIColor.whiteSmoke()
        
        let receiptText                     = NSLocalizedString("Amount Paid", comment: "PaypalTableViewCell : receiptLabelTitle : text")
        receiptLabelTitle?.text             = receiptText
        receiptLabelTitle?.font             = UIFont.proxima(.Regular, size: FontSizes.s14)
        receiptLabelTitle?.textColor        = UIColor.taupe()
        receiptLabelTitle?.backgroundColor  = UIColor.whiteSmoke()
        receiptLabelTitleWidthConstraint?.constant = receiptText.widthWithConstrainedHeight(1000, font: UIFont.proxima(.Regular, size: FontSizes.s14)) + 5
        receiptLabelData?.font              = UIFont.proxima(.SemiBold, size: FontSizes.s14)
        receiptLabelData?.textColor         = UIColor.taupe()
        receiptLabelData?.backgroundColor   = UIColor.whiteSmoke()
        
        dateLabelTitle?.text                = NSLocalizedString("Date Paid", comment: "PaypalTableViewCell : dateLabelTitle : text")
        dateLabelTitle?.font                = UIFont.proxima(.Regular, size: FontSizes.s14)
        dateLabelTitle?.textColor           = UIColor.taupe()
        dateLabelTitle?.backgroundColor     = UIColor.whiteSmoke()
        dateLabelTitleWidthConstraint?.constant = dateLabelTitle!.text!.widthWithConstrainedHeight(1000, font: dateLabelTitle!.font!) + 5
       
        dateLabelData?.font                 = UIFont.proxima(.SemiBold, size: FontSizes.s14)
        dateLabelData?.textColor            = UIColor.taupe()
        dateLabelData?.backgroundColor      = UIColor.whiteSmoke()
        
        let paymentText                     = NSLocalizedString("Payment Receipt", comment: "PaypalTableViewCell : paymentIdLabelTitle : text")
        paymentLabelTitle?.text             = paymentText
        paymentLabelTitle?.font             = UIFont.proxima(.Regular, size: FontSizes.s14)
        paymentLabelTitle?.textColor        = UIColor.taupe()
        paymentLabelTitle?.backgroundColor  = UIColor.whiteSmoke()
        paymentLabelTitleWidthConstraint?.constant = paymentText.widthWithConstrainedHeight(1000, font: UIFont.proxima(.Regular, size: FontSizes.s14)) + 5
       
        paymentLabelData?.font              = UIFont.proxima(.SemiBold, size: FontSizes.s14)
        paymentLabelData?.textColor         = UIColor.taupe()
        paymentLabelData?.backgroundColor   = UIColor.whiteSmoke()
    }
    
}

extension PaypalTableViewCell : ConfigurableCell {
    func configureForObject(object: PaypalViewModel) {
        paymentLabelData?.text              = "$\(object.amountPaid)"
        paymentLabelDataWidthConstraint?.constant = paymentLabelData!.text!.widthWithConstrainedHeight(1000, font: UIFont.proxima(.Regular, size: FontSizes.s14)) + 5
        
        dateLabelData?.text                 = object.slashyDateString
        dateLabelDataWidthConstraint?.constant = dateLabelData!.text!.widthWithConstrainedHeight(1000, font: UIFont.proxima(.Regular, size: FontSizes.s14)) + 5

        receiptLabelData?.text              = object.receiptId
        receiptLabelDataWidthConstraint?.constant = receiptLabelData!.text!.widthWithConstrainedHeight(1000, font: UIFont.proxima(.Regular, size: FontSizes.s14)) + 5
    }
}