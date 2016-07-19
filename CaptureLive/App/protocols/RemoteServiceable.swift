//
//  RemoteServiceable.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CaptureSync

protocol RemoteServiceable: class {
    var remoteService:CaptureLiveRemoteType! { get set }
}