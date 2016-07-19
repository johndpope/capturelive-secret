//
//  JobReceiptView.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/20/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class JobReceiptView: UIView {

    @IBOutlet weak var navTitleLabel:UILabel?
    @IBOutlet weak var navView:UIView?
    @IBOutlet weak var youveEarnedLabel:UILabel?
    @IBOutlet weak var youveEarnedLabelWConstraint:NSLayoutConstraint?
    @IBOutlet weak var youveEarnedStrokeView:UIView?
    
    @IBOutlet weak var amountLabel:UILabel?
    @IBOutlet weak var jobHighLightsLabel:UILabel?
    @IBOutlet weak var jobHighLightsLabelWConstraint:NSLayoutConstraint?
    @IBOutlet weak var jobHighLightsStrokeView:UIView?

    @IBOutlet weak var jobTitleLabel:UILabel?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var collectionView:UICollectionView?
    @IBOutlet weak var jobSummaryButton:CMPrimaryButton?

    @IBOutlet weak var collectionViewHeight:NSLayoutConstraint?
    
    private typealias Data = DefaultDataProvider<JobReceiptView>
    private var dataSource: CollectionViewDataSource<JobReceiptView, Data, ImageCollectionViewCell>!
    private var dataProvider: Data!
    
    func populate(viewModel:EventTableCellViewModel, attachments:[AttachmentCollectionViewModel]) {
        amountLabel?.text                       = viewModel.paymentString
        jobTitleLabel?.text                     = viewModel.titleString
        
        dataProvider                            = DefaultDataProvider(items:attachments, delegate :self)
        dataSource                              = CollectionViewDataSource(collectionView:collectionView!, dataProvider: dataProvider, delegate:self)
    }
    
}

extension JobReceiptView : CMViewProtocol {
    
    func didLoad() {
        backgroundColor                         = UIColor.whiteSmoke()
        
        navTitleLabel?.textColor                = UIColor.bistre()
        navTitleLabel?.text                     = NSLocalizedString("Job Complete!", comment:"JobReceiptView : navTitleLabel : text")
        navTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s17)
        navView?.layer.shadowOpacity            = 0.5
        navView?.layer.shadowOffset             = CGSizeMake(0, 0.2)
        navView?.layer.shadowRadius             = 0.5
        
        let youveEarnedText                     = NSLocalizedString("YOU’VE EARNED", comment:"JobReceiptView : youveEarnedLabel : text")
        youveEarnedLabel?.text                  = youveEarnedText
        youveEarnedLabel?.textColor             = UIColor.taupeGray()
        youveEarnedLabel?.font                  = UIFont.proxima(.Bold, size: FontSizes.s12)
        youveEarnedLabel?.backgroundColor       = UIColor.whiteSmoke()
        
        var width                               = youveEarnedText.widthWithConstrainedHeight(30, font: youveEarnedLabel!.font)
        youveEarnedLabelWConstraint?.constant   = width + 20
        
        let jobHighLightsText                   = NSLocalizedString("JOB HIGHLIGHTS", comment:"JobReceiptView : jobHighLightsLabel : text")
        jobHighLightsLabel?.text                = jobHighLightsText
        jobHighLightsLabel?.textColor           = UIColor.taupeGray()
        jobHighLightsLabel?.font                = UIFont.proxima(.Bold, size: FontSizes.s12)
        jobHighLightsLabel?.backgroundColor     = UIColor.whiteSmoke()

        width                                   = jobHighLightsText.widthWithConstrainedHeight(30, font: jobHighLightsLabel!.font)
        jobHighLightsLabelWConstraint?.constant = width + 20

        
        let summaryText                         = NSLocalizedString("VIEW JOB SUMMARY", comment:"JobReceiptView : jobSummaryButton : text")
        jobSummaryButton?.setTitle(summaryText, forState: .Normal)
        
        amountLabel?.textColor                  = UIColor.bistre()
        amountLabel?.font                       = UIFont.proxima(.Regular, size: FontSizes.s44)

        jobTitleLabel?.textColor                = UIColor.bistre()
        jobTitleLabel?.font                     = UIFont.proxima(.Regular, size: FontSizes.s14)
        
        tableView?.separatorStyle               = .None
        tableView?.backgroundColor              = UIColor.whiteSmoke()
       
        collectionView?.backgroundColor         = UIColor.whiteSmoke()
        let layout                              = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let w                                   = ScreenSize.SCREEN_WIDTH
        let h                                   = ScreenSize.SCREEN_WIDTH * 0.5
        layout.itemSize                         = CGSizeMake(w,h)
    }

}

extension JobReceiptView : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        nodes[indexPath.row].hasAgreedBool = !nodes[indexPath.row].hasAgreedBool
//        createDataProvider()
    }
}

extension JobReceiptView : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<AttachmentCollectionViewModel>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension JobReceiptView : DataSourceDelegate {
    func cellIdentifierForObject(object:AttachmentCollectionViewModel) -> String {
        return ImageCollectionViewCellReuseIdentifier
    }
}