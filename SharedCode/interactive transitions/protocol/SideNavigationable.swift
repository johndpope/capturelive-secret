//
//  SideNavigationable.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/4/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

private let SideNavViewTag:Int      = 30003000

public protocol SideNavigationReceivable:class {
    var presentSegue:String { get }
}

public protocol SideNavigationable:class {
//    var backSegue:String { get set }
    func addMoveVCView(view:UIView)
    func removeMoveVCView()
}

extension SideNavigationable where Self:UIViewController {
   
    public var sideNavView:UIView? {
        return self.view.viewWithTag(SideNavViewTag)
    }
    
    public func addMoveVCView(view:UIView) {
        view.tag                = SideNavViewTag
        view.removeFromSuperview()
        self.view.insertSubview(view, atIndex:0)
    }
    
    public func removeMoveVCView() {
        sideNavView?.removeFromSuperview()
    }
    
}