//
//  User+Owner.swift
//  Current
//
//  Created by Scott Jones on 3/15/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CoreDataHelpers

private let UserLoggedInKey             = "isLoggedIn"
private let UserAttemptingLoginKey      = "isAttemptingLogin"

public protocol UserLoggable: class {
    associatedtype Element
    var isLoggedIn:Bool { get set }
    var isAttemptingLogin:Bool { get set }
    
    func setAsLoggedInUser()
    func setAsAttemptingLoginUser()
    func logOut()
    
    static func loggedInUser(moc:NSManagedObjectContext)->Element?
    static func removeLoggedInUser(moc:NSManagedObjectContext)
    static var loggedInPredicate:NSPredicate { get }

    static func removeAttemptingLoginUser(moc:NSManagedObjectContext)
    static func attemptingLoginUser(moc:NSManagedObjectContext)->Element?
    static var attemptingLoginPredicate:NSPredicate { get }
}

extension UserLoggable where Self:User  {
    
    public func setAsLoggedInUser() {
        isLoggedIn          = true
        isAttemptingLogin   = false
    }

    public func setAsAttemptingLoginUser() {
        isAttemptingLogin   = true
        isLoggedIn          = false
    }
    
    static public var loggedInPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", UserLoggedInKey)
    }
   
    static public var attemptingLoginPredicate:NSPredicate {
        return NSPredicate(format: "%K == true", UserAttemptingLoginKey)
    }

}

public protocol UserValidatable {
    static var completedUserPredicate:NSPredicate { get }
    static var incompletedUserPredicate:NSPredicate { get }
    var isCompletedUser:Bool { get }
}










