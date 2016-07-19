//
//  Notification.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/25/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import CoreData
import CoreDataHelpers

enum NotificationSource:String {
    case Test                       = "Test"
    case Contract                   = "Contract"
    case Event                      = "Event"
    case User                       = "User"
}

extension Notification: KeyCodable {
    public enum Keys: String {
        case TheType                = "type"
        case ReadAt                 = "readAt"
        case EventSource            = "eventSource"
        case ContractSource         = "contractSource"
        case SourceUrlHash          = "sourceUrlHash"
    }
}

public final class Notification: ManagedObject {
    
    @NSManaged public private(set) var type: UInt16
    @NSManaged public private(set) var message: String
    @NSManaged public var readAt: NSDate?
    @NSManaged public internal(set) var eventSource: Event?
    @NSManaged public internal(set) var contractSource: Contract?
    @NSManaged public internal(set) var sourceUrlHash:String

    public var pushType:NotificationType {
        get {
            guard let nt = NotificationType(rawValue:type) else { fatalError("There is no NotificationType : \(type)") }
            return nt
        }
    }
    
    public override func willSave() {
        super.willSave()
        
        if Notification.notMarkedForRemoteVerificationPredicate.evaluateWithObject(self) && changedInNeedForRemoteVerification() {
            markForNeedsRemoteVerification()
        }
        
    }
    
    public var isRead:Bool {
        return readAt != nil
    }
    
    public static var unreadPredicate: NSPredicate {
        return NSPredicate(format:"%K == NULL", Notification.Keys.ReadAt.rawValue)
    }

    public static var eventSourceIsNilPredicate: NSPredicate {
        return NSPredicate(format:"%K == NULL", Notification.Keys.EventSource.rawValue)
    }
    
    public static var eventSourceIsNotNilPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: eventSourceIsNilPredicate)
    }
    
    public static var contractSourceIsNilPredicate: NSPredicate {
        return NSPredicate(format:"%K == NULL", Notification.Keys.ContractSource.rawValue)
    }
    
    public static var contractSourceIsNotNilPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: contractSourceIsNilPredicate)
    }
    
    public static var hasAtLeastOneSourcePredicate:NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [eventSourceIsNotNilPredicate, contractSourceIsNotNilPredicate])
    }

    public static func predicateForNotificationWith(pushType:NotificationType, contractSourceUrlHash:String)->NSPredicate {
        let pushTypePredicate       = NSPredicate(format: "%K == %d", Keys.TheType.rawValue,  pushType.rawValue)
        let contractSourcePredicate = NSPredicate(format: "%K == %@", Keys.SourceUrlHash.rawValue, contractSourceUrlHash)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [unreadPredicate, pushTypePredicate, contractSourcePredicate])
    }
    
    public static func fetchTotalNumberOfUnread(moc:NSManagedObjectContext)->Int {
        return countInContext(moc) { request in
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[
                 unreadPredicate
                ,hasAtLeastOneSourcePredicate
            ])
        }
    }
    
    public static func fetchFirstUnread(moc:NSManagedObjectContext)->Notification? {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[unreadPredicate, hasAtLeastOneSourcePredicate])
        return findOrFetchInContext(moc, matchingPredicate:predicate)
    }
    
}

extension Notification : ManagedObjectType {

    public static var entityName: String { return "Notification" }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "updatedAt", ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value:true)
    }
    
}

extension Notification: RemoteComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var urlHash: String
    
}

extension Notification : RemoteUpdatable {
    
    @NSManaged public var needsRemoteVerification:Bool
    @NSManaged public var shouldBlockFromJSONMapping:Bool
    
    public func changedInNeedForRemoteVerification()->Bool {
        let keys:[Keys] = [.ReadAt]
        return keys.reduce(false) { a, b in
            return a ? a : changedValues()[b.rawValue] != nil
        }
    }
    
}

public struct RemoteNotification: RemoteRecordType {
    
    public var urlHash: String
    public var createdAt: NSDate
    public var updatedAt: NSDate
    public var type: UInt16
    public var message: String
    public var sourceType:String
    public var sourceUrlHash:String
    public var readAt: NSDate?
    
    public init(notification:[String:AnyObject?]) {
        guard let uhash         = notification["url_hash"] as? String else { fatalError("notification json has no `url_hash`") }
        self.urlHash            = uhash
        guard let createdAt     = notification["unix_created_at"] as? NSTimeInterval else { fatalError("notification json has no `unix_created_at`") }
        self.createdAt          = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt     = notification["unix_updated_at"] as? NSTimeInterval else { fatalError("notification json has no `unix_updated_at`") }
        self.updatedAt          = NSDate(timeIntervalSince1970:updatedAt)
        
        guard let mess          = notification["message"] as? String else { fatalError("notification json has no `payload`.`message`") }
        self.message            = mess
        guard let psource       = notification["payload_source"] as? String else { fatalError("notification json has no `payload_source`") }
        self.sourceType         = String(psource.characters.prefix(1)).uppercaseString + String(psource.characters.dropFirst())
        guard let psourcehash   = notification["payload_object_url_hash"] as? String else { fatalError("notification json has no `payload_object_url_hash`") }
        self.sourceUrlHash      = psourcehash
        
        guard let type          = notification["push_type"] as? Int else { fatalError("notification json has no `type`") }
        self.type               = UInt16(type)
        
        guard let readAt        = notification["unix_read_at"] as? NSTimeInterval else { return }
        self.readAt             = NSDate(timeIntervalSince1970:readAt)
    }
    
}

extension RemoteNotification : RemoteRecordMappable {
    
    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let notification = managedObject as? Notification else {
            fatalError("Object mapped is not a Notification")
        }
        
        notification.urlHash        = self.urlHash
        notification.createdAt      = self.createdAt
        notification.updatedAt      = self.updatedAt
        notification.message        = self.message
        notification.type           = self.type
        notification.sourceUrlHash  = self.sourceUrlHash
    }
    
}

extension RemoteNotification {

    public func insertIntoContext(moc:NSManagedObjectContext)->Notification {
        return Notification.insertOrUpdate(moc, urlHash:urlHash) { notification in
            if notification.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(notification)
                guard let notSource = NotificationSource(rawValue: self.sourceType) else { fatalError("Not a NotificationClass : \(self.sourceType)") }
                let predicate       = NSPredicate(format:"%K == %@", RemoteComparableKeys.UrlHash.rawValue, self.sourceUrlHash)
                switch notSource  {
                case .Contract:
                    let contract    = Contract.findOrFetchInContext(moc, matchingPredicate: predicate)
                    contract?.addNotification(notification)
                case .Event:
                    self.mapTo(notification)
                    let event       = Event.findOrFetchInContext(moc, matchingPredicate: predicate)
                    event?.addNotification(notification)
                case .User:
                    break
                case .Test:
                    break
                }
            }
        }
    }
    
}

extension SequenceType where Generator.Element == RemoteNotification {
    
    public func removeTestsNotifications()->[RemoteNotification] {
        return filter{ $0.sourceType != NotificationSource.Test.rawValue }.flatMap{ $0 }
    }

}

