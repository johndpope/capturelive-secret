//
//  Notifiable.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers


public enum NotificationType:UInt16 {
    case NewJobs                    = 10
    case BreakingJob                = 11
//    case ActionMessage 21
    case Hired                      = 40
    case Arrived                    = 41
    case Canceled                   = 42
    case JobStartsIn1Hour           = 60
    case JobStartsIn24Hours         = 61
    case JobCompleted               = 43
    case PaymenUnderReview          = 70
    case PaymentDenied              = 71
    case PaymentAvailable           = 72
}

private enum NotifiableKeys : String {
    case Notifications              = "notifications"
    case NotificationUpdateTime     = "notificationUpdateTime"
}

public protocol Notifiable {
    var notifications:NSOrderedSet? { get set }
    var notificationUpdateTime:NSDate { get set }
}

extension Notifiable {
    
    public var mutableNotifications:[Notification] {
        guard let n = notifications?.array else { return [] }
        return n as? [Notification] ?? []
    }
    
    public var unreadNotifications:[Notification] {
        return mutableNotifications.filter { $0.readAt == nil }.flatMap { $0 } ?? []
    }
    
    public var readNotifications:[Notification] {
        return mutableNotifications.filter { $0.readAt != nil }.flatMap { $0 } ?? []
    }

    public var numberOfUnreadNotifications:UInt64 {
        return UInt64(unreadNotifications.count)
    }
    
    public var numberOfReadNotifications:UInt64 {
        return UInt64(readNotifications.count)
    }
    
    public var hasUnreadNotifications:Bool{
        return numberOfUnreadNotifications > 0
    }

    public var mostRecentNotification:Notification? {
        return mutableNotifications.last
    }
 
    public var mostRecentUnreadNotification:Notification? {
        return unreadNotifications.last
    }
    
    public func mostRecentNotification(favoringFirst type:NotificationType)->Notification? {
        return mutableNotifications.sortWith(priorityType:type).last
    }
    
    public func mostRecentUnreadNotification(favoringFirst type:NotificationType)->Notification? {
        return unreadNotifications.sortWith(priorityType:type).last
    }
    
    public func markNotificationAsRead(type:NotificationType) {
        let note = mutableNotifications.findFirstOccurence { $0.pushType == type }
        guard let n = note else { return }
        guard n.readAt == nil else { return }
        n.readAt = NSDate()
    }
    
    public func notification(type:NotificationType)->Notification? {
        return mutableNotifications.findFirstOccurence { $0.pushType == type }
    }
    
    public func markAllNotificationsAsRead() {
        for note in mutableNotifications {
            guard note.readAt == nil else { continue }
            note.readAt = NSDate()
        }
    }

    public func hasReadNotification(notificationType:NotificationType)->Bool {
        return readNotifications.contains { $0.type == notificationType.rawValue }
    }
    
}

extension Notifiable where Self:RemoteComparable {
    
    public var predicateForNotifications:NSPredicate {
        return NSPredicate(format: "%K == %@", Notification.Keys.SourceUrlHash.rawValue, self.urlHash)
    }
    
    public var predicateForHasNotifications:NSPredicate {
        return NSPredicate(format: "%K[SIZE] > 0", NotifiableKeys.Notifications.rawValue)
    }
    
    public static var predicateForHasNoNotifications: NSPredicate {
        return NSPredicate(format: "%K == NULL OR %K[SIZE] == 0", NotifiableKeys.Notifications.rawValue, NotifiableKeys.Notifications.rawValue)
    }
    
    public static var predicateForHasNotifications: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: predicateForHasNoNotifications)
    }
    
    public mutating func updateNotifications(moc:NSManagedObjectContext) {
        let notes = Notification.fetchInContext(moc) { [unowned self] fetchRequest in
            fetchRequest.predicate  = self.predicateForNotifications
        }
        guard notes.count != notifications?.count else { return }
        self.notificationUpdateTime = NSDate()
        notifications               = notes.orderedSet()
    }
    
}

extension SequenceType where Generator.Element : Notification {

    public func orderedSet()->NSOrderedSet? {
        let sorted = sort({ $0.updatedAt.compare($1.updatedAt) == .OrderedAscending })
        let readNotes = sorted.filter{ $0.readAt != nil }.flatMap{ $0 }
        let unreadNotes = sorted.filter{ !readNotes.contains($0) }.flatMap{ $0 }
        let all = readNotes + unreadNotes
        return NSOrderedSet(array:all)
    }
    
    public func sortWith(priorityType type:NotificationType)->[Generator.Element] {
        let notes = filter { $0.pushType == type }.flatMap { $0 }
        let notNotes = filter { $0.pushType != type }.flatMap { $0 }
        return notNotes + notes
    }
    
}


extension Notifiable where Self:ManagedObject, Self:ManagedObjectType, Self:RemoteComparable {

    public static func fetchAllWithAnyUnreadNotifications(moc:NSManagedObjectContext)->[Self] {
        let eventsWithUnread = Self.fetchInContext(moc) { request in
            let readCountPred               = NSPredicate(format: "ANY %K != NULL && (SUBQUERY(%K, $x, $x.%K == NULL).@count > 0)", NotifiableKeys.Notifications.rawValue, NotifiableKeys.Notifications.rawValue,  Notification.Keys.ReadAt.rawValue)

            request.predicate               = readCountPred
            request.returnsObjectsAsFaults  = false
            request.fetchBatchSize          = 50
            request.sortDescriptors         = [NSSortDescriptor(key:NotifiableKeys.NotificationUpdateTime.rawValue, ascending:true)]
        }
        return eventsWithUnread
    }
    
    public static func fetchAllsWithOnlyReadNotifications(moc:NSManagedObjectContext)->[Self] {
        let eventsWithUnread = Self.fetchInContext(moc) { request in
            let readCountPred               = NSPredicate(format: "ANY %K != NULL && (SUBQUERY(%K, $x, $x.%K == NULL).@count == 0)", NotifiableKeys.Notifications.rawValue, NotifiableKeys.Notifications.rawValue,  Notification.Keys.ReadAt.rawValue)
            
            request.predicate               = readCountPred
            request.returnsObjectsAsFaults  = false
            request.fetchBatchSize          = 50
            request.sortDescriptors         = [NSSortDescriptor(key:NotifiableKeys.NotificationUpdateTime.rawValue, ascending:true)]
        }
        return eventsWithUnread
    }
    
}


