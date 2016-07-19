//
//  TextFieldValidator.swift
//  Current
//
//  Created by Scott Jones on 4/9/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import UIKit

public typealias TextFieldValid = (String)->(isValid:Bool, reason:String)

public struct TextfieldValidator {
    public let textField:UITextField
    public let validate:TextFieldValid
    public let label:UILabel?
    public init(textField:UITextField, label:UILabel?, validate:TextFieldValid) {
        self.textField = textField
        self.validate = validate
        self.label = label
    }
}

func ==(l: TextfieldValidator, r: TextfieldValidator) -> Bool {
    return l.textField == r.textField
}

extension TextfieldValidator {
    
    public var text:String {
        guard let t = textField.text else {
            return ""
        }
        return t
    }
    
    public var isEmpty:Bool {
        guard let t = textField.text else {
            return false
        }
        return t.characters.count > 0
    }
    
    public var isValid:Bool {
        guard let t = textField.text else {
            return false
        }
        return self.validate(t).isValid
    }
    
    public func runValidate()->(isValid:Bool, reason:String) {
        guard let t = textField.text else {
            return self.validate("")
        }
        let v = self.validate(t)
        if v.isValid == false {
            label?.textColor = UIColor.redColor()
        }
        return v
    }
    
    public func next(arr:[TextfieldValidator])->TextfieldValidator? {
        guard let index = arr.indexOf({$0 == self}) else { return nil }
        let i = index + 1
        if i < arr.count {
            return arr[i]
        }else {
            return nil
        }
    }
    
    public func before(arr:[TextfieldValidator])->TextfieldValidator? {
        guard let index = arr.indexOf({$0 == self}) else { return nil }
        let i = index - 1
        if i < 0 {
            return nil
        } else {
            return arr[i]
        }
    }
    
}