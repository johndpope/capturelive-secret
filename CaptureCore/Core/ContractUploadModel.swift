//
//  S3ContratAttachmentUploaderModel.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import AWSCore
import CaptureModel
import CoreDataHelpers

private let MIMETYPE = "mp4"
public class ContractUploadModel:NSObject, CMS3CyclingUploaderModelProtocol {
    
    public var identifier:String {
        get {
            return "\(CMS3SessionUpload.CMS3SessionIdentifier).\(contract.urlHash))"
        }
    }
    
    public let contract:Contract!
    public let moc:NSManagedObjectContext!
    private var uploadingAttachment:Attachment?
    private var uploadingRemoteFile:RemoteFile?
    private let bundle = NSBundle(forClass:CaptureLiveAlamoFireService.self)
    private var inprogressBytes:UInt64 = 0
    
    public init(contract:Contract, managedObjectContext moc:NSManagedObjectContext) {
        self.contract   = contract
        self.moc        = moc
        super.init()
        
        moc.performChangesAndWait { [unowned self] in
            self.contract.configureSelectedAttachments()
            self.uploadingAttachment = self.contract.nextAttachmentToUpload
            self.uploadingAttachment?.configureUploadedBytes()
            self.uploadingRemoteFile = self.uploadingAttachment?.nextFileToUpload
            self.contract.configureUploadedBytes()
        }
    }

    public var s3FilePath:String {
        guard let ua = uploadingAttachment else { fatalError("Cannot upload a nil Attachment") }
        guard let urf = uploadingRemoteFile else { fatalError("Cannot upload a nil RemoteFile") }
        return "uploads/attachments/\(ua.uuid)/highquality/\(urf.index).\(MIMETYPE)"
    }
   
    public var libraryAlbumName:String? {
        return "Current"
    }
    
    public var nextLocalPath:String? {
        guard let doc = uploadingAttachment?.directory else {
            print("Cannot upload a nil Attachment directory")
            return nil
        }
        guard let file = uploadingAttachment?.nextFileToUpload?.localPath else {
            print("Cannot upload a nil RemoteFile localpath")
            return nil
        }
        return "\(NSFileManager.documents)/\(doc)/\(file)"
    }
    
    public var totalBytes:UInt64 {
        get {
            return contract.totalAttachmentFileBytes
        }
    }
    
    public var totalBytesUploaded:UInt64 {
        get {
            let attUploadedBytes = uploadingAttachment?.uploadedFileBytes ?? 0
            let t = contract.uploadedAttachmentFileBytes + attUploadedBytes + inprogressBytes
            return t
        }
    }
    
    public var s3Key:String {
        get {
            return bundle.s3Key
        }
    }
    
    public var s3Secret:String {
        get {
            return bundle.s3Secret
        }
    }
    
    public var s3Bucket:String {
        get {
            return bundle.s3Bucket
        }
    }
    
    public var s3Region:AWSRegionType {
        get {
            return AWSRegionType.USEast1
        }
    }
    
    public func updateByteValuesWithFileCompletion() {
        //  used to set total bytes uploaded of attachment at start
        moc.performChangesAndWait { [unowned self] in
            self.uploadingAttachment?.configureUploadedBytes()
            self.contract.configureUploadedBytes()
        }
    }
    
    public func updateUploadedByteValues(bytesUploaded: UInt64) {
        inprogressBytes                             = bytesUploaded
    }

    public func end() {
        moc.performChangesAndWait { [unowned self] in
            self.contract.configureUploadedBytes()
        }
    }
    
    public func startFromWake(uploadFinished:() -> (), uploadContinue:() -> ()) {
        guard let reFile = uploadingRemoteFile else {
            print("No remote file to upload, it must all be up there. fix your miss fire")
            return
        }
        inprogressBytes = 0
        
        moc.performChangesAndWait { [unowned self] in
            reFile.remotePath = self.s3FilePath
            self.uploadingAttachment?.configureUploadedBytes()
        }
        
        moc.performChangesAndWait { [unowned self] in
            guard let nextRF = self.uploadingAttachment?.nextFileToUpload else {
                self.uploadingAttachment?.uploaded = true
                guard let nextAtt = self.contract.nextAttachmentToUpload else {
                    uploadFinished()
                    return 
                }
                self.uploadingAttachment = nextAtt
                self.uploadingAttachment?.configureUploadedBytes()

                guard let nextRF = self.uploadingAttachment?.nextFileToUpload else {
                    uploadFinished()
                    return
                }
                self.uploadingRemoteFile = nextRF
                self.contract.configureUploadedBytes()
                uploadContinue()
                return
            }
            
            self.uploadingRemoteFile = nextRF
            self.uploadingAttachment?.configureUploadedBytes()
            uploadContinue()
        }
        
    }
    
}