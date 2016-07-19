//
//  CMTermsConditionsViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class TermsConditionsViewController: UIViewController, UIWebViewDelegate {
    
    var theView:TermsConditionsView {
        return self.view as! TermsConditionsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets       = false
        
        self.theView.didLoad()
        self.loadWebview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 7 view support
        self.theView.topConstraint?.constant            = 0
        self.edgesForExtendedLayout                     = .None
        self.view.layoutIfNeeded()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addEventHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    func addEventHandlers() {
        self.theView.backButton?.addTarget(self, action: #selector(TermsConditionsViewController.popBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.backButton?.removeTarget(self, action: #selector(TermsConditionsViewController.popBack), forControlEvents: .TouchUpInside)
    }
    
    func loadWebview() {
        self.theView.webview?.delegate                  = self
        let url                                         = NSURL(string:"https://capture.com/capture-live-terms")
        let urlRequest                                  = NSURLRequest(URL:url!)
        self.theView.webview?.loadRequest(urlRequest)
    }
    
    //MARK: Webview delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.theView.activityIndicator?.stopAnimating()
        self.theView.activityIndicator?.removeFromSuperview()
        let theDelay: Double = 0.2
        UIView.animateWithDuration( theDelay, animations: {
            self.theView.webview!.alpha = CGFloat(1.0)
        })
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.alertWebviewFailedToLoad()
    }
    
    //MARK: Navigation
    func popBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: Alert
    func alertWebviewFailedToLoad() {
        let title                                       = NSLocalizedString("Error", comment:"TermsConditions : failedToLoad : alertTitle")
        let message                                     = NSLocalizedString("There was a problem loading\nTerms & Conditions at this time.", comment:"TermsConditions : failedToLoad : alertMessage")
        let buttonTitle                                 = NSLocalizedString("Retry", comment:"TermsConditions : failedToLoad : retryButtonTitle")
        let alertViewController                         = CMAlertController(title:title, message:message)
        let refreshAction = CMAlertAction(title:buttonTitle, style: .Primary) { () -> () in
            self.loadWebview()
        }
        let cancelButtonTitle                           = NSLocalizedString("Cancel", comment:"TermsConditions : failedToLoad : cancelButtonTitle")
        let cancelAction = CMAlertAction(title:cancelButtonTitle, style: .Secondary) { () -> () in
            self.popBack()
        }
        
        alertViewController.addAction(refreshAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
    
}
