//
//  PhotoExtrasViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI
import CaptureModel

extension CYNavigationPush where Self : PhotoExtrasViewController {
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return PushTopAnimator()
    }
    func performSeguePush() {
        self.performSegueWithIdentifier(self.pushSegue, sender: self)
    }
    var pushSegue:String {
        return "pushToPermissionsScreen"
    }
}
extension CYNavigationPop where Self : PhotoExtrasViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopBottomAnimator()
    }
}

class PhotoExtrasViewController: UIViewController, SegueHandlerType, CYNavigationPush, CYNavigationPop, CreateProfileNavControllerChild {
    
    enum SegueIdentifier:String {
        case PushToPermissions  = "pushToPermissionsScreen"
        case ShowEquipment      = "showEquipment"
        case ShowBio            = "showBio"
    }
    
    var theView:PhotoExtrasView {
        guard let v = self.view as? PhotoExtrasView else { fatalError("Not a \(PhotoExtrasView.self)!") }
        return v
    }
    var equipment:[Equipment] = []
    var bio:String? = nil
    
    private typealias Data = DefaultDataProvider<PhotoExtrasViewController>
    private var dataSource:CollectionViewDataSource<PhotoExtrasViewController, Data, ProfileCollectionCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        theView.collectionView?.delegate = self
        createDataProvider()
    }

    func createDataProvider() {
        dataProvider    = DefaultDataProvider(items:[equipment.profileCellViewModel, bioVM], delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)
        theView.didLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addHandlers()
       
        theView.nextButton?.hidden = navContainer.onlyUpdate
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }

    func pushToPermissions() {
        performSegue(.PushToPermissions)
    }
    
    func addHandlers() {
        removeHandlers()
        theView.nextButton?.addTarget(self, action:#selector(nextButtonHit), forControlEvents:.TouchUpInside)
    }
    
    func removeHandlers() {
        theView.nextButton?.removeTarget(self, action:#selector(nextButtonHit), forControlEvents:.TouchUpInside)
    }
    
    func nextButtonHit() {
        navContainer.pushPermissions(photoExtras)
    }

    var completedBio:Bool {
        var completed = false
        if let b = self.bio where b.characters.count > 0 {
            completed = true
        }
        return completed
    }
    
    var bioVM:CellDecoratable {
        let title = NSLocalizedString("MY BIO", comment: "PhotoExtrasViewController : Bio Cell : title")
        return ProfileImageCompletedCellViewModel(
            type:PhotoExtrasType.Bio.rawValue
            ,title:title
            ,imageNameEnabled:"icon_mybio_active"
            ,imageNameDisabled:"icon_mybio_default"
            ,completed:completedBio
        )
    }
    
    var photoExtras:ProfileTableCellInfo {
        return ProfileTableCellInfo(
            title:NSLocalizedString("Photography extras", comment: "PhotoExtrasTableViewCell : titleLabel : text")
            ,type:.PHOTOEXTRAS
            ,roundButtons:[
                bioVM
                ,equipment.smallEquipmentViewModel()
            ]
        )
    }


     // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowEquipment:
            guard let levelVC = segue.destinationViewController as? EquipmentViewController else {
                fatalError("not a ExperienceLevelViewController")
            }
            levelVC.equipmentPicked = didPickEquipment
            levelVC.pickedEquipment = equipment
        case .ShowBio:
            guard let bioVC = segue.destinationViewController as? BioViewController else {
                fatalError("not a BioViewController")
            }
            bioVC.bio               = bio
            bioVC.bioCompleted      = didCompleteBio
        default:
            break
        }
    }

    
    //MARK: Completion handlers
    func didPickEquipment(equipment:[Equipment]) {
        self.equipment = equipment
        createDataProvider()
    }
    
    func didCompleteBio(bio:String?) {
        self.bio = bio
        createDataProvider()
    }
    
}

extension PhotoExtrasViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject else { return }
        guard let type = PhotoExtrasType(rawValue: object.type) else { fatalError("Not and PhotoExtrasType type : \(object.type)") }
        collectionView.deselectItemAtIndexPath(indexPath, animated:false)
        
        switch type {
        case .Bio:
            performSegue(.ShowBio)
        case .Equipment:
            performSegue(.ShowEquipment)
        }
    }
}

extension PhotoExtrasViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<CellDecoratable>]?) {
        dataSource.processUpdates(updates)
    }
}

extension PhotoExtrasViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:CellDecoratable) -> String {
        return ProfileCollectionCellIdentifier
    }
}
