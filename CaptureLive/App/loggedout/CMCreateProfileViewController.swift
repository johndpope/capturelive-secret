//
//  CMCreateProfileViewController.swift
//  Current
//
//  Created by Scott Jones on 4/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

class CMCreateProfileViewController: UIViewController, SegueHandlerType, RemoteAndLocallyServiceable {

    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CurrentRemoteType!

    private var observer:ManagedObjectObserver?
    var user:User!
    private var didUpdateProfile                    = false

    var tableViewController:CMCreateProfileTableViewController! {
        didSet {
            tableViewController.facebookUser        = self.facebookUser
            tableViewController.updateClosure       = self.updateDoneButton
            tableViewController.doneClosure         = self.doneRequested
            avatarURL                               = self.facebookUser.avatarPath
        }
    }
    
    var theView:CMCreateProfileView {
        return self.view as! CMCreateProfileView
    }
   
    var facebookUser:FacebookUser!
    var avatarURL:String?
    var s3Transfer:CMS3FileTransfer?
    var model:CMAvatarUploaderModel?

    enum SegueIdentifier:String {
        case EmbededTableView                       = "embedProfileTableViewController"
        case WorkReel                               = "goToWorkReel"
        case WorkReelNoAnimate                      = "goToWorkReelNoAnimate"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let saveButtonString                                        = NSLocalizedString("NEXT", comment:"CMRegisterUser : saveButton : text");
        self.theView.saveButton?.setTitle(saveButtonString, forState: UIControlState.Normal)
        
        self.theView.navTitleLabel?.textColor                               = UIColor.blackCurrent()
        self.theView.navTitleLabel?.text                                    = NSLocalizedString("CREATE PROFILE", comment:"CMRegisterUser : navTitleLabel : text")
        self.theView.navTitleLabel?.font                                    = UIFont.comfortaa(.Regular, size: .NavigationTitle)
        
        theView.didLoad()
        theView.stopActivityIndicator()
       
