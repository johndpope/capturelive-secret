//
//  Team.swift
//  Current
//
//  Created by Scott Jones on 3/23/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

public final class Team: ManagedObject {

    @NSManaged public var name: String
    @NSManaged public var iconUrl: String
    @NSManaged public var publishers: Set<Publisher>?
    @NSManaged public var contracts: Contract?

}

extension Team: RemoteComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var urlHash: String
    
}

extension Team : ManagedObjectType {
    
    public static var entityName: String {
        return "Team"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:RemoteComparableKeys.CreatedAt.rawValue, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

public struct RemoteTeam : RemoteRecordType {
    
    public var createdAt: NSDate
    public var updatedAt: NSDate
    public var urlHash: String
    public var name: String
    public var iconUrl: String
    
    public init(team:[String:AnyObject?]) {
        guard let uhash         = team["url_hash"] as? String else { fatalError("team json has no `url_hash`") }
        self.urlHash            = uhash
        guard let createdAt     = team["unix_created_at"] as? NSTimeInterval else { fatalError("team json has no `unix_created_at`") }
        self.createdAt          = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt     = team["unix_updated_at"] as? NSTimeInterval else { fatalError("team json has no `unix_updated_at`") }
        self.updatedAt          = NSDate(timeIntervalSince1970:updatedAt)
        self.name               = team["name"] as? String ?? ""
        self.iconUrl            = team["icon_url"] as? String ?? ""
    }
    
}

extension RemoteTeam : RemoteRecordMappable {

    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let team = managedObject as? Team else {
            fatalError("Object mapped is not a Team")
        }
        team.createdAt         = self.createdAt
        team.updatedAt         = self.updatedAt
        team.urlHash           = self.urlHash
        team.name              = self.name
        team.iconUrl           = self.iconUrl
    }

}

extension RemoteTeam {
    
    public func insertIntoContext(moc:NSManagedObjectContext)->Team {
        return Team.insertOrUpdate(moc, urlHash:urlHash) { team in
            if team.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(team)
            }
        }
    }
    
}


