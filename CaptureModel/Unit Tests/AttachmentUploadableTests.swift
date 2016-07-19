//
//  AttachmentUploadableTests.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import CaptureModel

class AttachmentUploadableTests: XCTestCase {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }
    
    func createAnAttachment(moc:NSManagedObjectContext, numRemoteFiles:UInt)->Attachment {
        var att : Attachment! = nil
        let contract = createContract(acquiredContract, moc:moc)
        moc.performChanges {
            att = createAttachment(contract, numRemoteFiles:numRemoteFiles)
        }
        waitForManagedObjectContextToBeDone(moc)
        return att
    }
    
    func addTotalBytesToRemoteFiles(attachment:Attachment) {
        attachment.managedObjectContext!.performChanges {
            for r in attachment.remoteFiles! {
                r.fileSize = 150
            }
            attachment.totalFileBytes = UInt64(150 * attachment.remoteFiles!.count)
        }
        waitForManagedObjectContextToBeDone(attachment.managedObjectContext!)
    }
    
    func testAttachmentUpdateTheUploadedFileBytesDefaultsZero() {
        // given
        let attachment = createAnAttachment(managedObjectContext, numRemoteFiles:5)
        addTotalBytesToRemoteFiles(attachment)
        
        // when
        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            bytes = attachment.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertEqual(0, bytes)
        XCTAssertEqual(0, attachment.uploadedFileBytes)
        let nextFemoteFile = attachment.nextFileToUpload
        XCTAssertEqual("attachment_file_0", nextFemoteFile!.localPath)
    }
    
    func testAttachmentUpdatesTheUploadedFileBytesToOneRemoteFilesUploadedTotalBytes() {
        // given
        let attachment = createAnAttachment(managedObjectContext, numRemoteFiles:5)
        addTotalBytesToRemoteFiles(attachment)
 
        // when
        let remoteFile = attachment.remoteFilesAscending.first!
        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            remoteFile.remotePath = "remote son"
            bytes = attachment.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertEqual(150, bytes)
        XCTAssertEqual(150, attachment.uploadedFileBytes)
        let nextFemoteFile = attachment.nextFileToUpload
        XCTAssertEqual("attachment_file_1", nextFemoteFile!.localPath)
    }
    
    func testAttachmentUpdatesTheUploadedFileBytesToAllRemoteFilesUploadedTotalBytes() {
        // given
        let numFiles = 5
        let attachment = createAnAttachment(managedObjectContext, numRemoteFiles:UInt(numFiles))
        addTotalBytesToRemoteFiles(attachment)
        
        // when
        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            for r in attachment.remoteFiles! {
                r.remotePath = "remote son"
            }
            bytes = attachment.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertEqual(UInt64(150 * numFiles), bytes)
        XCTAssertEqual(UInt64(150 * numFiles), attachment.uploadedFileBytes)
        let nextFemoteFile = attachment.nextFileToUpload
        XCTAssertNil(nextFemoteFile)
    }
    
    func testAttachmentUpdatesItselfToUploadWhenTotalBytesEqualsUploadedBytes() {
        // given
        let numFiles = 5
        let attachment = createAnAttachment(managedObjectContext, numRemoteFiles:UInt(numFiles))
        addTotalBytesToRemoteFiles(attachment)
        
        // when
        managedObjectContext.performChanges {
            for r in attachment.remoteFiles! {
                r.remotePath = "remote son"
            }
            let _ = attachment.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertTrue(attachment.uploaded)
    }
}
