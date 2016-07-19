//
//  ContractUploadableTests.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CoreLocation
@testable import CaptureModel

class ContractUploadableTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
    }
    
    override func tearDown() {
        managedObjectContext    = nil
        super.tearDown()
    }

    func addTotalBytesToContract(contract:Contract) {
        contract.managedObjectContext!.performChanges {
            for a in contract.attachments! {
                a.totalFileBytes = UInt64(a.remoteFiles!.count * 150)
            }
        }
        waitForManagedObjectContextToBeDone(contract.managedObjectContext!)
    }
    
    func addRemotePathToAttachment(attachment:Attachment) {
        for r in attachment.remoteFiles! {
            r.fileSize = 150
            r.remotePath = "remote son"
        }
        attachment.configureUploadedBytes()
    }
    
    func testContractDefaultsToUploadedByteZero() {
        // given
        let contract = createContractWithAttachments(managedObjectContext, numAttachments:5, numRemoteFiles:5)
        addTotalBytesToContract(contract)
        
        // when
        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            let _ = contract.configureSelectedAttachments()
            bytes = contract.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertEqual(0, bytes)
        XCTAssertEqual(0, contract.uploadedAttachmentFileBytes)
        XCTAssertEqual(5, contract.uploadableAttachments.count)
    }

    func testContactUpdatesTheUploadedFileBytesToOneAttachmentsUploadedTotalBytes() {
        // given
        let contract = createContractWithAttachments(managedObjectContext, numAttachments:5, numRemoteFiles:5)
        addTotalBytesToContract(contract)
        var totalbytes:UInt64 = 0
        managedObjectContext.performChanges {
            totalbytes = contract.configureSelectedAttachments()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
 
        // when
        let attachment = contract.selectedAttachments.first!
        addRemotePathToAttachment(attachment)

        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            attachment.configureUploadedBytes()
            bytes = contract.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        
        let expectedUploaded:UInt64 = 150 * 5   // one attachment
        let expectTotal:UInt64 = (150 * 5) * 5  // all five attachments
        XCTAssertEqual(expectTotal, totalbytes)
        XCTAssertEqual(expectTotal, contract.totalAttachmentFileBytes)
        XCTAssertEqual(expectedUploaded, bytes)
        XCTAssertEqual(expectedUploaded, contract.uploadedAttachmentFileBytes)

        XCTAssertNotNil(contract.nextAttachmentToUpload)
    }
   
    func testContactUpdatesTheUploadedFileBytesTo3AttachmentsUploadedTotalBytes() {
        // given
        let contract = createContractWithAttachments(managedObjectContext, numAttachments:5, numRemoteFiles:5)
        addTotalBytesToContract(contract)
        var totalbytes:UInt64 = 0
        managedObjectContext.performChanges {
            totalbytes = contract.configureSelectedAttachments()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        
        // when
        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            for i in 0..<3 {
                let attachment = contract.selectedAttachments[i]
                self.addRemotePathToAttachment(attachment)
            }
            bytes = contract.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let expectedUploaded:UInt64 = (150 * 5) * 3 // three attachments
        let expectTotal:UInt64 = (150 * 5) * 5
        XCTAssertEqual(expectTotal, totalbytes)
        XCTAssertEqual(expectTotal, contract.totalAttachmentFileBytes)
        XCTAssertEqual(expectedUploaded, bytes)
        XCTAssertEqual(expectedUploaded, contract.uploadedAttachmentFileBytes)

        XCTAssertNotNil(contract.nextAttachmentToUpload)
    }

    func testContactUpdatesTheUploadedFileBytesToAllAttachmentsUploadedTotalBytes() {
        // given
        let contract = createContractWithAttachments(managedObjectContext, numAttachments:5, numRemoteFiles:5)
        addTotalBytesToContract(contract)
        var totalbytes:UInt64 = 0
        managedObjectContext.performChanges {
            totalbytes = contract.configureSelectedAttachments()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        
        // when
        var bytes:UInt64 = 0
        managedObjectContext.performChanges {
            for a in contract.selectedAttachments {
                self.addRemotePathToAttachment(a)
            }
            bytes = contract.configureUploadedBytes()
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        let expectedUploaded:UInt64 = (150 * 5) * 5 // three attachments
        let expectTotal:UInt64 = (150 * 5) * 5
        XCTAssertEqual(expectTotal, totalbytes)
        XCTAssertEqual(expectTotal, contract.totalAttachmentFileBytes)
        XCTAssertEqual(expectedUploaded, bytes)
        XCTAssertEqual(expectedUploaded, contract.uploadedAttachmentFileBytes)

        XCTAssertNil(contract.nextAttachmentToUpload)
    }

}
