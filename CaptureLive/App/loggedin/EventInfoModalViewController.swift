//
//  EventInfoModalViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/9/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CoreData
import CaptureCore
import CaptureSync
import CaptureModel
import CoreDataHelpers

class EventInfoModalViewController: UIViewController {
    
    var modalInfo:ModalInfo!
    
    private typealias Data              = DefaultDataProvider<EventInfoModalViewController>
    private var dataSource: TableViewDataSource<EventInfoModalViewController, Data, EventInfoTableViewCell>!
    private var dataProvider: Data!
    
    var theView:EventInfoModalView {
        guard let v = self.view as? EventInfoModalView else { fatalError("Not a EventInfoModalView!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theView.didLoad()
        theView.populate(modalInfo)
        
        dataProvider                    = DefaultDataProvider(items:modalInfo.tableDataArray, delegate :self)
        dataSource                      = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate     = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    func goBack() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addEventHandlers() {
        theView.closeButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.closeButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EventInfoModalViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataProvider.objectAtIndexPath(indexPath).cellHeight
    }
}

extension EventInfoModalViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<EventIndexInfo>]?) {
//        dataSource.processUpdates(updates)
    }
}

extension EventInfoModalViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:EventIndexInfo) -> String {
        return EventInfoTableViewCell.Identifier
    }
}
