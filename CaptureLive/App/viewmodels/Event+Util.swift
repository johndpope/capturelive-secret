//
//  Event+Util.swift
//  Current
//
//  Created by Scott Jones on 2/26/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import Foundation
import CaptureModel
import CaptureCore

extension Event : TableViewCellModelType {
    public typealias Model = EventTableCellViewModel
    public func tableCellViewModel()->Model {
        return tableCellViewModel(CMUserMovementManager.shared)
    }
}

extension Event {
  
    func location()->CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func locationCoordinate()->CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var hasSeenStartFlagBool:Bool { return true }
    var isFirstArrivedFlagBool:Bool { return true }
    
}

extension Event {
   
    var cellHeight:CGFloat {
        return titleHeight + EventTableViewCellBaseHeight
    }
    
    var titleHeight:CGFloat {
        return title.heightWithConstrainedWidth(EventTableViewCellLabelWidth, font:EventTableViewCell.TitleFont)
    }
    
    func viewModel(coordinateParser:CoordinateParsable)->EventViewModel {
        let vmtitle                 = title ?? ""
        let vmStartTime             = startTime
        let vmEndTime               = hiringCutoffTime
        let contractStatus          = self.contractStatus
        let distance                = coordinateParser.distanceFromLocation(self.location())
        let pubUrl                  = publicUrl
        let eAddress                = locationName ?? ""
        let desc                    = detailDescription ?? ""
        return EventViewModel(
             titleString            : vmtitle
            ,startDateString        : vmStartTime.eventTime()
            ,endDateString          : vmEndTime.eventTime()
            ,hasStarted             : vmStartTime.hasPassed()
            ,exactAddressString     : eAddress
            ,radiusDouble           : radius
            ,distanceAwayDouble     : distance
            ,contractStatus         : contractStatus
            ,paymentAmountFloat     : paymentAmount
            ,descriptionString      : desc
            ,publicUrl              : pubUrl
            ,hasSeenStartedBool     : hasSeenStartFlagBool
            ,isFirstArrivalBool     : isFirstArrivedFlagBool
        )
    }
    
    func tableCellViewModel(coordinateParser:CoordinateParsable)->EventTableCellViewModel {
        let vmtitle                 = title ?? ""
        let hasStarted              = startTime.hasPassed()
        let vmStartTime             = (hasStarted) ? startTime.elapsedTimeString() : startTime.timeTilString()
        let contractStatus          = self.contractStatus
        let distance                = coordinateParser.distanceFromLocation(self.location())
        let paymentStatus           = contract?.paymentStatus ?? Contract.PaymentStatus.Pending
        let teamName                = contract?.team?.name ?? creatorName
        let iconUrl                 = contract?.team?.iconUrl ?? creatorIconUrl
        let canceled                = contract?.resolutionStatus.isCancelled ?? false
        return EventTableCellViewModel(
             urlHash                : urlHash
            ,titleString            : vmtitle
            ,organizationNameString : teamName
            ,organizationLogoPath   : iconUrl
            ,bannerImagePath        : bannerImageUrl
            ,startDateString        : vmStartTime
            ,hasStartedBool         : hasStarted
            ,radiusDouble           : radius
            ,distanceAwayDouble     : distance
            ,contractStatus         : contractStatus
            ,paymentAmountFloat     : paymentAmount
            ,paymentStatusString    : paymentStatus.localizedString
            ,isCancelledBool        : canceled
            ,completionDate         : nil
        )
    }
    
    func applicationModel()->EventApplicationModel {
        let vmtitle                 = title ?? ""
        let vmStartTime             = (startTime.hasPassed()) ? startTime.elapsedTimeString() : startTime.timeTilString()
        let contractStatus          = self.contractStatus
        let teamName                = contract?.team?.name ?? creatorName
        let iconUrl                 = contract?.team?.iconUrl ?? creatorIconUrl
        let address                 = locationName ?? ""
        let titlesData              = titlesAndData()
        let displayExpired          = displayTime.hasPassed()
        return EventApplicationModel(
             urlHash                : urlHash
            ,titleString            : vmtitle
            ,organizationNameString : teamName
            ,organizationLogoPath   : iconUrl
            ,bannerImagePath        : bannerImageUrl
            ,exactAddressString     : address
            ,startDateString        : vmStartTime
            ,displayExpired         : displayExpired
            ,contractStatus         : contractStatus
            ,paymentAmountFloat     : paymentAmount
            ,publicUrl              : publicUrl
            ,titlesAndData          : titlesData
        )
    }
    
    func titlesAndData()->[TitleAndData] {
        let vmtitle                 = self.title ?? ""
        let address                 = locationName ?? ""
        let details                 = detailDescription ?? ""
        let startTimeString         = startTime.timeTilString()
        return [
             TitleAndData(titleString:EventApplicationModel.eventTitle, dataString:vmtitle)
            ,TitleAndData(titleString:EventApplicationModel.startTitle, dataString:startTimeString)
            ,TitleAndData(titleString:EventApplicationModel.addressTitle, dataString:address)
            ,TitleAndData(titleString:EventApplicationModel.detailsTitle, dataString:details)
        ]
    }
    
