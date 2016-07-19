//
//  ByPassable.swift
//  Current
//
//  Created by Scott Jones on 4/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData

public protocol ScreenByPassable {
    var shouldByPass:Bool { get set }
}

private let ShouldByPassScreenKey = "ShouldByPassScreenKey"
extension NSManagedObjectContext: ScreenByPassable {
    
    public var shouldByPass:Bool {
        get {
            return metaData[ShouldByPassScreenKey] as? Bool ?? false
        }
        set {
            setMetaData(newValue, key:ShouldByPassScreenKey)
        }
    }
   
    public func preventScreenByPass() {
        self.shouldByPass = false
    }
   
    public func allowScreenByPass() {
        self.shouldByPass = true
    }

}

public protocol OnboardingByPassable {
    var canByPassOnboarding:Bool { get set }
}

private let ShouldByPassOnboardingKey = "ShouldByPassOnboardingKey"
extension NSManagedObjectContext: OnboardingByPassable {
    
    public var canByPassOnboarding:Bool {
        get {
            return metaData[ShouldByPassOnboardingKey] as? Bool ?? false
        }
        set {
            setMetaData(newValue, key:ShouldByPassOnboardingKey)
        }
    }
    
    public func allowOnboardingByPass() {
        self.canByPassOnboarding = true
    }
    
}
