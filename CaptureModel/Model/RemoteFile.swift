//
//  RemoteFile.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CoreLocation
import AVFoundation

extension RemoteFile: KeyCodable {
    public enum Keys: String {
        case IsUploaded             = "isUploaded"
        case Index                  = "index"
        case Corrupted              = "corrupted"
        case LocalPath              = "localPath"
        case RemotePath             = "remotePath"
    }
}

public class RemoteFile: ManagedObject {

    @NSManaged public var isUploaded: Bool
    @NSManaged public var index: UInt16
    @NSManaged public var remotePath: String?
    @NSManaged public var localPath: String
    @NSManaged public var corrupted: Bool
    @NSManaged public var fileSize:UInt64
    @NSManaged public var duration:UInt64
    @NSManaged public var attachment: Attachment
   
    public static func insertRemoteFiles(attachment:Attachment, directory:String, files:[String], managedObjectContext moc:NSManagedObjectContext)->[RemoteFile] {
        let remoteFiles:[RemoteFile] = files.map {
            let rmf:RemoteFile      = moc.insertObject()
            rmf.index               = UInt16(attachment.remoteFiles?.count ?? 0)
            rmf.localPath           = $0
            rmf.attachment          = attachment
            rmf.createdAt           = NSDate()
            rmf.updatedAt           = NSDate()
            rmf.uuid                = NSUUID().UUIDString
            let videoFilePath       = "\(directory)/\($0)"
            rmf.fileSize            = NSFileManager.defaultManager().sizeOfFile(videoFilePath)
            
            rmf.duration            = rmf.revealAssetDuration(videoFilePath)
            return rmf
        }
        return remoteFiles
    }
   
    public dynamic func revealAssetDuration(filePath:String)->UInt64 {
        let asset                   = AVURLAsset(URL: NSURL(fileURLWithPath: filePath), options: nil)
        return UInt64(CMTimeGetSeconds(asset.duration) * 1000)
    }
    
    public override func willSave() {
        super.willSave()
        
        if shouldMarkForRemoteVerification {
            markForNeedsRemoteVerification()
        }
    }

    public static var missingLocalFilePath: NSPredicate {
        return NSPredicate(format: "%K == NULL OR %K.length == 0", Keys.LocalPath.rawValue, Keys.LocalPath.rawValue)
    }
    
    public static var hasLocalFilePath: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: missingLocalFilePath)
    }

    private var shouldMarkForRemoteVerification:Bool {
        return (RemoteFile.notMarkedForRemoteVerificationPredicate.evaluateWithObject(self)
            && RemoteFile.hasLocalFilePath.evaluateWithObject(self)
            && changedInNeedForRemoteVerification())
    }
    
}

extension RemoteFile: LocalComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var uuid: String
    
}

extension RemoteFile : ManagedObjectType {
    
    public static var entityName: String {
        return "RemoteFile"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:RemoteComparableKeys.CreatedAt.rawValue, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

extension RemoteFile : RemoteUpdatable {
    
    @NSManaged public var needsRemoteVerification:Bool
    @NSManaged public var shouldBlockFromJSONMapping:Bool
    
    public func changedInNeedForRemoteVerification()->Bool {
        let keys:[Keys] = [.RemotePath]
        return keys.reduce(false) { a, b in
            return a ? a : changedValues()[b.rawValue] != nil
        }
    }
    
}

extension RemoteFile : JSONHashable {
    
    public func toJSON() -> [String : AnyObject] {
        let remoteFileJSON:[String:AnyObject] = [
             "uuid"         : uuid
            ,"duration"     : NSNumber(unsignedLongLong:UInt64(duration))
            ,"video_path"   : remotePath ?? ""
            ,"video_index"  : NSNumber(unsignedShort: index)
            ,"size"         : NSNumber(unsignedLongLong: fileSize)
            ,"attachment_uuid" : attachment.uuid
        ]
        return remoteFileJSON
    }
    
}



public struct RemoteRemoteFile: RemoteRecordType {

    public var uuid         : String
    public var createdAt    : NSDate
    public var updatedAt    : NSDate
    public var index        : UInt16
    public var remotePath   : String
    public var fileSize     : UInt64
    public var duration     : UInt64

    public init(remoteFile:[String:AnyObject?]) {
        guard let uid           = remoteFile["uuid"] as? String else { fatalError("remoteFile json has no `uuid`") }
        self.uuid               = uid
        guard let createdAt     = remoteFile["unix_created_at"] as? NSTimeInterval else { fatalError("remoteFile json has no `unix_created_at`") }
        self.createdAt          = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt     = remoteFile["unix_updated_at"] as? NSTimeInterval else { fatalError("remoteFile json has no `unix_updated_at`") }
        self.updatedAt          = NSDate(timeIntervalSince1970:updatedAt)
        self.index              = remoteFile["video_index"]??.unsignedShortValue ?? 0
        self.remotePath         = remoteFile["video_path"] as? String ?? ""
        self.fileSize           = remoteFile["size"]??.unsignedLongLongValue ?? 0
        self.duration           = remoteFile["duration"]??.unsignedLongLongValue ?? 0
    }
    
}

extension RemoteRemoteFile : RemoteRecordMappable {
    
    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let remoteFile = managedObject as? RemoteFile else {
            fatalError("Object mapped is not a RemoteFile")
        }
        remoteFile.uuid         = self.uuid
        remoteFile.createdAt    = self.createdAt
        remoteFile.updatedAt    = self.updatedAt
        remoteFile.index        = self.index
        remoteFile.remotePath   = self.remotePath
        remoteFile.fileSize     = self.fileSize
        remoteFile.duration     = self.duration
    }
    
}

extension RemoteRemoteFile {
    
    public func insertIntoContext(moc:NSManagedObjectContext)->RemoteFile {
        return RemoteFile.insertOrUpdate(moc, uuid: uuid) { remoteFile in
            if remoteFile.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(remoteFile)
            }
        }
    }
    
}





