//
//  CMSupportViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class SupportViewController: UIViewController{
    
    var theView:SupportView {
        guard let v = self.view as? SupportView else { fatalError("Not a CMSupportView!") }
        return v
    }
    
    private typealias Data                  = DefaultDataProvider<SupportViewController>
    private var dataSource: TableViewDataSource<SupportViewController, Data, SupportTableViewCell>!
    private var dataProvider: Data!
    
    let tableData:[String] = [
         NSLocalizedString("FAQs", comment: "CMSupportViewController : faqs : celltitle")
        ,NSLocalizedString("How it Works", comment: "CMSupportViewController : howitworks : celltitle")
        ,NSLocalizedString("Terms and Conditions", comment: "CMSupportViewController : termsconditions : celltitle")
        ,NSLocalizedString("Privacy Policy", comment: "CMSupportViewController : privacypolicy : celltitle")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        automaticallyAdjustsScrollViewInsets = true
        
        dataProvider    = DefaultDataProvider(items:tableData, delegate :self)
        dataSource      = TableViewDataSource(tableView:theView.tableView!, dataProvider:dataProvider, delegate:self)
        theView.tableView?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        theView.layoutSubviews()
        theView.updateTableViewHeight(tableData.count)
    }
    
    func addHandlers() {
        self.removeHandlers()
        self.theView.backButton?.addTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        self.theView.backButton?.removeTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    
    //MARK: Button handlers
    func popBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Navigation
    
}

extension SupportViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SupportTableViewCell.SupportTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
    }
    
}

extension SupportViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<Title>]?) {
    }
}

extension SupportViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:Title) -> String {
        return SupportTableViewCellIdentifier
    }
}
