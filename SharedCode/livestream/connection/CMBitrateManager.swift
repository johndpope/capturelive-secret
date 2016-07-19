//
//  CMBitrateManager.swift
//  Current
//
//  Created by Scott Jones on 11/10/15.
//  Copyright © 2015 CaptureMedia. All rights reserved.
//

import UIKit
import Alamofire

public typealias ChangeBitrate = (CMBitrate)->()
public typealias OnFrameRate = (Int)->()
public typealias Start = ()->()

private let FRAMERATE = 30
private let BITRATE = "BITRATE"

import Alamofire

public enum BitrateRouter:URLRequestConvertible {
    
    case Update(url:String, streamName:String, bitrate:String)
    
    public var URLRequest:NSMutableURLRequest {
        let result:(url:String, path:String, method:Alamofire.Method, parameters:[String:AnyObject]) = {
            switch self {
            case .Update(let url, let streamName, let bitrate):
                let params:[String:AnyObject] = ["streamname":streamName, "streaminglevel":bitrate]
                return (url, "/update_stream_level", .GET, params)
            }
        }()
        let URL                       = NSURL(string:result.url)!
        let URLRequest                = NSMutableURLRequest(URL:URL.URLByAppendingPathComponent(result.path))
        URLRequest.HTTPMethod         = result.method.rawValue
        URLRequest.timeoutInterval    = NSTimeInterval(10 * 1000)
        URLRequest.setValue("Accept-Encoding", forHTTPHeaderField:"gzip")
        URLRequest.setValue("Accept", forHTTPHeaderField:"application/json")
        
        let encoding                  = Alamofire.ParameterEncoding.URL
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
    
}



public class CMBitrateManager: NSObject {
    
    var bitrateChanged:ChangeBitrate?
    var onFrameRate:OnFrameRate?
    var start:Start?

    var timer:NSTimer!
    var interval:Double                     = 2.0
    var url :String!
    let brain:CMBitrateManagerBrain!
    let streamName:String!
    var isAutomatic:Bool                    = true
    
    public init(connectionModel:CMRTSPConnectionModel) {
        self.brain                          = CMBitrateManagerBrain(framerate:Int16(FRAMERATE))
        self.streamName                     = connectionModel.name
        self.url                            = "http://\(connectionModel.host):\(connectionModel.port)/"
        super.init()
        self.start                          = self.kickOff
        self.start?()
    }
    
    func destroy() {
        self.start                          = nil
        self.stop()
    }
    
    func fixForOldPhones() {
        
    }
    
    func stop() {
        if self.timer != nil {
            self.timer.invalidate()
        }
    }
    
    public func kickOff() {
        self.stop()
        self.timer                          = NSTimer.scheduledTimerWithTimeInterval(self.interval, target:self, selector:#selector(CMBitrateManager.getDroppedFrames), userInfo:nil, repeats:false)
    }
    
    func getDroppedFrames() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            if let string = self.fetchFrameRate() {
                let frameRate = Int16(string)
                if self.isAutomatic == true {
                    if self.brain.update(frameRate) == true {
                        self.bitrateChanged?(self.brain.bitrate)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.start?()
                    self.onFrameRate?(Int(frameRate))
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.start?()
                })
            }
        })
    }
    
    internal func fetchFrameRate()->Int16? {
        let string                          = "\(self.url)get_stream_info?streamname=\(self.streamName)"
        let streamURL                       = NSURL(string:string)!
        if let streamData = NSData(contentsOfURL: streamURL) {
            if let framerate = NSString(data: streamData, encoding:NSASCIIStringEncoding) {
                return Int16(framerate.intValue)
            }
        }
        return nil
    }
   
    func setBitrate(bitrate:CMBitrate) {
        self.isAutomatic                    = false
        self.stop()
        self.brain.bitrate                  = bitrate
        self.bitrateChanged?(bitrate)
    }
    
    func setBitrateAutomatic() {
        self.isAutomatic                    = true
        self.bitrateChanged?(self.brain.bitrate)
        self.start?()
    }
    
    func updateFrameRate(bitrate:CMBitrate) {
        let defaults                        = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSNumber(longLong: Int64(self.brain.bitrate.rawValue)), forKey:BITRATE)
        defaults.synchronize()

        self.brain.bitrate                  = bitrate
 
        Alamofire.request(
            BitrateRouter.Update(url: url, streamName:streamName, bitrate:bitrate.toString()))
            .validate()
            .responseString { response in
            guard response.result.isSuccess else {
                print("BITRATE Error:: \(response.result.error)")
                return
            }
//            
//            if let ro = response.result.value {
//                print("BITRATE JSON: \(ro)")
//            }
        }

    }
    
}

public enum CMBitrate : Int {
    case Normal     = 250000
    case Medium     = 150000
    case Low        = 75000
}

extension CMBitrate {

    mutating func moveUp() {
        switch self {
        case .Medium:
            self    = .Normal
        case .Normal:
            self    = .Normal
        case .Low:
            self    = .Medium
        }
//        print("moveUp : \(self.toString())")
    }
    
    mutating func moveDown() {
        switch self {
        case .Medium:
            self    = .Low
        case .Normal:
            self    = .Medium
        case .Low:
            self    = .Low
        }
//        print("moveDown : \(self.toString())")
    }
    
    func toString()->String {
        switch self {
        case .Medium:
            return "medium"
        case .Normal:
            return "normal"
        case .Low:
            return "low"
        }
    }
    
}

public class CMBitrateManagerBrain {
    
    var lastFrameRate:Int16     = 0
    var bitrate:CMBitrate!
    var configFramerate:Int16!
    static let Tolerance        = 0.75
    
    init(framerate:Int16) {
        self.configFramerate    = framerate
        self.bitrate            = .Low
    }
    
    func update(framerate:Int16)->Bool {
        let b                   = self.bitrate
        if framerate <= Int16(Double(self.configFramerate) * CMBitrateManagerBrain.Tolerance) {
            self.bitrate.moveDown()
        } else if self.lastFrameRate > 0 {
            self.bitrate.moveUp()
        }
        self.lastFrameRate      = framerate
        return b.rawValue != self.bitrate.rawValue
    }

}

















