//
//  CurrentAPIServicable.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreLocation
import AWSCore

public protocol AccessTokenRetrivable {
    func saveToken(token:String)
    var accessToken:String? { get }
    var hasAccessToken:Bool { get }
}

