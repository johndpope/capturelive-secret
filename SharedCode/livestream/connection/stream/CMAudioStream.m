//
//  WowzaAudioStream.m
//  CaptureMedia-Camera
//
//  Created by hatebyte on 3/10/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMAudioStream.h"


@interface CMAudioStream () {}


@end

@implementation CMAudioStream

- (CMStream *)initWithLocalPorts:(NSArray *)localPorts andRemotePorts:(NSArray *)remotePorts toHost:(NSString *)host {
    if (self = [super initWithLocalPorts:localPorts andRemotePorts:remotePorts toHost:host andQueue:dispatch_queue_create(AudioQueue, DISPATCH_QUEUE_SERIAL)]) {
        
    }
    return self;
}

// quick visual
void printBits(int s,void* p){
    int i,j;
    for(i=s-1;i>=0;i--)
        for(j=7;j>=0;j--)
            printf("%u", ( *((unsigned char*)p+i) & (1<<j) ) >> j);
    
    puts("");
}

- (void)onData:(NSData *)data time:(double)pts {
    const int rtp_header_size                                           = 12;
    const int rtp_header_au_header                                      = rtp_header_size + 4;
    const int max_audio_payload                                         = max_packet_size - rtp_header_au_header;
    
    unsigned char packet[max_packet_size];
    unsigned int cBytes                                                 = (unsigned int)[data length];
    unsigned int cRemaining = cBytes;
    unsigned char* src = (unsigned char*) [data bytes];
    
    while (cRemaining > 0)
    {
        unsigned int cThis = (cRemaining < max_audio_payload ? cRemaining : max_audio_payload);
        
        [self writeHeader:packet time:pts marker:(cThis == cRemaining)];

        // length of whole header (16 bytes)
        tonet_short(packet+rtp_header_size, 16);

        // length of whole audio block (13 bits)
        packet[rtp_header_size + 2] = (cBytes >> 5) & 0xff;
        packet[rtp_header_size +3] = (cBytes << 3) & 0xf8;

        memcpy(packet + rtp_header_au_header, src, cThis);
        [self sendPacket:packet length:(cBytes + rtp_header_au_header)];
        
        src += cThis;
        cRemaining -= cThis;
    }
}

- (void)writeHeader:(uint8_t*)packet time:(double)pts marker:(bool) bMarker
{
    packet[0] = 0x80;                           // v= 2
    packet[1] = 97 | (bMarker ? 0x80 : 0);      // !! 97 => change to 96+track index

    unsigned short seq = self.packets & 0xffff;
    tonet_short(packet+2, seq);
    
    // the pts we are given is already offset from a common baseline, and the mapping to a common NTP base
    // is fixed. We just need to offset by a stream-specific random value.
    
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
        if (self.updRTPSocket)  {
            CFDataRef data = CFDataCreate(nil, packet, cBytes);
            [self.updRTPSocket sendData:(__bridge_transfer NSData*)data toHost:self.host port:self.serverRTP withTimeout:-1 tag:0];
        }
        self.packets++;
        self.bytesSent += cBytes;
        
        // RTCP packets
        NSDate* now = [NSDate date];
        if ((self.sentRTCP == nil) || ([now timeIntervalSinceDate:self.sentRTCP] >= 1)) {
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

char *AudioQueue                                                    = "com.capturemedia.AudioQueue";
