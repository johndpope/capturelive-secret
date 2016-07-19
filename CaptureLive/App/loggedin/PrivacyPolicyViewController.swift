//
//  PrivacyPolicyViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/26/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import CaptureUI

extension PrivacyPolicyViewController : CYNavigationPop {
    var popAnimator:UIViewControllerAnimatedTransitioning? {
        return PopRightAnimator()
    }
}

class PrivacyPolicyViewController: UIViewController, NavGesturable, UIWebViewDelegate  {
    
    var theView:PrivacyPolicyView {
        return self.view as! PrivacyPolicyView
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
//        self.showReachiblity()
        navGesturer?.usePushRightPopLeftGestureRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeEventHandlers()
    }
    
    func addEventHandlers() {
        self.theView.backButton?.addTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.backButton?.removeTarget(self, action: #selector(popBack), forControlEvents: .TouchUpInside)
    }
    
    func loadWebview() {
        self.theView.webview?.delegate                  = self
        let url                                         = NSURL(string:"https://\(NSBundle.CoreBundle.wwwURL)/privacy")
        print(url!.absoluteString)
        
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
    
    func acceptTermsAndConditions() {
        //        self.navigateToRegistration()
    }
    
    
    //MARK: Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "pushToRegistration" {
//            let vc                                      = segue.destinationViewController as! CMCreateProfileViewController
//            vc.urlHash                                  = User.attemptingLoginUserUrlHash()
//        }
//    }
    
    func navigateToRegistration() {
        //        self.performSegueWithIdentifier("pushToRegistration", sender: self)
    }
    
    func popBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Alert
    func alertWebviewFailedToLoad() {
        let title                                       = NSLocalizedString("Error", comment:"TermsConditions : failedToLoad : alertTitle")
        let message                                     = NSLocalizedString("There was a problem loading\n Privacy Policy at this time.", comment:"PrivacyPolicy : failedToLoad : alertMessage")
        let buttonTitle                                 = NSLocalizedString("Retry", comment:"PrivacyPolicy : failedToLoad : retryButtonTitle")
        let alertViewController                         = CMAlertController(title:title, message:message)
        let refreshAction = CMAlertAction(title:buttonTitle, style: .Primary) { () -> () in
            self.loadWebview()
        }
        let cancelButtonTitle                           = NSLocalizedString("Cancel", comment:"PrivacyPolicy : failedToLoad : cancelButtonTitle")
        let cancelAction = CMAlertAction(title:cancelButtonTitle, style: .Secondary) { () -> () in
            self.popBack()
        }
        
        alertViewController.addAction(refreshAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
    
}
