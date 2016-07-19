//
//  Team+Util.swift
//  Current
//
//  Created by Scott Jones on 4/5/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel

extension Team {
    
    func viewModel()->TeamViewModel {
        return TeamViewModel( nameString:name ?? "FPO Team Name" )
    }
   
}