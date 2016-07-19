//
//  Publisher+Util.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

extension Publisher {
   
    var fullName:String {
        return "\(firstName) \(lastName)"
    }
    
    func hiredViewModel()->PublisherHiredViewModel {
        let teamName                = team?.name ?? "FPO team name"
        let aUrl                    = avatarUrl ?? "avatar_url"
        let fName                   = firstName ?? "F_name"
        let lName                   = lastName ?? "L_name"
        var lChar                   = ""
        if let lastChar1 = lName.characters.first {
            lChar                   = String(lastChar1)
        }
        
        let titleNameString         = "\(fName) \(lChar)"
        let hiredString             = NSLocalizedString("from %@ hired you.", comment: "Publisher : hiredViewModel : hiredString")
        let callString              = NSLocalizedString("call %@", comment: "Publisher : hiredViewModel : callString")
        let textString              = NSLocalizedString("send a text", comment: "Publisher : hiredViewModel : textString")
        return PublisherHiredViewModel(
             titleNameString        : titleNameString
            ,hiredYouString         : String(NSString(format: hiredString, teamName))
            ,avatarURLString        : aUrl
            ,callString             : String(NSString(format: callString, fName))
            ,textString             : textString
        )
    }
    
}