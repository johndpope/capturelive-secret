//
//  UserViewModel.swift
//  Current
//
//  Created by Scott Jones on 9/2/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

struct UserDetails {

    let fullNameString:String
    let avatarURLString:String
    let emailString:String
}

struct UserPaypalModel {
    let hasPaypalEmailBool:Bool
    let needsPaypalEmailBool:Bool
    let paypalEmailString:String?
    let totalAmountDouble:Double
}

extension UserPaypalModel {

    var totalAmountString:String {
        let moneySymbol                         = NSLocalizedString("$", comment:"money symbol")
        return String(NSString(format:"%@%.0f", moneySymbol, totalAmountDouble))
    }
    
}
