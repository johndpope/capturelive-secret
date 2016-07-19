//
//  Onboard4ViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class Onboard4ViewController: UIViewController {

    var theView:OnboardView {
        guard let v = self.view as? OnboardView else { fatalError("Not a \(OnboardView.self)!") }
        return v
    }
    
    let coverViewModel = OnboardCoverViewModel(
        logoNameString:"FPO logo"
        ,pageNumberInt:1
        ,totalPageNumberInt:4
        ,skipButtonTitleString:NSLocalizedString("ENTER YOUR PHONE NUMBER", comment:"OnboardViewModel : page2 : skipButtonTitleString")
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = OnboardViewModel(
            imageNameString:"onboarding_image4"
            ,titleLabelString:NSLocalizedString("Get hired by top companies", comment:"OnboardViewModel : page2 : titleLabelString")
            ,bodyLabelString:NSLocalizedString("Get notified when a media company\nhires you for a job.", comment:"OnboardViewModel : page2 : bodyLabelString")
        )
        
        theView.didLoad()
        theView.setUp(model, coverViewModel: coverViewModel)
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
        theView.coverView?.skipButton?.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.coverView?.skipButton?.removeTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
    }
    
    //MARK: Button handlers
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
