//
//  NotificationViewModel.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

struct NotificationTableCellViewModel {
    let isReadBool:Bool
    let logoUrlString:String
    let eventTitleString:String
    let messageString:String
    let createdAtDate:NSDate
    let jobIconNameString:String
    let font:CMFontProxima
}

extension NotificationTableCellViewModel {
    
    var cellHeight:CGFloat {
        return messageString.heightWithConstrainedWidth(NotificationTableViewCellLabelWidth, font:UIFont.proxima(font, size: FontSizes.s12)) + 72
    }

    var elapsedTimeString:String {
        return createdAtDate.elapsedTimeString()
    }
    
}
