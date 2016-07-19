//
//  NoficationTableSource.swift
//  CaptureLive
//
//  Created by Scott Jones on 4/27/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

import UIKit
import CaptureModel
import CoreData
import CaptureCore

protocol NotificationTableProtocol {
    func didSelectEvent(event:Event)
}

final class NotificationTableSource:NSObject {
    
    unowned let tableView:UITableView
    unowned let moc:NSManagedObjectContext
    private var notificatioDelegate:NotificationTableProtocol!
    internal private(set) var events:[Event] = []
    internal private(set) var eventsModels:[NotificationTableCellViewModel] = []

    init(tableView:UITableView, moc:NSManagedObjectContext, notificatioDelegate:NotificationTableProtocol) {
        self.tableView              = tableView
        self.moc                    = moc
        self.notificatioDelegate    = notificatioDelegate
        super.init()
        self.tableView.dataSource   = self
        self.tableView.delegate     = self
    }

    func fetch() {
        let readEvents              = Event.fetchAllsWithOnlyReadNotifications(moc)
        let unreadEvents            = Event.fetchAllWithAnyUnreadNotifications(moc)
        events                      = unreadEvents + readEvents
        eventsModels = events.map { e in
            guard let note = e.mostRecentNotification else { fatalError("No notification for a event in the notifications table") }
            return note.tableCellViewModel()
        }
        self.tableView.reloadData()
    }
    
}

extension NotificationTableSource : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return eventsModels[indexPath.row].cellHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsModels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(NotificationTableCell.Identifier, forIndexPath: indexPath) as? NotificationTableCell else { fatalError("No tablecell with identifier to NotificationTableCell") }
        let event = eventsModels[indexPath.row]
        cell.prepareForUse(event)
        return cell
    }
    
}

extension NotificationTableSource : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        notificatioDelegate.didSelectEvent(events[indexPath.row])
    }
    
}