//
//  WowzaRTSPConnection.m
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/5/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import <Reachability/Reachability-Swift.h>
#import "CMStreamRTSPConnection.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "WowzaStreamResponseParser.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "NALUnit.h"
#import "ifaddrs.h"
#import "arpa/inet.h"
#import "CMDisk.h"


static double OPTIONS_TIME_BUFFER                                          = 5;
//static float PING_NETWORK_THRESHOLD                                     = 2.2f;
//static float PING_NETWORK_ABOSOLUTION_THRESHOLD                         = 5.0f;
char const *Base64Mapping = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";



NSString* encodeLong(unsigned long val, int nPad) {
    char ch[4];
    int cch = 4 - nPad;
    for (int i = 0; i < cch; i++) {
        int shift = 6 * (cch - (i+1));
        int bits = (val >> shift) & 0x3f;
        ch[i] = Base64Mapping[bits];
    }
    for (int i = 0; i < nPad; i++) {
        ch[cch + i] = '=';
    }
    NSString* s = [[NSString alloc] initWithBytes:ch length:4 encoding:NSUTF8StringEncoding];
    return s;
}

NSString* encodeToBase64(NSData* data) {
    NSString* s = @"";
    
    const uint8_t* p = (const uint8_t*) [data bytes];
    int cBytes = (int)[data length];
    while (cBytes >= 3) {
        unsigned long val = (p[0] << 16) + (p[1] << 8) + p[2];
        p += 3;
        cBytes -= 3;
        
        s = [s stringByAppendingString:encodeLong(val, 0)];
    }
    if (cBytes > 0) {
        int nPad;
        unsigned long val;
        if (cBytes == 1) {
            // pad 8 bits to 2 x 6 and add 2 ==
            nPad = 2;
            val = p[0] << 4;
        } else {
            // must be two bytes -- pad 16 bits to 3 x 6 and add one =
            nPad = 1;
            val = (p[0] << 8) + p[1];
            val = val << 2;
        }
        s = [s stringByAppendingString:encodeLong(val, nPad)];
    }
    return s;
}

@interface CMStreamRTSPConnection () <GCDAsyncSocketDelegate>

@property(nonatomic, weak) CMRTSPConnectionModel *config;
@property(nonatomic, weak) id <CMStreamRTSPConnectionDelegate> delegate;
@property(nonatomic, strong) NSData *configData;
@property(nonatomic, strong) dispatch_queue_t queue;
@property(nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property(nonatomic, strong) NSString *realm;
@property(nonatomic, strong) NSString *nonce;
@property(nonatomic, strong) NSString *authString;
@property(nonatomic, strong) NSString *sessionId;
@property(nonatomic, strong) NSString *sessionDescription;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *optionsTimer;
@property(nonatomic, strong) NSString *optionsPingString;
@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, assign) int cseq;
@property(nonatomic, assign) int max_packet_size;
@property(nonatomic, assign) BOOL  hasDisconnected;
@property(nonatomic, strong) Reachability *reachability;

@end

@implementation CMStreamRTSPConnection

+ (CMStreamRTSPConnection *)connectionWithConfigData:(NSData *)configData andConfig:(CMRTSPConnectionModel *)config withDelegate:(id <CMStreamRTSPConnectionDelegate>)delegate {
    return [[CMStreamRTSPConnection alloc] initWithConfigData:configData andConfig:config withDelegate:delegate];
}

- (CMStreamRTSPConnection *)initWithConfigData:(NSData *)configData andConfig:(CMRTSPConnectionModel *)config withDelegate:(id <CMStreamRTSPConnectionDelegate>)delegate {
    if (self = [super init]) {
        _configData                                                 = configData;
        _config                                                     = config;
        _delegate                                                   = delegate;
        _max_packet_size                                            = 1200;
        _queue                                                      = dispatch_queue_create("com.capturemedia.wowza.connection.Queue", DISPATCH_QUEUE_SERIAL);
        [self connect];
    }
    return  self;
}

- (void)connect {
    _asyncSocket                                                    = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_queue];
    NSError *error                                                  = nil;
    NSTimeInterval timeout                                          = 10;
    _timer                                                          = [NSTimer timerWithTimeInterval:timeout
                                                                                              target:self
                                                                                            selector:@selector(socketConnectionDidTimeout)
                                                                                            userInfo:nil
                                                                                             repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    if (![_asyncSocket connectToHost:_config.host onPort:_config.port withTimeout:timeout error:&error]) {
        [self.delegate connectionFailure];
    } else {
        NSLog(@"Connecting to ...  %@:%ld/%@/%@", _config.host, (long)_config.port, _config.application, _config.name);
    }
    
    if (error) {
        NSLog(@"CMStreamRTSPConnection connectionFailure %@", error);
    }
}

