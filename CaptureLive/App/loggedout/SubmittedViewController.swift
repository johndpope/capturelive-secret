//
//  SubmittedViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureModel
import CaptureSync
import CaptureCore
import CoreData

class SubmittedViewController: UIViewController, RemoteAndLocallyServiceable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var attemptingUser:User!
    
    var theView:SubmittedView {
        guard let v = self.view as? SubmittedView else { fatalError("Not a \(SubmittedView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let attemptUser = User.attemptingLoginUser(managedObjectContext) else {
            fatalError("No attempting login user")
        }
        attemptingUser = attemptUser
        theView.didLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        theView.animateIn() { [unowned self] in
            self.loginUser()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginUser() {
        self.managedObjectContext.performChangesAndWait {
            self.attemptingUser.setAsLoggedInUser()
        }        
        
        // send login notification
        NSNotificationCenter.defaultCenter().postNotificationName(CaptureRequestsFetchRemoteDataNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(CaptureAppNotification.Login.rawValue, object: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
