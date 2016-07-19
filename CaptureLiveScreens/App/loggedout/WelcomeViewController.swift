//
//  CMWelcomeViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/17/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

extension CYNavigationPush where Self : WelcomeViewController {
    var pushAnimator:UIViewControllerAnimatedTransitioning? {
        return PushTopAnimator()
    }
    var pushSegue:String {
        return "pushToExperienceScreen"
    }
}
class WelcomeViewController: UIViewController, SegueHandlerType, CYNavigationPush, CreateProfileNavControllerChild {

    var theView:WelcomeView {
        guard let v = self.view as? WelcomeView else { fatalError("Not a \(WelcomeView.self)!") }
        return v
    }
    
    enum SegueIdentifier:String {
        case PushToExperience                 = "pushToExperienceScreen"
    }
    
    var profile = ProfileTableCellInfo(
        title:NSLocalizedString("Your Profile", comment: "ProfileTableViewCell : titleLabel : text")
        ,type:.PROFILE
        ,roundButtons:[
            SocialImageCellViewModel(
                avatarPath:"https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200"
                ,icon:""
            )
        ]
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theView.didLoad()
       
        theView.addUserName("Theodore S.")
        CMImageCache.defaultCache().imageForPath("https://en.gravatar.com/userimage/46582550/d2b7a43025e76943731d65b055868695.jpg?size=200", complete: { [weak self] error, image in
            if error == nil {
                self?.theView.imageView?.image = image
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addHandlers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        theView.layoutSubviews()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeHandlers()
    }
    
    func addHandlers() {
        removeHandlers()
        theView.nextButton?.addTarget(self, action: #selector(nextButtonHit), forControlEvents: .TouchUpInside)
    }
    
    func removeHandlers() {
        theView.nextButton?.removeTarget(self, action: #selector(nextButtonHit), forControlEvents: .TouchUpInside)
    }
   
    func pushToExperience() {
        performSegue(.PushToExperience)
    }
    
    //MARK: Button handlers
    func nextButtonHit() {
        navContainer.pushExperience(self.profile)
    }
    
}
