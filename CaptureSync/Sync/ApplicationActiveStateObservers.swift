//
//  ApplicationActiveStateObservers.swift
//  Trans
//
//  Created by Scott Jones on 2/21/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation

protocol ObserverTokenStore : class {
    func addObserverToken(token:NSObjectProtocol)
}

protocol ApplicationActiveStateObserving: class, ObserverTokenStore {
    
    func performGroupedBlock(block:()->())
    
    // Called when application becomes active
    func applicationDidBecomeActive()
    func applicationDidEnterBackground()
}

extension ApplicationActiveStateObserving {
    func setupApplicationActiveNotifications() {
        addObserverToken(NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.performGroupedBlock {
                observer.applicationDidEnterBackground()
            }
        })
        addObserverToken(NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.performGroupedBlock {
                observer.applicationDidBecomeActive()
            }
        })
        if UIApplication.sharedApplication().applicationState == .Active {
            applicationDidBecomeActive()
        }
    }
}

protocol ApplicationRequestModelDataObserving:ApplicationActiveStateObserving {
    func applicationDidRequestMoreEventData()
}
public let CaptureRequestsFetchRemoteDataNotification = "CaptureRequestsFetchRemoteDataNotification"
extension ApplicationRequestModelDataObserving {
    func setupForEventsFetchRequestNotication() {
        addObserverToken(NSNotificationCenter.defaultCenter().addObserverForName(CaptureRequestsFetchRemoteDataNotification, object: nil, queue: nil) { [weak self] note in
            guard let observer = self else { return }
            observer.performGroupedBlock {
                observer.applicationDidRequestMoreEventData()
            }
        })
    }
}


