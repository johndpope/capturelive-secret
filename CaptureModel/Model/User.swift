//
//  User.swift
//  Current
//
//  Created by Scott Jones on 3/8/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

extension User: KeyCodable {
    public enum Keys: String {
        case Avatar                 = "avatar"
        case RemoteAvatarUrl        = "remoteAvatarUrl"
        case Email                  = "email"
        case FirstName              = "firstName"
        case InstagramUsername      = "instagramUsername"
        case LastName               = "lastName"
        case Bio                    = "bio"
        case PaypalEmail            = "paypalEmail"
        case PaypalAccessCode       = "paypalAccessCode"
        case PaypalVerified         = "paypalVerified"
        case TotalPaymentsMade      = "totalPaymentsMade"
        case PhoneNumber            = "phoneNumber"
        case ValidationError        = "validationError"
        case Latitude               = "latitude"
        case Longitude              = "longitude"
        case FacebookAuthToken      = "facebookAuthToken"
        case FacebookProfileUrl     = "facebookProfileUrl"
        case AgeRangeMin            = "ageRangeMin"
        case AcceptedTNCDate        = "acceptedTNCDate"
        case WorkReelArray          = "workReelArray"
        case ExperienceDictionary   = "experienceDictionary"
        case EquipmentArray         = "equipmentArray"
    }
}

public final class User: ManagedObject {

    @NSManaged public var avatar: String?
    @NSManaged public var remoteAvatarUrl: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var instagramUsername: String?
    @NSManaged public var lastName: String?
    @NSManaged public var bio: String?
    @NSManaged public var totalPaymentsMade: Double
    @NSManaged public var phoneNumber: String
    @NSManaged public var facebookAuthToken: String?
    @NSManaged public var facebookProfileUrl: String?
    @NSManaged public private(set) var acceptedTNCDate: NSDate?
    @NSManaged public private(set) var workReelArray: [[String:AnyObject]]?
    @NSManaged public private(set) var experienceDictionary: [String:AnyObject]?
    @NSManaged public private(set) var equipmentArray: [String]?

    public var equipment:[Equipment] {
        get {
            return equipmentArray?.toEquipmentArray() ?? []
        }
        set {
            equipmentArray = newValue.toLiteralArray()
        }
    }
    
    public var experience:Experience? {
        get {
            return experienceDictionary?.toExperience()
        }
        set {
            experienceDictionary = newValue?.toDictionary()
        }
    }
    
    public var workReel:[Reel] {
        get {
            return workReelArray?.toReelArray() ?? []
        }
        set {
            workReelArray = newValue.toJSONArray()
        }
    }

    public override func willSave() {
        super.willSave()
       
        if User.notMarkedForRemoteUpdateAndHasNoValidationErrorPredicate.evaluateWithObject(self)
            && changedInNeedForRemoteVerification() {
            markForNeedsRemoteVerification()
        }
        
        if User.notMarkedForNeedsPaypalVerificationPredicate.evaluateWithObject(self)
            && changedInNeedForRemotePaypalVerificationUpdate() {
            markForNeedsPaypalVerification()
        }

    }
 
    public static var facebookTokenNilPredicate: NSPredicate {
        return NSPredicate(format: "%K == NULL", Keys.FacebookAuthToken.rawValue)
    }
    
    public static var facebookTokenNotNilPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: facebookTokenNilPredicate)
    }
   
    public static var workReelEmptyPredicate: NSPredicate {
        return NSPredicate(format: "%K == NULL", Keys.WorkReelArray.rawValue)
    }
    
    public static var workReelNotEmptyPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: workReelEmptyPredicate)
    }
    
    public static var equipmentEmptyPredicate: NSPredicate {
        return NSPredicate(format: "%K == NULL OR %K[SIZE] == 0", Keys.EquipmentArray.rawValue, Keys.EquipmentArray.rawValue)
    }
    
    public static var equipmentNotEmptyPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: equipmentEmptyPredicate)
    }
    
    public static var experienceEmptyPredicate: NSPredicate {
        return NSPredicate(format: "%K == NULL", Keys.ExperienceDictionary.rawValue)
    }
    
    public static var experienceNotEmptyPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: experienceEmptyPredicate)
    }
    
    public static var hasNotAcceptedTermsAndConditionsPredicate: NSPredicate {
        return NSPredicate(format: "%K == NULL", Keys.AcceptedTNCDate.rawValue)
    }
    
    public static var hasAcceptedTermsAndConditionsPredicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: hasNotAcceptedTermsAndConditionsPredicate)
    }
    
    public func acceptTermsAndConditions() {
        acceptedTNCDate = NSDate()
    }
}

