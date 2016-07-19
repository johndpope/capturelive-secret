//
//  CaptureScreenListTableViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/4/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
let DefaultScreenTableViewCell = "DefaultScreenTableViewCell"
class CaptureScreenListTableViewController: UITableViewController, StoryboardScreenable {
   
    var desiredStoryBoard:String = ""
    var desiredScreen:String = ""
    let screens = CaptureScreensDict
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate                     = self
        self.automaticallyAdjustsScrollViewInsets   = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView:UITableView, viewForHeaderInSection section:Int) -> UIView? {
        let headerView                              = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 54))
        headerView.backgroundColor                  = UIColor.whiteColor()
        let label                                   = UILabel(frame: CGRectMake(0, headerView.frame.size.height - 24, tableView.bounds.size.width, 24))
        label.backgroundColor                       = UIColor.whiteColor()
        label.textAlignment                         = NSTextAlignment.Center
        let storyboard                              = screens[section]["section"] as? String
        label.text                                  = storyboard
        headerView.addSubview(label)
        return headerView;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return screens[section]["section"] as? String
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return screens.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dict:NSDictionary                       = self.screens[section]
        let screens:[String]                        = dict["screens"] as! [String]
        return screens.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DefaultScreenTableViewCell, forIndexPath: indexPath)
        cell.backgroundColor                        = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        let dict:NSDictionary                       = self.screens[indexPath.section]
        let screens:[String]                        = dict["screens"] as! [String]
        cell.textLabel?.text                        = screens[indexPath.row]
        return cell;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict:NSDictionary                       = self.screens[indexPath.section]
        let screenList:[String]                     = dict["screens"] as! [String]
        desiredStoryBoard                           = dict["storyboard"] as! String
        desiredScreen                               = screenList[indexPath.row]
        self.performSegueWithIdentifier("linkedSegue", sender: self)
    }
}
