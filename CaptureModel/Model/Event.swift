//
//  Event.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

extension Event: KeyCodable {
    public enum Keys: String {
        case HiringCutoffTime               = "hiringCutoffTime"
        case StartTime                      = "startTime"
        case DisplayTime                    = "displayTime"
        case Contract                       = "contract"
        case PaymentAmount                  = "paymentAmount"
    }
}

public final class Event: ManagedObject {
    
    @NSManaged public var hasSeenReminderFlag:Bool
    @NSManaged public var reminderFlag:Bool
    @NSManaged public var localDeletionDate:NSDate?
    @NSManaged public private(set) var hiringCutoffTime: NSDate
    @NSManaged public private(set) var latitude:Double
    @NSManaged public private(set) var longitude:Double
    @NSManaged public private(set) var paymentAmount:Float
    @NSManaged public private(set) var radius:Double
    @NSManaged public private(set) var startTime: NSDate
    @NSManaged public private(set) var displayTime: NSDate
    @NSManaged public private(set) var title: String
    @NSManaged public private(set) var creatorName: String
    @NSManaged public private(set) var creatorIconUrl: String
    @NSManaged public private(set) var bannerImageUrl: String
    @NSManaged public private(set) var publicUrl: String
    @NSManaged public private(set) var contractUrlHash: String?
    @NSManaged public private(set) var exactAddress: String?
    @NSManaged public private(set) var locationName: String?
    @NSManaged public private(set) var heroUrl: String?
    @NSManaged public private(set) var thumbnailUrl: String?
    @NSManaged public private(set) var detailDescription: String?
   
    public override func willSave() {
        super.willSave()
    }
    
    public static var pastHiringCutoffDatePredicate:NSPredicate {
        return NSPredicate(format: "%K <= %@", Keys.HiringCutoffTime.rawValue, NSDate())
    }
    
    public static var notPastHiringCutoffDatePredicate:NSPredicate {
        return NSPredicate(format: "%K >= %@", Keys.HiringCutoffTime.rawValue, NSDate())
    }
    
    public static var pastDisplayDatePredicate:NSPredicate {
        return NSPredicate(format: "%K < %@", Keys.DisplayTime.rawValue, NSDate())
    }
   
    public static var notPastDisplayDatePredicate:NSPredicate {
        return NSPredicate(format: "%K >= %@", Keys.DisplayTime.rawValue, NSDate())
    }
    
    public var isPastCameraAccessTime:Bool {
        let hoursAsSeconds:NSTimeInterval           = -(1 * 60.0 * 60.0)
        let hourBeforeStart                         = startTime.dateByAddingTimeInterval(hoursAsSeconds)
        return hourBeforeStart.timeIntervalSince1970 < NSDate().timeIntervalSince1970
    }
    
    public static var contractIsNilPredicate:NSPredicate {
        return NSPredicate(format: "%K == NULL", Keys.Contract.rawValue)
    }
    
    public static var contractIsNotNilPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: contractIsNilPredicate)
    }

    public static var contractIsAcquiredPredicate:NSPredicate {
        return NSPredicate(format: "%K.%K == true", Event.Keys.Contract.rawValue, Contract.Keys.Acquired.rawValue)
    }
    
    public static var contractIsNotAcquiredPredicate:NSPredicate {
        return NSPredicate(format: "%K.%K == false", Event.Keys.Contract.rawValue, Contract.Keys.Acquired.rawValue)
    }
    
    public static var contractResolutionIsOpenPredicate:NSPredicate {
        return NSPredicate(format: "%K.%K == %@", Event.Keys.Contract.rawValue, Contract.Keys.Resolution.rawValue, Contract.ResolutionStatus.Open.rawValue)
    }
    
    public static var contractResolutionIsNotOpenPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate:contractResolutionIsOpenPredicate)
    }
    
    public static var contractResolutionIsCompletedPredicate:NSPredicate {
        return NSPredicate(format: "%K.%K == %@", Event.Keys.Contract.rawValue, Contract.Keys.Resolution.rawValue, Contract.ResolutionStatus.Completed.rawValue)
    }
  
    public static var contractNilOrNotAcquiredPredicate:NSPredicate {
        let notAcquiredAndOpen = NSCompoundPredicate(andPredicateWithSubpredicates: [contractIsNotAcquiredPredicate,contractResolutionIsOpenPredicate])
        return NSCompoundPredicate(orPredicateWithSubpredicates: [contractIsNilPredicate, notAcquiredAndOpen])
    }
    
    public static var notExpiredAndAppliedOrUnappliedPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [notPastDisplayDatePredicate, contractNilOrNotAcquiredPredicate])
    }

    public static var needsMarkForLocalDeletionPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [pastHiringCutoffDatePredicate, notMarkedForLocalDeletionPredicate, contractNilOrNotAcquiredPredicate])
    }

    public static var contractIsHistoryPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contractIsAcquiredPredicate, contractResolutionIsNotOpenPredicate])
    }

    public static var contractIsOpenAndAcquiredPredicate:NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contractResolutionIsOpenPredicate, contractIsAcquiredPredicate])
    }
    
}

extension Event: RemoteComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var urlHash: String

}

extension Event :Notifiable {
    
    @NSManaged public var notifications: NSOrderedSet?
    @NSManaged public var notificationUpdateTime: NSDate

    internal func addNotification(notification:Notification) {
        notification.eventSource = self
        notifications = mutableNotifications.orderedSet()
        notificationUpdateTime = NSDate()
    }
    
}

extension Event : ManagedObjectType {
    
    public static var entityName: String {
        return "Event"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:RemoteComparableKeys.CreatedAt.rawValue, ascending: false)]
    }

    public static var defaultPredicate: NSPredicate {
        return notMarkedForLocalDeletionPredicate
    }
    
}

