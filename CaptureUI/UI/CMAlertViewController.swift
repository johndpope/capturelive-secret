//
//  CMAlertView.swift
//  Current
//
//  Created by hatebyte on 7/24/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit

public typealias CompletedBanner = ()->()

class CMAlertOverlayWindow:UIWindow {

    var oldKeyWindow:UIWindow!

    override func makeKeyAndVisible() {
        self.oldKeyWindow                                   = UIApplication.sharedApplication().keyWindow
        self.windowLevel                                    = UIWindowLevelAlert
        
        super.makeKeyAndVisible()
    }
    
    override func resignKeyWindow() {
        super.resignKeyWindow()
        self.oldKeyWindow.makeKeyAndVisible()
    }

}


public class CMAlert {
    
    private class var shared:CMAlert {
        struct Singleton {
            static let instance = CMAlert()
        }
        return Singleton.instance
    }
    
    var window:CMAlertOverlayWindow?
    var avc:CMAlertController?
    
    public static func presentViewController(avc:CMAlertController) {
        self.shared.avc                         = avc
        self.shared.present()
    }
    
    func present() {
        self.avc?.overlayDismissClosure         = dismiss
        self.window                             = CMAlertOverlayWindow(frame:UIScreen.mainScreen().bounds)
        self.window?.alpha                      = 0.0
        self.window?.backgroundColor            = UIColor.clearColor()
        if let avcReal =  self.avc {
            self.window?.rootViewController     = avcReal
        }
       
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())
        self.window?.makeKeyAndVisible()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.window?.alpha                  = 1.0
            
            }) { (fin:Bool) -> Void in
                
        }
        
        self.avc?.present()
    }
    
    func dismiss() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.window?.alpha                  = 0.0
            
            }) { (fin:Bool) -> Void in
                
                self.window?.resignKeyWindow()
                self.window?.rootViewController = nil
                self.window                     = nil

        }
        
        self.avc?.dismiss()
    }
    
}

public struct CMAlertAction {
    
    var title:String?
    var style:CMBaseButtonStyle
    var handler:CompletedBanner?
    
    public init(title:String, style:CMBaseButtonStyle, handler:CompletedBanner? = nil) {
        self.title                              = title
        self.style                              = style
        self.handler                            = handler
    }
    
}

extension CMAlertAction {
    
    func button()->CMBaseButton {
        return CMBaseButton.create(self.style, title:self.title)
    }
    
}

extension Array {
    
    public func mapWithIndex<T>(f:(Int, Element)->T)->[T] {
        return zip((self.startIndex ..< self.endIndex), self).map(f)
    }
    
}


typealias LinkedAction = (index:Int, alertAction:CMAlertAction, button:UIButton)


public class CMAlertController: UIViewController {
  
    var actions:[CMAlertAction]                 = []
    var linkedActions:[LinkedAction]            = []
    var titleString:String!
    var messageString:String!
    var buttonDismissClosure:CompletedBanner?
    var overlayDismissClosure:CompletedBanner?
    
    public var titleLabel:UILabel? {
        return alertView.titleLabel
    }
    
    public var messageLabel:UILabel? {
        return alertView.messageLabel
    }
    
    public func readdData() {
        alertView.readdData()
    }

    public convenience init(message messageString:String) {
        self.init(title: "", message: messageString)
    }
    
    public convenience init(title titleString:String) {
        self.init(title: titleString, message: "")
    }
    
    public init(title titleString:String, message messageString:String) {
        self.titleString                        = titleString
        self.messageString                      = messageString
        super.init(nibName:nil, bundle:nil)
    }
    
    var alertView:CMAlertViewProtocol {
        return self.view as! CMAlertViewProtocol
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        let aView:CMAlertView                   = UIView.fromNib()
        self.view = aView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertView.didLoad()
        self.alertView.addData(self.titleString, messageString:self.messageString)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.buttonDismissClosure?()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    public override func shouldAutorotate() -> Bool {
        return true
    }

    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIApplication.sharedApplication().statusBarStyle
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return UIApplication.sharedApplication().statusBarHidden
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    public override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.alertView.layoutIfNeeded()
    }
    
    public override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.alertView.layoutIfNeeded()
    }
    
    func updateLayout() {
        self.alertView.addData(self.titleString, messageString:self.messageString)
        self.alertView.layoutIfNeeded()
    }

    func present() {
        self.alertView.present()
    }
    
    func dismiss() {
        self.alertView.dismiss()
    }
    
    public func addAction(action:CMAlertAction) {
        self.actions.append(action)
        
        // convert actionsArray to Tuple Array (button tag)
        self.linkedActions = self.actions.mapWithIndex { (index:Int, elem:CMAlertAction) -> LinkedAction in
            let button                  = elem.button()
            button.tag                  = index
            button.addTarget(self, action: #selector(CMAlertController.buttonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            return (index, elem, button)
        }

        // get array of buttons
        let buttons                     = self.linkedActions.map { action in
            return action.button
        }
        self.alertView.addButtons(buttons)
    }
    
    func buttonPressed(sender:CMBaseButton) {
        self.buttonDismissClosure       = self.linkedActions[sender.tag].alertAction.handler
        self.overlayDismissClosure?()
    }
    
}


extension UIView {
    
    class func fromNib<T:UIView>(nibNameOrNil:String? = nil) -> T {
        let v:T?                        = fromNib(nibNameOrNil)
        return v!
    }
    
    class func fromNib<T:UIView>(nibNameOrNil:String? = nil) -> T? {
        var view:T?
        let name:String
        if let nibName = nibNameOrNil {
            name                        = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name                        = "\(T.self)".componentsSeparatedByString(".").last!
        }
        let nibViews                    = NSBundle(forClass:CMAlertController.self).loadNibNamed(name, owner:nil, options:nil)
        for v in nibViews {
            if let tog = v as? T {
                view                    = tog
            }
        }
        return view
    }
    
}