extension User: RemoteComparable {
    
    @NSManaged public var createdAt: NSDate
    @NSManaged public var updatedAt: NSDate
    @NSManaged public var urlHash: String

}

extension User : ManagedObjectType {
    
    public static var entityName: String {
        return "User"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key:RemoteComparableKeys.CreatedAt.rawValue, ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }

}

private let LoggedInUserCacheKey            = "com.capture.current.ios.loggedinuserkey"
private let AttemptingLoggedInUserCacheKey  = "com.capture.current.ios.loggedinuserkey.attempting"
extension User: UserLoggable {
    
    @NSManaged public var isLoggedIn:Bool
    @NSManaged public var isAttemptingLogin:Bool

    public func logOut() {
        isLoggedIn                  = false
        isAttemptingLogin           = false
        managedObjectContext?.setObject(nil, forSingleObjectCacheKey: LoggedInUserCacheKey)
        managedObjectContext?.setObject(nil, forSingleObjectCacheKey: AttemptingLoggedInUserCacheKey)
    }
    
    public static func removeLoggedInUser(moc:NSManagedObjectContext) {
        guard let loggedInUser = User.loggedInUser(moc) else {
            return
        }
        loggedInUser.isLoggedIn     = false
        moc.setObject(nil, forSingleObjectCacheKey: LoggedInUserCacheKey)
    }
    
    public static func removeAttemptingLoginUser(moc:NSManagedObjectContext) {
        guard let attloggedInUser = User.attemptingLoginUser(moc) else {
            return
        }
        attloggedInUser.isAttemptingLogin = false
        moc.setObject(nil, forSingleObjectCacheKey:AttemptingLoggedInUserCacheKey)
    }
    
    public static func loggedInUser(moc:NSManagedObjectContext)->User? {
        let user = User.fetchSingleObjectInContext(moc, cacheKey:LoggedInUserCacheKey) { request in
            request.predicate       = loggedInPredicate
        }
        guard let u = user else {
            return nil
        }
        return u
    }

    public static func attemptingLoginUser(moc:NSManagedObjectContext)->User? {
        let user = User.fetchSingleObjectInContext(moc, cacheKey:AttemptingLoggedInUserCacheKey) { request in
            request.predicate       = attemptingLoginPredicate
            request.returnsObjectsAsFaults = false
        }
        guard let u = user else {
            return nil
        }

        return u
    }
    
}

extension User : RemoteUpdatable {
   
    @NSManaged public var needsRemoteVerification:Bool
    @NSManaged public var shouldBlockFromJSONMapping:Bool
    
    public func changedInNeedForRemoteVerification()->Bool {
        let keys:[Keys] = [.FirstName, .LastName, .InstagramUsername, .Email, .Bio, .RemoteAvatarUrl, .FacebookAuthToken, .FacebookProfileUrl, .WorkReelArray, .EquipmentArray, .ExperienceDictionary, .AcceptedTNCDate, .ValidationError]
        return keys.reduce(false) { a, b in
            return a ? a : changedValues()[b.rawValue] != nil
        }
    }
    
    public static var notMarkedForRemoteUpdateAndHasNoValidationErrorPredicate:NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [notMarkedForRemoteVerificationPredicate, hasNoValidationErrorPredicate])
    }

    public static var markedForRemoteUpdateAndHasNoValidationErrorPredicate:NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [markedForRemoteVerificationPredicate, hasNoValidationErrorPredicate])
    }
    
}

