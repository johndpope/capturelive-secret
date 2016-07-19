//
//  ReelViewController.swift
//  Current
//
//  Created by Scott Jones on 4/12/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CoreData
import CaptureModel
import CaptureCore
import CaptureSync
import CoreDataHelpers

class CMReelViewController: UIViewController, SegueHandlerType, RemoteAndLocallyServiceable {
   
    enum SegueIdentifier:String {
        case Equipment                  = "gotoEquipment"
        case EquipmentNoAnimate         = "gotoEquipmentNoAnimate"
    }
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CurrentRemoteType!
    
    private var observer:ManagedObjectObserver?
    var user:User!
    var theView:CMReelView {
        guard let v = self.view as? CMReelView else { fatalError("Not a CMReelView!") }
        return v
    }
    
    private var exampleDataSource : ExampleReelTableViewSource!
    private var reelDataSource : ReelTableViewSource!
    private var currentReelSource:ReelSource! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        exampleDataSource               = ExampleReelTableViewSource(tableView: theView.exampleReelTableView!, reelDelegate:self)
        reelDataSource                  = ReelTableViewSource(tableView: theView.reelTableView!, reelDelegate:self)

        theView.didLoad()
        if self.user.isAttemptingLogin {
            theView.showForAttemptingLogin()
            hasEnoughToGetPastReelCreation(self) { [unowned self] in
                self.performSegue(.EquipmentNoAnimate)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventHandlers()
        
        reelDataSource.replaceReel(user.workReel)
        exampleDataSource.minusReels(user.workReel.map { $0.source })
        tryToEnableNextButton()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
        observer = nil
    }
    
    func addEventHandlers() {
        theView.nextButton?.addTarget(self, action: #selector(CMReelViewController.nextButtonHit), forControlEvents:.TouchUpInside)
        theView.backButton?.addTarget(self, action: #selector(CMReelViewController.goBack), forControlEvents: .TouchUpInside)
        let nc                              = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector:#selector(CMReelViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification,   object:nil)
        nc.addObserver(self, selector:#selector(CMReelViewController.keyboardDidHide(_:)), name:UIKeyboardWillHideNotification,   object:nil)
    }
    
    func removeEventHandlers() {
        theView.nextButton?.removeTarget(self, action: #selector(CMReelViewController.nextButtonHit), forControlEvents:.TouchUpInside)
        theView.backButton?.removeTarget(self, action: #selector(CMReelViewController.goBack), forControlEvents: .TouchUpInside)

        let nc                              = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name:UIKeyboardWillShowNotification, object:nil)
        nc.removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? CMEquipmentViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
        vc.user                                         = user
    }
   
    func userCreateEquipmentProfile() {
        performSegue(.Equipment)
    }
    
    //MARK: Events
    func keyboardWillShow(notification:NSNotification) {
        let keyboardValues = UIView.keyboardNotificationValues(notification)
        theView.adjustTableHeightForKeyboard(CGFloat(keyboardValues.height))
    }
   
    func keyboardDidHide(_:NSNotification) {
        theView.adjustTableHeightForKeyboard(CGFloat(75))
    }
    
    func nextButtonHit() {
        print("nextButtonHit")
        theView.startActivityIndicator()
       
        observer = ManagedObjectObserver(object:user) { [unowned self] type in
            guard type == .Update else {
                return
            }
            self.updateResponse()
        }
        managedObjectContext.performChanges { [unowned self] in
            self.user.validationError         = nil
            self.user.needsRemoteVerification = true
            
            self.user.workReel = self.reelDataSource.reels
        }
    }
    
    func goBack() {
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.managedObjectContext.preventScreenByPass()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: methods
    func updateResponse() {
//        if User.hasValidationErrorPredicate.evaluateWithObject(self.user){
//            print("DO NOT PROCEEED EVEN!!!!!!!!!!")
//            theView.stopActivityIndicator()
//            return
//        }
//        
//        if User.notMarkedForRemoteVerification.evaluateWithObject(self.user)
//            && User.workReelNotEmptyPredicate.evaluateWithObject(self.user) {
//            print("PROCEEED EVEN!!!!!!!!!!")
//            theView.stopActivityIndicator()
//            if user.isAttemptingLogin {
//                userCreateEquipmentProfile()
//            } else {
//                self.goBack()
//            }
//        }
        
        if user.isAttemptingLogin {
//            hasEnoughToGetPastReelCreation(self) { [unowned self] in
                print("PROCEEED EVEN!!!!!!!!!!")
                self.theView.stopActivityIndicator()
                self.userCreateEquipmentProfile()
//            }
        } else {
            self.goBack()
        }
    }
   
    func addToReels(reel:Reel) {
        reelDataSource.addReel(reel)
        exampleDataSource.minusReels(reelDataSource.reels.map { $0.source })
    }
    
    func removeFromToReels(reelSource:ReelSource) {
        reelDataSource.minusReels(reelSource)
        exampleDataSource.minusReels(reelDataSource.reels.map { $0.source })
    }
    
    func delgateReelToTextField() {
        theView.reelTextField?.enabled  = true
        theView.reelTextField?.text     = currentReelSource?.address
        theView.reelTextField?.becomeFirstResponder()
        theView.reelTextField?.delegate = self
    }
    
    func tryToEnableNextButton() {
        print(reelDataSource.reels.count)
        print(reelDataSource.reels.count > 0)
        theView.nextButton?.enabled     = reelDataSource.reels.count > 0
    }
    
}

extension CMReelViewController : ReelProtocol {
    
    func editReel(reel:Reel) {
        currentReelSource               = reel.source
        delgateReelToTextField()
        theView.reelTextField?.text     = currentReelSource!.address + reel.value
    }
    
    func addReel() {
        theView.showExamples()
    }
}

extension CMReelViewController : ExampleReelProtocol {
    
    func reelSelected(reelSource:ReelSource) {
        currentReelSource = reelSource
        delgateReelToTextField()
        theView.hideExamples()
        theView.reelTableView?.hidden = true
    }

}

extension CMReelViewController : UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if range.location < currentReelSource.address.characters.count && string.characters.count == 0 {
            textField.text = currentReelSource.address
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        theView.reelTextField?.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        let data = textField.text!.stringByReplacingOccurrencesOfString(currentReelSource.address, withString: "")
        if data.characters.count > 0 {
            addToReels(Reel(value:data, source:currentReelSource))
        } else {
            removeFromToReels(currentReelSource)
        }
        theView.reelTextField?.text         = ""
        theView.reelTextField?.enabled      = false
        theView.reelTableView?.hidden       = false
        tryToEnableNextButton()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        theView.reelTextField?.text         = ""
        theView.reelTextField?.enabled      = false
        return true
    }
    
}













