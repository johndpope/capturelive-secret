//
//  CurrentAPIService.swift
//  Current
//
//  Created by Scott Jones on 3/13/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers
import CaptureModel
import CaptureSync
import Alamofire

public final class CaptureLiveAlamoFireService : CaptureLiveRemoteType {
    
    private var persistanceLayer:APIPersistable
    
    public init(persistanceLayer:APIPersistable) {
        self.persistanceLayer = persistanceLayer
    }
   
    public var hasAccessToken:Bool {
        return self.persistanceLayer.accessToken != nil
    }
    
    func parseError(response:Response<AnyObject, NSError>) -> NSError? {
        do {
            let userInfo = try NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [String:AnyObject]
            guard let error = response.result.error else {
                return response.result.error
            }
            guard let statusCode = response.response?.statusCode else {
                return response.result.error
            }
            return NSError(domain:error.domain, code:statusCode, userInfo:userInfo)
        } catch {
            return response.result.error
        }
    }
    
}

extension CaptureLiveAlamoFireService : DeviceRemoteType {
    
    public func updateDeviceData(latitude:Double, longitude:Double, completion:(NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else {
            completion(nil)
            return
        }
        let uuid =  self.persistanceLayer.uuid
        let params = self.persistanceLayer.appSpecsWithToken
            .union( self.persistanceLayer.liveDeviceSpecs)
            .union(["latitude":NSNumber(double: latitude), "longitude":NSNumber(double:longitude)])
       
//        print(params)
        Alamofire.request(
            DeviceUpdateRouter.UpdateDevice(
                deviceUuid          : uuid,
                params              : params,
                accessToken         : accessToken
            ))
            .validate()
            .responseJSON { response in
//                print("VALUE : \(response.result.value)")
                switch response.result {
                case .Success:
//                    print("SUCCESS")
                    completion(nil)
                case .Failure(let error):
                    print("POST REQUEST ERROR - \(error.localizedDescription)")
//                    print("=== REQUEST INFORMATION ===")
//                    print("Status Code: \(response.response!.statusCode)")
//                    print("Request URL: \(response.request!.URLString)")
//                    print("===")
                    completion(error)
                }
                
        }
    }
    
}

extension CaptureLiveAlamoFireService : AuthenticationRemoteType {

    public func requestAuthorizationCode(number:String, completion:(NSError?)->()) {
       Alamofire.request(
        AuthenticationRouter.TempToken)
        .validate()
        .responseJSON { response in

            guard response.result.isSuccess else {
                print("Error requesting temporary access token")
                print("POST REQUEST ERROR - \(response.result.error!.localizedDescription)")
                print("=== REQUEST INFORMATION ===")
                print("Status Code: \(response.response!.statusCode)")
                print("Request URL: \(response.request!.URLString)")
                print("===")

                completion(response.result.error)
                return
            }
           
            guard let responseJSON = response.result.value as? [String:AnyObject],
                tempToken = responseJSON["access_token"] as? String else {
                    print("Error requesting temporary access token, no access code returne")
                    completion(response.result.error)
                    return
            }
           
            Alamofire.request(
                AuthenticationRouter.RequestCode(number: number, accessCode:tempToken))
                .validate()
                .responseString { response in
                    switch response.result {
                    case .Success:
                        completion(nil)
                    case .Failure(let error):
                        completion(response.result.error)
                        print("POST REQUEST ERROR - \(error.localizedDescription)")
                        print("=== REQUEST INFORMATION ===")
                        print("Status Code: \(response.response!.statusCode)")
                        print("Request URL: \(response.request!.URLString)")
                        print("===")
                    }
            }
            
        }
    }
    
    public func fetchAuthorizationCode(number:String, code:String, completion:(NSError?)->()) {
        Alamofire.request(
            AuthenticationRouter.Authorize(number: number, code:code))
            .validate()
            .responseJSON { [unowned self] response in
                guard response.result.isSuccess else {
                    print("Error requesting text authorization code")
                    completion(response.result.error)
                    return
                }
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    accessToken = responseJSON["access_token"] as? String else {
                        print("Error requesting temporary access token, no access code returned")
                        completion(response.result.error)
                        return
                }
                
                self.persistanceLayer.saveToken(accessToken)
                completion(nil)
        }
    }
   
}

extension CaptureLiveAlamoFireService : UserRemoteType {

    public func fetchLoggedInUser(completion:(RemoteUser?, NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else {
            completion(nil, nil)
            return
        }
        Alamofire.request(
            UserRouter.GetUser(accessToken:accessToken))
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error requesting user : \(response.result.error)")
                    completion(nil, response.result.error)
                    return
                }
//                print(response.result.value)
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    user = responseJSON["user"] as? [String:AnyObject] else {
                        print("Error requesting user, no user returned : \(response.result.value)")
                        completion(nil, response.result.error)
                        return
                }
                
                completion(RemoteUser(user:user), nil)
        }
    }
    
