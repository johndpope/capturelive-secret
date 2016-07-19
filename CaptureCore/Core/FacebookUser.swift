//
//  FacebookUser.swift
//  Current
//
//  Created by Scott Jones on 4/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

public struct FacebookUser {
    
    public let firstName:String?
    public let lastName:String?
    public let ageRangeMin:UInt16
    public var avatarPath:String?   = nil
    public let email:String?
    public var token:String?        = nil
    public let profileUrl:String?
    
    public init(json:[NSObject:AnyObject]) {
        firstName                   = json["first_name"] as? String
        lastName                    = json["last_name"] as? String
        email                       = json["email"] as? String
        profileUrl                  = json["link"] as? String
        var ar:UInt16               = 0
        if let range = json["age_range"], min = range["min"] {
            if let ta = min?.unsignedShortValue {
                ar                  = ta
            }
        }
        ageRangeMin = ar
        guard let id = json["id"] as? String else {
            return
        }
        avatarPath                  = "https://graph.facebook.com/\(id)/picture?height=600&width=600"
    }

}

extension FacebookUser : AgeRangeLimitable {}
extension FacebookUser {
   
    public init(user:User) {
        firstName                   = user.firstName
        lastName                    = user.lastName
        email                       = user.email
        ageRangeMin                 = user.ageRangeMin
        avatarPath                  = user.avatar
        token                       = user.facebookAuthToken
        profileUrl                  = user.facebookProfileUrl ?? ""
    }
    
}

extension User {
    
    public func mapFromFacebook(fuser:FacebookUser) {
        self.firstName               = fuser.firstName
        self.lastName                = fuser.lastName
        self.email                   = fuser.email
        self.remoteAvatarUrl         = fuser.avatarPath
        self.avatar                  = fuser.avatarPath
        guard let token = fuser.token else { fatalError("No facebook token") }
        self.facebookAuthToken       = token
        self.facebookProfileUrl      = fuser.profileUrl
        self.ageRangeMin             = fuser.ageRangeMin
    }
    
}
