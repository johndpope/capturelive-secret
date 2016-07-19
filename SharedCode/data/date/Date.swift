//
//  Date.swift
//  Current
//
//  Created by Scott Jones on 3/14/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

extension NSDate {
   
    public func eventTime()->String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    }
    
    public func elapsedTimeString() -> String {
        let aMomentAgo = NSLocalizedString("a moment ago", comment:"elapsedTimeString : a moment ago")
        var interval = NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
        
        if interval > 0 {
            let yearAgo = NSLocalizedString("year ago", comment:"elapsedTimeString : year ago")
            let yearsAgo = NSLocalizedString("years ago", comment:"elapsedTimeString : years ago")
            return interval == 1 ? "\(interval)" + " " + yearAgo : "\(interval)" + " " + yearsAgo
        }
        
        interval = NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month
        if interval > 0 {
            let monthAgo = NSLocalizedString("month ago", comment:"elapsedTimeString : month ago")
            let monthsAgo = NSLocalizedString("months ago", comment:"elapsedTimeString : months ago")
            return interval == 1 ? "\(interval)" + " " + monthAgo : "\(interval)" + " " + monthsAgo
        }
        
        interval = NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: NSDate(), options: []).day
        if interval > 0 {
            if interval == 1 {
                let yesterday = NSLocalizedString("Yesterday", comment:"elapsedTimeString : yesterday")
                return yesterday
            } else {
                let dateFormatter = NSDateFormatter()
                dateFormatter.AMSymbol = "am"
                dateFormatter.PMSymbol = "pm"
                dateFormatter.dateFormat = "MMMM dd h:mmaa"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                return dateFormatter.stringFromDate(self)
            }
        }
        
        interval = NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
        if interval > 0 {
            let hrAgo = NSLocalizedString("hr ago", comment:"elapsedTimeString : hr ago")
            let hrsAgo = NSLocalizedString("hrs ago", comment:"elapsedTimeString : hrs ago")
            return interval == 1 ? "\(interval)" + " " + hrAgo : "\(interval)" + " " + hrsAgo
        }
        
        interval = NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
        if interval > 0 {
            let mAgo = NSLocalizedString("m ago", comment:"elapsedTimeString : m ago")
            let msAgo = NSLocalizedString("ms ago", comment:"elapsedTimeString : ms ago")
            return interval == 1 ? "\(interval)" + " " + mAgo : "\(interval)" + " " + msAgo
        }
        return aMomentAgo
    }
    
    public func timeTilString()->String {
        if self.hasPassed() {
            let now = NSLocalizedString("Now", comment:"timeTilString : Now")
            return now
        }
        
        if self.isToday() {
            let dateFormatter = NSDateFormatter()
            dateFormatter.AMSymbol = "am"
            dateFormatter.PMSymbol = "pm"
            dateFormatter.dateFormat = "h:mm aa"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            return dateFormatter.stringFromDate(self)
        }
        let calendar = NSCalendar.currentCalendar()
        if calendar.isDateInTomorrow(self) {
            return NSLocalizedString("Tomorrow", comment:"timeTilString : tomorrow")
        }
        
        let inText = NSLocalizedString("In", comment:"timeTilString : In")
//        var interval = abs(NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year)
//        if interval > 0 {
//            let year = NSLocalizedString("year", comment:"timeTilString : year")
//            let years = NSLocalizedString("years", comment:"timeTilString : years")
//            return interval == 1 ? inText + "\(interval) " + year : inText + "\(interval) " + years
//        }
//        interval = abs(NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month)
//        if interval > 0 {
//            let month = NSLocalizedString("month", comment:"elapsedTimeString : month")
//            let months = NSLocalizedString("months", comment:"elapsedTimeString : months")
//            return interval == 1 ? "\(interval)" + " " + month : "\(interval)" + " " + months
//        }
        let interval = abs(calendar.components(.Month, fromDate: self, toDate: NSDate(), options: []).day)
        if interval == 2 {
//            let day = NSLocalizedString("day", comment:"elapsedTimeString : day")
            let days = NSLocalizedString("days", comment:"elapsedTimeString : days")
            return inText + "\(interval)" + " " + days
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter.stringFromDate(self)
    }

    public var weekAgo:NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate:self)
        components.day = components.day - 7
        return calendar.dateFromComponents(components)!
    }
    
    public var startOfDay:NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate:self)
        return calendar.dateFromComponents(components)!
    }
    
    public var endOfDay:NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate:self)
        components.day = components.day + 1
        return calendar.dateFromComponents(components)!
    }
    
    public static func monthNameString(monthNumber:Int)->String {
        let df = NSDateFormatter()
        let monthnames = NSArray(array: df.standaloneMonthSymbols)
        guard let month = monthnames.objectAtIndex(monthNumber - 1) as? String else {
            return monthnames.objectAtIndex(11) as! String
        }
        return month
    }
    
    public func hasPassed()->Bool {
        return self.timeIntervalSinceNow.isSignMinus
    }
    
    public func isToday()->Bool {
        let mycomponents        = NSCalendar.currentCalendar().components([.Day], fromDate:self)
        let todaycomponents     = NSCalendar.currentCalendar().components([.Day], fromDate:NSDate())
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return mycomponents.day == todaycomponents.day
    }
    
    public func hoursFromNow(hours:NSTimeInterval)->NSDate {
        let d = NSDate()
        let hoursAsSeconds = hours * 60.0 * 60.0
        return d.dateByAddingTimeInterval(hoursAsSeconds)
    }
    
    public func isWithin(seconds:NSTimeInterval, endDate:NSDate)->Bool {
        let diff = endDate.timeIntervalSince1970 - self.timeIntervalSince1970
        return diff > 0 && diff < seconds
    }
    
    public func directoryNameFormat()->String {
        let formatter           = NSDateFormatter()
        formatter.timeZone      = NSTimeZone.localTimeZone()
        formatter.dateStyle     = .MediumStyle
        formatter.dateFormat    = "yyyy-MM-dd-h.mm.ssa"
        return formatter.stringFromDate(self)
    }
    
    public func s3NameFormat()->String {
        let formatter           = NSDateFormatter()
        formatter.timeZone      = NSTimeZone(name: "UTC")
        formatter.dateStyle     = .MediumStyle
        formatter.dateFormat    = "yyyy-MM-dd-h.mm.ssa"
        return formatter.stringFromDate(self)
    }
    
}

