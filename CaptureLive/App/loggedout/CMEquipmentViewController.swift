//
//  HistoryViewController.swift
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

class CMEquipmentViewController: UIViewController ,RemoteAndLocallyServiceable, SegueHandlerType {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CurrentRemoteType!

    enum SegueIdentifier:String {
        case Experience            = "pushToExperience"
        case ExperienceNoAnimate   = "pushToExperienceNoAnimate"
    }

    private var observer:ManagedObjectObserver?
    var user:User!
    
    var theView:CMEquipmentView {
        guard let v = self.view as? CMEquipmentView else { fatalError("Not a CMEquipmentView!") }
        return v
    }
   
    private var equipmentDataSource :EquipmentTableViewSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        equipmentDataSource             = EquipmentTableViewSource(tableView: theView.tableView!, equipmentDelegate:self)
        
        theView.didLoad()
        updateNextButton()
       
        theView.spaceValueLabel?.text   = "\(CMDisk.freeDiskSpace())"
        theView.deviceValueLabel?.text  = "\(CMDevice.commonName(CMDevice.model()))"
        theView.batteryValueLabel?.text = "\(CMDevice.battery()) %"
        
        if self.user.isAttemptingLogin {
            theView.showForAttemptingLogin()
            hasEnoughToGetPastEquipmentCreation(self) { [unowned self] in
                self.performSegue(.ExperienceNoAnimate)
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
        
        equipmentDataSource.replaceEquip(user.equipment)
        updateNextButton()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
        observer = nil
    }
    
    func addEventHandlers() {
        theView.nextButton?.addTarget(self, action: #selector(nextButtonHit), forControlEvents:.TouchUpInside)
        theView.backButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.nextButton?.removeTarget(self, action: #selector(nextButtonHit), forControlEvents:.TouchUpInside)
        theView.backButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func updateNextButton() {
        theView.nextButton?.enabled = self.equipmentDataSource.ownedEquipment.count > 0
    }
    
    // MARK: Button handlers
    func nextButtonHit() {
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
            self.user.equipment = self.equipmentDataSource.ownedEquipment
        }
    }
    
    func goBack() {
        managedObjectContext.performChangesAndWait { [unowned self] in
            self.managedObjectContext.preventScreenByPass()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
  
    func userCreateExperienceProfile() {
        performSegue(.Experience)
    }
    
    // MARK: User update notificaiton
    func updateResponse() {
//        if User.notMarkedForRemoteVerification.evaluateWithObject(self.user)
//            && User.workReelNotEmptyPredicate.evaluateWithObject(self.user) {
//            print("PROCEEED EVEN!!!!!!!!!!")
//            theView.stopActivityIndicator()
//            if user.isAttemptingLogin {
//                userCreateExperienceProfile()
//            } else {
//                goBack()
//            }
//        }
        
        
        if user.isAttemptingLogin {
//            hasEnoughToGetPastEquipmentCreation(self) { [unowned self] in
                print("PROCEEED EVEN!!!!!!!!!!")
                self.theView.stopActivityIndicator()
                self.userCreateExperienceProfile()
//            }
        } else {
            self.goBack()
        }

    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? CMExperienceViewController else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
        vc.user                                         = user
    }

}


extension CMEquipmentViewController : EquipmentTableSourceProtocol {
    
    func equipmentSelected(equipment:Equipment) {
        updateNextButton()
    }
    
}