        if self.user.isAttemptingLogin {
            theView.showForAttemptingLogin()
            hasEnoughToGetPastCreateProfile(self) { [unowned self] in
                self.performSegue(.WorkReelNoAnimate)
                return
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
//        self.showReachiblity()
        
        if User.hasValidationErrorPredicate.evaluateWithObject(self.user) {
            self.theView.profileUpdate(self.user.validationError!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateProfilePic()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
        observer = nil
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
   
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        self.theView.saveButton?.enabled                                    = true
        self.theView.saveButton?.addTarget(self.tableViewController, action: #selector(CMCreateProfileTableViewController.attemptToSucceed), forControlEvents: .TouchUpInside)
        self.theView.backButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        
        tableViewController.avatarButton?.addTarget(self, action: #selector(changeAvatar), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.saveButton?.enabled                                    = false
        self.theView.saveButton?.removeTarget(self.tableViewController, action: #selector(CMCreateProfileTableViewController.attemptToSucceed), forControlEvents: .TouchUpInside)
        self.theView.backButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        tableViewController.avatarButton?.removeTarget(self, action: #selector(changeAvatar), forControlEvents: .TouchUpInside)
    }
    
    // MARK: button handlers
    func goBack() {
        CMImageCache.defaultCache().removeCachedFile(self.avatarURL)
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.managedObjectContext.preventScreenByPass()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func updateDoneButton(shouldEnable:Bool) {
        self.theView.saveButton?.enabled = shouldEnable
    }
   
    func doneRequested(error:NSError?) {
        if let e = error {
            self.theView.profileUpdateError(e)
            return
        }
        
        if self.didUpdateProfile == true {
            startS3Upload()
        } else {
            saveUserProfile()
        }
    }
    
    func saveUserProfile() {
        self.removeEventHandlers()
        self.theView.startActivityIndicator()
       
        observer = ManagedObjectObserver(object:user) { [unowned self] type in
            guard type == .Update else {
                return
            }
            self.updateResponse()
        }
        self.managedObjectContext.performChanges { [unowned self] in
            // done here because of automatic observer response, I GKNOW PATHERTIC
            self.user.validationError         = nil
            self.user.needsRemoteVerification = true
            
            self.user.firstName               = self.tableViewController.firstNameField!.text!
            self.user.lastName                = self.tableViewController.lastNameField!.text!
            self.user.email                   = self.tableViewController.emailField!.text!
            self.user.remoteAvatarUrl         = self.avatarURL
            guard let token = self.facebookUser.token else { fatalError("No facebook token") }
            self.user.facebookAuthToken       = token
            self.user.facebookProfileUrl      = self.facebookUser.profileUrl
            self.user.ageRangeMin             = self.facebookUser.ageRangeMin
        }
    }
    
    func updateResponse() {
        if User.hasValidationErrorPredicate.evaluateWithObject(self.user){
            print("DO NOT PROCEEED EVEN!!!!!!!!!!")
            self.theView.profileUpdate(self.user.validationError!)
            self.addEventHandlers()
            theView.stopActivityIndicator()
            return
        }
        
        if User.notMarkedForRemoteVerificationPredicate.evaluateWithObject(self.user)
        && User.facebookTokenNotNilPredicate.evaluateWithObject(self.user) {
            print("PROCEEED EVEN!!!!!!!!!!")
            theView.stopActivityIndicator()
            if user.isAttemptingLogin {
                userCreateSuccess()
            } else {
                goBack()
            }
        }
    }
    
    func userCreateSuccess() {
        self.performSegue(.WorkReel)
    }

    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .EmbededTableView:
            guard let vc                                    = segue.destinationViewController as? CMCreateProfileTableViewController else { fatalError("DesinationViewController does not conform to RemoteAndLocallyServiceable") }
            vc.facebookUser = self.facebookUser
            self.tableViewController = vc
        default:
            guard let vc                                    = segue.destinationViewController as? CMReelViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
            vc.managedObjectContext                         = managedObjectContext
            vc.remoteService                                = remoteService
            vc.user                                         = user
        }
    }
    
    override func segueForUnwindingToViewController(toViewController:UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue? {
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
    }
    
    @IBAction func unwindToUserRegistration(sender:UIStoryboardSegue) {
        
    }
   
    
    
    
    // MARK: Change avatar
    func changeAvatar() {
        tableViewController.clearKeyboard()
        let message                                 = NSLocalizedString( "Choose Option", comment: "CMRegisterUserDescriptionViewController : avatarActionSheet : message")
        let alertView                               = CMActionSheetController(message: message)
        
        let takePictureButton                       = NSLocalizedString( "Take photo now", comment: "CMRegisterUserDescriptionViewController : avatarActionSheet : takePictureButtonText")
        let takeAction = CMAlertAction(title:takePictureButton, style: .Primary) { [unowned self]  in
            self.didUpdateProfile                   = true
            let takeAvatarViewController            = CMTakeAvatarViewController(nibName:"CMTakeAvatarViewController", bundle: nil)
            let avNav                               = CMAvatarNavigationController()
            avNav.viewControllers                   = [takeAvatarViewController]
            avNav.avatarDelegate                    = self
            self.presentViewController(avNav, animated: true, completion: nil)
        }
        
        let fromLibraryButton                       = NSLocalizedString( "Choose from library", comment: "CMCreateProfileViewController : avatarActionSheet : fromLibraryButtonText")
        let libraryAction = CMAlertAction(title:fromLibraryButton, style: .Primary) { [unowned self]  in
            self.didUpdateProfile                   = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
                let imagePickerController           = UIImagePickerController()
                imagePickerController.sourceType    = UIImagePickerControllerSourceType.PhotoLibrary
                imagePickerController.delegate      = self
                
                self.presentViewController(imagePickerController, animated:true) { () in
                    
                }
            }
        }
       
        let cancelButton                            = NSLocalizedString( "Cancel", comment: "CMCreateProfileViewController : avatarActionSheet : cancelButtonText")
        let cancelAction = CMAlertAction(title:cancelButton, style: .Secondary) { [unowned self]  in
            self.didUpdateProfile                   = false
        }
        alertView.addAction(cancelAction)
        if self.didUpdateProfile == true && user.isAttemptingLogin {
            let resetFacebookImageText              = NSLocalizedString( "Reset Facebook Avatar", comment: "CMCreateProfileViewController : avatarActionSheet : resetFacebookAvatar")
            let resetActionAction = CMAlertAction(title:resetFacebookImageText, style: .Secondary) { [unowned self] in
                self.didUpdateProfile               = false
                self.avatarURL                      = self.facebookUser.avatarPath
                self.updateProfilePic()
            }
            alertView.addAction(resetActionAction)
        }
        
        alertView.addAction(libraryAction)
        alertView.addAction(takeAction)
        
        CMAlert.presentViewController(alertView)
    }

    func updateProfilePic() {
        if self.didUpdateProfile == true {
            guard let image = NSFileManager.defaultManager().getCroppedImage() else { return }
            tableViewController.updateProfileImage(image)
        } else {
            guard let url = facebookUser.avatarPath else { return }
            tableViewController.updateProfileUrl(url)
        }
    }

    // MARK: CMS3FileTransferDelegate
    func startS3Upload() {
        self.removeEventHandlers()
        self.theView.startActivityIndicator()
        
        let m                                       = CMAvatarUploaderModel()
        let key                                     = m.s3Key
        let secret                                  = m.s3Secret
        let bucket                                  = m.s3Bucket
        let region                                  = m.s3Region
        self.s3Transfer                             = CMS3FileTransfer(key:key, secret:secret, bucket:bucket, region:region)
        self.s3Transfer?.delegate                   = self
        self.s3Transfer?.start(m.avatarPath, s3Path:m.s3FilePath)
    }

}

extension CMCreateProfileViewController : CMAvatarNavigationDelegate {
    
    func dismiss(didSuccessFullyChangeAvatar:Bool) {
        self.didUpdateProfile                       = didSuccessFullyChangeAvatar
        self.updateProfilePic()
    }
    
}

extension CMCreateProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: UIImagePicker
    func imagePickerController(picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        let image:UIImage?                          = info[UIImagePickerControllerOriginalImage] as? UIImage
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            NSFileManager.defaultManager().saveRawImage(UIImageJPEGRepresentation(image!, 1.0)!)
            dispatch_async(dispatch_get_main_queue(), {
                let cropController                  = CMCropAvatarViewController(nibName:"CMCropAvatarViewController", bundle: nil)
                
                let avNav                           = CMAvatarNavigationController()
                avNav.viewControllers               = [cropController]
                avNav.avatarDelegate                = self
                self.dismissViewControllerAnimated(false, completion:{
                    self.presentViewController(avNav, animated:false) { () in
                        
                    }
                })
                
            })
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.didUpdateProfile                       = false
        self.dismissViewControllerAnimated(true, completion:{
            
        })
    }

}


extension CMCreateProfileViewController : CMS3Delegate {

    func completedUpload(path:String, index:Int) {
        self.avatarURL                              = path
        self.saveUserProfile()
        self.s3Transfer?.delegate                   = nil
        self.s3Transfer                             = nil
    }
    
    func failedUpload(error: NSError) {
        self.addEventHandlers()
        self.theView.stopActivityIndicator()
        self.theView.profileUpdateError(error)
    }

    func startedUpload() {}
    func pausedUpload() {}
    func resumedUpload() {}
    func cancelledUpload() {}
    func completedUpload() {}
    func progress(bytesUploaded:UInt64, bytesTotal:UInt64) {}
}


