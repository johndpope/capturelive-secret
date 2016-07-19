//
//  ContractUploaderModelTests.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import XCTest
import CoreData
import CaptureModel
import CoreDataHelpers
@testable import CaptureCore

private let oneFileSize:UInt64 = 1024 * 1024 * 1024
private let numAttachments:UInt64 = 2
private let numFilesForEachAttachment:UInt64 = 3
private let contractTotalBytes = numAttachments * numFilesForEachAttachment * oneFileSize

class ContractUploaderModelTests: XCTestCase {

    var managedObjectContext:NSManagedObjectContext!
    var contract:Contract!
    var docDir :String!
    
    override func setUp() {
        managedObjectContext    = NSManagedObjectContext.currentInMemoryContext()
       
        docDir = NSFileManager.documents

        contract = createContractWithAttachments(managedObjectContext, numAttachments:UInt(numAttachments), numFilesForAttachments: UInt(numFilesForEachAttachment))
        addTotalBytesToContract(contract)
        super.setUp()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        super.tearDown()
    }
    
    func addTotalBytesToContract(contract:Contract) {
        managedObjectContext.performChanges {
            for a in contract.attachments! {
                var total:UInt64 = 0
                for r in a.remoteFiles! {
                    r.fileSize = oneFileSize
                    total += oneFileSize
                }
                a.totalFileBytes = total
            }
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func addRemotePathToAttachment(attachment:Attachment) {
        managedObjectContext.performChanges {
            for r in attachment.remoteFiles! {
                r.remotePath = "remote son"
            }
        }
        waitForManagedObjectContextToBeDone(managedObjectContext)
    }
    
    func startFromWake(contractUploadModel:ContractUploadModel, numTimes:Int)->(shouldFinish:Bool, shouldContinue:Bool) {
        var shouldFinish    = false
        var shouldContinue  = false
        for _ in 0..<numTimes {
            contractUploadModel.startFromWake({
                shouldFinish = true
                shouldContinue = false
            }) {
                shouldFinish = false
                shouldContinue = true
            }
        }
        return (shouldFinish:shouldFinish, shouldContinue:shouldContinue)
    }
    
    func fileName(path:String?)->String? {
        guard let p = path else { return nil }
        let absString               =  (p as NSString)
        return String(absString.pathComponents.last!)
    }
    
    func testStartFromWakeIsContinuedWithFirstCall() {
        // given
        let contractUploadModel = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        waitForManagedObjectContextToBeDone(managedObjectContext)
        XCTAssertEqual("attachment_0_file_0", fileName(contractUploadModel.nextLocalPath))
 
        // when
        let numtimes = 1
        let result = startFromWake(contractUploadModel, numTimes:numtimes)
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(result.shouldFinish)
        XCTAssertTrue(result.shouldContinue)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytes)
        XCTAssertEqual(oneFileSize * UInt64(numtimes), contractUploadModel.totalBytesUploaded)
        

        XCTAssertEqual("attachment_0_file_1", fileName(contractUploadModel.nextLocalPath))
    }
    
    func testStartFromWakeIsContinuedWithSecondCall() {
        // given
        let contractUploadModel = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        addTotalBytesToContract(contract)
        
        // when
        let numtimes = 2
        let result = startFromWake(contractUploadModel, numTimes:numtimes)
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(result.shouldFinish)
        XCTAssertTrue(result.shouldContinue)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytes)
        XCTAssertEqual(oneFileSize * UInt64(numtimes), contractUploadModel.totalBytesUploaded)
        XCTAssertEqual("attachment_0_file_2", fileName(contractUploadModel.nextLocalPath))
    }

    func testStartFromWakeIsContinuedWithThirdCall() {
        // given
        let contractUploadModel = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        addTotalBytesToContract(contract)
        
        // when
        let numtimes = 3
        let result = startFromWake(contractUploadModel, numTimes:numtimes)
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(result.shouldFinish)
        XCTAssertTrue(result.shouldContinue)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytes)
        XCTAssertEqual(oneFileSize * UInt64(numtimes), contractUploadModel.totalBytesUploaded)
        XCTAssertEqual("attachment_1_file_0", fileName(contractUploadModel.nextLocalPath))
    }
    
    func testStartFromWakeIsContinuedWithFourthCall() {
        // given
        let contractUploadModel = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        addTotalBytesToContract(contract)
        
        // when
        let numtimes = 4
        let result = startFromWake(contractUploadModel, numTimes:numtimes)
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(result.shouldFinish)
        XCTAssertTrue(result.shouldContinue)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytes)
        XCTAssertEqual(oneFileSize * UInt64(numtimes), contractUploadModel.totalBytesUploaded)
        XCTAssertEqual("attachment_1_file_1", fileName(contractUploadModel.nextLocalPath))
    }

    func testStartFromWakeIsContinuedWithFifthCall() {
        // given
        let contractUploadModel = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        addTotalBytesToContract(contract)
        
        // when
        let numtimes = 5
        let result = startFromWake(contractUploadModel, numTimes:numtimes)
        waitForManagedObjectContextToBeDone(managedObjectContext)
        
        // then
        XCTAssertFalse(result.shouldFinish)
        XCTAssertTrue(result.shouldContinue)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytes)
        XCTAssertEqual(oneFileSize * UInt64(numtimes), contractUploadModel.totalBytesUploaded)
        XCTAssertEqual("attachment_1_file_2", fileName(contractUploadModel.nextLocalPath))

    }

    func testStartFromWakeIsFinishedWithLastFileAndAttachmentCall() {
        // given
        let contractUploadModel = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        addTotalBytesToContract(contract)
        
        // when
        let result = startFromWake(contractUploadModel, numTimes:Int(numAttachments * numFilesForEachAttachment))
 
        // then
        XCTAssertTrue(result.shouldFinish)
        XCTAssertFalse(result.shouldContinue)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytes)
        XCTAssertEqual(contractTotalBytes, contractUploadModel.totalBytesUploaded)
        XCTAssertNil(contractUploadModel.nextLocalPath)
    }
    

}
