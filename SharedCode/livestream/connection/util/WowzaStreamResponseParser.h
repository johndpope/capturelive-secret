//
//  StreamResponseParser.h
//  CaptureMedia-Data
//
//  Created by hatebyte on 3/3/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
//
//static NSString *const RegexOptionsStatus                                       = @"messagesLossBytesRate:\\s([0-9.]+)";
//static NSString *const RegexOptionsStatus                                       = @"(\\{.*\\})";
static NSString *const RegexOptionsStatus                                       = @".*poor_performance:\\strue.*";

static NSString *const RegexStatus                                              = @"(?<=RTSP/\\d.\\d )(\\d+)(?= (\\w+))";
static NSString *const RegexNonce                                               = @"(?<=nonce=\")(.*?)(?=\")";
static NSString *const RegexRealm                                               = @"(?<=realm=\")(.*?)(?=\",)";
static NSString *const RegexServerPorts                                         = @"(?<=;server_port=)(.+)";
static NSString *const RegexClientPorts                                         = @"(?<=;client_port=)([^;]+)";
static NSString *const RegexSession                                             = @"(?<=Session:\\s)(\\d*?)(?=;)";
static NSString *const RegexMessageInBytes                                      = @"(?<=message_in_bytes:\\s)(\\d*?)(?=\\s)";

@interface WowzaStreamResponseParser : NSObject

+ (NSString *)response:(NSString *)responseString valueForPrefix:(NSString *)pattern;

@end