- (void)reconnect {
    [_asyncSocket setDelegate:nil delegateQueue:NULL];
    self.hasDisconnected                                            = true;
    [self connect];
}

- (void)socketConnectionDidTimeout {
    [self killConnectionTimer];
    [self killOptionsPinger];
    [_asyncSocket disconnect];
    [_asyncSocket setDelegate:nil delegateQueue:NULL];
    [self.delegate connectionTerminated];
}

- (void)killConnectionTimer {
    [_timer invalidate];
    _timer                                                          = nil;
}

- (void)shutDown {
    [self killConnectionTimer];
    [self killOptionsPinger];
    [self tearDownState];
}

#pragma private method
- (void)sendRequestToServer:(NSString *)request withTag:(long)tag {
    NSData *data                                                    = [[NSData alloc] initWithData:[request dataUsingEncoding:NSUTF8StringEncoding]];
    [_asyncSocket writeData:data withTimeout:-1.0 tag:tag];
    NSData *responseTerminatorData                                  = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    [_asyncSocket readDataToData:responseTerminatorData withTimeout:-1.0 tag:tag];
}

#pragma private GDCAsyncSocket
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    [self announceStateUnauthorize];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //DDLogVerbose(@"socket:didWriteDataWithTag:");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *httpResponse                                          = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (self.hasDisconnected == YES) {
        [self reconnectwithTag:tag andResponse:httpResponse];
    } else {
        [self connectwithTag:tag andResponse:httpResponse];
    }
}

- (void)connectwithTag:(long)tag andResponse:(NSString *)httpResponse {
    switch (tag) {
        case AuthorizationStateUnauthorize:
            [self announceStateAuthorize:httpResponse];
            break;
        case AuthorizationStateAuthorize:
            [self requestAudioSetup];
            break;
        case AuthorizationStateRequestAudioSetup:
            [self resolvePortsWithResponse:httpResponse isVideo:NO];
            [self requestVideoSetup];
            break;
        case AuthorizationStateRequestVideoSetup:
            [self resolvePortsWithResponse:httpResponse isVideo:YES];
            [self sendRecordRequest];
            break;
        case AuthorizationStateRequestRecord:
            [self killConnectionTimer];
            [self.delegate connectionSuccess];
            [self startOptionsPingers];
            break;
        case AuthorizationStateRequestPause:
            break;
        case AuthorizationStateRequestOptions:
            self.optionsPingString = httpResponse;
            break;
        case AuthorizationStateRequestGetParameter:
            break;
        case AuthorizationStateRequestTearDown:
            [self socketConnectionDidTimeout];
            break;
        default:
            [self socketConnectionDidTimeout];
            break;
    }
}

- (void)reconnectwithTag:(long)tag andResponse:(NSString *)httpResponse {
    switch (tag) {
        case AuthorizationStateUnauthorize:
            [self announceStateAuthorize:httpResponse];
            break;
        case AuthorizationStateAuthorize:
            [self killConnectionTimer];
            [self startOptionsPingers];
            break;
        case AuthorizationStateRequestOptions:
            self.optionsPingString                              = httpResponse;
            break;
        case AuthorizationStateRequestGetParameter:
            break;
        case AuthorizationStateRequestTearDown:
            [self socketConnectionDidTimeout];
            break;
        default:
            break;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    // Since we requested HTTP/1.0, we expect the server to close the connection as soon as it has sent the response.
    [self killConnectionTimer];
    [self.delegate connectionTerminated];
}

#pragma mark connection methods
- (void)announceStateUnauthorize {
    _cseq++;
    
    NSString *request                                               = [NSString stringWithFormat:@"ANNOUNCE %@ RTSP/1.0\r\nCSeq: %d\r\nContent-Length: %lu\r\nContent-Type: application/sdp \r\n\r\n%@", _config.url, _cseq, (unsigned long)self.sessionDescription.length, self.sessionDescription];
    [self sendRequestToServer:request withTag:AuthorizationStateUnauthorize];
}

- (void)announceStateAuthorize:(NSString *)responseString {
    _cseq++;
    
    NSString *realm                                                 = [WowzaStreamResponseParser response:responseString valueForPrefix:RegexRealm];
    NSString *nonce                                                 = [WowzaStreamResponseParser response:responseString valueForPrefix:RegexNonce];
    _sessionId                                                      = [WowzaStreamResponseParser response:responseString valueForPrefix:RegexSession];
    
    NSString *hash1                                                 = [[NSString stringWithFormat:@"%@:%@:%@", _config.userName, realm, _config.password] md5];
    NSString *hash2                                                 = [[NSString stringWithFormat:@"ANNOUNCE:%@", _config.url] md5];
    NSString *hash3                                                 = [[NSString stringWithFormat:@"%@:%@:%@", hash1, nonce, hash2] md5];
    
    _authString                                                     = [NSString stringWithFormat:@"Digest username=\"%@\",realm=\"%@\",nonce=\"%@\",uri=\"%@\",response=\"%@\"", _config.userName, realm, nonce, _config.url, hash3];
    
    NSString *request                                               = [NSString stringWithFormat:@"ANNOUNCE %@ RTSP/1.0\r\nCSeq: %d\r\nContent-Length: %lu\r\nAuthorization: %@\r\nSession: %@\r\nContent-Type: application/sdp \r\n\r\n%@",
                                                                       _config.url, _cseq, (unsigned long)self.sessionDescription.length, _authString, _sessionId, self.sessionDescription];
    [self sendRequestToServer:request withTag:AuthorizationStateAuthorize];
}

- (void)requestAudioSetup  {
    int i                                                           = 0;
    NSString *request                                               = [NSString stringWithFormat:@"SETUP %@/trackID=%d RTSP/1.0\r\nTransport: RTP/AVP/UDP;unicast;client_port=%d-%d;mode=receive\r\n%@",
                                                                       _config.url, i, (5000+2*i), (5000+2*i+1), [self headers]];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestAudioSetup];
}

