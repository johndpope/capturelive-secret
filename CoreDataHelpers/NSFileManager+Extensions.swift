//
//  NSFileManager+Extensions.swift
//  Current
//
//  Created by Scott Jones on 3/30/16.
//  Copyright © 2016 Barf. All rights reserved.
//

import Foundation

extension NSFileManager {
    
    public static var documents:String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    }
    
    public func createDirectoryInDirectory(directory:String, path:String)->String {
        let filePath = NSString(format:"%@", directory).stringByAppendingPathComponent(path)
        if fileExistsAtPath(filePath) == false {
            do {
                try createDirectoryAtPath(filePath, withIntermediateDirectories:true, attributes: nil)
            } catch {
//                print("Error : createPathInDirectory : \(error)")
            }
        }
        return path
    }
    
    public func createIndexedPath(directory:String, fileName:String, ext:String)->String {
        var numContents:Int = 0
        do {
            numContents = try contentsOfDirectoryAtPath(directory).count
        } catch {
//            print("Error : createIndexedPath : \(error)")
        }
        return "\(directory)/\(fileName) \(numContents).\(ext)"
    }
    
    public func deleteItem(path:String) {
        do {
            try removeItemAtPath(path)
        } catch  {
//            print("Error : deleteItem : \(error)")
        }
    }
    
    public func deleteAllInDirectory(directory:String) {
        var numContents:[String] = []
        do {
            numContents = try contentsOfDirectoryAtPath(directory)
            for n in numContents {
                deleteItem(n)
            }
        } catch {
//            print("Error : deleteAllInDirectory : \(error)")
        }
    }
    
    public func bytesSizeOfAllFiles(files:[String])->UInt64 {
        let totalBytesOfFiles   = files.map {
            var size:UInt64     = 0
            do {
                size            = try attributesOfItemAtPath($0)[NSFileSize]?.unsignedLongLongValue ?? 0
            } catch _ {}
            return UInt64(size)
            }.flatMap{ $0 }.reduce(UInt64(0), combine:+)
        return totalBytesOfFiles
    }
    
    public func sizeOfFile(filePath:String)->UInt64 {
        var fileSize : UInt64 = 0
        do {
            let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
            if let _attr = attr {
                fileSize = _attr.fileSize();
            }
        } catch {
//            print("Error : sizeOfFile : \(filePath) : \(error)")
        }
        return fileSize
    }
   
    public func contentsOfDirectory(directory:String)->[String] {
        do {
            let contents = try contentsOfDirectoryAtPath(directory)
            return contents
        } catch {
//            print("Error : createIndexedPath : \(error)")
            return []
        }
    }
    
    public func fileCreationDate(path:String)->NSDate? {
        do {
            let info = try attributesOfItemAtPath(path)
            return info[NSFileCreationDate] as? NSDate
        } catch {
//            print("Error : fileCreationDate : \(error)")
            return nil
        }
    }
    
}