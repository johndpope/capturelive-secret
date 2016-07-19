//
//  Categories+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/12/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureModel

public typealias CategoriesPicked = ([CaptureModel.Category])->()

public struct LargeCategoryTextCellViewModel:RoundButtonDecoratable {
    public var content:String
    public var subContent:String
    public let type:String
    public var completed:Bool
    public init(type:String, content:String, subContent:String, completed:Bool = false)  {
        self.type       = type
        self.content    = content
        self.subContent = subContent
        self.completed  = completed
    }
    
    public func decorate(button: RoundProfileButton) {
        button.reset()
        button.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0)
        button.setTitle(content, subTitle: subContent, titleSize:FontSizes.s12, subTitleSize:FontSizes.s10, forState:.Normal)
        if completed {
            button.setBackgroundImage(UIImage(named:"icon_sm_greenchk"), forState: .Normal)
        }
    }
    
    var toCategory:CaptureModel.Category {
        guard let l =  Category(rawValue: type) else { fatalError("Not a level : \(type)") }
        return l
    }
}

extension CaptureModel.Category {
    
    public var largeCellViewModel:LargeCategoryTextCellViewModel {
        return LargeCategoryTextCellViewModel(
            type:self.rawValue
            ,content:localizedString
            ,subContent:"\n\(localizedEventsString)"
        )
    }
    
    public static func modelsWithSelection(selected:[CaptureModel.Category])->[RoundButtonDecoratable] {
        return Category.allValues.map { c in
            return LargeCategoryTextCellViewModel(
                type:c.rawValue
                ,content:c.localizedString
                ,subContent:"\n\(c.localizedEventsString)"
                ,completed:selected.contains(c)
            )
        }
    }
    
}


extension CollectionType where Generator.Element == CaptureModel.Category {
   
    var numCategoriesString:String {
        let emptyString = NSLocalizedString("No", comment: "ExperienceScreen : smallCategoryViewModel : none selected")
        var num = "\(self.count)"
        if self.count == 1 {
            if let f = self.first {
                if f == Category.None {
                    num = emptyString
                }
            }
        }
        if self.count == 0 {
            num = emptyString
        }
        return num
    }
    
    var localEvent:String {
        var localevent = NSLocalizedString("events", comment: "ExperienceScreen : smallCategoryViewModel : events")
        if self.count == 1 {
            if let f = self.first {
                if f != Category.None {
                    localevent = NSLocalizedString("event", comment: "ExperienceScreen : smallCategoryViewModel : event")
                }
            }
        }
        return localevent
    }
    
    public var smallCategoryViewModel:SmallTextCellViewModel {
        let num = numCategoriesString
        return SmallTextCellViewModel(
            content:"\(num)"
            ,subContent:"\n\(localEvent)"
        )
    }
   
    public var profileCellViewModel:TitledTextCellViewModel {
        let num = numCategoriesString
        return TitledTextCellViewModel(
            type:ExperienceType.Categories.rawValue
            ,title:NSLocalizedString("I'VE FILMED", comment:"ExperienceScreen : celltitle : category")
            ,content:"\(num)"
            ,subContent:"\n\(localEvent)"
            ,completed:false
        )
    }

}