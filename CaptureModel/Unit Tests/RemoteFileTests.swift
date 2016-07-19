//
//  RemoteFileTests.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import CaptureModel

class RemoteFileTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func createAttachment(moc:NSManagedObjectContext)->Attachment {
        let contract = createContractWithAttachments(managedObjectContext, numAttachments: 1, numRemoteFiles: 5)
        return contract.attachments!.first!
    }
  
    
    func createAttachmentNoRemoteFiles(moc:NSManagedObjectContext)->Attachment {
        let contract = createContractWithAttachments(managedObjectContext, numAttachments:1, numRemoteFiles: 0)
        return contract.attachments!.first!
    }
    
    
    func testJsonTransformsToRemoteFile() {
        // given
        
        // when
        let remoteRemoteFile          = RemoteRemoteFile(remoteFile:remoteFileJSON)
        
        // then
        XCTAssertEqual(remoteRemoteFile.uuid, "im_a_uuid")
        XCTAssertEqual(remoteRemoteFile.createdAt, NSDate(timeIntervalSince1970: 1457708802))
        XCTAssertEqual(remoteRemoteFile.updatedAt, NSDate(timeIntervalSince1970: 1458678297))
        XCTAssertEqual(remoteRemoteFile.index, 1)
        XCTAssertEqual(remoteRemoteFile.remotePath, "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4")
        XCTAssertEqual(remoteRemoteFile.fileSize, 12543)
        XCTAssertEqual(remoteRemoteFile.duration, 1234399)
    }
    
    func testRemoteFileObjectToManagedRemoteFile() {
        // given
        let attachment              = createAttachmentNoRemoteFiles(managedObjectContext)
        
        // when
        let remoteFile              = createRemoteFile(remoteFileJSON, attachment:attachment, moc: managedObjectContext)
        
        // then
        XCTAssertEqual(remoteFile.attachment.uuid, attachment.uuid)
        XCTAssertEqual(remoteFile.uuid, "im_a_uuid")
        XCTAssertEqual(remoteFile.createdAt, NSDate(timeIntervalSince1970: 1457708802))
        XCTAssertEqual(remoteFile.updatedAt, NSDate(timeIntervalSince1970: 1458678297))
        XCTAssertEqual(remoteFile.index, 1)
        XCTAssertEqual(remoteFile.remotePath, "capture-media-mobile/uploads/f7c26bv/b96b57c2-7d8d-4a1b-842c-c8c8384868b6/part_1.mp4")
        XCTAssertEqual(remoteFile.fileSize, 12543)
        XCTAssertEqual(remoteFile.duration, 1234399)
    }
   
    func testNeedsRemoteVerificationFalseIfMappedFromJson() {
        // given
        let attachment              = createAttachmentNoRemoteFiles(managedObjectContext)
        
        // when
        let remoteFile              = createRemoteFile(remoteFileJSON, attachment:attachment, moc: managedObjectContext)
        
        // then
        XCTAssertFalse(RemoteFile.markedForRemoteVerificationPredicate.evaluateWithObject(remoteFile))
    }
    
    func testRemoteFileFromAttachmentAndFileName() {
        // given
        let attachment              = createAttachment(managedObjectContext)

        // when
        let rfiles                  = attachment.remoteFilesAscending
        
        // then
        XCTAssertEqual(5, rfiles.count)

        let remoteFile = rfiles.first!
        XCTAssertEqual(0, remoteFile.index)
        XCTAssertEqual("attachment_file_0", remoteFile.localPath)
    }
    
    func testRemoteFileFromAttachmentOrdersProperFileNames() {
        // given
        let attachment = createAttachment(managedObjectContext)
        
        // when
        let rfiles = attachment.remoteFilesAscending
        
        // then
        XCTAssertEqual(5, rfiles.count)
        
        var remoteFile = rfiles[0]
        XCTAssertEqual(0, remoteFile.index)
        XCTAssertEqual("attachment_file_0", remoteFile.localPath)
        
        remoteFile = rfiles[1]
        XCTAssertEqual(1, remoteFile.index)
        XCTAssertEqual("attachment_file_1", remoteFile.localPath)

        remoteFile = rfiles[2]
        XCTAssertEqual(2, remoteFile.index)
        XCTAssertEqual("attachment_file_2", remoteFile.localPath)

        remoteFile = rfiles[3]
        XCTAssertEqual(3, remoteFile.index)
        XCTAssertEqual("attachment_file_3", remoteFile.localPath)

        remoteFile = rfiles[4]
        XCTAssertEqual(4, remoteFile.index)
        XCTAssertEqual("attachment_file_4", remoteFile.localPath)
    }

    func testRemoteFileDefaultsToNotNeedRemotVerification() {
        // given
        let attachment = createAttachment(managedObjectContext)
        
        // when
        let rfiles = attachment.remoteFiles!
        
        // then
        let remoteFile = rfiles.first!
        XCTAssertFalse(RemoteFile.markedForRemoteVerificationPredicate.evaluateWithObject(remoteFile))
    }
    
    func testRemoteFileNeedRemotVerificationAfterSettingRemotePath() {
        // given
        let attachment = createAttachment(managedObjectContext)
        
        // when
        let rfiles = attachment.remoteFilesAscending
        let remoteFile = rfiles.first!
        managedObjectContext.performChanges {
            remoteFile.remotePath = "attachment_file_0_IN DA CLOUD!!!"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(RemoteFile.markedForRemoteVerificationPredicate.evaluateWithObject(remoteFile))
    }

    func testRemoteFileGoesbackToNotNeedRemotVerification() {
        // given
        let attachment = createAttachment(managedObjectContext)
        
        // when
        let rfiles = attachment.remoteFilesAscending
        let remoteFile = rfiles.first!
        managedObjectContext.performChanges {
            remoteFile.remotePath = "attachment_file_0_IN DA CLOUD!!!"
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        XCTAssertTrue(RemoteFile.markedForRemoteVerificationPredicate.evaluateWithObject(remoteFile))
        
        managedObjectContext.performChanges {
            remoteFile.unMarkForNeedsRemoteVerification()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(RemoteFile.markedForRemoteVerificationPredicate.evaluateWithObject(remoteFile))
    }

    
}
