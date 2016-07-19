//
//  TermsOfServiceViewController.swift
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

typealias TermsAndServiceCompleted = (accepted:Bool)->()
class TermsOfServiceRegistrationViewController: UIViewController, UIWebViewDelegate, RemoteAndLocallyServiceable {
    
    var managedObjectContext: NSManagedObjectContext!
    var remoteService: CaptureLiveRemoteType!
    var attemptingUser:User!
    
    var theView:TermsOfServiceRegistrationView {
        guard let v = self.view as? TermsOfServiceRegistrationView else { fatalError("Not a \(TermsOfServiceRegistrationView.self)!") }
        return v
    }
    
    var termsCompleted:TermsAndServiceCompleted!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
        loadWebview()
        self.theView.agreeButton?.enabled               = false
        self.theView.disagreeButton?.enabled            = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeEventHandlers()
    }
    
    func addEventHandlers() {
        self.theView.closeButton?.addTarget(self, action: #selector(denyTerms), forControlEvents: .TouchUpInside)
        self.theView.disagreeButton?.addTarget(self, action: #selector(denyTerms), forControlEvents: .TouchUpInside)
        self.theView.agreeButton?.addTarget(self, action: #selector(acceptedTerms), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.closeButton?.removeTarget(self, action: #selector(denyTerms), forControlEvents: .TouchUpInside)
        self.theView.disagreeButton?.removeTarget(self, action: #selector(denyTerms), forControlEvents: .TouchUpInside)
        self.theView.agreeButton?.removeTarget(self, action: #selector(acceptedTerms), forControlEvents: .TouchUpInside)
    }
    
    func loadWebview() {
        theView.startActivityIndicator()
        self.theView.webView?.delegate                  = self
        let url                                         = NSURL(string:"https://\("capture.com")/terms")
        print(url!.absoluteString)
        let urlRequest                                  = NSURLRequest(URL:url!)
        self.theView.webView?.loadRequest(urlRequest)
    }
   
    func acceptedTerms(){
        self.termsCompleted(accepted:true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func denyTerms() {
        self.termsCompleted(accepted:false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Webview delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.theView.stopActivityIndicator()
        let theDelay: Double                            = 0.2
        UIView.animateWithDuration( theDelay, animations: {
            self.theView.webView!.alpha = CGFloat(1.0)
        })
        self.theView.agreeButton?.enabled               = true
        self.theView.disagreeButton?.enabled            = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.theView.stopActivityIndicator()
        self.alertWebviewFailedToLoad()
    }
    
    func acceptTermsAndConditions() {
        theView.startActivityIndicator()
        removeEventHandlers()
    }
    
    
    //MARK: Alert
    func alertWebviewFailedToLoad() {
        let title                                       = NSLocalizedString("Error", comment:"TermsConditions : failedToLoad : alertTitle")
        let message                                     = NSLocalizedString("There was a problem loading\nTerms & Conditions at this time.", comment:"TermsConditions : failedToLoad : alertMessage")
        let buttonTitle                                 = NSLocalizedString("Retry", comment:"TermsConditions : failedToLoad : retryButtonTitle")
        let alertViewController                         = CMAlertController(title:title, message:message)
        let refreshAction = CMAlertAction(title:buttonTitle, style: .Primary) { [unowned self] in
            self.loadWebview()
        }
        let cancelButtonTitle                           = NSLocalizedString("Cancel", comment:"TermsConditions : failedToLoad : cancelButtonTitle")
        let cancelAction = CMAlertAction(title:cancelButtonTitle, style: .Secondary) { [unowned self] in
            self.denyTerms()
        }
        
        alertViewController.addAction(refreshAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let vc                                    = segue.destinationViewController as? RemoteAndLocallyServiceable else { fatalError("DestinationViewController \(segue.destinationViewController.self) does not conform to RemoteAndLocallyServiceable") }
        vc.managedObjectContext                         = managedObjectContext
        vc.remoteService                                = remoteService
    }

}
