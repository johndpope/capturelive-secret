//
//  Equipment.swift
//  Current
//
//  Created by Scott Jones on 4/11/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

public enum Equipment:String {
    case BatteryPack            = "battery_pack"
    case SelfieStick            = "selfie_stick"
    case SmartPhoneLens         = "smartphone_lens"
    case LightingTools          = "lighting_tools"
    case MobileTripod           = "mobile_tripod"
}

extension Equipment {

    public static let allValues:[Equipment] = [.BatteryPack, .SelfieStick, .SmartPhoneLens, .LightingTools, .MobileTripod]
    
    public var localizedString:String {
        switch self {
        case .SmartPhoneLens            : return NSLocalizedString("Smartphone Lens", comment: self.rawValue)
        case .MobileTripod              : return NSLocalizedString("Mobile Tripod", comment: self.rawValue)
        case .SelfieStick               : return NSLocalizedString("Selfie Stick", comment: self.rawValue)
        case .LightingTools             : return NSLocalizedString("Lighting Tools", comment: self.rawValue)
        case .BatteryPack               : return NSLocalizedString("Battery Pack", comment: self.rawValue)
        }
    }
   
    public var localizedFirstString:String {
        switch self {
        case .SmartPhoneLens            : return NSLocalizedString("Smartphone", comment: self.rawValue + " : firstword")
        case .MobileTripod              : return NSLocalizedString("Mobile", comment: self.rawValue + " : firstword")
        case .SelfieStick               : return NSLocalizedString("Selfie", comment: self.rawValue + " : firstword")
        case .LightingTools             : return NSLocalizedString("Lighting", comment: self.rawValue + " : firstword")
        case .BatteryPack               : return NSLocalizedString("Battery", comment: self.rawValue + " : firstword")
        }
    }
    
    public var localizedSecondString:String {
        switch self {
        case .SmartPhoneLens            : return NSLocalizedString("Lens", comment: self.rawValue + " : secondword")
        case .MobileTripod              : return NSLocalizedString("Tripod", comment: self.rawValue + " : secondword")
        case .SelfieStick               : return NSLocalizedString("Stick", comment: self.rawValue + " : secondword")
        case .LightingTools             : return NSLocalizedString("Tools", comment: self.rawValue + " : secondword")
        case .BatteryPack               : return NSLocalizedString("Pack", comment: self.rawValue + " : secondword")
        }
    }

}

extension SequenceType where Generator.Element == Equipment {
    
    public func toLiteralArray()->[String] {
        return self.map { String($0.rawValue) }.flatMap { $0 }
    }
 
}

extension SequenceType where Generator.Element == String {
    
    public func toEquipmentArray()->[Equipment] {
        let rawVals:[String] = Equipment.allValues.map { $0.rawValue }
        return self.filter { rawVals.contains($0) }.flatMap { Equipment(rawValue:$0) }
    }
    
}


public struct BioAndEquiment {
    public let bio:String
    public let equipment:[Equipment]
    public init(bio:String, equipment:[Equipment]) {
        self.bio                = bio
        self.equipment          = equipment
    }
}

public enum PhotoExtrasType:String {
    case Bio                    = "bio"
    case Equipment              = "equipment"
}

extension BioAndEquiment {
    
    public func toDictionary()->[String:AnyObject] {
        return [
             PhotoExtrasType.Bio.rawValue         : bio
            ,PhotoExtrasType.Equipment.rawValue   : equipment.toLiteralArray()
        ]
    }
    
}

extension Dictionary where Key:StringLiteralConvertible, Value: AnyObject {
    
    public func toBioAndEquiment()->BioAndEquiment? {
        guard let bio = self["bio"] as? String else {
            return nil
        }
        if bio.characters.count < 1 { return nil }
        guard let eqString = self["equipment"] as? [String] else {
            return nil
        }
        let eq = eqString.toEquipmentArray()
        if eq.count < 1 { return nil }
        
        return BioAndEquiment(bio: bio, equipment: eq)
    }
    
}








