//
//  Contract+Util.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

extension Contract {
  
    func hiredModel()->EventHiredModel {
        return EventHiredModel(
             eventModel             : event.applicationModel()
            ,publisherNameString    : publisher!.fullName
            ,publisherAvatarString  : publisher!.avatarUrl
        )
    }
    
    var recieptDataArray:[[TitleAndData]] {
        let receiptData = [
             streamsReceiptDataArray
            ,companyReceiptArray
            ,paymentReceiptArray
        ]
        return receiptData
    }
   
    var paymentReceiptArray:[TitleAndData] {
        let status = paymentStatus ?? Contract.PaymentStatus.Pending
        return [
             TitleAndData(titleString:NSLocalizedString("Payment Status", comment:"Contract : paymentReceiptArray : paymentStatus"),   dataString:status.localizedString)
            ,TitleAndData(titleString:NSLocalizedString("Amount Paid", comment:"Contract : paymentReceiptArray : amountPaid"),   dataString:paymentAmountString())
        ]
    }
    
    var companyReceiptArray:[TitleAndData] {
        guard let t = team else { fatalError("Cannot get reciept data without a team") }
        guard let p = publisher else { fatalError("Cannot get reciept data without a publisher") }
        return [
             TitleAndData(titleString:NSLocalizedString("Hiring Company", comment:"Contract : companyReceiptArray : teamName"),   dataString:t.name)
            ,TitleAndData(titleString:NSLocalizedString("Length of video", comment:"Contract : companyReceiptArray : publisherName"),   dataString:p.fullName)
        ]
    }
    
    var descriptionStrings:[String] {
        let videoStreams = NSLocalizedString("%d Video Streams", comment:"Contract : companyReceiptArray : teamName")
        let lengthOfVideo = NSLocalizedString("%@ total length of video", comment:"Contract : companyReceiptArray : teamName")
        let totalFileSize = NSLocalizedString("%@ total file size", comment:"Contract : companyReceiptArray : teamName")
        let formattedTime               = ClockFormatter()
        formattedTime.time              = Double(Float64(uploadedAttachmentsTotalDuration) / 1000)
        let formattedMemorySize         = CMDisk.memoryFormatter(Int64(uploadedAttachmentFileBytes))
        return [
             String(NSString(format:videoStreams, numberOfUploadedAttachments))
            ,String(NSString(format:lengthOfVideo, formattedTime.clockString))
            ,String(NSString(format:totalFileSize, formattedMemorySize))
        ]
    }

    var streamsReceiptDataArray:[TitleAndData] {
        let formattedTime               = ClockFormatter()
        formattedTime.time              = Double(Float64(uploadedAttachmentsTotalDuration) / 1000)
        let formattedMemorySize         = CMDisk.memoryFormatter(Int64(uploadedAttachmentFileBytes))
        return [
             TitleAndData(titleString:NSLocalizedString("Number of streams", comment:"Contract : streamsReceiptDataArray : numberOfStreams"),   dataString:"\(numberOfUploadedAttachments)")
            ,TitleAndData(titleString:NSLocalizedString("Length of video", comment:"Contract : streamsReceiptDataArray : lengthOfVideo"),   dataString:formattedTime.clockString)
            ,TitleAndData(titleString:NSLocalizedString("Total file size", comment:"Contract : streamsReceiptDataArray : totalFileSize"),   dataString:formattedMemorySize)
        ]
    }

    func viewModel()->ContractViewModel {
        let cModel = ContractViewModel(
            hiredBool:self.acquired
            ,titleString:event.title
            ,numUnuploadedAttachmentsInt:UInt(uploadableAttachments.count)
            ,numUploadedAttachmentsInt:UInt(uploadedAttachments.count)
        )
        return cModel
    }
    
    func onTheJobModel()->ContractOnTheJobViewModel {
        let eventModel                  = event.viewModel()
        let contractModel = ContractOnTheJobViewModel(
             hasArrivedBool                 : eventModel.hasArrivedBool
            ,isUploadingBool                : hasStartedUpload
            ,distanceAwayDouble             : eventModel.distanceAwayDouble
            ,numUnuploadedAttachmentsInt    : UInt(uploadableAttachments.count)
            ,numUploadedAttachmentsInt      : UInt(uploadedAttachments.count)
        )
        return contractModel
    
    }
    
    func paypalModel()->PaypalViewModel {
        return PaypalViewModel(
             receiptId:urlHash
            ,paymentDate: paymentDate ?? NSDate()
            ,amountPaid: Double(event.paymentAmount)
        )
    }
    
    var unUploadedAttachmentCollectionModels:[AttachmentCollectionViewModel] {
        return uploadableAttachments.map { $0.collectionViewModel() }.flatMap { $0 }
    }
   
    var uploadedAttachmentCollectionModels:[AttachmentCollectionViewModel] {
        return uploadedAttachments.map { $0.collectionViewModel() }.flatMap { $0 }
    }

    func paymentAmountString()->String {
        let moneySymbol                         = NSLocalizedString("$", comment:"money symbol")
        return String(NSString(format:"%@%.0f", moneySymbol, self.event.paymentAmount))
    }

}