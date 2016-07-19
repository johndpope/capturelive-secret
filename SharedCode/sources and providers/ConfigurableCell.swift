//
//  ConfigurableCell.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation

public protocol ConfigurableCell {
    associatedtype DataSource
    func configureForObject(object:DataSource)
}