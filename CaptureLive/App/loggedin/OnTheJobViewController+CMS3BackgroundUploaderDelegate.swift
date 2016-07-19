//
//  OnTheJobViewController+UploaderDelegate.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureCore

extension OnTheJobViewController : CMS3BackgroundUploaderDelegate {
    
    // MARK : Controls
    func configureUploader() {
        uploaderModel                       = ContractUploadModel(contract:contract, managedObjectContext:managedObjectContext)
        backgroundUploader.setup(uploaderModel)
        backgroundUploader.delegate         = self

        managedObjectContext.performChangesAndWait{ [unowned self] in
            self.contract.hasStartedUpload  = true
        }
        repopulateView()
    }
  
    func removePauseButtonHandlers() {
        theView.directionsModuleView?.footageView?.pauseButton?.removeTarget(self, action: #selector(pause), forControlEvents: .TouchUpInside)
        theView.directionsModuleView?.footageView?.pauseButton?.removeTarget(self, action: #selector(resume), forControlEvents: .TouchUpInside)
    }
    
    func addPauseHandler() {
        removePauseButtonHandlers()
        theView.directionsModuleView?.footageView?.pauseButton?.addTarget(self, action: #selector(pause), forControlEvents: .TouchUpInside)
        theView.pauseUploading()
    }
    
    func addResumeHandler() {
        removePauseButtonHandlers()
        theView.directionsModuleView?.footageView?.pauseButton?.addTarget(self, action: #selector(resume), forControlEvents: .TouchUpInside)
        theView.resumeUploading()
    }
    
    func showUploadCancelAlert() {
        guard let publisher = contract.publisher else { fatalError("There is no publisher for contract \(contract)") }
        
        let message                 = NSLocalizedString("Sure you want to cancel", comment:"CMUploadingContract : cancelAlert : alertMessage")
        let paymentString           = contract.paymentAmountString() ?? ""
        let messageString           = String(NSString(format: message, publisher.firstName, paymentString))
        let title                   = NSLocalizedString("Cancel?", comment:"CMUploadingContract : cancelAlert : alertTitle")
        let alertViewController     = CMAlertController(title:title, message:messageString)
        
        let cancelTitle             = NSLocalizedString("YES", comment:"CMUploadingContract : cancelAlert : cancekTitle")
        let cancelAction = CMAlertAction(title:cancelTitle, style: .Primary) { () -> () in
            self.cancel()
        }
        let resumeTitle             = NSLocalizedString("NO", comment:"CMUploadingContract : cancelAlert : resumeTitle")
        let resumeAction = CMAlertAction(title:resumeTitle, style: .Primary) { () -> () in
            self.resume()
        }
        alertViewController.addAction(resumeAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
        
        pause()
    }
    
    func start() {
        removeEventHandlers()
        theView.startActivityIndicator()
        
        backgroundUploader.start({ [weak self] object in
            self?.theView.stopActivityIndicator()
            self?.addEventHandlers()
            self?.addPauseHandler()
 
            }, failure: { [weak self] error in
                print("start Error:  \(error.localizedDescription)")
                self?.theView.stopActivityIndicator()
                let title                           = NSLocalizedString("Ooops. Check your network conection", comment:"CMUploadUserEmailUpdateError : startRequestFailure : alertTitle")
                self?.couldNotFullfileRequest(title, complete: {
                    self?.addEventHandlers()
                    self?.addPauseHandler()
                })
        })
    }
    
    func pause() {
        removeEventHandlers()
        theView.startActivityIndicator()
    
        backgroundUploader.pause({ [weak self] object in
            self?.theView.stopActivityIndicator()
            self?.addEventHandlers()
            self?.addResumeHandler()
 
            }, failure: { (error:NSError!) -> Void in
                print("remoteNofityPaused Error:  \(error.localizedDescription)")
                self.theView.stopActivityIndicator()
                let title                           = NSLocalizedString("Ooops. Check your network connection", comment:"CMUploadUserEmailUpdateError : pauseRequestFailure : alertTitle")
                self.couldNotFullfileRequest(title, complete: { [weak self] in
                    self?.addEventHandlers()
                    self?.addResumeHandler()
                })
        })
    }
    
    func resume() {
        removeEventHandlers()
        theView.startActivityIndicator()

        backgroundUploader.resume({ [weak self] (contract:AnyObject?) in
            self?.theView.stopActivityIndicator()
            self?.addEventHandlers()
            self?.addPauseHandler()
            
            }, failure: { [weak self] (error:NSError) in
                print("remoteNofityResume Error:  \(error.localizedDescription)")
                self?.theView.stopActivityIndicator()
                let title                           = NSLocalizedString("Ooops. Check your network conection", comment:"CMUploadUserEmailUpdateError : resumeRequestFailure : alertTitle")
                self?.couldNotFullfileRequest(title, complete: { [weak self] in
                    self?.addEventHandlers()
                    self?.addPauseHandler()
                })
                
        })
    }
   
    internal func cancel() {
        removePauseButtonHandlers()
        removeEventHandlers()
        theView.startActivityIndicator()
        
        self.backgroundUploader.cancel({ [weak self] (contract:AnyObject?) in
            self?.theView.stopActivityIndicator()
            self?.addEventHandlers()
            self?.navigationController?.popViewControllerAnimated(true)
            
            }, failure: { [weak self] (error:NSError) in
                print("remoteNofityCancelled Error:  \(error.localizedDescription)")
                self?.theView.stopActivityIndicator()
                let title                           = NSLocalizedString("Ooops. Check your network conection", comment:"CMUploadUserEmailUpdateError : cancelRequestFailure : alertTitle")
                self?.couldNotFullfileRequest(title, complete: { () -> () in
                    self?.addEventHandlers()
                })
                
        })
    }
    
    func couldNotFullfileRequest(reason:String, complete:Completed) {
        let buttonTitle             = NSLocalizedString("Ok", comment:"CMUploadScreen : couldNotFullfileRequest : alertOkButton")
        let alertViewController     = CMAlertController(title:reason)
        let action                  = CMAlertAction(title:buttonTitle, style: .Primary, handler:complete)
        alertViewController.addAction(action)
        CMAlert.presentViewController(alertViewController)
    }
    
    //MARK : Delegate
    func percentUploaded(percent: Float) {
        let totalVideos = contract.numberOfUploadedAttachments + contract.numberOfUnuploadedAttachments
        theView.showUploadingVideos(Int(contract.numberOfUploadedAttachments + 1), totalNumVideos: Int(totalVideos), progress:CGFloat(percent))
    }
    
    func completedUpload(path: String, index: Int, complete: CaptureCore.S3UploadComplete) {
    
    }
    
    func allFilesCompletedUpload() {
        print("allFilesCompletedUpload FORGROUND !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        allFilesCompletedUploadFromBackground {}
    }
    
    func allFilesCompletedUploadFromBackground(complete:Completed) {
        print("allFilesCompletedUpload BACKGROUND !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        self.backgroundUploader.untie()
        self.backgroundUploader.end()
       
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.contract.hasStartedUpload  = false
            self.contract.resolutionStatus = .Completed
            self.contract.markForNeedsRemoteVerification()
        }
        complete()
    }

    func errorSavingToLibrary() {
        print("There was a error saving to the library")
    }

    func failedUpload(error: NSError) {
        print("Failed upload error : \(error.localizedDescription)")
        self.theView.stopActivityIndicator()
        let title                           = NSLocalizedString("Ooops. Check your network conection", comment:"CMUploadUserEmailUpdateError : cancelRequestFailure : alertTitle")
        self.couldNotFullfileRequest(title, complete: { () -> () in
            
        })
    }

}