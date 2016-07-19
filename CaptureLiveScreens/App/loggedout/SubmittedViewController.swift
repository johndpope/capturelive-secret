//
//  SubmittedViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class SubmittedViewController: UIViewController {
    
    var theView:SubmittedView {
        guard let v = self.view as? SubmittedView else { fatalError("Not a \(SubmittedView.self)!") }
        return v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theView.didLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        theView.animateIn() { [unowned self] in
            self.goBack()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
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
