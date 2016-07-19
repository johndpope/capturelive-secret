//
//  NoAnimationSegue.swift
//  Current
//
//  Created by Scott Jones on 4/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

public class NoAnimationSegue: UIStoryboardSegue {
    override public func perform() {
        sourceViewController.navigationController?.pushViewController(destinationViewController, animated: false)
    }
}
