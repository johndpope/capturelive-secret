//
//  Attachment.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CoreLocation

extension Attachment: KeyCodable {
    public enum Keys: String {
        case Duration               = "duration"
        case IsCorrupted            = "isCorrupted"
        case ShouldSaveAssets       = "shouldSaveAssets"
        case TotalFileBytes         = "totalFileBytes"
        case TotalNumFiles          = "totalNumFiles"
        case Uploaded               = "uploaded"
        case UploadedFileBytes      = "uploadedFileBytes"
        case RemoteThumbnailPath    = "remoteThumbnailPath"
        case LocalThumbnailPath     = "localThumbnailPath"
        case UploadableFiles        = "uploadableFiles"
        case ContractIndex          = "contractIndex"
        case Directory              = "directory"
        case Contract               = "contract"
        case Latitude               = "latitude"
        case Longitude              = "longitude"
    }
}

private let Source = "mobile"
public final class Attachment: ManagedObject {
  
    @NSManaged public var duration:UInt64
    @NSManaged public var isCorrupted:Bool
    @NSManaged public var shouldSaveAssets: Bool
    @NSManaged public var totalNumFiles:UInt16
    @NSManaged public var totalFileBytes: UInt64
    @NSManaged public var uploadedFileBytes:UInt64
    @NSManaged public var localThumbnailPath: String?
    @NSManaged public var remoteThumbnailPath: String?
    @NSManaged public var uploaded:Bool
    @NSManaged public private(set) var source:String
    @NSManaged public private(set) var contractIndex:UInt32
    @NSManaged public private(set) var directory:String
    @NSManaged public private(set) var contract:Contract
    @NSManaged public private(set) var remoteFiles:Set<RemoteFile>?
    @NSManaged public private(set) var latitude: Double
    @NSManaged public private(set) var longitude:Double

    public static func insertAttachment(contract contract:Contract, directory:String, location:CLLocationCoordinate2D, managedObjectContext moc:NSManagedObjectContext)->Attachment {
        let att:Attachment      = moc.insertObject()
        att.contractIndex       = UInt32(contract.attachments?.count ?? 0)
        att.contract            = contract
        att.createdAt           = NSDate()
        att.uuid                = NSUUID().UUIDString
        att.directory           = NSFileManager.defaultManager().createDirectoryInDirectory(directory, path:att.uuid)
        att.latitude            = location.latitude
        att.longitude           = location.longitude
        att.source              = Source
        return att
    }

    public func completeMedia(directory:String, files:[String]) {
        self.totalNumFiles      = UInt16(files.count)
//        self.localThumbnailPath = localThumbnail
        self.isCorrupted        = false
        let files               = RemoteFile.insertRemoteFiles(self, directory:directory, files:files, managedObjectContext:self.managedObjectContext!)
        self.totalFileBytes     = files.reduce(0) { $0 + $1.fileSize }
        self.duration           = files.reduce(0) { $0 + $1.duration }
    }
   
    public override func willSave() {
        super.willSave()
        
        if shouldMarkForRemoteVerification {
            markForNeedsRemoteVerification()
        }
        
        if shouldMarkForS3Verification {
            markForNeedsS3Verification()
        }
        
    }
    
    public override func didSave() {
        super.didSave()
        shouldBlockWhenJSONMapping = false
    }

    private var shouldMarkForRemoteVerification:Bool {
        return (Attachment.notMarkedForRemoteVerificationPredicate.evaluateWithObject(self)
            && Attachment.notBlockedFromJSONMappingPredicate.evaluateWithObject(self)
            && changedInNeedForRemoteVerification())
    }
    
    private var shouldMarkForS3Verification:Bool {
        return (Attachment.notMarkedForS3VerificationPredicate.evaluateWithObject(self)
            && Attachment.notBlockedFromJSONMappingPredicate.evaluateWithObject(self)
            && changedInNeedS3Verification())
    }

    public static var alreadyUploadedPredicate: NSPredicate {
        return NSPredicate(format:"%K == true", Keys.Uploaded.rawValue)
    }
    
    public static var notAlreadyUploadedPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: alreadyUploadedPredicate)
    }
    
}

extension Attachment {
    
    public func configureUploadedBytes()->UInt64 {
        uploadedFileBytes = remoteFilesAscending.reduce(0) {
            guard let _ = $1.remotePath else {
                return $0
            }
            return $0 + $1.fileSize
        }
        uploaded = (totalFileBytes == uploadedFileBytes)
        return uploadedFileBytes
    }
    
    public var nextFileToUpload:RemoteFile? {
        return remoteFilesAscending.filter{ $0.remotePath == nil }.flatMap { $0 }.first
    }
    
    public var remoteFilesDescending:[RemoteFile] {
        guard let rf = remoteFiles else { return [] }
        return rf.sort({ $0.createdAt.compare($1.createdAt) == .OrderedDescending })
    }
    
    public var remoteFilesAscending:[RemoteFile] {
        guard let rf = remoteFiles else { return [] }
        return rf.sort({ $0.createdAt.compare($1.createdAt) == .OrderedAscending })
    }
    
}