- (void)requestVideoSetup  {
    int i                                                           = 1;
    NSString *request                                               = [NSString stringWithFormat:@"SETUP %@/trackID=%d RTSP/1.0\r\nTransport: RTP/AVP/UDP;unicast;client_port=%d-%d;mode=receive\r\n%@",
                                                                       _config.url, i, (5000+2*i), (5000+2*i+1), [self headers]];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestVideoSetup];
}

- (void)sendRecordRequest  {
    NSString *request                                               = [NSString stringWithFormat:@"RECORD %@ RTSP/1.0\r\nRange: npt=0.000-\r\n%@", _config.url, [self headers]];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestRecord];
}

- (void)sendPauseRequest  {
    NSString *request                                               = [NSString stringWithFormat:@"PAUSE %@ RTSP/1.0\r\nRange: npt=0.000-\r\n%@", _config.url, [self headers]];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestPause];
}

- (void)sendOptionsRequest  {
    NSString *request                                               = [NSString stringWithFormat:@"OPTIONS %@ RTSP/1.0\r\n%@", _config.url, [self headers]];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestOptions];
}

- (void)sendGetParameterRequest  {
    _cseq++;
    
    NSString *getDescription                                        = @"bytes_per_second_published_to_server\r\nbytes_per_second_lost\r\n";
    NSString *request                                               = [NSString stringWithFormat:@"GET_PARAMETER %@ RTSP/1.0\r\nCSeq: %d\r\nContent-Type: text/parameters\r\nSession: %@\r\nAuthorization: %@\r\nContent-Length: %lu\r\n\r\n%@", _config.url, _cseq, _sessionId, _authString, (unsigned long)getDescription.length, getDescription];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestGetParameter];
}

- (void)tearDownState {
    NSString *request                                               = [NSString stringWithFormat:@"TEARDOWN %@ RTSP/1.0\r\n%@", _config.url, [self headers]];
    [self sendRequestToServer:request withTag:AuthorizationStateRequestTearDown];
}

- (void)resolvePortsWithResponse:(NSString *)responseString isVideo:(BOOL)isVideo {
    NSString *portstringServer                                      = [WowzaStreamResponseParser response:responseString valueForPrefix:RegexServerPorts];
    NSArray* portsServer                                            = [portstringServer componentsSeparatedByString:@"-"];
    NSString *portstringLocal                                       = [WowzaStreamResponseParser response:responseString valueForPrefix:RegexClientPorts];
    NSArray* portsLocal                                             = [portstringLocal componentsSeparatedByString:@"-"];
    [self.delegate connection:self configureLocalPorts:portsLocal configureRemotePorts:portsServer isVideo:isVideo];
}

#pragma mark - options pinger
- (void)startOptionsPingers {
    [self sendOptionsRequest];
    
    _optionsTimer                                                   = [NSTimer timerWithTimeInterval:OPTIONS_TIME_BUFFER
                                                                                          target:self
                                                                                        selector:@selector(optionsPingTimeout)
                                                                                        userInfo:nil
                                                                                         repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_optionsTimer forMode:NSDefaultRunLoopMode];
}

