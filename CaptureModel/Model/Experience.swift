//
//  Experience.swift
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

private let CategoriesKey   = "categories"
public enum Category:String {
    case Sports             = "sports"
    case Celebrity          = "celebrity"
    case News               = "news"
    case Weather            = "weather"
    case None               = "none"
}

extension Category {
    
    public static let allValues:[Category] = [.Weather, Celebrity, .Sports, .News, .None]
    
    public var localizedString:String {
        switch self {
            case .Sports            : return NSLocalizedString("Sports", comment: self.rawValue)
            case .Celebrity         : return NSLocalizedString("Celebrity", comment: self.rawValue)
            case .News              : return NSLocalizedString("News", comment: self.rawValue)
            case .Weather           : return NSLocalizedString("Weather", comment: self.rawValue)
            case .None              : return NSLocalizedString("None", comment: self.rawValue)
        }
    }

    public var localizedEventsString:String {
        switch self {
        case .None      : return NSLocalizedString("", comment: "Category : localizedEventsString : none")
        default         : return NSLocalizedString("events", comment: "Category : localizedEventsString : events")
        }
    }
}

private let LevelKey        = "level"
public enum Level:UInt16 {
    case LessThanOne        = 0
    case TwoToFive          = 1
    case FiveToTen          = 2
}

extension Level {
    
    public static let allValues:[Level] = [.LessThanOne, .TwoToFive, .FiveToTen]
    
    public var localizedAmountString:String {
        switch self {
        case .LessThanOne   : return NSLocalizedString("0-1", comment: "ExperienceLevel : 0-1")
        case .TwoToFive     : return NSLocalizedString("2-5", comment: "ExperienceLevel : 2-5")
        case .FiveToTen     : return NSLocalizedString("5+", comment: "ExperienceLevel : 5+")
        }
    }
    
    public var localizedYearsString:String {
        switch self {
        case .LessThanOne   : return NSLocalizedString("year", comment: "ExperienceLevel : year")
        case .TwoToFive     : return NSLocalizedString("years", comment: "ExperienceLevel : years")
        case .FiveToTen     : return NSLocalizedString("years", comment: "ExperienceLevel : years")
        }
    }

}

public struct Experience {
    
    public let level:Level
    public let categories:[Category]
    
    public init(categories:[Category], level:Level = .LessThanOne) {
        self.categories     = categories
        self.level          = level
    }
}

extension Experience {
    
    public func toDictionary()->[String:AnyObject] {
        return [
            CategoriesKey   : categories.toLiteralArray(),
            LevelKey        : NSNumber(unsignedShort:level.rawValue)
        ]
    }
    
}

extension Dictionary where Key:StringLiteralConvertible, Value: AnyObject {
    
    public func toExperience()->Experience? {
        if let dict = (self as? AnyObject) as? Dictionary<String, AnyObject> {
            let yvalues:[UInt16] = Level.allValues.map { $0.rawValue }
            
            let history = (dict[CategoriesKey] ?? []) as! [String]
            let fhist = history.toCategoryArray()
            
            if let years = (dict[LevelKey] as? NSNumber)?.unsignedShortValue {
                let fyears = yvalues.filter { $0 == UInt16(years) }
                guard fyears.first != nil else {
                    return nil
                }
                let l = fyears.first ?? 0
                guard let level = Level(rawValue:l) else { return nil }
                return Experience(categories:fhist, level:level)
            } else {
                return nil
            }
        }
        return nil
    }
    
}

extension SequenceType where Generator.Element == Category {
    
    public func toLiteralArray()->[String] {
        return self.map { String($0.rawValue) }.flatMap { $0 }
    }
    
}

extension SequenceType where Generator.Element == String {
    
    public func toCategoryArray()->[Category] {
        let rawVals:[String] = Category.allValues.map { $0.rawValue }
        return self.filter { rawVals.contains($0) }.flatMap { Category(rawValue:$0) }
    }
    
}





