extension User : UserValidatable {

    public static var completedUserPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate:incompletedUserPredicate)
    }
    
    public static var incompletedUserPredicate:NSPredicate {
        return NSPredicate(format: "%K == nil", Keys.ExperienceDictionary.rawValue)
    }

    public var isCompletedUser:Bool {
        return self.avatar == nil
    }

}

extension User : BinaryStringArrayTransformable {}
extension User : BinaryDicationaryTransformable {}
extension User : BinaryDictionaryArrayTransformable {}

extension User : AgeRangeLimitable {
        
    @NSManaged public var ageRangeMin:UInt16
    
}

extension User : Validatable {
    
    @NSManaged public var validationError:[String:AnyObject]?

}

extension User : RemotePaypalVerifyable {
    
    @NSManaged public var needsPaypalVerification:Bool
    @NSManaged public var paypalAccessCode: String?
    @NSManaged public var needsPaypalEmail:Bool
    @NSManaged public var paypalEmail: String?

    public func resetPaypalExperience() {
        needsPaypalVerification = false
        needsPaypalEmail = false
        paypalAccessCode = nil
        paypalEmail = nil
    }
    
    public func changedInNeedForRemotePaypalVerificationUpdate()->Bool {
        guard let _ = changedValues()[Keys.PaypalAccessCode.rawValue] as? String else {
            return false
        }
        return paypalAccessCode != nil
    }
    
    public static var doesNotPaypalEmailPredicate:NSPredicate {
        return NSPredicate(format: "%K == nil OR %K =''", Keys.PaypalEmail.rawValue, Keys.PaypalEmail.rawValue)
    }
    
    public static var hasPaypalEmailPredicate:NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: doesNotPaypalEmailPredicate)
    }
    
}


extension User : JSONHashable {
    
    public func toJSON() -> [String : AnyObject] {
        var user:[String:AnyObject] = [
            "url_hash"              : self.urlHash,
            "unix_created_at"       : self.createdAt.timeIntervalSince1970,
            "unix_updated_at"       : self.updatedAt.timeIntervalSince1970,
            "first_name"            : self.firstName ?? "",
            "last_name"             : self.lastName ?? "",
            "phone_number"          : self.phoneNumber ?? "",
            "contact_email"         : self.email ?? "",
            "bio"                   : self.bio ?? "",
            "instagram_username"    : self.instagramUsername ?? "",
            "age_range_min"         : NSNumber(unsignedShort: self.ageRangeMin),
            "facebook_token"        : self.facebookAuthToken ?? "",
            "facebook_profile_url"  : self.facebookProfileUrl ?? ""
        ]
        if let tcDate = self.acceptedTNCDate {
            user["unix_terms_accepted_at"] = tcDate.timeIntervalSince1970
        }
        if let pemail = self.paypalEmail {
            user["paypal_email"]    = pemail
        }
        if let ppac = self.paypalAccessCode {
            user["paypal_authorization_code"] = ppac
        }
        if let rau = self.remoteAvatarUrl {
            user["remote_avatar_url"] = rau
        }
        
        let reel                    = self.workReelArray ?? []
        user["reels"]               = reel
        
        let equipment               = self.equipmentArray ?? []
        user["equipment"]           = equipment

        if let experience = self.experienceDictionary {
            user["experience"]      = experience
        }
        return user
    }
    
}

public struct RemoteUser: RemoteRecordType {

    public var urlHash: String
    public var createdAt: NSDate
    public var updatedAt: NSDate
    public var ageRangeMin: UInt16 = 0
    public var acceptedTNCDate:NSDate?
    public var firstName: String?
    public var lastName: String?
    public var phoneNumber: String
    public var email: String?
    public var bio: String?
    public var paypalEmail: String?
    public var totalPaymentsMade:Double = 0
    public var avatar: String?
    public var instagramUsername: String?
    public var facebookAuthToken:String?
    public var facebookProfileUrl:String?
    public var workReelArray:[[String:AnyObject]]?
    public var equipmentArray:[String]?
    public var experienceDictionary:[String:AnyObject]?

