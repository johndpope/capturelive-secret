//
//  Level+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//
import CaptureUI
import CaptureModel

public struct LargeLevelTextCellViewModel:RoundButtonDecoratable {
    public var content:String
    public var subContent:String
    public let type:UInt16
    public init(type:UInt16, content:String, subContent:String)  {
        self.type       = type
        self.content    = content
        self.subContent = subContent
    }

    public func decorate(button: RoundProfileButton) {
        button.reset()
        button.setTitle(content, subTitle: subContent, titleSize: FontSizes.s18, subTitleSize:FontSizes.s10, forState:.Normal)
    }
    
    var toLevel:Level {
        guard let l =  Level(rawValue: type) else { fatalError("Not a level : \(type)") }
        return l
    }
}

public struct SmallTextCellViewModel:RoundButtonDecoratable {
    public var content:String
    public var subContent:String
    public init(content:String, subContent:String)  {
        self.content    = content
        self.subContent = subContent
    }
    
    public func decorate(button: RoundProfileButton) {
        button.reset()
        button.titleLabel?.textAlignment  = .Center
        button.setTitle(content, subTitle: subContent, titleSize: FontSizes.s10, subTitleSize: FontSizes.s6, forState:.Normal)
    }
}

public enum ExperienceType:String {
    case Level = "level"
    case Categories = "categories"
}

public typealias ExperienceLevelPicked = (Level?)->()

extension Level {
    
    public var largeCellViewModel:LargeLevelTextCellViewModel {
        return LargeLevelTextCellViewModel(
            type:self.rawValue
            ,content:localizedAmountString
            ,subContent:"\n\(localizedYearsString)"
        )
    }
    
    public var smallCellViewModel:SmallTextCellViewModel {
        return SmallTextCellViewModel(
            content:localizedAmountString
            ,subContent:"\n\(localizedYearsString)"
        )
    }
   
    public var profileCellViewModel:TitledTextCellViewModel {
        return TitledTextCellViewModel(
             type:ExperienceType.Level.rawValue
            ,title:NSLocalizedString("MY EXPERIENCE", comment:"ExperienceScreen : celltitle : level")
            ,content:localizedAmountString
            ,subContent:"\n\(localizedYearsString)"
            ,completed:false
        )
    }
    
}
