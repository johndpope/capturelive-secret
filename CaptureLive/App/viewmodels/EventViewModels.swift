//
//  Event+Text.swift
//  Current
//
//  Created by Scott Jones on 2/24/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import Foundation

protocol EventSentence {
    var paymentAmountFloat:Float { get  }
    var radiusDouble:Double { get  }
    var distanceAwayDouble:Double { get  }
    // computed
    var paymentString:String { get }
    var hasArrivedBool:Bool { get }
    func distanceAwayString()->String
}

extension EventSentence {
    var paymentString:String {
        return String(format: "$%.0f", paymentAmountFloat)
    }
    var hasArrivedBool:Bool {
        return distanceAwayDouble < radiusDouble
    }
    func distanceAwayString()->String {
        let milesAway = NSLocalizedString("mi", comment:"EventViewModel : miles away")
        return "\(String(format: "%.1f", distanceAwayDouble)) \(milesAway)"
    }
}

struct EventViewModel:EventSentence {
    let titleString:String
    let startDateString:String
    let endDateString:String
    let hasStarted:Bool
    let exactAddressString:String
    let radiusDouble:Double
    let distanceAwayDouble:Double
    let contractStatus:EventContractStatus
    let paymentAmountFloat:Float
    let descriptionString:String
    let publicUrl:String
    let hasSeenStartedBool:Bool
    let isFirstArrivalBool:Bool
}

public struct EventTableCellViewModel:EventSentence {
    let urlHash:String
    let titleString:String
    let organizationNameString:String
    let organizationLogoPath:String
    let bannerImagePath:String
    let startDateString:String
    let hasStartedBool:Bool
    let radiusDouble:Double
    let distanceAwayDouble:Double
    let contractStatus:EventContractStatus
    let paymentAmountFloat:Float
    let paymentStatusString:String?
    let isCancelledBool:Bool
    let completionDate:NSDate?
}

extension EventTableCellViewModel {
    var cellHeight:CGFloat {
        return titleHeight + EventTableViewCellBaseHeight
    }
    var titleHeight:CGFloat {
        return titleString.heightWithConstrainedWidth(EventTableViewCellLabelWidth, font:EventTableViewCell.TitleFont)
    }
    var completionDateString:String {
        return completionDate?.elapsedTimeString() ?? ""
    }
}

public struct TitleAndData {
    let titleString:String
    let dataString:String
}
public struct EventApplicationModel {
    let urlHash:String
    let titleString:String
    let organizationNameString:String
    let organizationLogoPath:String
    let bannerImagePath:String
    let exactAddressString:String
    let startDateString:String
    let displayExpired:Bool
    let contractStatus:EventContractStatus
    let paymentAmountFloat:Float
    let publicUrl:String?
    let titlesAndData:[TitleAndData]
}

extension EventApplicationModel {
    
    static var eventTitle:String {
        return NSLocalizedString("Event", comment:"EventApplicationModel : eventName : starts")
    }
    static var startTitle:String {
        return NSLocalizedString("Starts", comment:"EventApplicationModel : startTitle : starts")
    }
    static var addressTitle:String {
        return NSLocalizedString("Address", comment:"EventApplicationModel : addressTitle : starts")
    }
    static var detailsTitle:String {
        return NSLocalizedString("Job Details", comment:"EventApplicationModel : detailsTitle : starts")
    }

}

public struct EventHiredModel {
    let eventModel:EventApplicationModel
    let publisherNameString:String
    let publisherAvatarString:String
}

extension ContractViewModel {
    var numVideosString:String {
        let numVideos = self.numUnuploadedAttachmentsInt
        var text = ""
        if numVideos == 1 {
            let localizedText                       = NSLocalizedString("Upload %d Video", comment: "EventViewModel | numVideosString | no videos ready text")
            text                                    = String(NSString(format: localizedText, numVideos ))
        }
        else if numVideos > 1 {
            let localizedText                       = NSLocalizedString("Upload %d Videos", comment: "EventViewModel | numVideosString | no videos ready text")
            text                                    = String(NSString(format: localizedText, numVideos ))
        }
        else {
            text                                    = NSLocalizedString("Upload", comment: "EventViewModel | numVideosString | no videos text")
        }
        return text
    }
}


struct ModalInfo {
    let navTitleString:String
    let titleString:NSAttributedString
    let tableDataArray:[EventIndexInfo]
}

struct EventIndexInfo {
    let indexInt:Int
    let dataString:String
    let hidesSeperatorBool:Bool
}

extension SequenceType where Generator.Element == EventIndexInfo {
    
    var totalHeight:CGFloat {
        return reduce(0) { $0 + $1.cellHeight }
    }
    
}


extension EventIndexInfo {
    var cellHeight:CGFloat {
        return max(dataLabelHeight + 40, EventInfoTableViewCellBaseHeight)
    }
    var dataLabelHeight:CGFloat {
        return dataString.heightWithConstrainedWidth(EventInfoTableViewCellDataLabelWidth, font:EventInfoTableViewCell.DataLabelFont)
    }
}








