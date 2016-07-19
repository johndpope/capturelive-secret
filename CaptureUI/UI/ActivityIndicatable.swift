//
//  CMContractView.swift
//  Current
//
//  Created by Scott Jones on 9/7/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public protocol ActivityIndicatable {
    var activityIndicator:UIActivityIndicatorView? { get }
    func startActivityIndicator()
    func stopActivityIndicator()
}

extension ActivityIndicatable {
    
    public func startActivityIndicator() {
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.hidden = false
    }
    
    public func stopActivityIndicator() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.hidden = true
    }
    
}

public protocol CMViewProtocol {
    func didLoad()
}

