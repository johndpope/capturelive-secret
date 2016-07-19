//
//  Equipment+Extensions.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/13/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import Foundation
import CaptureModel

public typealias EquipmentPicked = ([Equipment])->()
public struct LargeEquipmentTextCellViewModel:RoundButtonDecoratable {
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
        let boldAtt             = [
            NSFontAttributeName: UIFont.proxima(.SemiBold, size:FontSizes.s10)
            ,NSForegroundColorAttributeName: UIColor.bistre()
            ,NSBackgroundColorAttributeName: UIColor.clearColor()
        ]
        let titleString         = NSMutableAttributedString(string:content, attributes: boldAtt )
        let lightAtt            = [
            NSFontAttributeName: UIFont.proxima(.SemiBold, size:FontSizes.s10)
            ,NSForegroundColorAttributeName: UIColor.bistre()
            ,NSBackgroundColorAttributeName: UIColor.clearColor()
        ]
        let subString           = NSMutableAttributedString(string:subContent, attributes:lightAtt )
        titleString.appendAttributedString(subString)
        button.setAttributedTitle(titleString, forState:.Normal)
        
        button.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0)
        if completed {
            button.setBackgroundImage(UIImage(named:"icon_sm_greenchk"), forState: .Normal)
        }
    }
    
    var toEquipment:Equipment {
        guard let e =  Equipment(rawValue: type) else { fatalError("Not a equipment : \(type)") }
        return e
    }
}

extension Equipment {
   
    public var largeCellViewModel:LargeEquipmentTextCellViewModel {
        return LargeEquipmentTextCellViewModel(
            type:rawValue
            ,content:localizedFirstString
            ,subContent:"\n\(localizedSecondString)"
        )
    }
    
    public static func modelsWithSelection(selected:[Equipment])->[RoundButtonDecoratable] {
        return Equipment.allValues.map { c in
            return LargeEquipmentTextCellViewModel(
                type:c.rawValue
                ,content:c.localizedFirstString
                ,subContent:"\n\(c.localizedSecondString)"
                ,completed:selected.contains(c)
            )
        }
    }

}

extension CollectionType where Generator.Element == Equipment {
    
    var numItemsString:String {
        let emptyString = NSLocalizedString("No", comment: "Equipement : smallCategoryViewModel : none selected")
        var num = "\(self.count)"
        if self.count == 0 {
            num = emptyString
        }
        return num
    }
    
    var localItems:String {
        var localItem = NSLocalizedString("items", comment: "Equipement : smallCategoryViewModel : events")
        if self.count == 1 {
            localItem = NSLocalizedString("item", comment: "Equipement : smallCategoryViewModel : event")
        }
        return localItem
    }
    
    public func smallEquipmentViewModel()->SmallTextCellViewModel {
        let num = numItemsString
        return SmallTextCellViewModel(
             content:"\(num)"
            ,subContent:"\n\(localItems)"
        )
    }
    
    public var profileCellViewModel:TitledTextCellViewModel {
        let num = numItemsString
        return TitledTextCellViewModel(
             type:PhotoExtrasType.Equipment.rawValue
            ,title:NSLocalizedString("MY EQUIPMENT", comment:"Equipement : celltitle : category")
            ,content:"\(num)"
            ,subContent:"\n\(localItems)"
            ,completed:false
        )
    }
    
}