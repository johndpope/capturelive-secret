//
//  CMWorkViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI
import CaptureModel

extension CYNavigationPush where Self : WorkViewController {
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return PushTopAnimator()
    }
    func performSeguePush() {
        self.performSegueWithIdentifier(self.pushSegue, sender: self)
    }
    var pushSegue:String {
        return "pushToPhotoExtrasScreen"
    }
}
extension CYNavigationPop where Self : WorkViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopBottomAnimator()
    }
}

class WorkViewController: UIViewController, SegueHandlerType, CYNavigationPush, CYNavigationPop, CreateProfileNavControllerChild {
    
    enum SegueIdentifier:String {
        case PushToPhotoExtras = "pushToPhotoExtrasScreen"
        case ShowAddReelScreen = "showAddReelScreen"
    }
    
    var theView:WorkView {
        guard let v = self.view as? WorkView else { fatalError("Not a \(WorkView.self)!") }
        return v
    }
   
    private typealias Data = DefaultDataProvider<WorkViewController>
    private var dataSource:CollectionViewDataSource<WorkViewController, Data, ProfileCollectionCell>!
    private var dataProvider: Data!
   
    let allReels = ReelSource.allValues
    var myReels:[Reel] = []
    var items:[CellDecoratable] = []
    
    var selectedReelSource:ReelSource = .Personal
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theView.collectionView?.delegate = self
        theView.didLoad()
        createViewModelList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addHandlers()
        
//        theView.nextButton?.enabled = myReels.count > 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    func pushToPhotoExtras() {
        performSegue(.PushToPhotoExtras)
    }
    
    func addHandlers() {
        removeHandlers()
        theView.nextButton?.addTarget(self, action:#selector(nextButtonHit), forControlEvents:.TouchUpInside)
    }
    
    func removeHandlers() {
        theView.nextButton?.removeTarget(self, action:#selector(nextButtonHit), forControlEvents:.TouchUpInside)
    }
    
    func nextButtonHit() {
        navContainer.pushPhotoExtras(work)
    }

    var work:ProfileTableCellInfo {
        let smallreels:[RoundButtonDecoratable] = myReels.map { $0.source.smallCellViewModel }
        
        return ProfileTableCellInfo(
            title:NSLocalizedString("Your Work", comment: "WorkTableViewCell : titleLabel : text")
            ,type:.WORK
            ,roundButtons:smallreels
        )
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowAddReelScreen:
            guard let reelVC = segue.destinationViewController as? ReelViewController else {
                fatalError("not a ExperienceLevelViewController")
            }
            reelVC.reelSource   = selectedReelSource
            reelVC.reel         = myReels.reelForSource(selectedReelSource)
            reelVC.reelCreated  = didCreateReel
        default:
            break
        }
    }
    
    func subtractReel(reel:ReelSource) {
        myReels = myReels.filter{ $0.source != reel }.flatMap{ $0 }
    }
    
    func addReel(reel:Reel) {
        let r = myReels.filter { $0.source != reel.source }.flatMap { $0 }
        myReels = [reel] + r
    }
    
    func createViewModelList() {
        items           = ReelSource.modelsWithSelection(myReels)
        dataProvider    = DefaultDataProvider(items:items, delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)
    }
    
    func didCreateReel(sourceWithContent:SourceWithReel) {
        if let r = sourceWithContent.reel {
            addReel(r)
        } else {
            subtractReel(sourceWithContent.source)
        }
        createViewModelList()
    }

}

extension WorkViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject else { return }
        collectionView.deselectItemAtIndexPath(indexPath, animated:false)
       
        guard let source = ReelSource(rawValue: object.type) else { fatalError("Not a reelSource : \(object.type)") }
        selectedReelSource = source
        performSegue(.ShowAddReelScreen)
    }
}

extension WorkViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<CellDecoratable>]?) {
        dataSource.processUpdates(updates)
    }
}

extension WorkViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:CellDecoratable) -> String {
        return ProfileCollectionCellIdentifier
    }
}
