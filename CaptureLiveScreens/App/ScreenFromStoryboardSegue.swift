//
//  ScreenFromStoryboardSegue.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/5/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

class ScreenFromStoryboardSegue: UIStoryboardSegue {
    
    static func sceneNamed(initalVC:String, storyBoard:String)->UIViewController {
        let storyBoard      = UIStoryboard(name: storyBoard, bundle: nil)
        return storyBoard.instantiateViewControllerWithIdentifier(initalVC)
    }
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        guard let uisource = source as? StoryboardScreenable else {
            fatalError("source UIViewController not StoryboardScreenable")
        }
        let storyBoard      = UIStoryboard(name:uisource.desiredStoryBoard, bundle:nil)
        super.init(
            identifier      : identifier,
            source          : source,
            destination     : storyBoard.instantiateViewControllerWithIdentifier(uisource.desiredScreen)
        )
    }
    
    override func perform() {
        let source          = self.sourceViewController
        source.navigationController?.pushViewController(self.destinationViewController, animated: true)
    }
    
}