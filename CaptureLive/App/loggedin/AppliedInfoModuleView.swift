//
//  AppliedInfoModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/8/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class AppliedInfoModuleView: UIView {

    @IBOutlet weak var jobInfoModuleView:JobInfoModuleView?
    @IBOutlet weak var jobDetailsButton:UIButton?
    @IBOutlet weak var cancelButton:UIButton?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var tableContainerView:UIView?
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var heightConstraint:NSLayoutConstraint?
    
    private typealias Data  = DefaultDataProvider<AppliedInfoModuleView>
    private var dataSource: TableViewDataSource<AppliedInfoModuleView, Data, JobInfoTableViewCell>!
    private var dataProvider: Data!
    
    var totalHeight:CGFloat {
        let dbuttonHeight                           = ScreenSize.SCREEN_WIDTH * 0.125
        let cbuttonHeight                           = (ScreenSize.SCREEN_WIDTH * 0.075)
        let infoHeight                              = (ScreenSize.SCREEN_WIDTH * 0.206)
        return dbuttonHeight + cbuttonHeight + infoHeight + tableHeight + 40
    }
    
    var hiddenHeight:CGFloat {
        let cbuttonHeight                           = (ScreenSize.SCREEN_WIDTH * 0.075)
        let infoHeight                              = (ScreenSize.SCREEN_WIDTH * 0.206)
        return cbuttonHeight + infoHeight + tableHeight + 40
    }
    
    private var tableHeight:CGFloat                 = 0
    
    func populate(titlesAndData:[TitleAndData]) {
        tableHeight                                 = titlesAndData.totalHeight
        dataProvider                                = DefaultDataProvider(items:titlesAndData, delegate :self)
        dataSource                                  = TableViewDataSource(tableView:tableView!, dataProvider: dataProvider, delegate:self)
        tableView?.delegate                         = self
      
        if jobInfoModuleView!.hidden {
            bottomConstraint?.constant              = -hiddenHeight
            heightConstraint?.constant              = totalHeight + 1
            layoutIfNeeded()
        }
    }
   
    func toggleShowDetails() {
        if bottomConstraint?.constant < 0 {
            show()
        } else {
            hide()
        }
    }
   
    func hideUI() {
        cancelButton?.hidden                        = true
        jobInfoModuleView?.hidden                   = true
        tableContainerView?.hidden                  = true
    }
    
    func showUI() {
        cancelButton?.hidden                        = false
        jobInfoModuleView?.hidden                   = false
        tableContainerView?.hidden                  = false
    }
    
    func show() {
        showUI()
        UIView.animateWithDuration(0.75,
                                   delay: 0,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                                    self?.bottomConstraint?.constant = 0
                                    self?.layoutIfNeeded()
                                    
            }, completion: { finished in
                
        })
    }
    
    func hide() {
        let h = -hiddenHeight
        UIView.animateWithDuration(0.75,
                                   delay: 0,
                                   usingSpringWithDamping:0.8,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                                    self?.bottomConstraint?.constant = h
                                    self?.layoutIfNeeded()
                                    
            }, completion: { [weak self] finished in
                self?.hideUI()
        })
    }

}

extension AppliedInfoModuleView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor                             = UIColor.isabelline()
        
        jobInfoModuleView?.didLoad()
        jobInfoModuleView?.layer.shadowColor        = UIColor.bistre().CGColor
        jobInfoModuleView?.layer.shadowOpacity      = 0.5
        jobInfoModuleView?.layer.shadowOffset       = CGSizeMake(0, 0.5)
        jobInfoModuleView?.layer.shadowRadius       = 0.8
        
        tableContainerView?.layer.masksToBounds     = false
        tableContainerView?.layer.cornerRadius      = 2
        tableContainerView?.layer.shadowColor       = UIColor.bistre().CGColor
        tableContainerView?.layer.shadowOpacity     = 0.5
        tableContainerView?.layer.shadowOffset      = CGSizeMake(0, 0.5)
        tableContainerView?.layer.shadowRadius      = 0.8
        tableView?.separatorStyle                   = .None
        
        let titleText                               = NSLocalizedString("JOB DETAILS", comment: "AppliedInfoModuleView : jobDetailsButton : text")
        jobDetailsButton?.setTitle(titleText, forState: .Normal)
        jobDetailsButton?.setTitleColor(UIColor.bistre(), forState: .Normal)
        jobDetailsButton?.titleLabel?.font          = UIFont.proxima(.Bold, size: FontSizes.s15)
        jobDetailsButton?.backgroundColor           = UIColor.whiteColor()
        jobDetailsButton?.layer.shadowColor         = UIColor.bistre().CGColor
        jobDetailsButton?.layer.shadowOpacity       = 0.5
        jobDetailsButton?.layer.shadowOffset        = CGSizeMake(0, 0.5)
        jobDetailsButton?.layer.shadowRadius        = 0.8

        let cancelText                              = NSLocalizedString("CANCEL JOB", comment: "AppliedInfoModuleView : cancelButton : text")
        cancelButton?.setTitle(cancelText, forState: .Normal)
        cancelButton?.setTitleColor(UIColor.bistre(), forState: .Normal)
        cancelButton?.titleLabel?.font              = UIFont.proxima(.Bold, size: FontSizes.s10)
        cancelButton?.backgroundColor               = UIColor.whiteColor()
        cancelButton?.layer.shadowColor             = UIColor.bistre().CGColor
        cancelButton?.layer.shadowOpacity           = 0.5
        cancelButton?.layer.shadowOffset            = CGSizeMake(0, 0.5)
        cancelButton?.layer.shadowRadius            = 0.8
        
        hideUI()
        bottomConstraint?.constant                  = -hiddenHeight
        heightConstraint?.constant                  = totalHeight + 1
    }

}


extension AppliedInfoModuleView : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).heightForJobInfoCell
    }
}

extension AppliedInfoModuleView : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<TitleAndData>]?) {
        dataSource.processUpdates(updates)
    }
}

extension AppliedInfoModuleView : DataSourceDelegate {
    func cellIdentifierForObject(object:TitleAndData) -> String {
        return JobInfoTableViewCell.Identifier
    }
}


