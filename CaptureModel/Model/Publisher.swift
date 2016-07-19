//
//  Publisher.swift
//  Current
//
//  Created by Scott Jones on 3/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers


public final class Publisher: ManagedObject {

    @NSManaged public var teamUrlHash: String
    @NSManaged public var phoneNumber: String
    @NSManaged public var lastName: String
    @NSManaged public var firstName: String
    @NSManaged public var avatarUrl: String
    @NSManaged public var team: Team?
    @NSManaged public var contracts: Set<Contract>?

}

extension Publisher: RemoteComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var urlHash: String
    
}

extension Publisher : ManagedObjectType {
    
    public static var entityName: String {
        return "Publisher"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:RemoteComparableKeys.CreatedAt.rawValue, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}


public struct RemotePublisher : RemoteRecordType {
    
    public var createdAt: NSDate
    public var updatedAt: NSDate
    public var urlHash: String
    public var teamUrlHash: String
    public var phoneNumber: String
    public var lastName: String
    public var firstName: String
    public var avatarUrl: String
    
    public init(publisher:[String:AnyObject?]) {
        guard let uhash         = publisher["url_hash"] as? String else { fatalError("publisher json has no `url_hash`") }
        self.urlHash            = uhash
        guard let createdAt     = publisher["unix_created_at"] as? NSTimeInterval else { fatalError("publisher json has no `unix_created_at`") }
        self.createdAt          = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt     = publisher["unix_updated_at"] as? NSTimeInterval else { fatalError("publisher json has no `unix_updated_at`") }
        self.updatedAt          = NSDate(timeIntervalSince1970:updatedAt)
        self.teamUrlHash        = publisher["team_url_hash"] as? String ?? ""
        self.phoneNumber        = publisher["phone_number"] as? String ?? ""
        self.lastName           = publisher["last_name"] as? String ?? ""
        self.firstName          = publisher["first_name"] as? String ?? ""
        self.avatarUrl          = publisher["avatar_url"] as? String ?? ""
    }
    
}

extension RemotePublisher : RemoteRecordMappable {
    
    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let publisher = managedObject as? Publisher else {
            fatalError("Object mapped is not a Publisher")
        }
        publisher.urlHash       = self.urlHash
        publisher.createdAt     = self.createdAt
        publisher.updatedAt     = self.updatedAt
        publisher.teamUrlHash   = self.teamUrlHash
        publisher.phoneNumber   = self.phoneNumber
        publisher.lastName      = self.lastName
        publisher.firstName     = self.firstName
        publisher.avatarUrl     = self.avatarUrl
    }

}

extension RemotePublisher {
    
    public func insertIntoContext(moc:NSManagedObjectContext)->Publisher {
        return Publisher.insertOrUpdate(moc, urlHash:urlHash) { publisher in
            if publisher.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(publisher)
            }
        }
    }
    
}






