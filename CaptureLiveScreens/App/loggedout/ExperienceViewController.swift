//
//  ExperienceViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI
import CaptureModel

extension CYNavigationPush where Self : ExperienceViewController {
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return PushTopAnimator()
    }
    var pushSegue:String {
        return "pushToWorkScreen" 
    }
}
extension CYNavigationPop where Self : ExperienceViewController {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopBottomAnimator()
    }
}

class ExperienceViewController: UIViewController, SegueHandlerType, CYNavigationPush, CYNavigationPop, CreateProfileNavControllerChild {

    enum SegueIdentifier:String {
        case PushToWork                 = "pushToWorkScreen"
        case ShowExperienceLevel        = "showExperienceLevel"
        case ShowExperienceCategories   = "showExperienceCategories"
    }
    
    var theView:ExperienceView {
        guard let v = self.view as? ExperienceView else { fatalError("Not a \(ExperienceView.self)!") }
        return v
    }
    
    private typealias Data = DefaultDataProvider<ExperienceViewController>
    private var dataSource:CollectionViewDataSource<ExperienceViewController, Data, ProfileCollectionCell>!
    private var dataProvider: Data!

    var level = Level.LessThanOne
    var categories:[CaptureModel.Category] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        theView.collectionView?.delegate = self
        
        createDataProvider()
    }
    
    func createDataProvider() {
        dataProvider    = DefaultDataProvider(items:[level.profileCellViewModel, categories.profileCellViewModel], delegate :self)
        dataSource      = CollectionViewDataSource(collectionView:theView.collectionView!, dataProvider: dataProvider, delegate:self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addHandlers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
   
    func pushToWork() {
        performSegue(.PushToWork)
    }
    
    func addHandlers() {
        removeHandlers()
        theView.nextButton?.addTarget(self, action:#selector(nextButtonHit), forControlEvents:.TouchUpInside)
    }
    
    func removeHandlers() {
        theView.nextButton?.removeTarget(self, action:#selector(nextButtonHit), forControlEvents:.TouchUpInside)
    }

    func nextButtonHit() {
        navContainer.pushWork(getExperience())
    }
   
    func getExperience()->ProfileTableCellInfo {
        return ProfileTableCellInfo(
            title:NSLocalizedString("Your Photography Experience", comment: "ExperienceTableViewCell : titleLabel : text")
            ,type:.EXPERIENCE
            ,roundButtons:[
                 self.categories.smallCategoryViewModel
                ,self.level.smallCellViewModel
            ]
        )
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowExperienceLevel:
            guard let levelVC = segue.destinationViewController as? ExperienceLevelViewController else {
                fatalError("not a ExperienceLevelViewController")
            }
            levelVC.experienceLevelPicked = didPickExperienceLevel
        case .ShowExperienceCategories:
            guard let levelVC = segue.destinationViewController as? ExperienceCategoriesViewController else {
                fatalError("not a ExperienceCategoriesViewController")
            }
            levelVC.categoriesPicked = didPickCategories
            levelVC.pickedCategories = categories
        default:
            break
        }
    }
   
    // MARK: Model callbacks
    func didPickExperienceLevel(lev:Level?) {
        guard let l = lev else { return }
        self.level = l
        createDataProvider()
    }
    
    func didPickCategories(categories:[CaptureModel.Category]) {
        self.categories = categories
        createDataProvider()
    }
    
}

extension ExperienceViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = dataSource.selectedObject else { return }
        guard let type = ExperienceType(rawValue: object.type) else { fatalError("Not an experience type") }
        collectionView.deselectItemAtIndexPath(indexPath, animated:false)
        
        switch type {
        case .Level:
            performSegue(.ShowExperienceLevel)
        case .Categories:
            performSegue(.ShowExperienceCategories)
        }
    }
}

extension ExperienceViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<CellDecoratable>]?) {
        dataSource.processUpdates(updates)
    }
}

extension ExperienceViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:CellDecoratable) -> String {
        return ProfileCollectionCellIdentifier
    }
}
