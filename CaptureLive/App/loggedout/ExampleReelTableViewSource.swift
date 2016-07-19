//
//  ExampleReelTableViewSource.swift
//  Current
//
//  Created by Scott Jones on 4/12/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CaptureModel

typealias ReelSelected = (ReelSource)->()

protocol ExampleReelProtocol {
    func reelSelected(reelSource:ReelSource)
}


 final class ExampleReelTableViewSource:NSObject {
    
    private unowned let tableView:UITableView
    var reelDelegate:ExampleReelProtocol!
    internal private(set) var reelSources:[ReelSource] = ReelSource.allValues
    
    init(tableView:UITableView, reelDelegate:ExampleReelProtocol) {
        self.tableView              = tableView
        self.reelDelegate           = reelDelegate
        super.init()
        self.tableView.dataSource   = self
        self.tableView.delegate     = self
        self.tableView.reloadData()
    }
    
    func minusReels(userReelsSources:[ReelSource]) {
        reelSources = ReelSource.allValues.filter{ !userReelsSources.contains($0) }.flatMap { $0 }
        self.tableView.reloadData()
    }
    
    func addBackReel(reelSource:ReelSource) {
        let r = ReelSource.allValues.filter{ $0 != reelSource }.flatMap { $0 }
        reelSources = [reelSource] + r
    }
    
}

private let ExampleReelTableViewCell = "ExampleReelTableViewCell"
extension ExampleReelTableViewSource : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reelSources.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ExampleReelTableViewCell, forIndexPath: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let reel = reelSources[indexPath.row]
        cell.textLabel?.text = reel.address
        cell.textLabel?.textColor = UIColor.greyCurrent()
        return cell
    }
    
}

extension ExampleReelTableViewSource : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.reelDelegate.reelSelected(reelSources[indexPath.row])
    }
    
}