//
//  UserDataSource.swift
//  CaptureLive
//
//  Created by Scott Jones on 5/6/16.
//  Copyright © 2016 Capture Media. All rights reserved.
//

import UIKit
import CaptureUI

enum UserNodeIndex:Int {
    case Profile        = 0
    case Experience     = 1
    case Work           = 2
    case PhotoExtras    = 3
}

public class CreateProfileDataProvider<Delegate:DataProviderDelegate>:NSObject, DataProvider {

    public typealias Object     = Delegate.Object
    typealias DeletesAndDict    = (dictionary:[String:Object], deletes:[DataProviderUpdate<Object>])
 
    required public init(userDictionary:[String:Object], delegate: Delegate) {
        self.delegate           = delegate
        self.userDictionary     = userDictionary
        super.init()
    }
    
    // removes keys/values except for keys/value in elem
    func remoteElements(elem:[String], dictionary:[String:Object])->DeletesAndDict {
        let keys = dictionary.keys.filter{ elem.contains($0) }.flatMap{ $0 }
        var good:[String:Object] = [:]
        for i in keys {
            good[i] = dictionary[i]
        }
        var deletes:[DataProviderUpdate<Object>] = []
        for i in good.keys.count..<dictionary.keys.count {
            deletes.append( .Delete(NSIndexPath(forRow:i, inSection: 0)))
        }
        return (dictionary:good, deletes:deletes)
    }
    
    public func popToExperience() {
        let refresh = remoteElements([
             ProfileTableCellType.PROFILE.rawValue], dictionary: self.userDictionary)
        self.userDictionary     = refresh.dictionary
        self.delegate.dataProviderDidUpdate(refresh.deletes)
    }
    
    public func popToWork() {
        let refresh = remoteElements([
             ProfileTableCellType.PROFILE.rawValue
            ,ProfileTableCellType.EXPERIENCE.rawValue], dictionary: self.userDictionary)
        self.userDictionary     = refresh.dictionary
        self.delegate.dataProviderDidUpdate(refresh.deletes)
    }
    
    public func popToPhotoExtras() {
        let refresh = remoteElements([
             ProfileTableCellType.PROFILE.rawValue
            ,ProfileTableCellType.EXPERIENCE.rawValue
            ,ProfileTableCellType.WORK.rawValue], dictionary: self.userDictionary)
        self.userDictionary     = refresh.dictionary
        self.delegate.dataProviderDidUpdate(refresh.deletes)
    }

    public func addProfile(profileObject:Object) {
        var updates:[DataProviderUpdate<Object>] = []
        if let _ = self.userDictionary[ProfileTableCellType.PROFILE.rawValue] {
            updates.append( .Update(NSIndexPath(forRow:0, inSection: 0), profileObject) )
        } else {
            updates.append( .Insert(NSIndexPath(forRow:0, inSection: 0)) )
        }
        self.userDictionary[ProfileTableCellType.PROFILE.rawValue] = profileObject
        self.delegate.dataProviderDidUpdate(updates)
    }
    
    public func addExperience(experienceObject:Object) {
        var updates:[DataProviderUpdate<Object>] = []
        if let _ = self.userDictionary[ProfileTableCellType.EXPERIENCE.rawValue] {
            updates.append( .Update(NSIndexPath(forRow:1, inSection: 0), experienceObject) )
        } else {
            updates.append( .Insert(NSIndexPath(forRow:1, inSection: 0)) )
        }
        self.userDictionary[ProfileTableCellType.EXPERIENCE.rawValue] = experienceObject
        self.delegate.dataProviderDidUpdate(updates)
    }

    public func addWork(workObject:Object) {
        var updates:[DataProviderUpdate<Object>] = []
        if let _ = self.userDictionary[ProfileTableCellType.WORK.rawValue] {
            updates.append( .Update(NSIndexPath(forRow:2, inSection: 0), workObject) )
        } else {
            updates.append( .Insert(NSIndexPath(forRow:2, inSection: 0)) )
        }
        self.userDictionary[ProfileTableCellType.WORK.rawValue] = workObject
        self.delegate.dataProviderDidUpdate(updates)
    }
    
    public func addPhotoExtras(photoExtras:Object) {
        var updates:[DataProviderUpdate<Object>] = []
        if let _ = self.userDictionary[ProfileTableCellType.PHOTOEXTRAS.rawValue] {
            updates.append( .Update(NSIndexPath(forRow:3, inSection: 0), photoExtras) )
        } else {
            updates.append( .Insert(NSIndexPath(forRow:3, inSection: 0)) )
        }
        self.userDictionary[ProfileTableCellType.PHOTOEXTRAS.rawValue] = photoExtras
        self.delegate.dataProviderDidUpdate(updates)
    }
    
    private weak var delegate:Delegate!
    private var userDictionary:[String:Object] = [:]
 
    // MARK: DataProvider
    public func objectAtIndexPath(indexPath: NSIndexPath) -> Object {
        guard let index = UserNodeIndex(rawValue: indexPath.row) else {
            fatalError("No UserNodeIndex for \(indexPath.row)")
        }
        switch index {
        case .Profile:
            return self.userDictionary[ProfileTableCellType.PROFILE.rawValue]!
        case .Experience:
            return self.userDictionary[ProfileTableCellType.EXPERIENCE.rawValue]!
        case .Work:
            return self.userDictionary[ProfileTableCellType.WORK.rawValue]!
        case .PhotoExtras:
            return self.userDictionary[ProfileTableCellType.PHOTOEXTRAS.rawValue]!
        }
    }
   
    public func numberOfItemsInSection(section: Int) -> Int {
        return self.userDictionary.keys.count
    }
    
}