- (void)killOptionsPinger {
    [_optionsTimer invalidate];
    _optionsTimer                                                   = nil;
}

- (void)optionsPingTimeout {
    if (self.optionsPingString == nil) {
        [self.delegate connectionLost];
        [self killOptionsPinger];
    } else {
        [self.delegate reconnectionSuccess];
        [self startOptionsPingers];
    }
    self.optionsPingString                                          = nil;
}

#pragma mark - utils
- (NSString *)sessionDescription {
    if (!_sessionDescription) {
        
        NSData* config                                              = _configData;
        avcCHeader avcC((const BYTE*)[config bytes], (int)[config length]);
        SeqParamSet seqParams;
        seqParams.Parse(avcC.sps());
        
        NSString* profile_level_id                                  = [NSString stringWithFormat:@"%02x%02x%02x", seqParams.Profile(), seqParams.Compat(), seqParams.Level()];
        
        NSData* data                                                = [NSData dataWithBytes:avcC.sps()->Start() length:avcC.sps()->Length()];
        NSString* sps                                               = encodeToBase64(data);
        data                                                        = [NSData dataWithBytes:avcC.pps()->Start() length:avcC.pps()->Length()];
        NSString* pps                                               = encodeToBase64(data);
        
        //      !! o=, s=, u=, c=, b=? control for track?
        NSDate *timeStamp                                           = [NSDate date];
        _sessionDescription                                         = [NSString stringWithFormat:@"v=0\r\no=- %f %f IN IP4 %@\r\ns=Live stream from iOS\r\nc=IN IP4 %@\r\nt=0 0\r\na=control:*\r\n", [timeStamp timeIntervalSince1970], [timeStamp timeIntervalSince1970], [self getIPAddress], _config.host];
       
        unsigned int configAudio                                    = _config.rstp_audioProfile<<11 | _config.rstp_audioFrequencyIndex<<7 | _config.rstp_audioChannel<<3;
        // audio
        
        // !! payload type should be 96+track -- hardwire as 96 for video, 97 for audio for now
        _sessionDescription                                         = [_sessionDescription stringByAppendingFormat:@"m=audio 5004 RTP/AVP 97\r\na=rtpmap:97 mpeg4-generic/90000\r\na=fmtp:97 profile-level-id=1; mode=AAC-hbr; config=%04x; SizeLength=13; IndexLength=3; IndexDeltaLength=3;\r\na=control:trackID=0\r\n", configAudio];
        
        _sessionDescription                                         = [_sessionDescription stringByAppendingFormat:@"m=video 5006 RTP/AVP 96\r\na=rtpmap:96 H264/90000\r\na=fmtp:96 packetization-mode=1;profile-level-id=%@;sprop-parameter-sets=%@,%@;\r\na=control:trackID=1\r\n", profile_level_id, sps, pps];
    }
    
    return _sessionDescription;
}

- (NSString *)headers {
    _cseq++;
    NSString *headers                                               = [NSString stringWithFormat:@"CSeq: %d\r\nContent-Length: 0\r\nSession: %@\r\n", _cseq, _sessionId];
    if (_videoCutLength > 0) {
        NSString *videoheaders                                      = [NSString stringWithFormat:@"video_offset_length: %ld\r\n", _videoCutLength];
        headers                                                     = [headers stringByAppendingString:videoheaders];
    }
    if (_authString) {
        NSString *authheaders                                       = [NSString stringWithFormat:@"Authorization: %@\r\n\r\n", _authString];
        headers                                                     = [headers stringByAppendingString:authheaders];
    } else {
        headers                                                     = [headers stringByAppendingString:@"\r\n\r\n"];
    }
    return headers;
}

- (NSString*)getIPAddress {
    NSString* address;
    struct ifaddrs *interfaces                                      = nil;
    
    // get all our interfaces and find the one that corresponds to wifi
    if (!getifaddrs(&interfaces)) {
        for (struct ifaddrs* addr = interfaces; addr != NULL; addr = addr->ifa_next) {
            if (([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:@"en0"]) &&
                (addr->ifa_addr->sa_family == AF_INET)) {
                struct sockaddr_in* sa                              = (struct sockaddr_in*) addr->ifa_addr;
                address                                             = [NSString stringWithUTF8String:inet_ntoa(sa->sin_addr)];
                break;
            }
        }
    }
    freeifaddrs(interfaces);
    return address;
}

@end
