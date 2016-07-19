//
//  Reel+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureModel

typealias SourceWithReel    = (source:ReelSource, reel:Reel?)
typealias ReelCreated       = (SourceWithReel)->()

extension ReelSource {
      
    public var enterUrlString:String {
        switch self {
        case .Personal:
            return NSLocalizedString("Enter your website url.", comment: "ReelSource : personal : enterUrlString")
        case .Flickr:
            return NSLocalizedString("Enter your Flickr url.", comment: "ReelSource : flickr : enterUrlString")
        case .FiveHundredPX:
            return NSLocalizedString("Enter your 500px url.", comment: "ReelSource : 500px : enterUrlString")
        case .Instagram:
            return NSLocalizedString("Enter your Instagram url.", comment: "ReelSource : instagram : enterUrlString")
        }
    }
    
    public var smallCellViewModel:ProfileImageCellViewModel {
        return ProfileImageCellViewModel(
                type:rawValue
                ,title:""
                ,imageName:largeIconName
        )
    }
    
    public var profileCellViewModel:ProfileImageCompletedCellViewModel {
        return ProfileImageCompletedCellViewModel(
            type:rawValue
            ,title:titleString
            ,imageNameEnabled:selectedIconName
            ,imageNameDisabled:unselectedIconName
            ,completed:false
        )
    }

    public static func modelsWithSelection(selected:[Reel])->[CellDecoratable] {
        let rSources = selected.map { $0.source }
        return ReelSource.allValues.map { c in
            return ProfileImageCompletedCellViewModel(
                type:c.rawValue
                ,title:c.titleString
                ,imageNameEnabled:c.unselectedIconName
                ,imageNameDisabled:c.selectedIconName
                ,completed:!rSources.contains(c)
            )
        }
    }
    
}

extension CollectionType where Generator.Element == Reel {

    public func reelForSource(source:ReelSource)->Reel? {
        return findFirstOccurence { $0.source == source }
    }
    
}

