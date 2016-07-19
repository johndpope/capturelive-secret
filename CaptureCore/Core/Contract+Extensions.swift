//
//  Contract+Extensions.swift
//  Current
//
//  Created by Scott Jones on 4/7/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CaptureModel
import CoreData

extension Contract {
    
    public func connectionModel()->CMRTSPConnectionModel {
        let model                       = CMRTSPConnectionModel()
        model.name                      = self.streamName
        model.application               = self.streamApplication
        model.url                       = self.URL
        model.host                      = self.streamHost
        model.port                      = UInt(self.streamPort)
        model.userName                  = Contract.userName
        model.password                  = Contract.password
        print(model.name)
        print(model.url)
        return model
    }
    
}
