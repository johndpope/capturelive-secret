//
//  ViewController+Extensions.swift
//  Current
//
//  Created by Scott Jones on 3/19/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation
import CoreData
import CaptureModel
import CaptureCore

protocol RemoteAndLocallyServiceable:class, ManagedObjectContextSettable, RemoteServiceable {}

typealias Progression                   = (AnyObject?)->Bool
typealias ProgressionObject             = (AnyObject?)->AnyObject?

func addProgObjectToProg(progObj:ProgressionObject, prog:Progression)->Progression {
    return { u in
        return prog(progObj(u))
    }
}

func combineProg(prog1:Progression, prog2:Progression)->Progression {
    return { u in
        return prog1(u) && prog2(u)
    }
}

func userHasFacebookToken()->Progression {
    return User.facebookTokenNotNilPredicate.evaluateWithObject
}

func userHasFilledOutProfile()->Progression {
    return { user in
        guard let u = user else { return false }
        return User.hasAcceptedTermsAndConditionsPredicate.evaluateWithObject(u)
    }
}

func userHasCreatedWorkReel()->Progression {
    return User.workReelNotEmptyPredicate.evaluateWithObject
}

func userHasCreatedEquipmentList()->Progression {
    return User.equipmentNotEmptyPredicate.evaluateWithObject
}

func userHasCreatedExperience()->Progression {
    return User.experienceNotEmptyPredicate.evaluateWithObject
}

func userHasNoValidationError()->Progression {
    return User.hasNoValidationErrorPredicate.evaluateWithObject
}

func notMarkedForRemoteVerification()->Progression {
    return User.notMarkedForRemoteVerificationPredicate.evaluateWithObject
}

func attemptingLoginUser()->ProgressionObject {
    return { mc in
        guard let moc = mc as? NSManagedObjectContext else {
            return nil
        }
        return User.attemptingLoginUser(moc)
    }
}

func hasAttemptingLoginUser()->Progression {
    return { mc in
        guard let moc = mc as? NSManagedObjectContext else { return false }
        return User.attemptingLoginUser(moc) != nil
    }
}

func hasServiceToken()->Progression {
    return { atr in
        guard let actable = atr as? AccessTokenRetrivable else { return false }
        return actable.hasAccessToken
    }
}

func hasAcceptedPermissions()->Progression {
    return { atr in
        guard let actable = atr as? ApplicationRememberable else { return false }
        return actable.hasAcceptedPermissions
    }
}

func isScreenByPassable()->Progression {
    return { mc in
        guard let moc = mc as? NSManagedObjectContext else {
            return false
        }
        return moc.shouldByPass
    }
}

func hasEnoughToByPassPhoneLogin(apiAndDatabase:RemoteAndLocallyServiceable, complete:()->()) {
    let both                            = combineProg(hasAttemptingLoginUser(), prog2:hasServiceToken())
    let final                           = combineProg(both, prog2:isScreenByPassable())
    if final(apiAndDatabase.managedObjectContext) {
        complete()
    }
}

func hasEnoughToGetPastFaceBook(apiAndDatabase:RemoteAndLocallyServiceable, complete:()->()){
    var final:Progression!              = nil
    let attLogUser                      = attemptingLoginUser()
    let userHasFBToken                  = addProgObjectToProg(attLogUser, prog:userHasFacebookToken())
    let userNoValidationError           = addProgObjectToProg(attLogUser, prog:userHasNoValidationError())
    let userNotMarkedForSync            = addProgObjectToProg(attLogUser, prog:notMarkedForRemoteVerification())
    final                               = combineProg(userHasFBToken, prog2:hasServiceToken())
    final                               = combineProg(final, prog2:isScreenByPassable())
    final                               = combineProg(final, prog2:userNoValidationError)
    final                               = combineProg(final, prog2:userNotMarkedForSync)
    if final(apiAndDatabase.managedObjectContext) {
        complete()
    }
}

func hasAcceptedTermsAndBeenAskedForPermissions(apiAndDatabase:RemoteAndLocallyServiceable)->Bool {
    var final:Progression!              = nil
    let attLogUser                      = attemptingLoginUser()
    let userHasProfile                  = addProgObjectToProg(attLogUser, prog:userHasFilledOutProfile())
    let userNoValidationError           = addProgObjectToProg(attLogUser, prog:userHasNoValidationError())
    final                               = combineProg(userHasProfile, prog2:hasServiceToken())
    final                               = combineProg(final, prog2:isScreenByPassable())
    final                               = combineProg(final, prog2:hasAcceptedPermissions())
    final                               = combineProg(final, prog2:userNoValidationError)
    return final(apiAndDatabase.managedObjectContext)
}

func hasEnoughToGetPastReelCreation(apiAndDatabase:RemoteAndLocallyServiceable, complete:()->()){
    var final:Progression!              = nil
    let attLogUser                      = attemptingLoginUser()
    let userHasWorkReel                 = addProgObjectToProg(attLogUser, prog:userHasCreatedWorkReel())
    let userNoValidationError           = addProgObjectToProg(attLogUser, prog:userHasNoValidationError())
    let userNotMarkedForSync            = addProgObjectToProg(attLogUser, prog:notMarkedForRemoteVerification())
    final                               = combineProg(userHasWorkReel, prog2:hasServiceToken())
    final                               = combineProg(final, prog2:isScreenByPassable())
    final                               = combineProg(final, prog2:userNoValidationError)
    final                               = combineProg(final, prog2:userNotMarkedForSync)
    if final(apiAndDatabase.managedObjectContext) {
        complete()
    }
}

func hasEnoughToGetPastEquipmentCreation(apiAndDatabase:RemoteAndLocallyServiceable, complete:()->()){
    var final:Progression!              = nil
    let attLogUser                      = attemptingLoginUser()
    let userHasWorkReel                 = addProgObjectToProg(attLogUser, prog:userHasCreatedEquipmentList())
    let userNoValidationError           = addProgObjectToProg(attLogUser, prog:userHasNoValidationError())
    let userNotMarkedForSync            = addProgObjectToProg(attLogUser, prog:notMarkedForRemoteVerification())
    final                               = combineProg(userHasWorkReel, prog2:hasServiceToken())
    final                               = combineProg(final, prog2:isScreenByPassable())    
    final                               = combineProg(final, prog2:userNoValidationError)
    final                               = combineProg(final, prog2:userNotMarkedForSync)
    if final(apiAndDatabase.managedObjectContext) {
        complete()
    }
}

func hasEnoughToGetPastExperienceCreation(apiAndDatabase:RemoteAndLocallyServiceable, complete:()->()){
    var final:Progression!              = nil
    let attLogUser                      = attemptingLoginUser()
    let userHasWorkReel                 = addProgObjectToProg(attLogUser, prog:userHasCreatedExperience())
    let userNoValidationError           = addProgObjectToProg(attLogUser, prog:userHasNoValidationError())
    let userNotMarkedForSync            = addProgObjectToProg(attLogUser, prog:notMarkedForRemoteVerification())
    final                               = combineProg(userHasWorkReel, prog2:hasServiceToken())
    final                               = combineProg(final, prog2:isScreenByPassable())
    final                               = combineProg(final, prog2:userNoValidationError)
    final                               = combineProg(final, prog2:userNotMarkedForSync)
    if final(apiAndDatabase.managedObjectContext) {
        complete()
    }
}

func f(c:Progression)->Progression {
    return { u in
        return c(u)
    }
}















