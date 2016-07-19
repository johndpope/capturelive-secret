//
//  HiredNotifiable.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

//private let NeedsNotificationForAcquirement = "needsNotificationForAcquirement"
//private let HasAcknowledgedHiredNotification = "hasAcknowledgedHiredNotification"
//
//public protocol HiredNotifiable:class {
//    var needsNotificationForAcquirement:Bool { get set }
//    var hasAcknowledgedHiredNotification:Bool { get set }
//    
//    func markForNeedsNotificationForAcquirement()
//    func unMarkForNeedsNotificationForAcquirement()
//}
//
//extension HiredNotifiable {
//
//    public func markForNeedsNotificationForAcquirement() {
//        needsNotificationForAcquirement         = true
//    }
//    
//    public func unMarkForNeedsNotificationForAcquirement() {
//        needsNotificationForAcquirement         = false
//        hasAcknowledgedHiredNotification        = true
//    }
//    
//    public static var markedForNeedsNotificationForAcquirementPredicate:NSPredicate {
//        return NSPredicate(format: "%K == true", NeedsNotificationForAcquirement)
//    }
//    
//    public static var unMarkedForNeedsNotificationForAcquirementPredicate:NSPredicate {
//        return NSCompoundPredicate(notPredicateWithSubpredicate: markedForNeedsNotificationForAcquirementPredicate)
//    }
//    
//    public static var markedForAcknowledgedAcquiredNotificationPredicate:NSPredicate {
//        return NSPredicate(format: "%K == true", HasAcknowledgedHiredNotification)
//    }
//    
//    public static var unMarkedForAcknowledgedAcquiredNotificationPredicate:NSPredicate {
//        return NSCompoundPredicate(notPredicateWithSubpredicate: markedForAcknowledgedAcquiredNotificationPredicate)
//    }
//    
//    public static var canBeMarkedForNeedsNotificationForAcquirementPredicate:NSPredicate {
//        return NSCompoundPredicate(andPredicateWithSubpredicates: [unMarkedForAcknowledgedAcquiredNotificationPredicate, unMarkedForNeedsNotificationForAcquirementPredicate])
//    }
//
//}