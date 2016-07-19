//
//  WowzaVideoStream.m
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/7/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
// 

#import "CMVideoStream.h"


@interface CMVideoStream ()

@property(nonatomic, assign) int count;
@property(nonatomic, assign) int moduler;

@end

@implementation CMVideoStream

- (CMStream *)initWithLocalPorts:(NSArray *)localPorts andRemotePorts:(NSArray *)remotePorts toHost:(NSString *)host {
    if (self = [super initWithLocalPorts:localPorts andRemotePorts:remotePorts toHost:host andQueue:dispatch_queue_create(VideoQueue, DISPATCH_QUEUE_SERIAL)]) {
        
    }
    return self;
}

/**************************************************************************
 //  Created by Geraint Davies on 14/01/2013.
**************************************************************************/
- (void)onData:(NSArray*)data time:(double) pts {
    const int rtp_header_size = 12;
    const int max_single_packet = max_packet_size - rtp_header_size;
    const int max_fragment_packet = max_single_packet - 2;
    unsigned char packet[max_packet_size];
    
    int nNALUs = (int)[data count];
    for (int i = 0; i < nNALUs; i++) {
        NSData* nalu = [data objectAtIndex:i];
        int cBytes = (int)[nalu length];
        BOOL bLast = (i == nNALUs-1);
        
        const unsigned char* pSource = (unsigned char*)[nalu bytes];
        if (cBytes < max_single_packet)  {
            [self writeHeader:packet marker:bLast time:pts];
            memcpy(packet + rtp_header_size, [nalu bytes], cBytes);
            [self sendPacket:packet length:(cBytes + rtp_header_size)];
        } else  {
            unsigned char NALU_Header = pSource[0];
            pSource += 1;
            cBytes -= 1;
            BOOL bStart = YES;
            
            while (cBytes) {
                int cThis = (cBytes < max_fragment_packet)? cBytes : max_fragment_packet;
                BOOL bEnd = (cThis == cBytes);
                [self writeHeader:packet marker:(bLast && bEnd) time:pts];
                unsigned char* pDest = packet + rtp_header_size;
                
                pDest[0] = (NALU_Header & 0xe0) + 28;   // FU_A type
                unsigned char fu_header = (NALU_Header & 0x1f);
                if (bStart)
                {
                    fu_header |= 0x80;
                    bStart = false;
                }
                else if (bEnd)
                {
                    fu_header |= 0x40;
                }
                pDest[1] = fu_header;
                pDest += 2;
                memcpy(pDest, pSource, cThis);
                pDest += cThis;
                [self sendPacket:packet length:(int)(pDest - packet)];
                
                pSource += cThis;
                cBytes -= cThis;
            }
        }
    }
}

- (void)writeHeader:(uint8_t*)packet marker:(BOOL)bMarker time:(double)pts {
    packet[0] = 0x80;   // v= 2
    if (bMarker)  {
        packet[1] = 96 | 0x80;
    } else {
        packet[1] = 96;
    }
    unsigned short seq = self.packets & 0xffff;
    tonet_short(packet+2, seq);

    // map time
    while (self.rtpBase == 0) {
        self.rtpBase = random();
    }
    uint64_t rtp = (uint64_t)(pts * 90000);
    rtp += self.rtpBase;

    tonet_long(packet + 4, (long)rtp);
    tonet_long(packet + 8, self.ssrc);
}

- (void)sendPacket:(uint8_t*)packet length:(int) cBytes
{
    @synchronized(self)
    {
        if (self.updRTPSocket) {
            CFDataRef data = CFDataCreate(nil, packet, cBytes);
            [self.updRTPSocket sendData:(__bridge_transfer NSData*)data toHost:self.host port:self.serverRTP withTimeout:-1 tag:0];
        }
        self.packets++;
        self.bytesSent += cBytes;
        
        // RTCP packets
        NSDate* now = [NSDate date];
        if ((self.sentRTCP == nil) || ([now timeIntervalSinceDate:self.sentRTCP] >= 1)){
            uint8_t buf[7 * sizeof(uint32_t)];
            buf[0] = 0x80;
            buf[1] = 200;   // type == SR
            tonet_short(buf+2, 6);  // length (count of uint32_t minus 1)
            tonet_long(buf+4, self.ssrc);
            tonet_long(buf+8, (self.ntpBase >> 32));
            tonet_long(buf+12, (long)self.ntpBase);
            tonet_long(buf+16, (long)self.rtpBase);
            tonet_long(buf+20, (self.packets - self.packetsReported));
            tonet_long(buf+24, (self.bytesSent - self.bytesReported));
            int lenRTCP = 28;
            if (self.updRTCPSocket) {
                CFDataRef dataRTCP = CFDataCreate(nil, buf, lenRTCP);
                [self.updRTCPSocket sendData:(__bridge_transfer NSData*)dataRTCP toHost:self.host port:self.serverRTCP withTimeout:-1 tag:0];
            }
            
            self.sentRTCP = now;
            self.packetsReported = self.packets;
            self.bytesReported = self.bytesSent;
        }
    }
        
}

@end

char *VideoQueue                                                    = "com.capturemedia.VideoQueue";
