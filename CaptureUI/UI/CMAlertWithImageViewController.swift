//
//  CMAlertWithImageViewController.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/16/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public final class CMAlertWithImageViewController: CMAlertController {

    override public func loadView() {
        let aView:CMAlertWithImageView = UIView.fromNib()
        self.view = aView
    }

    var imageName:String!
   
    public convenience init(imageName:String) {
        self.init(title: "", message:"", imageName:imageName)
    }
    
    public convenience init(message messageString:String, imageName:String) {
        self.init(title: "", message: messageString, imageName:imageName)
    }
    
    public convenience init(title titleString:String, imageName:String) {
        self.init(title: titleString, message: "", imageName:imageName)
    }
    
    public init(title titleString:String, message messageString:String, imageName:String) {
        self.imageName                          = imageName
        super.init(title:titleString, message:messageString)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertView.didLoad()
        self.alertView.addData(self.titleString, messageString:self.messageString)
        
        guard let alwImage = alertView as? CMAlertWithImageView else {
            return
        }
        
        alwImage.addImage(self.imageName)
    }

}
