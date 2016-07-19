//
//  CMS3CyclingUploader.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 6/11/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import Foundation
import AssetsLibrary

enum CMS3CyclingUploaderErrorCode : Int {
    case NoFilesToUpload;
}

public class CMS3CyclingUploader: NSObject, CMS3Delegate, CMS3CyclingUploaderProtocol {
    
    static let Domain                           = "com.capturemedia.upload.cyclinguploader"
    
    var currentFilePath:String?
    var index:Int                               = 0
    public var delegate:CMS3CyclingUploaderDelegate?
    internal var s3Protocol:CMS3Protocol!
    internal var model:CMS3CyclingUploaderModelProtocol!
   
    public func untie() {
        self.delegate                           = nil
    }
    
    func setup(model:CMS3CyclingUploaderModelProtocol) {
        self.model                              = model
        self.s3Protocol                         = self.createS3Protocol()
    }
    
    public func startFromWake(complete:WakeCompletion) {
        self.model.updateByteValuesWithFileCompletion()
        self.model.startFromWake({ () -> () in
            self.untie()
            complete(isTotallyFinished:true)
        }, uploadContinue: { () -> () in
            self.start()
            complete(isTotallyFinished:false)
        })
    }
    
    public func end() {
        self.s3Protocol.end()
        self.model.end()
    }

    public func start() {
        updateAndUpload()
    }
    
    public func pause() {
        if let st = self.s3Protocol {
            st.pause()
        }
    }
    
    public func resume() {
        if let st = self.s3Protocol {
            st.resume()
        }
    }
    
    public func cancel() {
        if let st = self.s3Protocol {
            self.currentFilePath                = nil
            st.cancel()
        }
    }
   
    internal func updateAndUpload() {
        // delete current file
        self.deleteFile()
//        self.s3Protocol.delegate                = nil
 
        // get next file path
        if let filePath = self.model.nextLocalPath {
            // update stream.uploadedFileBytes to self.cBytesUploaded
            self.model.updateByteValuesWithFileCompletion()
            
            self.currentFilePath                = filePath;
            
            // start next upload
            self.s3Protocol.delegate            = self
            self.s3Protocol.start(filePath, s3Path:self.model.s3FilePath)
            print("CMS3CyclingUploader SAYS:  KEEPT GOING")
        } else {
            // update stream.uploadedFileBytes to self.model.totalBytes
            self.model.updateByteValuesWithFileCompletion()
            
            self.currentFilePath                = nil
            // not an error, theres not more files, so done
            
            print("CMS3CyclingUploader SAYS: SAYS END")

            toMainQueue({ () -> Void in
                if let d = self.delegate {
                    d.allFilesCompletedUpload()
                }
            })
        }
    }
    
    internal func deleteFile() {
        if let cp = self.currentFilePath {
            print("DELETE FILE : \(cp)")
            do {
                try NSFileManager.defaultManager().removeItemAtPath(cp)
            } catch _ {
            }
        }
    }
    
    public func createS3Protocol()->CMS3Protocol {
        fatalError("createS3Protocol()->CMS3Protocol has not been implemented")
    }
    
    // MARK: CMS3FileTransferDelegate
    public func startedUpload() {
        toMainQueue({ () -> Void in
            self.delegate?.startedUpload()
        })
    }
    
    public func progress(bytesUploaded: UInt64, bytesTotal: UInt64) {
        self.model.updateUploadedByteValues(bytesUploaded)
        // send to delegate a float  0.0 - 1.0
        let progress                            = Float(self.model.totalBytesUploaded) / Float(self.model.totalBytes)
        toMainQueue({ () -> Void in
            self.delegate?.percentUploaded(progress)
        })
    }
    
    public func pausedUpload() {
        toMainQueue({ () -> Void in
            self.delegate?.pausedUpload()
        })
    }
    
    public func resumedUpload() {
        toMainQueue({ () -> Void in
            self.delegate?.resumedUpload()
        })
    }
    
    public func cancelledUpload() {
        self.currentFilePath                = nil
        toMainQueue({ () -> Void in
                self.delegate?.cancelledUpload()
        })
    }
    public func completedUpload(path:String, index:Int) {}
    public func completedUpload() {
        let i = self.index
        let s3path = self.model.s3FilePath
        let finished:S3UploadComplete = {
            self.toMainQueue({ () -> Void in
                self.delegate?.completedUpload(s3path, index:i, complete:{ () -> () in
                })
            })
        }
        
//        if let albumName = self.model.libraryAlbumName {
//            if let _ = self.currentFilePath {
//                let assetLib                = ALAssetsLibrary()
//                assetLib.saveVideoUrl(NSURL(fileURLWithPath:self.currentFilePath!), toAlbum:albumName) { (asset:ALAsset!, error:NSError!) in
//                    if error != nil {
//                        print("saving video to library failed : [\(error)]")
//                    }
//                    finished()
//                }
//                return
//            }
//        }
        finished()
    }
    
    public func failedUpload(error: NSError) {
        self.currentFilePath                = nil
        toMainQueue({ () -> Void in
            self.delegate?.failedUpload(error)
        })
    }
    
    func toMainQueue(complete:()->()) {
        if NSThread.isMainThread() {
            complete()
        } else {
            dispatch_async(dispatch_get_main_queue(), complete)
        }
    }
    
}
