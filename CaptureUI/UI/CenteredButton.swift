//
//  CenteredButton.swift
//  CaptureLive
//
//  Created by Scott Jones on 6/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public class CenteredButton: UIButton {

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let titleLabel = self.titleLabel {
            titleLabel.frame.origin.x = (self.bounds.size.width - titleLabel.frame.size.width) / 2.0
            titleLabel.frame.origin.y = (self.bounds.size.height / 2) - (titleLabel.frame.size.height / 2)
        }
        if let imageView = self.imageView {
            imageView.frame.origin.x = (self.bounds.size.width - imageView.frame.size.width) / 2.0
            imageView.frame.origin.y = (self.bounds.size.height / 2) - (imageView.frame.size.height / 5)
        }
    }

}
