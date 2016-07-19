//
//  ConsoleRemote.swift
//  Trans
//
//  Created by Scott Jones on 2/23/16.
//  Copyright © 2016 *. All rights reserved.
//

import Foundation
import CaptureModel

class ConsoleRemote : CaptureLiveRemoteType {
    private func log(str:String) {
        print("--- Dummy network adapter loggin to console; ---\n", str)
    }
}

extension ConsoleRemote: AuthenticationRemoteType {
    
    func requestAuthorizationCode(number:String, completion:(NSError?)->()) {
        log("Requesting Authorization - number : \(number)")
        completion(nil)
    }
    
    func fetchAuthorizationCode(number:String, code:String, completion:(NSError?)->()) {
        log("Fetching Authorization - number : \(code), code : \(code)")
        completion(nil)
    }
}

extension ConsoleRemote: UserRemoteType {
    
    func fetchLoggedInUser(completion:(RemoteUser?, NSError?)->()) {
        log("Fetching logged in user")
        let fakeUser = [
            "url_hash"              : "b6a910c",
            "unix_created_at"       : 1456845403,
            "unix_updated_at"       : 1457961208,
            "first_name"            : "Scoats",
            "last_name"             : "Maloats",
            "phone_number"          : "9085818600",
            "contact_email"         : "scott+v3@capture.com",
            "instagram_username"    : "hatebyte",
            "paypal_email"          : "hatebyte@gmail.com",
            "avatar"                : "https://capture-media-mobile.s3.amazonaws.com/uploads/user/avatar/48/retina_1456845450.jpg"
        ]
        completion(RemoteUser(user:fakeUser), nil)
    }
    
    func updateLoggedInUser(user:User, completion:(RemoteUser?, NSError?)->()) {
        log("Updating logged in user")
        completion(RemoteUser(user:user), nil)
    }
    
    func logoutUser(completion:(NSError?)->()) {
        completion(nil)
    }
    
}

extension ConsoleRemote: DeviceRemoteType {

    func updateDeviceData(latitude:Double, longitude:Double, completion:(NSError?)->()) {
        log("updateDeviceData - latitude: \(latitude), longitude:\(longitude)")
        completion(nil)
    }
    
}

extension ConsoleRemote : EventRemoteType {

    func fetchLatestRemoteEvents(completion:([RemoteEvent], [RemoteContract])->()) {
        log("Fetching latest remote events")
        completion([], [])
    }

}

extension ConsoleRemote : ContractRemoteType {
   
    func fetchRemoteContract(contract:Contract, completion:(RemoteContract?, NSError?)->()) {
        log("Getting attachment : \(contract.urlHash)")
        completion(nil, nil)
    }
  
    func fetchCompletedRemoteContracts(completion:([RemoteContract])->()) {
        completion([])
    }

    func createRemoteContract(event:Event, completion:(RemoteContract?, NSError?)->()) {
        log("Fetching latest remote events")
        completion(nil, nil)
    }

    func deleteRemoteContract(contract:Contract, completion:(NSError?)->()) {
        completion(nil)
    }
    
    func updateRemoteContract(contract:Contract, completion:(NSError?)->()) {
        completion(nil)
    }
    
}

extension ConsoleRemote : AttachmentRemoteType {
    
    func updateAttachment(attachment:Attachment, completion:(RemoteAttachment?, NSError?)->()) {
        log("Updating attachment : \(attachment.toJSON())")
        completion(nil, nil)
    }
    
    func uploadLocalThumbnailToRemote(attachment:Attachment, completion:(String?, NSError?)->()) {
        log("Updating attachment thumbnail to s3: \(attachment.localThumbnailPath)")
        completion("remote_thumbnail_path", nil)
    }
    
}

extension ConsoleRemote : RemoteFileRemoteType {
    
    func updateRemoteFile(remoteFile:RemoteFile, completion:(NSError?)->()) {
        log("Updating notification : \(remoteFile)")
        completion(nil)
    }
    
}

extension ConsoleRemote : NotificationRemoteType {
    
    func fetchLatestRemoteNotifications(completion:([RemoteNotification])->()) {
        log("Fetching latest remote notifications")
        completion([])
    }
    
    func updateRemoteNotification(notification:Notification, completion:(NSError?)->()) {
        log("Updating notification : \(notification)")
        completion(nil)
    }
    
}



extension RemoteUser {
    
    private init?(user:User) {
        self.urlHash                = user.urlHash
        self.createdAt              = user.createdAt
        self.updatedAt              = user.updatedAt
        self.firstName              = user.firstName
        self.lastName               = user.lastName
        self.phoneNumber            = user.phoneNumber
        self.email                  = user.email
        self.instagramUsername      = user.instagramUsername
        self.paypalEmail            = user.paypalEmail
        self.bio                    = user.bio
        self.avatar                 = user.avatar
        self.ageRangeMin            = user.ageRangeMin
        self.facebookAuthToken      = user.facebookAuthToken
        self.facebookProfileUrl     = user.facebookProfileUrl
        self.workReelArray          = user.workReelArray ?? []
        self.equipmentArray         = user.equipmentArray ?? []
        self.experienceDictionary   = user.experienceDictionary ?? [:]
        self.acceptedTNCDate        = user.acceptedTNCDate
        self.totalPaymentsMade      = user.totalPaymentsMade
    }
    
}