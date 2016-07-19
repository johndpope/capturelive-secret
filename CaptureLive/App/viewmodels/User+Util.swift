//
//  User+Util.swift
//  Current
//
//  Created by Scott Jones on 4/10/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

extension User {

    func viewModel()->UserDetails {
        let uModel = UserDetails(
            fullNameString: "\(firstName) \(lastName)"
            ,avatarURLString:avatar ?? ""
            ,emailString: email ?? ""
        )
        return uModel
        
    }
    
    func paypalModel()->UserPaypalModel {
        let totalAmountPaid = Contract.fetchTotalPaymentsMade(managedObjectContext!)
        let uModel = UserPaypalModel(
             hasPaypalEmailBool: User.hasPaypalEmailPredicate.evaluateWithObject(self)
            ,needsPaypalEmailBool : needsPaypalEmail
            ,paypalEmailString: paypalEmail
            ,totalAmountDouble: totalAmountPaid
        )
        return uModel
    }
    
}