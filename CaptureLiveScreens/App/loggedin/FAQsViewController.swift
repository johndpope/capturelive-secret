//
//  CMAboutViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

class FAQsViewController: UIViewController, UIWebViewDelegate {
    
    var theView:FAQsView {
        return self.view as! FAQsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets       = false
        
        theView.didLoad()
        self.loadWebview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        theView.backButton?.addTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        theView.backButton?.removeTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func popBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func loadWebview() {
        self.theView.webview?.delegate          = self
        let url                                 = NSURL(string:"https://currenthelp.zendesk.com/hc/en-us")
        let urlRequest                          = NSURLRequest(URL:url!)
        self.theView.webview?.loadRequest(urlRequest)
    }
    
    
    //MARK: Webview delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.theView.activityIndicator?.stopAnimating()
        self.theView.activityIndicator?.removeFromSuperview()
        let theDelay: Double                    = 0.2
        UIView.animateWithDuration( theDelay, animations: {
            self.theView.webview!.alpha = CGFloat(1.0)
        })
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.alertWebviewFailedToLoad()
    }
    
    
    // MARK: Alert
    func alertWebviewFailedToLoad() {
        let title                               = NSLocalizedString("Error", comment:"CMSupportViewController : failedToLoad : alertTitle")
        let message                             = NSLocalizedString("There was a problem loading\nCurrent FAQ at this time.", comment:"CMSupportViewController : failedToLoad : alertMessage")
        let buttonTitle                         = NSLocalizedString("Retry", comment:"CMSupportViewController : failedToLoad : retryButtonTitle")
        let alertViewController                 = CMAlertController(title:title, message:message)
        let refreshAction = CMAlertAction(title:buttonTitle, style: .Primary) { () -> () in
            self.loadWebview()
        }
        let cancelButtonTitle                   = NSLocalizedString("Cancel", comment:"CMSupportViewController : failedToLoad : cancelButtonTitle")
        let cancelAction = CMAlertAction(title:cancelButtonTitle, style: .Secondary) { () -> () in
            self.popBack()
        }
        
        alertViewController.addAction(refreshAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
    
}
