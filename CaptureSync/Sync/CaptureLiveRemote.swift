//
//  UserRemote.swift
//  Current
//
//  Created by Scott Jones on 3/10/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CaptureModel

public typealias UrlHash       = String
public typealias AccessToken   = String

public enum RemoteRecordChange<T:RemoteRecordType> {
    case Insert(T)
    case Update(T)
    case Delete(T)
}

public enum RemoteError {
    case Permanent
    case Temporary
    var isPermanent:Bool {
        switch self {
        case .Permanent: return true
        default: return false
        }
    }
}

public protocol AuthenticationRemoteType:class {
    
    func requestAuthorizationCode(number:String, completion:(NSError?)->())
    func fetchAuthorizationCode(number:String, code:String, completion:(NSError?)->())
    
}

public protocol UserRemoteType:class {
    
    func fetchLoggedInUser(completion:(RemoteUser?, NSError?)->())
    func updateLoggedInUser(user:User, completion:(RemoteUser?, NSError?)->())
    func logoutUser(completion:(NSError?)->())
    
}

public protocol DeviceRemoteType:class {
    
    func updateDeviceData(latitude:Double, longitude:Double, completion:(NSError?)->())
    
}


public protocol EventRemoteType:class {
    
    func fetchLatestRemoteEvents(completion:([RemoteEvent], [RemoteContract])->())
    
}

public protocol AttachmentRemoteType:class {
    
    func updateAttachment(attachment:Attachment, completion:(RemoteAttachment?, NSError?)->())
//    func updateAttachments(attachments:[Attachment], completion:([RemoteAttachment], NSError?)->())
//    func completeAttachment(attachment:Attachment, completion:([RemoteAttachment], NSError?)->())
    func uploadLocalThumbnailToRemote(attachment:Attachment, completion:(String?, NSError?)->())
    
}

public protocol RemoteFileRemoteType:class {
    
    func updateRemoteFile(remoteFile:RemoteFile, completion:(NSError?)->())
    
}

public protocol ContractRemoteType:class {
   
    func fetchRemoteContract(contract:Contract, completion:(RemoteContract?, NSError?)->())
    func fetchCompletedRemoteContracts(completion:([RemoteContract])->())
    func createRemoteContract(event:Event, completion:(RemoteContract?, NSError?)->())
    func deleteRemoteContract(contract:Contract, completion:(NSError?)->())
    func updateRemoteContract(contract:Contract, completion:(NSError?)->())
 
}


public protocol NotificationRemoteType:class {
    
    func fetchLatestRemoteNotifications(completion:([RemoteNotification])->())
    func updateRemoteNotification(notification:Notification, completion:(NSError?)->())

}

public protocol CaptureLiveRemoteType:class
    ,AuthenticationRemoteType
    ,UserRemoteType
    ,DeviceRemoteType
    ,EventRemoteType
    ,ContractRemoteType
    ,AttachmentRemoteType
    ,RemoteFileRemoteType
    ,NotificationRemoteType
{}









