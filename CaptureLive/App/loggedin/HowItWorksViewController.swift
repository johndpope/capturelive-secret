//
//  CMSupportViewController.swift
//  Current
//
//  Created by Scott Jones on 1/25/16.
//  Copyright © 2016 CaptureMedia. All rights reserved.
//

import UIKit

extension HowItWorksViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class HowItWorksViewController: UIViewController, NavGesturable {

    var theView:HowItWorksView {
        return self.view as! HowItWorksView
    }
    
    private typealias Data                  = DefaultDataProvider<HowItWorksViewController>
    private var dataSource: TableViewDataSource<HowItWorksViewController, Data, HowItWorksTableViewCell>!
    private var dataProvider: Data!
   
    let tableData:[HowItWorksViewModel] = [
        HowItWorksViewModel(
            titleString : "STEP 1"
            ,subTitleString:"APPLY"
            ,descriptionString:"Record video footage as described in the details video canfootage as described in the job foota describe what."
            ,showSeperator:true
        )
        ,HowItWorksViewModel(
            titleString : "STEP 2"
            ,subTitleString:"GET HIRED"
            ,descriptionString:"Record video footage as described in the details video canfootage as described in the job foota describe what."
            ,showSeperator:true
        )
        ,HowItWorksViewModel(
            titleString : "STEP 3"
            ,subTitleString:"STREAM VIDEO"
            ,descriptionString:"Record video footage as described in the details video canfootage as described in the job foota describe what."
            ,showSeperator:true
        )
        ,HowItWorksViewModel(
            titleString : "STEP 4"
            ,subTitleString:"GET PAID"
            ,descriptionString:"Record video footage as described in the details video canfootage as described in the job foota describe what."
            ,showSeperator:false
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets       = false

        theView.didLoad()
        
        dataProvider    = DefaultDataProvider(items:tableData, delegate :self)
        dataSource      = TableViewDataSource(tableView:theView.tableView!, dataProvider:dataProvider, delegate:self)
        theView.tableView?.delegate = self
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
        
        navGesturer?.usePushRightPopLeftGestureRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    func addEventHandlers() {
        self.theView.backButton?.addTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.backButton?.removeTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func popBack() {
        performSeguePop()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}


extension HowItWorksViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableData[indexPath.row].cellHieght
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
    }
    
}

extension HowItWorksViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<HowItWorksViewModel>]?) {
    }
}

extension HowItWorksViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:HowItWorksViewModel) -> String {
        return HowItWorksTableViewCellIdentifier
    }
}