    public init(user:[String:AnyObject]) {
        guard let uhash         = user["url_hash"] as? String else { fatalError("User json has no `url_hash`") }
        self.urlHash            = uhash
        guard let createdAt     = user["unix_created_at"] as? NSTimeInterval else { fatalError("User json has no `unix_created_at`") }
        self.createdAt          = NSDate(timeIntervalSince1970:createdAt)
        guard let updatedAt     = user["unix_updated_at"] as? NSTimeInterval else { fatalError("User json has no `unix_updated_at`") }
        self.updatedAt          = NSDate(timeIntervalSince1970:updatedAt)
        guard let phoneNumber   = user["phone_number"] as? String else { fatalError("User json has no `phone_number`") }
        self.phoneNumber        = phoneNumber
        self.firstName          = user["first_name"] as? String
        self.lastName           = user["last_name"] as? String
        self.email              = user["contact_email"] as? String
        self.bio                = user["bio"] as? String
        self.instagramUsername  = user["instagram_username"] as? String
        self.paypalEmail        = user["paypal_email"] as? String
        self.facebookAuthToken  = user["facebook_token"] as? String
        self.facebookProfileUrl = user["facebook_profile_url"] as? String
        self.avatar             = user["avatar"] as? String
        if let tpm = user["total_payments_made"] as? NSNumber {
            self.totalPaymentsMade = tpm.doubleValue
        }
        if let agm = user["age_range_min"] as? NSNumber {
            self.ageRangeMin    = agm.unsignedShortValue
        }
        if let tcDate = user["unix_terms_accepted_at"] as? NSTimeInterval {
            self.acceptedTNCDate = NSDate(timeIntervalSince1970:tcDate)
        }
        
        self.workReelArray      = user["reels"] as? [[String:AnyObject]] ?? nil
        self.equipmentArray     = user["equipment"] as? [String] ?? [] ?? nil
        self.experienceDictionary = user["experience"] as? [String:AnyObject] ?? nil
    }

}

extension RemoteUser : RemoteRecordMappable {
    
    public func mapTo<T:ManagedObjectType>(managedObject:T) {
        guard let user = managedObject as? User else {
            fatalError("Object mapped is not a User")
        }
        user.urlHash            = self.urlHash
        user.createdAt          = self.createdAt
        user.updatedAt          = self.updatedAt
        user.firstName          = self.firstName
        user.lastName           = self.lastName
        user.phoneNumber        = self.phoneNumber
        user.email              = self.email
        user.bio                = self.bio
        user.instagramUsername  = self.instagramUsername
        user.totalPaymentsMade  = self.totalPaymentsMade
        user.avatar             = self.avatar
        user.facebookAuthToken  = self.facebookAuthToken
        user.facebookProfileUrl = self.facebookProfileUrl
        user.ageRangeMin        = self.ageRangeMin
        user.acceptedTNCDate    = self.acceptedTNCDate
        if let ppemail = self.paypalEmail {
            user.paypalEmail    = ppemail
        }
        
        if let reels = self.workReelArray {
            if reels.count > 0 {
                user.workReel   = reels.toReelArray()
            }
        }
        
        if let equip = self.equipmentArray {
            if equip.count > 0 {
                user.equipment  = equip.toEquipmentArray()
            }
        }
        
        if let exp = self.experienceDictionary?.toExperience() {
            user.experience     = exp
        }
        
        // unmark temp vars
        user.remoteAvatarUrl    = nil
    }
    
}

extension RemoteUser {
    public func insertIntoContext(moc:NSManagedObjectContext)->User {
        return User.insertOrUpdate(moc, urlHash:urlHash) { user in
            if user.updatedAt.compare(self.updatedAt) == NSComparisonResult.OrderedAscending {
                self.mapTo(user)
            }
        }
    }
}



