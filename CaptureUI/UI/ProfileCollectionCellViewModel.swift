//
//  ProfileCollectionCellViewModel.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/10/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit

public enum ProfileTableCellType:String {
    case PROFILE        = "profile"
    case EXPERIENCE     = "experience"
    case WORK           = "work"
    case PHOTOEXTRAS    = "photo_extras"
}

public protocol RoundButtonDecoratable {
    func decorate(button:RoundProfileButton)
}

public protocol CellDecoratable:RoundButtonDecoratable {
    var title:String { get }
    var type:String { get }
}

public struct ProfileTextCellViewModel:CellDecoratable {

    public let title:String
    public var content:String
    public var subContent:String
    public let type:String
    public init(type:String, title:String, content:String, subContent:String) {
        self.type       = type
        self.title      = title
        self.content    = content
        self.subContent = subContent
    }
}

public struct ProfileTextCompletedCellViewModel:CellDecoratable {

    public let title:String
    public var content:String
    public var subContent:String
    public let completed:Bool
    public let type:String
    public init(type:String, title:String, content:String, subContent:String, completed:Bool) {
        self.type = type
        self.title = title
        self.content = content
        self.subContent = subContent
        self.completed = completed
    }
}
extension ProfileTextCompletedCellViewModel {
    public var small:ProfileTextCellViewModel {
        return ProfileTextCellViewModel(
            type: type
            ,title : title
            ,content : content
            ,subContent : subContent
        )
    }
}

public struct ProfileImageCompletedCellViewModel:CellDecoratable {

    public let title:String
    public let imageNameEnabled:String
    public let imageNameDisabled:String
    public let completed:Bool
    public let type:String
    public init(type:String, title:String, imageNameEnabled:String, imageNameDisabled:String, completed:Bool) {
        self.type               = type
        self.title              = title
        self.imageNameEnabled   = imageNameEnabled
        self.imageNameDisabled  = imageNameDisabled
        self.completed          = completed
    }
}

public struct ProfileImageCellViewModel:CellDecoratable {

    public let title:String
    public let imageName:String
    public let type:String
    public var color:UIColor?
    public init(type:String, title:String, imageName:String, color:UIColor? = nil) {
        self.type               = type
        self.title              = title
        self.imageName          = imageName
        self.color              = color
    }
}

extension ProfileImageCompletedCellViewModel {
    public var imageName:String {
        return completed ? imageNameEnabled : imageNameDisabled
    }
}

public struct SocialImageCellViewModel {
    public let avatarPath:String
    public let icon:String
    public init(avatarPath:String, icon:String) {
        self.avatarPath = avatarPath
        self.icon = icon
    }
}



extension ProfileImageCellViewModel : RoundButtonDecoratable {
    public func decorate(button: RoundProfileButton) {
        button.reset()
        button.backgroundColorActive        = color
        button.decorate()
        button.setImage(UIImage(named:imageName), forState: .Normal)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.bistre(), forState: .Normal)
        button.imageView?.contentMode       = UIViewContentMode.ScaleAspectFit

        button.titleLabel?.font             = UIFont.sourceSansPro(.Bold, size:FontSizes.s14)
    }
}

extension ProfileTextCompletedCellViewModel: RoundButtonDecoratable {
    public func decorate(button: RoundProfileButton) {
        button.imageView?.contentMode       = UIViewContentMode.ScaleAspectFit
        if completed {
            // add check
        }
        button.setTitle(content, subTitle: subContent, titleSize: FontSizes.s18, subTitleSize: FontSizes.s10, forState:.Normal)
    }
}

extension ProfileTextCellViewModel: RoundButtonDecoratable {
    public func decorate(button: RoundProfileButton) {
        button.reset()
        button.imageView?.contentMode       = UIViewContentMode.ScaleAspectFit
        button.setTitle(nil, forState: .Normal)
        button.setTitle(content, subTitle: subContent, titleSize: FontSizes.s12, subTitleSize: FontSizes.s8, forState:.Normal)
    }
}

extension ProfileImageCompletedCellViewModel: RoundButtonDecoratable {
    public func decorate(button: RoundProfileButton) {
        button.reset()
        button.setImage(UIImage(named:imageName), forState: .Normal)
        button.contentHorizontalAlignment   = UIControlContentHorizontalAlignment.Fill
        button.contentVerticalAlignment     = UIControlContentVerticalAlignment.Fill
        button.imageView?.contentMode       = UIViewContentMode.ScaleAspectFit
    }
}

extension SocialImageCellViewModel: RoundButtonDecoratable {
    public func decorate(button: RoundProfileButton) {
        CMImageCache.defaultCache().imageForPath(self.avatarPath, complete: { error, image in
            if error == nil {
                button.setImage(image, forState: .Normal)
            }
        })
    }
}




public struct TitledTextCellViewModel:CellDecoratable {
    
    public let title:String
    public var content:String
    public var subContent:String
    public let completed:Bool
    public let type:String
    public init(type:String, title:String, content:String, subContent:String, completed:Bool) {
        self.type = type
        self.title = title
        self.content = content
        self.subContent = subContent
        self.completed = completed
    }

}
extension TitledTextCellViewModel: RoundButtonDecoratable {
    public func decorate(button: RoundProfileButton) {
        button.reset()
        if completed {
            // add check
        }
        button.setTitle(content, subTitle: subContent, titleSize:FontSizes.s18, subTitleSize: FontSizes.s10, forState:.Normal)
    }
}


