//
//  ModelVersion.swift
//  Current
//
//  Created by Scott Jones on 3/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import CoreDataHelpers

enum CaptureModelVersion : String {
    case Version1 = "CaptureModel"
}

extension CaptureModelVersion:ModelVersionType {
    static var AllVersions: [CaptureModelVersion] { return [.Version1] }
    static var CurrentVersion: CaptureModelVersion { return .Version1 }
    
    var name: String { return rawValue }
    var modelBundle: NSBundle { return NSBundle(forClass: User.self) }
    var modelDirectoryName: String { return "CaptureModel.momd" }
}




