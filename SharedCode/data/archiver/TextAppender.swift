//
//  TextAppender.swift
//  Capture-Live-Camera
//
//  Created by hatebyte on 6/29/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

import UIKit

class TextAppender: NSObject {
    
    var fileName:String
    
    init(fileName:String) {
        self.fileName = fileName
        super.init()
    }

    var filepath : String {
        get {
            return NSHomeDirectory() + "/Documents/" + self.fileName
        }
    }
    
    func writeToFile(text:String) {
        let appendText = text + "\n"
        if NSFileManager().fileExistsAtPath(filepath) == true {
            let myhandle = NSFileHandle(forWritingAtPath: filepath)
            myhandle?.seekToEndOfFile()
            myhandle?.writeData(appendText.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        } else {
            do {
                try appendText.writeToFile(filepath, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {            }
        }
    }
    
    func readFile()->String? {
        return TextAppender.open(filepath, utf8: NSUTF8StringEncoding)
    }
    
    class func open (path: String, utf8: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        if NSFileManager().fileExistsAtPath(path) == true {
            do {
                let st = try String(contentsOfFile: path, encoding: utf8)
                return st
            } catch {
                return nil
            }

        } else {
            return nil
        }
    }
    
    func clear() {
        if NSFileManager().fileExistsAtPath(filepath) == true {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filepath)
            } catch {

            }
        }
    }
    
}