    func viewModel()->EventViewModel {
        return viewModel(CMUserMovementManager.shared)
    }
    
    var contractStatus:EventContractStatus {
        guard let c = self.contract else {
            return .NONE
        }
        if c.acquired {
            return .ACQUIRED
        } else {
            return .APPLIED
        }
    }

    var recieptDataArray:[[TitleAndData]] {
        guard let c = contract else { fatalError("Cannot get reciept data without a contract") }
        return c.recieptDataArray
    }
    
    func modalInfo()->ModalInfo {
        return ModalInfo(
            navTitleString:NSLocalizedString("JOB INFO", comment: "JobInfo : navtitle : text")
            ,titleString:getInfoAttributedTitle()
            ,tableDataArray:[
                EventIndexInfo(indexInt:1, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:2, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:3, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:4, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:5, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:6, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:true)
            ]
        )
    }
    
    func getInfoAttributedTitle()->NSAttributedString {
        let requirementsText = NSLocalizedString("\nThe Job Requirements\n", comment: "JobInfo : requirements : text")
        let boldAtt                 = [
            NSFontAttributeName            : UIFont.proxima(.Regular, size: FontSizes.s17)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let attString               = NSMutableAttributedString(string:requirementsText, attributes:boldAtt)
        return attString
    }
    
    func paymentModalInfo()->ModalInfo {
        return ModalInfo(
            navTitleString:NSLocalizedString("JOB PAYS", comment: "JobPays : navtitle : text")
            ,titleString:getPaymentAttributedTitle()
            ,tableDataArray:[
                EventIndexInfo(indexInt:1, dataString:NSLocalizedString("All payments will be made based on lorim ipsum...",       comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:2, dataString:NSLocalizedString("All payments will be made based on lorim ipsum...",       comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:3, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:4, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:false)
                ,EventIndexInfo(indexInt:5, dataString:NSLocalizedString("Record video footage as described in the job details",    comment: "JobInfo : requirements : text"), hidesSeperatorBool:true)
            ]
        )
    }
    
    func getPaymentAttributedTitle()->NSAttributedString {
        let titleText               = title ?? NSLocalizedString("FPO Event Title", comment: "JobPays : eventtitle : text")
        let thisJobText             = NSLocalizedString("This Job Pays:", comment: "JobPays : title : text")
        let paymentText             = "$\(UInt(paymentAmount))"
        let paymentDetailsText      = NSLocalizedString("Job Payment Details", comment: "JobPays : amountPay : text")
        
        let eventTitleAtt           = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size: FontSizes.s14)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let attString               = NSMutableAttributedString(string:titleText + "\n", attributes:eventTitleAtt)
        
        let thisJobAtt              = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size:FontSizes.s20)
            ,NSForegroundColorAttributeName : UIColor.mountainMeadow()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let thisJobString           = NSMutableAttributedString(string:"\n" + thisJobText + "\n", attributes:thisJobAtt)
        attString.appendAttributedString(thisJobString)
        
        let paymentAtt              = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size:FontSizes.s27)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let paymentString           = NSMutableAttributedString(string:paymentText + "\n", attributes:paymentAtt)
        attString.appendAttributedString(paymentString)
        
        let paymentDetailsAtt       = [
            NSFontAttributeName             : UIFont.proxima(.Regular, size:FontSizes.s14)
            ,NSForegroundColorAttributeName : UIColor.bistre()
            ,NSBackgroundColorAttributeName : UIColor.clearColor()
        ]
        let paymentDetailsString    = NSMutableAttributedString(string:paymentDetailsText, attributes:paymentDetailsAtt)
        attString.appendAttributedString(paymentDetailsString)
        return attString
    }
    
}

extension NSDate {
    
    func eventDisplayTime()->String {
        if self.hasPassed() {
            return NSLocalizedString("Job starts NOW", comment: "eventDisplayTime : now")
        } else if self.isToday() {
            let timeString = NSLocalizedString("Job starts %@ @%@", comment: "eventDisplayTime : today")
            let dateFormatter                   = NSDateFormatter()
            dateFormatter.timeZone              = NSTimeZone.systemTimeZone()
            dateFormatter.dateFormat            = "h:mma";
            let today                           = NSLocalizedString("today", comment: "Today")
            return String(NSString(format: timeString, today, dateFormatter.stringFromDate(self)))
        } else {
            let timeString = NSLocalizedString("Job starts %@ %@", comment: "eventDisplayTime : not today")
            let mycomponents                    = NSCalendar.currentCalendar().components([.Month, .Day], fromDate:self)
            return String(NSString(format: timeString, "\(NSDate.monthNameString(mycomponents.month))", "\(mycomponents.day)"))
        }
    }
    
}