    public func updateLoggedInUser<U:JSONHashable>(user:U, completion:(RemoteUser?, NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else {
            fatalError("There is no access token")
        }
//        print(user.toJSON())
        Alamofire.request(
            UserRouter.UpdateUser(user:user.toJSON(), accessToken:accessToken))
            .validate()
            .responseJSON { [unowned self] response in
                guard response.result.isSuccess else {
                    completion(nil, self.parseError(response))
                    return
                }
//                print("FROM USER UPDATE")
//                print(response.result.value)
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    user = responseJSON["user"] as? [String:AnyObject] else {
                        completion(nil, response.result.error)
                        return
                }
                completion(RemoteUser(user: user), nil)
        }
    }
    
    public func logoutUser(completion:(NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else {
            fatalError("There is no access token")
        }
        Alamofire.request(
            UserRouter.LogOutUser(accessToken:accessToken))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
//                    print("SUCCESS")
//                    print(response.result.value)
                    completion(nil)
                case .Failure(let error):
                    completion(error)
                    print("POST REQUEST ERROR - \(error.localizedDescription)")
//                    print("=== REQUEST INFORMATION ===")
//                    print("Status Code: \(response.response!.statusCode)")
//                    print("Request URL: \(response.request!.URLString)")
//                    print("===")
                }
        }
    }
        
}

extension CaptureLiveAlamoFireService : EventRemoteType {
    
    public func fetchLatestRemoteEvents(completion:([RemoteEvent], [RemoteContract])->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        Alamofire.request(
            EventRouter.AllEvents(accessToken:accessToken))
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion([], [])
                    return
                }
//                print(response.result.value)
                var revents:[RemoteEvent] = []
                if let responseJSON = response.result.value as? [String:AnyObject],
                    events = responseJSON["events"] as? [[String:AnyObject]] {
                        revents = events.map { RemoteEvent(event:$0) }
                }
//                print(revents)
                var rcontracts:[RemoteContract] = []
                if let responseJSON = response.result.value as? [String:AnyObject],
                    meta = responseJSON["meta"] as? [String:AnyObject],
                    contracts = meta["upcoming_contracts"] as? [[String:AnyObject]] {
                        rcontracts = contracts.map { RemoteContract(contract:$0) }
                }
                completion(revents, rcontracts)
        }
    }

}

extension CaptureLiveAlamoFireService : ContractRemoteType {
   
    public func fetchRemoteContract(contract:Contract, completion:(RemoteContract?, NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        Alamofire.request(
            ContractRouter.FetchContract(contractUrlHash:contract.urlHash, accessToken:accessToken))
            .validate()
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    print("Error fetching contract : \(response.result.error)")
                    completion(nil, response.result.error)
                    return
                }
//                print(response.result.value as? [String:AnyObject])
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    contract = responseJSON["contract"] as? [String:AnyObject] else {
                        completion(nil, response.result.error)
                        return
                }
                completion(RemoteContract(contract: contract), nil)
        }
    }
   
    public func fetchCompletedRemoteContracts(completion:([RemoteContract])->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        Alamofire.request(
            ContractRouter.JobHistory(filter:.All, accessToken:accessToken))
            .validate()
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    print("Error fetching contract : \(response.result.error)")
                    completion([])
                    return
                }
//                print(response.result.value as? [String:AnyObject])
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    contracts = responseJSON["contracts"] as? [[String:AnyObject]] else {
                        completion([])
                        return
                }
                let rcontracts = contracts.map { RemoteContract(contract:$0) }
                completion(rcontracts)
                
        }
    }

    public func createRemoteContract(event:Event, completion:(RemoteContract?, NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        Alamofire.request(
            ContractRouter.CreateContract(eventUrlHash:event.urlHash, accessToken:accessToken))
            .validate()
            .responseJSON { response in
       
                guard response.result.isSuccess else {
                    print("Error creating contract : \(response.result.error)")
                    completion(nil, response.result.error)
                    return
                }
//                print(response.result.value as? [String:AnyObject])
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    contract = responseJSON["contract"] as? [String:AnyObject] else {
                        completion(nil, response.result.error)
                        return
                }
                completion(RemoteContract(contract: contract), nil)

        }
    }
    
    public func deleteRemoteContract(contract:Contract, completion:(NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        Alamofire.request(
            ContractRouter.DeleteContract(urlHash:contract.urlHash, accessToken:accessToken))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    completion(nil)
                case .Failure(let error):
                    completion(error)
                }
        }
    }
    
    public func updateRemoteContract(contract:Contract, completion:(NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        Alamofire.request(
            ContractRouter.UpdateContract(urlHash:contract.urlHash, contract: contract.toJSON(), accessToken:accessToken))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
//                    print("SUCCESS")
//                    print(response.result.value)
                    completion(nil)
                case .Failure(let error):
                    completion(error)
//                    print("POST REQUEST ERROR - \(error.localizedDescription)")
//                    print("=== REQUEST INFORMATION ===")
//                    print("Status Code: \(response.response!.statusCode)")
//                    print("Request URL: \(response.request!.URLString)")
//                    print("===")
                }
        }
    }
    
}


