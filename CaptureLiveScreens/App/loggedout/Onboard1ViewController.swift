//
//  Onboard1ViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/18/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class Onboard1ViewController: UIViewController {

    var theView:OnboardView {
        guard let v = self.view as? OnboardView else { fatalError("Not a \(OnboardView.self)!") }
        return v
    }
    
    let coverViewModel = OnboardCoverViewModel(
         logoNameString:"FPO logo"
        ,pageNumberInt:0
        ,totalPageNumberInt:4
        ,skipButtonTitleString:NSLocalizedString("Enter your phone number", comment:"OnboardViewModel : page1 : skipButtonTitleString")
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = OnboardViewModel(
             imageNameString:"onboarding_image1"
            ,titleLabelString:NSLocalizedString("Apply to cover neaby events", comment:"OnboardViewModel : page1 : titleLabelString")
            ,bodyLabelString:NSLocalizedString("Let hiring companies know that you’re\navailable to live stream an event.", comment:"OnboardViewModel : page1 : bodyLabelString")
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
