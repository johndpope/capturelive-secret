//
//  FacebookAuthable.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/3/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

public protocol FacebookAuthAble {
    func fetchedFacebookUser(faceuser:FacebookUser)
    func fetchFacebookUserDidFail(error:NSError)
}

extension FacebookAuthAble where Self:UIViewController {
    
    public func requestFacebookAuthorization() {
        //FBSDKLoginManagerLoginResult
        let login                   = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { [unowned self] loginManagerResult, error in
            guard let result = loginManagerResult else {
                self.fetchFacebookUserDidFail(error)
                return
            }
            if result.isCancelled {
                // show alert
                guard let e = error else { return }
                self.fetchFacebookUserDidFail(e)
                return
            }
            
            self.fetchuser()
        }
    }
    
    internal func fetchuser() {
        let params = ["fields": "id,name,first_name,last_name,age_range,link,gender,locale,picture,timezone,updated_time,verified,email"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).startWithCompletionHandler { [unowned self] connection, connectionResult, error in
            guard let meResult = connectionResult as? [NSObject:AnyObject] else {
                // show alert
                guard let e = error else { return }
                self.fetchFacebookUserDidFail(e)
                return
            }
            print(meResult)
            var facebookUser            = FacebookUser(json:meResult)
            facebookUser.token          = FBSDKAccessToken.currentAccessToken().tokenString
            self.fetchedFacebookUser(facebookUser)
        }
    }
    
}