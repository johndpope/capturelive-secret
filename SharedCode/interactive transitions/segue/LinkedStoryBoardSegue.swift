//
//  LinkedStoryBoardSegue.swift
//  Current
//
//  Created by hatebyte on 8/16/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public class LinkedStoryBoardSegue: UIStoryboardSegue {
    
    static func sceneNamed(identifier:String)->UIViewController {
        let info                                        = identifier.componentsSeparatedByString("@")
        var scene_name:String?
        var storyBoardName:String!
        var bundle:NSBundle? = nil
        
        if info.count == 2 {
            storyBoardName                              = info[1]
            scene_name                                  = info[0]
        } else if info.count == 3 {
            storyBoardName                              = info[1]
            scene_name                                  = info[0]
            bundle                                      = NSBundle(identifier: "com.capturemedia.ios.mobile.\(info[2])")
        } else {
            storyBoardName                              = info.last
        }
        print(bundle)
        let storyBoard                                  = UIStoryboard(name:storyBoardName, bundle:bundle)
        if let scene = scene_name {
            return storyBoard.instantiateViewControllerWithIdentifier(scene)
        } else {
            return storyBoard.instantiateInitialViewController()!
        }
    }
    
    override init(identifier:String?, source:UIViewController, destination:UIViewController) {
        super.init(identifier:identifier, source:source, destination:LinkedStoryBoardSegue.sceneNamed(identifier!))
    }
    
    override public func perform() {
        let source                                      = self.sourceViewController
        let nav                                         = UINavigationController()
        nav.viewControllers                             = [self.destinationViewController]
        nav.navigationBarHidden                         = true
        
        guard let _ = source.navigationController else {
            source.presentViewController(nav, animated: true, completion: { () -> Void in
            })
            return
        }
        
        source.navigationController?.pushViewController(self.destinationViewController, animated: true)

    }

}
