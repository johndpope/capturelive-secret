//
//  UnappliedEventModuleView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/7/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class UnappliedEventModuleView: UIView {

    @IBOutlet weak var jobInfoModuleView:JobInfoModuleView?
    @IBOutlet weak var applyButton:CMPrimaryButton?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var tableContainerView:UIView?
    
    private typealias Data = DefaultDataProvider<UnappliedEventModuleView>
    private var dataSource: TableViewDataSource<UnappliedEventModuleView, Data, JobInfoTableViewCell>!
    private var dataProvider: Data!

    var totalHeight:CGFloat {
        let submitbuttonHeight                      = ScreenSize.SCREEN_WIDTH * 0.125
        let infoHeight                              = (ScreenSize.SCREEN_WIDTH * 0.206)
        return submitbuttonHeight + infoHeight + tableHeight + 30
    }
    
    private var tableHeight:CGFloat                 = 0
    
    func populate(titlesAndData:[TitleAndData]) {
        tableHeight                                 = titlesAndData.totalHeight
        dataProvider                                = DefaultDataProvider(items:titlesAndData, delegate :self)
        dataSource                                  = TableViewDataSource(tableView:tableView!, dataProvider: dataProvider, delegate:self)
        tableView?.delegate                         = self
    }
    
}

extension UnappliedEventModuleView : CMViewProtocol {
   
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

        let titleText                               = NSLocalizedString("APPLY FOR THIS JOB", comment: "UnappliedEventModuleView : applyButton : text")
        applyButton?.setTitle(titleText, forState: .Normal)
    }
    
}


extension UnappliedEventModuleView : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).heightForJobInfoCell
    }
}

extension UnappliedEventModuleView : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<TitleAndData>]?) {
        dataSource.processUpdates(updates)
    }
}

extension UnappliedEventModuleView : DataSourceDelegate {
    func cellIdentifierForObject(object:TitleAndData) -> String {
        return JobInfoTableViewCell.Identifier
    }
}


extension TitleAndData {
    var heightForJobInfoCell:CGFloat {
        return max(heightForJobDataText, JobInfoTableViewCellBaseHeight)
    }
    var heightForJobDataText:CGFloat {
        return dataString.heightWithConstrainedWidth(JobInfoDataLabelWidth, font:JobInfoTableViewCell.dataLabelFont)
    }
    var hideSeparatorView:Bool {
        return titleString == EventApplicationModel.detailsTitle
    }
}

extension SequenceType where Generator.Element == TitleAndData {
   
    var totalHeight:CGFloat {
        return reduce(0) { $0 + $1.heightForJobInfoCell }
    }
    
}





