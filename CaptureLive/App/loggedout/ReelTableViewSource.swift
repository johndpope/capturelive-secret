//
//  ReelTableViewSource.swift
//  Current
//
//  Created by Scott Jones on 4/12/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit
import CaptureModel

protocol ReelProtocol {
    func addReel()
    func editReel(reel:Reel)
}

private let ReelTableViewCellHeight:CGFloat = 54
final class ReelTableViewSource:NSObject {
    
    unowned let tableView:UITableView
    private var reelDelegate:ReelProtocol!
    internal private(set) var reels:[Reel] = []
    
    init(tableView:UITableView, reelDelegate:ReelProtocol) {
        self.tableView              = tableView
        self.reelDelegate           = reelDelegate
        super.init()
        self.tableView.dataSource   = self
        self.tableView.delegate     = self
    }
   
    func replaceReel(rs:[Reel]) {
        reels = rs
        self.tableView.reloadData()
    }
    
    func addReel(reel:Reel) {
        let r = reels.filter{ $0.source != reel.source }.flatMap { $0 }
        reels = [reel] + r
        self.tableView.reloadData()
    }
    
    func minusReels(reelSource:ReelSource) {
        reels = reels.filter{ $0.source != reelSource }.flatMap { $0 }
        self.tableView.reloadData()
    }
    
    var totalHeight:CGFloat {
        return CGFloat(reels.count) * ReelTableViewCellHeight
    }
    
}

private let ReelTableViewCell = "ReelTableViewCell"
extension ReelTableViewSource : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let c = reels.count
        if c == ReelSource.allValues.count { return c }
        return c + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReelTableViewCell, forIndexPath: indexPath)
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        let i = indexPath.row
        if reels.count == ReelSource.allValues.count {
            let reel = reels[i]
            cell.textLabel?.text = reel.url?.absoluteString
            return cell
        }
        if i == 0 {
            cell.textLabel?.text = "+ add"
        } else {
            let reel = reels[i - 1]
            cell.textLabel?.text = reel.url?.absoluteString
        }
        return cell
    }
    
}

extension ReelTableViewSource : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let i = indexPath.row
        if i == 0 {
            reelDelegate.addReel()
        } else {
            reelDelegate.editReel(reels[i - 1])
        }
    }
    
}