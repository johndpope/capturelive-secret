//
//  TermsOfServiceViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class TermsOfServiceRegistrationViewController: UIViewController, UIWebViewDelegate {

    var theView:TermsOfServiceRegistrationView {
        guard let v = self.view as? TermsOfServiceRegistrationView else { fatalError("Not a \(TermsOfServiceRegistrationView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theView.didLoad()
        loadWebview()
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
        self.theView.closeButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        self.theView.disagreeButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        self.theView.agreeButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func removeEventHandlers() {
        self.theView.closeButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        self.theView.disagreeButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        self.theView.agreeButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func loadWebview() {
        self.theView.webView?.delegate                  = self
        let url                                         = NSURL(string:"https://\("capture.com")/terms")
        print(url!.absoluteString)
        let urlRequest                                  = NSURLRequest(URL:url!)
        self.theView.webView?.loadRequest(urlRequest)
    }
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Webview delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.theView.activityIndicator?.stopAnimating()
        self.theView.activityIndicator?.removeFromSuperview()
        let theDelay: Double                            = 0.2
        UIView.animateWithDuration( theDelay, animations: {
            self.theView.webView!.alpha = CGFloat(1.0)
        })
        self.theView.agreeButton?.enabled               = true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
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
            self.goBack()
        }
        
        alertViewController.addAction(refreshAction)
        alertViewController.addAction(cancelAction)
        CMAlert.presentViewController(alertViewController)
    }
}
