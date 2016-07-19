//
//  Reel.swift
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

private let ReelSourceKey   = "source"
private let ReelTypeKey     = "type"
private let ReelValueKey    = "value"

public enum ReelType:String {
    case UserName           = "username"
    case Url                = "url"
    case Channel            = "channel"
}

extension ReelType {
    public static let allValues:[ReelType] = [
         .UserName
        ,.Url
        ,.Channel
    ]
}

public enum ReelSource:String {
    case Personal           = "personal"
    case Flickr             = "flickr"
    case FiveHundredPX      = "500px"
    case Instagram          = "instagram"
}

extension ReelSource {
    
    public static let allValues:[ReelSource] = [
         .Personal
        ,.Instagram
        ,.Flickr
        ,.FiveHundredPX
    ]
   
    public var localizedString:String {
        switch self {
        case .Personal:
            return NSLocalizedString("portfolio", comment: "ReelSource : portfolio")
        case .Flickr:
            return NSLocalizedString("flickr", comment: "ReelSource : portfolio")
        case .FiveHundredPX:
            return NSLocalizedString("500px", comment: "ReelSource : portfolio")
        case .Instagram:
            return NSLocalizedString("instagram", comment: "ReelSource : portfolio")
        }
    }
    
    public var titleString:String {
        let my = NSLocalizedString("MY ", comment: "ReelSource title prefix : my ")
        return (my + self.localizedString).uppercaseString
    }
    
    public var largeIconName:String {
        switch self {
        case .Personal:
            return "icon_myportfolio"
        case .Flickr:
            return "icon_flickr"
        case .FiveHundredPX:
            return "icon_500px"
        case .Instagram:
            return "icon_instagram"
        }
    }
    
    public var unselectedIconName:String {
        switch self {
        case .Personal:
            return "bttn_default_myportfolio"
        case .Flickr:
            return "bttn_default_flickr"
        case .FiveHundredPX:
            return "bttn_default_500px"
        case .Instagram:
            return "bttn_default_instagram"
        }
    }

    public var selectedIconName:String {
        switch self {
        case .Personal:
            return "bttn_entered_myportfolio"
        case .Flickr:
            return "bttn_entered_flickr"
        case .FiveHundredPX:
            return "bttn_entered_500px"
        case .Instagram:
            return "bttn_entered_instagram"
        }
    }

    
    public var prefixString:String {
        switch self {
        case .Personal:
            return "www."
        case .Flickr:
            return "flickr.com/photos/"
        case .FiveHundredPX:
            return "500px.com/"
        case .Instagram:
            return "instagram.com/"
        }
    }
    
    public var type:ReelType {
        switch self {
        case .Personal:
            return .Url
        case .Flickr:
            return .UserName
        case .FiveHundredPX:
            return .UserName
        case .Instagram:
            return .UserName
        }
    }
    
    public var jsonValue:String {
        return self.rawValue
    }
    
    public func url(data:String)->NSURL? {
        let okayChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=._/".characters)
        let clean = String(data.characters.filter { okayChars.contains($0) })
        let path = "http://\((self == .Personal ? "" : prefixString))\(clean)"
        return NSURL(string: path)
    }
    
}

typealias ReelSourceValidator = (String)->Bool

public struct Reel {
    
    public let value:String
    public let source:ReelSource
    
    public init(value:String, source:ReelSource) {
        self.value      = value
        self.source     = source
    }
   
    public var url:NSURL? {
        return source.url(value)
    }
    
    public func toDictionary()->[String:AnyObject] {
        return [
             "source"   : source.jsonValue
            ,"type"     : source.type.rawValue
            ,"value"    : value
        ]
    }
    
}

extension Dictionary where Key:StringLiteralConvertible {
    
    public func toReel()->Reel? {
        let sources:[String] = self.keys.map { key in
            if String(key) == ReelSourceKey { return self[key] as? String }
            return nil
        }.flatMap { $0 }
        guard let s = sources.first else { return nil }
        guard let reelSource = ReelSource(rawValue:s) else { return nil }
        
        let values:[String] = self.keys.map { key in
            if String(key) == ReelValueKey { return self[key] as? String }
            return nil
        }.flatMap { $0 }
        guard let v = values.first else { return nil }
        return Reel(value: v, source:reelSource)
    }
    
}

extension SequenceType where Generator.Element == Reel {

    public func toJSONArray()->[[String:AnyObject]] {
        return self.map { $0.toDictionary() }.flatMap { $0 }
    }
    
}

extension SequenceType where Generator.Element == [String:AnyObject] {
    
    public func toReelArray()->[Reel] {
        return self.map { $0.toReel() }.flatMap { $0 }
    }
    
}















