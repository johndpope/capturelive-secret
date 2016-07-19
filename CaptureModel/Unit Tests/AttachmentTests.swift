//
//  AttachmentTests.swift
//  Current
//
//  Created by Scott Jones on 3/29/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import CaptureModel

extension RemoteFile {
   
    public func test_RevealAssetDuration(filePath:String)->UInt64 {
        return 100
    }
   
    public static func swizzleDurationGetter() {
        let originalMethod = class_getInstanceMethod(self, #selector(RemoteFile.revealAssetDuration(_:)))
        let swizzledMethod = class_getInstanceMethod(self, #selector(RemoteFile.test_RevealAssetDuration(_:)))
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
}

class AttachmentTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {

        waitForManagedObjectContextToBeDone(managedObjectContext)
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func fetchAttachment(urlHash:String, moc:NSManagedObjectContext)->Attachment? {
        let fr = NSFetchRequest(entityName: Attachment.entityName)
        fr.fetchLimit           = 1
        fr.returnsObjectsAsFaults = false
        return try! moc.executeFetchRequest(fr).first as? Attachment
    }
   
    func testJsonTransformsToAttachment() {
        // given
        
        // when
        let remoteAttachment          = RemoteAttachment(attachment:attachmentJSON)
        
        // then
        XCTAssertEqual(remoteAttachment.uuid, "b96b57c2-7d8d-4a1b-842c-c8c8384868b6")
        XCTAssertEqual(remoteAttachment.createdAt, NSDate(timeIntervalSince1970: 1466531862))
        XCTAssertEqual(remoteAttachment.updatedAt, NSDate(timeIntervalSince1970: 1466531887))
        XCTAssertEqual(remoteAttachment.latitude, 40.7219618)
        XCTAssertEqual(remoteAttachment.longitude, -73.9998685)
        XCTAssertEqual(remoteAttachment.source, "mobile")
        XCTAssertEqual(remoteAttachment.remoteThumbnailPath, "http://capture-media-mobile.s3.amazonaws.com/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/thumbnail.jpg")
    }
    
    func testRemoteAttachmentObjectToManagedAttachment() {
        // given
        
        // when
        let managedAttachment          = createAttachment(attachmentJSON, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(managedAttachment.uuid, "b96b57c2-7d8d-4a1b-842c-c8c8384868b6")
        XCTAssertEqual(managedAttachment.createdAt, NSDate(timeIntervalSince1970: 1466531862))
        XCTAssertEqual(managedAttachment.updatedAt, NSDate(timeIntervalSince1970: 1466531887))
        XCTAssertEqual(managedAttachment.latitude, 40.7219618)
        XCTAssertEqual(managedAttachment.longitude, -73.9998685)
        XCTAssertEqual(managedAttachment.source, "mobile")
        XCTAssertEqual(managedAttachment.remoteThumbnailPath, "http://capture-media-mobile.s3.amazonaws.com/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/thumbnail.jpg")
    }
    
    func testJsonTransformsToRemoteFileJsonOnRemoteAttachment() {
        // given
        
        // when
        let remoteAttachment          = RemoteAttachment(attachment:attachmentJSON)

        // then
        XCTAssertEqual(1, remoteAttachment.remoteRemoteFiles.count)
        let rf = remoteAttachment.remoteRemoteFiles.first!
        XCTAssertEqual("im_a_uuid", rf.uuid)
    }
    
    func testRemoteAttachmentTransformsRemoteFilesToManagedRemoteFiles() {
        // given
        
        // when
        let managedAttachment          = createAttachment(attachmentJSON, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(1, managedAttachment.remoteFiles?.count)
        let rf = managedAttachment.remoteFiles!.first!
        XCTAssertEqual("im_a_uuid", rf.uuid)
    }

    func testComputedPropertiesAfterJsonToManagedObject() {
        // given
        let numChunks                   = 3
        var json                        = attachmentJSON
        json["hd_chunks"]               = getHdChunks(numChunks)
        
        // when
        let managedAttachment           = createAttachment(json, moc:managedObjectContext)
        
        // then
        XCTAssertEqual(3, managedAttachment.remoteFiles?.count)
        
        XCTAssertEqual(managedAttachment.duration, UInt64(numChunks * 7623623))
        XCTAssertEqual(managedAttachment.totalNumFiles, UInt16(managedAttachment.remoteFiles!.count))
        XCTAssertEqual(managedAttachment.uploadedFileBytes, UInt64(numChunks * 12543))
    }
    
    func testMappingAttachmentFromJSONDoesNotMarkForRemoteVerification() {
        // given
        
        // when
        let managedAttachment          = createAttachment(attachmentJSON, moc:managedObjectContext)
        
        // then
        XCTAssertFalse(Attachment.markedForRemoteVerificationPredicate.evaluateWithObject(managedAttachment))
        XCTAssertFalse(Attachment.markedForS3VerificationPredicate.evaluateWithObject(managedAttachment))
    }

    func testAttachmentCanBeCreatedViaContract() {
        // given
        let contract            = acquiredContract(managedObjectContext)
        
        // when
        let coordinate          = CLLocationCoordinate2D(latitude: 2.0, longitude: 3.0)
        let attachment          = Attachment.insertAttachment(contract: contract, directory:"",  location:coordinate, managedObjectContext:managedObjectContext)
        
        // then
        XCTAssertNotNil(attachment.uuid)
        XCTAssertEqual(contract, attachment.contract)
        XCTAssertEqual(0, attachment.contractIndex)
        XCTAssertTrue(attachment.isCorrupted)
        XCTAssertEqual(2.0, attachment.latitude)
        XCTAssertEqual(3.0, attachment.longitude)
        XCTAssertEqual("mobile", attachment.source)
    }
    
    func testAttachmentToJSON() {
        // given
        let contract            = acquiredContract(managedObjectContext)
        let coordinate          = CLLocationCoordinate2D(latitude: 2.0, longitude: 3.0)
        let attachment          = Attachment.insertAttachment(contract: contract, directory:"",  location:coordinate, managedObjectContext:managedObjectContext)
        managedObjectContext.performChanges {
            attachment.remoteThumbnailPath = "thumbnail_local_path"
            attachment.totalFileBytes = 30000
            attachment.uploadedFileBytes = 15
            attachment.totalNumFiles = 4
            attachment.duration = 10000
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
 
        // when
        var attJSON = attachment.toJSON()

        // then
        XCTAssertEqual(attJSON["uuid"] as? String, attachment.uuid)
        XCTAssertEqual(attJSON["unix_created_at"] as? NSTimeInterval, attachment.createdAt.timeIntervalSince1970)
        XCTAssertEqual(attJSON["unix_updated_at"] as? NSTimeInterval, attachment.updatedAt.timeIntervalSince1970)
        XCTAssertEqual(attJSON["duration"]?.unsignedLongLongValue, attachment.duration)
        XCTAssertEqual(attJSON["corrupted"] as? Bool, attachment.isCorrupted)
        XCTAssertEqual(attJSON["total_size"]?.unsignedLongLongValue, attachment.totalFileBytes)
        XCTAssertEqual(attJSON["bytes_uploaded"]?.unsignedLongLongValue, attachment.uploadedFileBytes)
        XCTAssertEqual(attJSON["number_of_hd_chunks"]?.unsignedShortValue, attachment.totalNumFiles)
        XCTAssertEqual(attJSON["latitude"] as? Double, attachment.latitude)
        XCTAssertEqual(attJSON["longitude"] as? Double, attachment.longitude)
        XCTAssertEqual(attJSON["thumbnail_url"] as? String, attachment.remoteThumbnailPath)
        XCTAssertEqual(attJSON["source"] as? String, attachment.source)
    }
    
    func testPropertiesAfterCompletion() {
        // given
        RemoteFile.swizzleDurationGetter()
        let attachmentMO        = createAttachment(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            attachmentMO.completeMedia("", files:["file_one", "file_two", "file_three"])
            attachmentMO.localThumbnailPath = "thumbnail_local_path"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
    
        // then
        XCTAssertEqual(attachmentMO.totalNumFiles, 3)
        XCTAssertEqual(attachmentMO.duration, 300)
        XCTAssertEqual(attachmentMO.localThumbnailPath, "thumbnail_local_path")

        XCTAssertTrue(Attachment.markedForS3VerificationPredicate.evaluateWithObject(attachmentMO))
        XCTAssertTrue(Attachment.markedForRemoteVerificationPredicate.evaluateWithObject(attachmentMO))
    }
    
    func testEventNotMarkedForRemoteVerification() {
        // given
        let attachmentMO        = createAttachment(managedObjectContext)
        // when
        
        // then 
        XCTAssertFalse(Attachment.markedForRemoteVerificationPredicate.evaluateWithObject(attachmentMO))
    }
    
    func testEventIsMarkedForRemoteVerificationAfterCompleting() {
        // given
        let attachmentMO        = createAttachment(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            attachmentMO.completeMedia("", files:["file_one", "file_two", "file_three"])
            attachmentMO.localThumbnailPath = "thumbnail_local_path"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Attachment.markedForRemoteVerificationPredicate.evaluateWithObject(attachmentMO))
    }
    
    func testEventIsMarkedForS3VerificationAfterLocalThumbnailSet() {
        // given
        let attachmentMO        = createAttachment(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            attachmentMO.localThumbnailPath = "thumbnail_local_path"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Attachment.markedForS3VerificationPredicate.evaluateWithObject(attachmentMO))
    }
    
    func testEventIsMarkedForRemoteVerificationAfterRemoteThumbnailSet() {
        // given
        let attachmentMO        = createAttachment(managedObjectContext)
        
        // when
        managedObjectContext.performChanges {
            attachmentMO.remoteThumbnailPath = "thumbnail_local_path"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(Attachment.markedForRemoteVerificationPredicate.evaluateWithObject(attachmentMO))
    }
   
}
