//
//  Notification+Util.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureCore
import CaptureModel

extension Notification {

    func tableCellViewModel()->NotificationTableCellViewModel {
        let logoSourceUrl       = eventSource?.creatorIconUrl ?? "https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
        let titleString         = eventSource?.title ?? "FPO Event Title"
        let model = NotificationTableCellViewModel(
             isReadBool         : isRead
            ,logoUrlString      : logoSourceUrl
            ,eventTitleString   : titleString
            ,messageString      : message
            ,createdAtDate      : createdAt
            ,jobIconNameString  : iconName
            ,font               : font
        )
        return model
    }
    
    var font:CMFontProxima {
        if readAt != nil {
            return .Light
        } else {
            return .Bold
        }
    }
    
    var iconName:String {
        return pushType.iconName
    }
    
}

extension NotificationType {
    
    var iconName:String {
        switch self {
        case .Arrived:
            return "icon_jobsuccess"
        case .Canceled:
            return "icon_cancelledjob"
        case .JobStartsIn1Hour:
            return "icon_jobname_star_blksmall"
        case .Hired:
            return "icon_jobsuccess"
        case .NewJobs:
            return "icon_jobname_star_blksmall"
        case .PaymentDenied:
            return "icon_jobname_star_blksmall"
        case .PaymenUnderReview:
            return "icon_jobname_star_blksmall"
        case .PaymentAvailable:
            return "icon_jobsuccess"
        case .JobStartsIn24Hours:
            return "icon_jobname_star_blksmall"
        case .JobCompleted:
            return "icon_jobname_star_blksmall"
        case .BreakingJob:
            return "icon_jobname_star_blksmall"
        }
    }
    
}