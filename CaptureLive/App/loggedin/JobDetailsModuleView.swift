//
//  JobDetailsModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/14/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI


class JobDetailsModuleView: UIView {
    
    private typealias Data = DefaultDataProvider<JobDetailsModuleView>
    private var dataSource:TableViewDataSource<JobDetailsModuleView, Data, JobInfoTableViewCell>!
    private var dataProvider:Data!

    @IBOutlet weak var closeButton:CenteredButton?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var heightConstraint:NSLayoutConstraint?
    @IBOutlet weak var closeButtonHeightConstraint:NSLayoutConstraint?
    
    var visibleHeight:CGFloat                       = 0
    
    func populate(titlesAndData:[TitleAndData]) {
        tableHeight                                 = titlesAndData.totalHeight
        heightConstraint?.constant                  = totalHeight
        bottomConstraint?.constant                  = hiddenHeight

        dataProvider                                = DefaultDataProvider(items:titlesAndData, delegate :self)
        dataSource                                  = TableViewDataSource(tableView:tableView!, dataProvider: dataProvider, delegate:self)
        tableView?.delegate                         = self
    }
    
    var totalHeight:CGFloat {
        let infoHeight                              = closeButtonHeightConstraint!.constant + tableHeight + 40
        let infoPublisherHeight                     = ScreenSize.SCREEN_HEIGHT * 0.415
        return max(infoHeight, infoPublisherHeight)
    }
    
    func showButton() {
        visibleHeight                               = ScreenSize.SCREEN_WIDTH * 0.125
    }
    
    var hiddenHeight:CGFloat {
        return -totalHeight + visibleHeight
    }
    
    var showingHeight:CGFloat {
        return 0
    }
    
    private var tableHeight:CGFloat                 = 0
    
    func animateIn() {
        UIView.animateWithDuration(0.5,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.7,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                                    self?.show()
                                    
        }) { fin in

        }
    }
    
    func animateOut() {
        UIView.animateWithDuration(0.5,
                                   delay: 0.0,
                                   usingSpringWithDamping:0.7,
                                   initialSpringVelocity:0.5,
                                   options: [],
                                   animations: { [weak self] in
                                    self?.hide()
                                    
        }) { fin in

        }
    }
    
    func show() {
        bottomConstraint?.constant                  = showingHeight
        layoutIfNeeded()
    }
    
    func hide() {
        bottomConstraint?.constant                  = hiddenHeight
        layoutIfNeeded()
    }

    func toggleJobDetails() {
        if bottomConstraint?.constant == 0 {
            animateOut()
        } else {
            animateIn()
        }
    }
    
}

extension JobDetailsModuleView : CMViewProtocol {
    
    func didLoad() {
        let buttonText                              = NSLocalizedString("JOB DETAILS", comment:"JobDetailsModuleView : jobDetailsLabel : text")
        closeButton?.setTitle(buttonText, forState: .Normal)
        closeButton?.setTitleColor(UIColor.bistre(), forState: .Normal)
        closeButton?.setImage(UIImage.iconDownArrowGray(), forState: .Normal)
        closeButton?.backgroundColor                = UIColor.isabelline()
        closeButton?.titleLabel?.font               = UIFont.proxima(.Bold, size: FontSizes.s12)
        
        tableView?.separatorStyle                   = .None
        tableView?.contentInset                     = UIEdgeInsetsMake(15, 0, 25, 0)
        
        closeButtonHeightConstraint?.constant       = ScreenSize.SCREEN_WIDTH * 0.125
    }

}

extension JobDetailsModuleView : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).heightForJobInfoCell
    }
}

extension JobDetailsModuleView : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<TitleAndData>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension JobDetailsModuleView : DataSourceDelegate {
    func cellIdentifierForObject(object:TitleAndData) -> String {
        return JobInfoTableViewCell.Identifier
    }
}