extension CaptureLiveAlamoFireService : AttachmentRemoteType {
    
    public func updateAttachment(attachment:Attachment, completion:(RemoteAttachment?, NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
//        print(attachment.toJSON())
        Alamofire.request(
            AttachmentRouter.UpdateAttachment(
                 uuid               : attachment.uuid
                ,contractUrlHash    : attachment.contract.urlHash
                ,attachmentJSON     : attachment.toJSON()
                ,accessToken        : accessToken
            ))
            .validate()
            .responseJSON { response in
            
                guard response.result.isSuccess else {
                    print("Error updating attachment : \(response.result.error)")
                    completion(nil, response.result.error)
                    return
                }
//                print(response.result.value)
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    attachment = responseJSON["attachment"] as? [String:AnyObject] else {
                        completion(nil, response.result.error)
                        return
                }
                completion(RemoteAttachment(attachment: attachment), nil)
            
        }
    }
    
    public func uploadLocalThumbnailToRemote(attachment:Attachment, completion:(String?, NSError?)->()) {
        guard let localpath = attachment.localThumbnailPath else {
            return
        }
        let uploaderModel       = CMS3ThumbnailUploaderModel(path:localpath, keyname:attachment.uuid)
        let uploader            = S3ThumbnailUploader(model:uploaderModel)
        uploader.upload(NSBundle(forClass: CaptureLiveAlamoFireService.self), complete: { path in
            completion(path, nil)
 
            }, error: { error in
                print(error)
                completion(nil, error)
 
        })
    }
    
}

extension CaptureLiveAlamoFireService : RemoteFileRemoteType {
    
    public func updateRemoteFile(remoteFile:RemoteFile, completion:(NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        
        Alamofire.request(
            AttachmentRouter.UpdateRemoteRemoteFile(
                 uuid           : remoteFile.attachment.uuid
                ,remoteFileJSON : remoteFile.toJSON()
                ,accessToken    : accessToken
            ))
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error updating remote file : \(response.result.error)")
                    completion(response.result.error)
                    return
                }
//                print(response.result.value)
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    _ = responseJSON["attachment"] as? [String:AnyObject] else {
                        completion(response.result.error)
                        return
                }
                completion(nil)
        }
    }
    
}


extension CaptureLiveAlamoFireService : NotificationRemoteType {
    
    public func fetchLatestRemoteNotifications(completion:([RemoteNotification])->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        
        Alamofire.request(
            NotificationRouter.UnreadNotifications(accessToken:accessToken))
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error downloading notifications : \(response.result.error)")
                    completion([])
                    return
                }

//                print(response.result.value)
                var notifications:[RemoteNotification] = []
                if let responseJSON = response.result.value as? [String:AnyObject],
                    pushNotes = responseJSON["push_notifications"] as? [[String:AnyObject]] {
                    notifications = pushNotes.map { RemoteNotification(notification:$0) }
                }

                completion(notifications.removeTestsNotifications())
        }
    }
    
    public func updateRemoteNotification(notification:Notification, completion:(NSError?)->()) {
        guard let accessToken = self.persistanceLayer.accessToken else { return }
        guard let readAt = notification.readAt else { fatalError("Notification cannot be missing readAt date when updating") }
        
        Alamofire.request(
            NotificationRouter.UpdateRemoteNotification(
                 notificationHash   : notification.urlHash
                ,readDate           : readAt
                ,accessToken        : accessToken
            ))
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error updating notification file : \(response.result.error)")
                    completion(response.result.error)
                    return
                }
//                print(response.result.value)
                guard let responseJSON = response.result.value as? [String:AnyObject],
                    _ = responseJSON["attachment"] as? [String:AnyObject] else {
                        completion(response.result.error)
                        return
                }
                completion(nil)
        }
    }
    
}


private  let APITokenKey            = "com.capture.ios.apitoken"
extension NSManagedObjectContext:AccessTokenRetrivable {
    
    public func saveToken(token:String) {
        setMetaData(token, key:APITokenKey)
    }
    public var accessToken:String? {
        return metaData[APITokenKey] as? String
    }
    
    public var hasAccessToken:Bool {
        return accessToken != nil
    }
    
}