extension Attachment: LocalComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var uuid: String

}

extension Attachment : ManagedObjectType {
    
    public static var entityName: String {
        return "Attachment"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:LocalComparableKeys.CreatedAt.rawValue, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

extension Attachment : RemoteUpdatable {
    
    @NSManaged public var needsRemoteVerification:Bool

    public func changedInNeedForRemoteVerification()->Bool {
        let keys:[Keys] = [.UploadableFiles, .TotalNumFiles, .TotalFileBytes, .Duration, .IsCorrupted, .RemoteThumbnailPath, .Uploaded]
        return keys.reduce(false) { a, b in
            return a ? a : changedValues()[b.rawValue] != nil
        }
    }
    
}

extension Attachment : RemoteUpdateBlockable {
    
    @NSManaged public var shouldBlockWhenJSONMapping:Bool
    
}


extension Attachment : S3Uploadable {
    
    @NSManaged public var needsS3Verification:Bool
    
    public var keysForS3Upload:[String] {
        let keys:[Keys] = [.LocalThumbnailPath]
        return keys.map { $0.rawValue }
    }

}

extension Attachment : JSONHashable {
    
    public func toJSON() -> [String : AnyObject] {
        var attachment:[String:AnyObject] = [
             "uuid"                 : uuid
            ,"unix_created_at"      : createdAt.timeIntervalSince1970
            ,"unix_updated_at"      : updatedAt.timeIntervalSince1970
            ,"duration"             : NSNumber(unsignedLongLong: duration)
            ,"corrupted"            : NSNumber(bool: isCorrupted)
            ,"total_size"           : NSNumber(unsignedLongLong: totalFileBytes)
            ,"bytes_uploaded"       : NSNumber(unsignedLongLong: uploadedFileBytes)
            ,"number_of_hd_chunks"  : NSNumber(unsignedShort: totalNumFiles)
            ,"latitude"             : latitude
            ,"longitude"            : longitude
            ,"source"               : source
        ]
        guard let thumbnail = remoteThumbnailPath else {
            return attachment
        }
        attachment["thumbnail_url"]     = thumbnail
        return attachment
    }
    
}


public struct RemoteAttachment {

    public var createdAt: NSDate
    public var updatedAt: NSDate
    public var uuid: String
    public var remoteThumbnailPath: String?
    public var latitude:Double
    public var longitude:Double
    public var source:String
    public var remoteRemoteFiles:[RemoteRemoteFile]

    public init(attachment:[String:AnyObject?]) {
        guard let uid               = attachment["uuid"] as? String else { fatalError("attachment json has no `uuid`") }
        self.uuid                   = uid
        guard let createdAt         = attachment["unix_created_at"] as? NSTimeInterval else { fatalError("attachment json has no `unix_created_at`") }
        self.createdAt              = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt         = attachment["unix_updated_at"] as? NSTimeInterval else { fatalError("attachment json has no `unix_updated_at`") }
        self.updatedAt              = NSDate(timeIntervalSince1970:updatedAt)
        self.latitude               = attachment["latitude"] as? Double ?? 0.0
        self.longitude              = attachment["longitude"] as? Double  ?? 0.0
        self.source                 = attachment["source"] as? String ?? "unknown"
        self.remoteThumbnailPath    = attachment["thumbnail_url"] as? String

        if let remoteFilesJSON = attachment["hd_chunks"] as? [[String:AnyObject]] {
            remoteRemoteFiles       = remoteFilesJSON.map { RemoteRemoteFile(remoteFile:$0) }
        } else {
            remoteRemoteFiles       = []
        }
    }
    
}

extension RemoteAttachment : RemoteRecordMappable {
    
    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let attachment = managedObject as? Attachment else {
            fatalError("Object mapped is not a remoteAttachment")
        }
        attachment.shouldBlockWhenJSONMapping = true
        attachment.uuid             = self.uuid
        attachment.createdAt        = self.createdAt
        attachment.updatedAt        = self.updatedAt
        attachment.latitude         = self.latitude
        attachment.longitude        = self.longitude
        attachment.source           = self.source
        attachment.remoteThumbnailPath = self.remoteThumbnailPath
    }
    
}

extension RemoteAttachment {
    
    public func insertIntoContext(moc:NSManagedObjectContext)->Attachment {
        return Attachment.insertOrUpdate(moc, uuid: uuid) { attachment in
            if attachment.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(attachment)
            }
           
            let rf                  = self.remoteRemoteFiles.map { $0.insertIntoContext(moc) }
            attachment.remoteFiles  = Set(rf)
            
            // computed properties
            attachment.duration     = rf.reduce(0) { $0 + $1.duration }
            attachment.totalNumFiles = UInt16(rf.count)
            attachment.totalFileBytes = rf.reduce(0) { $0 + $1.fileSize }
            attachment.uploadedFileBytes = attachment.totalFileBytes
            attachment.uploaded     = true
        }
    }
    
}