extension Event: DelayedDeletable {
    @NSManaged public var markedForDeletionDate: NSDate?
}

extension Event : ContractCreatable {
    @NSManaged public var needsToCreateRemoteContract:Bool
    @NSManaged public var contract: Contract?
}

extension Event : ContractDeletable {
    @NSManaged public var needsToDeleteRemoteContract:Bool
}

extension Event : JSONHashable {
    
    public func toJSON() -> [String : AnyObject] {
        let event:[String:AnyObject] = [
            "url_hash"                  : self.urlHash,
            "unix_created_at"           : self.createdAt.timeIntervalSince1970,
            "unix_updated_at"           : self.updatedAt.timeIntervalSince1970,
            "unix_hiring_cutoff_time"   : self.hiringCutoffTime.timeIntervalSince1970,
            "latitude"                  : self.latitude ?? 0.0,
            "longitude"                 : self.longitude ?? 0.0,
            "radius"                    : self.longitude ?? 0.0,
            "unix_start_time"           : self.startTime.timeIntervalSince1970,
            "title"                     : self.longitude ?? 0.0,
            "public_url"                : self.publicUrl ?? "",
            "contract_url_hash"         : self.contractUrlHash ?? "",
            "exact_address"             : self.exactAddress ?? "",
            "location_name"             : self.locationName ?? "",
            "hero_url"                  : self.heroUrl ?? "",
            "thumbnail_url"             : self.longitude ?? 0.0,
            "description"               : self.detailDescription ?? 0.0
        ]
        return event
    }
    
}

public struct RemoteEvent: RemoteRecordType {
 
    public var createdAt: NSDate
    public var updatedAt: NSDate
    public var urlHash: String
    public var hiringCutoffTime: NSDate
    public var latitude:Double
    public var longitude:Double
    public var paymentAmount:Float
    public var radius:Double
    public var startTime: NSDate
    public var title: String
    public var publicUrl: String
    public var bannerImageUrl: String
    public var creatorName: String
    public var creatorIconUrl: String
    public var contractUrlHash: String?
    public var exactAddress: String?
    public var locationName: String?
    public var heroUrl: String?
    public var thumbnailUrl: String?
    public var detailDescription: String?
    public var contract: Contract?

    public init(event:[String:AnyObject?]) {
        guard let uhash         = event["url_hash"] as? String else { fatalError("event json has no `url_hash`") }
        self.urlHash            = uhash
        guard let createdAt     = event["unix_created_at"] as? NSTimeInterval else { fatalError("event json has no `unix_created_at`") }
        self.createdAt          = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt     = event["unix_updated_at"] as? NSTimeInterval else { fatalError("event json has no `unix_updated_at`") }
        self.updatedAt          = NSDate(timeIntervalSince1970:updatedAt)
        self.latitude           = event["latitude"] as? Double ?? 0.0
        self.longitude          = event["longitude"] as? Double  ?? 0.0
        self.paymentAmount      = event["payment_amount"] as? Float  ?? 0.0
        self.radius             = event["radius"] as? Double ?? 0.0
        self.title              = event["title"]  as? String ?? ""
        self.publicUrl          = event["public_url"] as? String  ?? ""
        self.bannerImageUrl     = event["banner_image_url"] as? String  ?? ""
        self.creatorName        = event["creator_name"] as? String  ?? ""
        self.creatorIconUrl     = event["creator_icon_url"] as? String  ?? ""
        self.startTime          = NSDate(timeIntervalSince1970: event["unix_start_time"] as? NSTimeInterval ?? 0)
        self.hiringCutoffTime   = NSDate(timeIntervalSince1970: event["unix_hiring_cutoff_time"] as? NSTimeInterval ?? 0)
        // optionals
        self.contractUrlHash    = event["contract_url_hash"] as? String
        self.exactAddress       = event["exact_address"] as? String
        self.locationName       = event["location_name"] as? String
        self.heroUrl            = event["hero_url"] as? String
        self.thumbnailUrl       = event["thumbnail_url"] as? String
        self.detailDescription  = event["description"] as? String
    }

}

extension RemoteEvent : RemoteRecordMappable {
    
    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let event = managedObject as? Event else {
            fatalError("Object mapped is not a Event")
        }
        event.createdAt         = self.createdAt
        event.updatedAt         = self.updatedAt
        event.urlHash           = self.urlHash
        event.hiringCutoffTime  = self.hiringCutoffTime
        event.latitude          = self.latitude
        event.locationName      = self.locationName
        event.longitude         = self.longitude
        event.paymentAmount     = self.paymentAmount
        event.radius            = self.radius
        event.title             = self.title
        event.bannerImageUrl    = self.bannerImageUrl
        event.creatorName       = self.creatorName
        event.creatorIconUrl    = self.creatorIconUrl
        event.publicUrl         = self.publicUrl
        event.startTime         = self.startTime
        event.contractUrlHash   = self.contractUrlHash
        event.exactAddress      = self.exactAddress
        event.heroUrl           = self.heroUrl
        event.thumbnailUrl      = self.thumbnailUrl
        event.detailDescription = self.detailDescription
        
        event.displayTime       = self.hiringCutoffTime.dateByAddingTimeInterval(NSTimeInterval(60.0 * 60.0 * 24))
    }
    
}

extension RemoteEvent {
    
    public func insertIntoContext(moc:NSManagedObjectContext)->Event {
        return Event.insertOrUpdate(moc, urlHash:urlHash) { event in
            if event.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(event)
            }
            var e               = event
            e.updateNotifications(moc)
        }
    }
    
}

