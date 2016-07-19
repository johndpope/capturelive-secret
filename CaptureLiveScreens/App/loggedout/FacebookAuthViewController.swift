//
//  CMFacebookAuthViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class FacebookAuthViewController: UIViewController {

    var theView:FacebookAuthView {
        guard let v = self.view as? FacebookAuthView else { fatalError("Not a \(FacebookAuthView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addHandlers()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    func addHandlers() {
        removeHandlers()
        theView.whyButton?.addTarget(self, action: #selector(showOverlay), forControlEvents: .TouchUpInside)
        theView.revealCloseButton?.addTarget(self, action: #selector(hideOverlay), forControlEvents: .TouchUpInside)
        theView.authButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.whyButton?.removeTarget(self, action: #selector(showOverlay), forControlEvents: .TouchUpInside)
        theView.revealCloseButton?.removeTarget(self, action: #selector(hideOverlay), forControlEvents: .TouchUpInside)
        theView.authButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    //MARK: Button handlers
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showOverlay() {
        theView.revealOverlay()
    }
    
    func hideOverlay() {
        theView.dismisOverlay()
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
