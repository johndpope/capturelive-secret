//
//  ContractViewModels.swift
//  Current
//
//  Created by Scott Jones on 9/2/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

enum EventContractStatus {
    case APPLIED
    case ACQUIRED
    case EXPIRED
    case NONE
}

struct ContractViewModel {
    let hiredBool:Bool
    let titleString:String
    let numUnuploadedAttachmentsInt:UInt
    let numUploadedAttachmentsInt:UInt
}

extension ContractViewModel {
    
    func hasFootage()->Bool {
        return (numUnuploadedAttachmentsInt > 0)
    }
    
    func hasCompletedUpload()->Bool {
        return numUnuploadedAttachmentsInt == 0 && numUploadedAttachmentsInt > 0
    }
    
}

struct ContractOnTheJobViewModel {
    let hasArrivedBool:Bool
    let isUploadingBool:Bool
    let distanceAwayDouble:Double
    let numUnuploadedAttachmentsInt:UInt
    let numUploadedAttachmentsInt:UInt
}

extension ContractOnTheJobViewModel {
    
    func hasFootage()->Bool {
        return (numUnuploadedAttachmentsInt > 0)
    }
    
    func hasCompletedUpload()->Bool {
        return numUnuploadedAttachmentsInt == 0 && numUploadedAttachmentsInt > 0
    }
    
}

struct PaypalViewModel {
    let receiptId:String
    let paymentDate:NSDate
    let amountPaid:Double
}

extension PaypalViewModel {
   
    var slashyDateString:String {
        let dateFormatter                   = NSDateFormatter()
        dateFormatter.dateFormat            = "MM/dd/MM"
        dateFormatter.timeZone              = NSTimeZone.localTimeZone()
        return dateFormatter.stringFromDate(paymentDate)
    }
    
}



















