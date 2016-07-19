//
//  CMPaypalViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class PaypalViewController: UIViewController {

    var theView:PaypalView {
        guard let v = self.view as? PaypalView else { fatalError("Not a PaypalView!") }
        return v
    }
   
    private typealias Data = DefaultDataProvider<PaypalViewController>
    private var dataSource:TableViewDataSource<PaypalViewController, Data, PaypalTableViewCell>!
    private var dataProvider: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
       
        let tablemodel = [
            PaypalViewModel(
                 receiptId:"fasdfasd"
                ,paymentDate:NSDate()
                ,amountPaid:112.9
            )
            ,PaypalViewModel(
                 receiptId:"fasdfasd"
                ,paymentDate:NSDate()
                ,amountPaid:111.9
            )
            ,PaypalViewModel(
                 receiptId:"fasdfasd"
                ,paymentDate:NSDate()
                ,amountPaid:113.9
            )
        ]

        dataProvider                        = DefaultDataProvider(items:tablemodel, delegate :self)
        dataSource                          = TableViewDataSource(tableView:theView.tableView!, dataProvider: dataProvider, delegate:self)
        theView.tableView?.delegate         = self
        
        let paypalModel = UserPaypalModel(
             hasPaypalEmailBool: false
            ,needsPaypalEmailBool: false
            ,paypalEmailString: nil
            ,totalAmountDouble: 0.0
        )
        theView.populate(paypalModel)
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
    
    // MARK: ADD/REMOVE handles
    func addEventHandlers() {
        theView.backButton?.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.verifyButton?.addTarget(self, action: #selector(verifyPaypal), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        theView.verifyButton?.removeTarget(self, action: #selector(verifyPaypal), forControlEvents: .TouchUpInside)
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
   
    func verifyPaypal() {
        let paypalModel = UserPaypalModel(
             hasPaypalEmailBool: true
            ,needsPaypalEmailBool: false
            ,paypalEmailString: "scoats+maloats@capture.com"
            ,totalAmountDouble: 100.0
        )
        theView.populate(paypalModel)
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

extension PaypalViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return PaypalTableViewCellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:false)
        back()
    }
    
}

extension PaypalViewController : DataProviderDelegate {
    func dataProviderDidUpdate(updates:[DataProviderUpdate<PaypalViewModel>]?) {
    }
}

extension PaypalViewController : DataSourceDelegate {
    func cellIdentifierForObject(object:PaypalViewModel) -> String {
        return PaypalTableViewCell.Identifier
    }
}
