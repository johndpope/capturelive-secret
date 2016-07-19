//
//  User+Extensions.swift
//  Current
//
//  Created by Scott Jones on 3/19/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel

extension User {
    
    public var firstNameLastLetter:String {
        guard let fn = firstName, char = lastName?.characters.first else {
            return ""
        }
        return "\(fn) \(char)."
    }
    
}

private let FormatNilOrBlankString = "%K == nil OR %K ==''"
extension User {
    
    public static var hasFilledOutCreateProfilePredicate:NSPredicate {
        return NSPredicate(format: "%K != nil AND %K != nil AND %K != nil", Keys.FirstName.rawValue, Keys.LastName.rawValue, Keys.Email.rawValue)
    }
    
    public static var hasPartiallyCreatedProfilePredicate:NSPredicate {
        let missingFieldNamesPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [hasFirstName, hasLastName, hasEmail])
        return NSCompoundPredicate(orPredicateWithSubpredicates: [hasValidationErrorPredicate, missingFieldNamesPredicate, hasPhoneNumber])
    }
   
    public static var hasCompletedProfilePredicate:NSPredicate {
        return NSPredicate(format: "%K != nil", Keys.Avatar.rawValue)
    }
    
    public static var hasNotCompletedProfilePredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate:hasCompletedProfilePredicate)
    }
   
    public static var missingPaypalEmail:NSPredicate  {
        return NSPredicate(format:"(%K == nil OR %K=='')", Keys.PaypalEmail.rawValue, Keys.PaypalEmail.rawValue)
    }
    
    public static var hasPaypalEmail:NSPredicate  {
        return NSCompoundPredicate(notPredicateWithSubpredicate:missingPaypalEmail)
    }
    
    public static var hasPhoneNumber:NSPredicate  {
        return NSPredicate(format:"%K != nil", Keys.PhoneNumber.rawValue)
    }
   
    public static var hasNoAvatar:NSPredicate  {
        return NSPredicate(format: FormatNilOrBlankString, Keys.Avatar.rawValue, Keys.Avatar.rawValue)
    }

    public static var hasAvatar:NSPredicate  {
        return NSCompoundPredicate(notPredicateWithSubpredicate:hasNoAvatar)
    }
    
    public static var hasNoFirstName:NSPredicate  {
        return NSPredicate(format: FormatNilOrBlankString, Keys.FirstName.rawValue, Keys.FirstName.rawValue)
    }
   
    public static var hasFirstName:NSPredicate  {
        return NSCompoundPredicate(notPredicateWithSubpredicate:hasNoFirstName)
    }
    
    public static var hasNoLastName:NSPredicate  {
        return NSPredicate(format: FormatNilOrBlankString, Keys.LastName.rawValue, Keys.LastName.rawValue)
    }
    
    public static var hasLastName:NSPredicate  {
        return NSCompoundPredicate(notPredicateWithSubpredicate:hasNoLastName)
    }

    public static var hasNoEmail:NSPredicate  {
        return NSPredicate(format: FormatNilOrBlankString, Keys.Email.rawValue, Keys.Email.rawValue)
    }
   
    public static var hasEmail:NSPredicate  {
        return NSCompoundPredicate(notPredicateWithSubpredicate:hasNoEmail)
    }

}
