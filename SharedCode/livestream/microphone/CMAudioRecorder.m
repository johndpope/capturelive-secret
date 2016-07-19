//
//  CMAudioRecorder.m
//  Capture-Live-Camera
//
//  Created by hatebyte on 4/17/15.
//  Copyright (c) 2015 CaptureMedia. All rights reserved.
//

#import "CMAudioRecorder.h"
#import <UIKit/UIKit.h>
#import <mach/mach_time.h>
#import <Accelerate/Accelerate.h>
#import <AVFoundation/AVFoundation.h>

// return max value for given values
#define max(a, b) (((a) > (b)) ? (a) : (b))
// return min value for given values
#define min(a, b) (((a) < (b)) ? (a) : (b))

static AudioUnitElement kOutputBusU                 = 0;
static AudioUnitElement kInputBusU                  = 1;
static Float64 kDeviceTimeScale                     = 1000000000.0f;
static double kAudioSampleRate                      = 16000.0f;//44100.0f;s
//static double kAACSampleRate                        = 44100.0f;
//static double kAudioSampleRate                     = 16000.0f;
static double kAACSampleRate                        = 16000.0f;//44100.0f;
static UInt32 kAACBufferSize                        = 1024;
static UInt32 kNumChannels                          = 1;
static mach_timebase_info_data_t info;

@interface CMAudioRecorder ()

@property(nonatomic, strong) dispatch_queue_t conversionQueue;
@property(nonatomic, assign) AudioUnit rioUnit;
@property(nonatomic, assign) AudioConverterRef audioConverter;
@property(nonatomic, assign) AudioStreamBasicDescription pcmASBD;
@property(nonatomic, assign) AudioStreamBasicDescription aacASBD;
@property(nonatomic, assign) CMFormatDescriptionRef cmformat;
@property(nonatomic, assign) AudioBuffer audioBuffer;
@property(nonatomic) AudioBuffer *aacBuffer;
@property(nonatomic, assign) AudioComponentInstance audioUnit;
@property(nonatomic, assign) Float64 sampleRate;
@property(nonatomic, assign) Float64 aacSampleRate;
@property(nonatomic, assign) NSTimeInterval ioBufferDuration;
@property(nonatomic, assign) UInt32 aacBufferSize;
@property(nonatomic, assign) CMTime duration;

@property(nonatomic, assign) uint64_t trueTime;
@property(nonatomic, assign) uint64_t adjustedTime;


- (void)cmSampleBuffer:(AudioBufferList *)audioBufferList
        numberOfFrames:(UInt32)inNumberFrames
                  time:(uint64_t)time;
- (void)converToAAC:(AudioBufferList *)audioBufferList
     numberOfFrames:(UInt32)inNumberFrames
               time:(uint64_t)time;

@end

@implementation CMAudioRecorder

+ (void)shouldTryToAccessMicrophone:(void (^)(BOOL granted))handler {
    AVAuthorizationStatus authStatus                = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        handler(true);
    } else if(authStatus == AVAuthorizationStatusDenied) {
        handler(false);
    } else if(authStatus == AVAuthorizationStatusRestricted) {
        handler(false);
    } else if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:handler];
    } else {
        handler(false);
    }
}

#pragma mark helpers
static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    
    char errString[20];
    // see if it appears to be a 4 char code
    *(UInt32 *)(errString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errString[1]) && isprint(errString[2]) && isprint(errString[3]) && isprint(errString[4])) {
        errString[0] = errString[5] = '\'';
        errString[6] = '\0';
    } else
        sprintf(errString, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errString);
    exit(1);
}

OSStatus RecordingCallback(void *inRefCon,
                           AudioUnitRenderActionFlags *ioActionFlags,
                           const AudioTimeStamp *inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList *ioData) {
    
    CMAudioRecorder *recorder = (__bridge CMAudioRecorder *)inRefCon;
    
    
    // the place where the data gets rendered
    AudioBuffer buffer;
    
    // number of frame is usually 512 or 1024
    buffer.mDataByteSize                        = inNumberFrames * (kNumChannels * 2);
    buffer.mNumberChannels                      = kNumChannels;
    buffer.mData                                = malloc(inNumberFrames * (kNumChannels * 2));   // 4 for for 2 *  channe
    
    // we the buffer into a bufferlist in order to pass to renderer
    AudioBufferList bufferList;
    bufferList.mNumberBuffers                   = 1;
    bufferList.mBuffers[0]                      = buffer;
//                                                                        // BAD     GOOD
//    NSLog(@"buffer          : %d", (unsigned int)buffer.mDataByteSize); // 512 === 2048
//    NSLog(@"inNumberFrames  : %d\n\n", (unsigned int)inNumberFrames);   // 256 === 1024
    
    // render input
    CheckError(AudioUnitRender(recorder.rioUnit,
                               ioActionFlags,
                               inTimeStamp,
                               inBusNumber,
                               inNumberFrames,
                               &bufferList),
               "Couldn't render from RemoteIO unit");
    
    /* Convert to nanoseconds */
    uint64_t time                               = inTimeStamp->mHostTime;
    time                                        *= info.numer;
    time                                        /= info.denom;
   
    [recorder converToAAC:&bufferList numberOfFrames:inNumberFrames time:time];
    [recorder cmSampleBuffer:&bufferList numberOfFrames:inNumberFrames time:time];
    
    // release the memory
    free(bufferList.mBuffers[0].mData);
    
    return noErr;
}

static OSStatus ConvertDataProc(AudioConverterRef inAudioConverter,
                                UInt32 *ioNumberDataPackets,
                                AudioBufferList *ioData,
                                AudioStreamPacketDescription **outDataPacketDescription,
                                void *inUserData) {
    
    CMAudioRecorder *encoder                        = (__bridge CMAudioRecorder *)(inUserData);
    UInt32 requestedPackets                         = *ioNumberDataPackets;
    UInt32 copiedSamples                            = encoder.audioBuffer.mDataByteSize;
    if (copiedSamples < requestedPackets) {
        *ioNumberDataPackets                        = 0;
        return -1;
    }
//    NSLog(@"ioNumberDataPackets   : %u", (unsigned int)*ioNumberDataPackets);
    ioData->mBuffers[0].mData                       = encoder.audioBuffer.mData;
    ioData->mBuffers[0].mDataByteSize               = encoder.audioBuffer.mDataByteSize;
//    *ioNumberDataPackets                            = 1024;
    *ioNumberDataPackets = 1;//(*ioNumberDataPackets / kAudioSampleRate) * kAACSampleRate;
    
//    *ioNumberDataPackets = (UInt32)encoder.audioBuffer.mDataByteSize / requestedPackets;
    
//    NSLog(@"encoder.audioBuffer.mDataByteSize          : %d", (unsigned int)encoder.audioBuffer.mDataByteSize);
//    NSLog(@"ioNumberDataPackets : %d", (unsigned int)ioNumberDataPackets);
    return noErr;
}

- (void)converToAAC:(AudioBufferList *)audioBufferList numberOfFrames:(UInt32)inNumberFrames time:(uint64_t)time {
    dispatch_sync(self.conversionQueue, ^{
        AudioBuffer sourceBuffer                    = audioBufferList->mBuffers[0];
        if (_audioBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
            free(_audioBuffer.mData);
            
            // assess new byte size and allocate them to mData
            _audioBuffer.mDataByteSize              = inNumberFrames * (kNumChannels * 2);
            _audioBuffer.mData                      = malloc(inNumberFrames * (kNumChannels * 2));
            _audioBuffer.mNumberChannels            = kNumChannels;
        }
        // copy incoming audio to the buffer
        memcpy(_audioBuffer.mData, audioBufferList->mBuffers[0].mData, audioBufferList->mBuffers[0].mDataByteSize);
        
        memset(_aacBuffer, 0, self.aacBufferSize);
        AudioBufferList aacOutBuffer                = {0};
        aacOutBuffer.mNumberBuffers                 = 1;
        aacOutBuffer.mBuffers[0].mNumberChannels    = kNumChannels;
        aacOutBuffer.mBuffers[0].mDataByteSize      = self.aacBufferSize;
        aacOutBuffer.mBuffers[0].mData              = _aacBuffer;
        
        AudioStreamPacketDescription *outDescription = NULL;
        UInt32 ioOutPacketSize                      = 1;
        
        CheckError(AudioConverterFillComplexBuffer(_audioConverter,
                                                   ConvertDataProc,
                                                   (__bridge void *)(self),
                                                   &ioOutPacketSize,
                                                   &aacOutBuffer,
                                                   outDescription),
                   "Could not convert pcm to aac with AudioConverterFillComplexBuffer");
//        if (self.adjustedTime == 0) {
//            self.adjustedTime = time;
//        }
//       
//        uint64_t diffTime                           = time - self.trueTime;
//        NSLog(@"diffTime   : %llu", diffTime);
//        diffTime                                    = (diffTime / kAudioSampleRate) * kAACSampleRate;
//        self.adjustedTime += diffTime;
//        self.trueTime    bb                               = time;
//        NSLog(@"diffTime   : %llu\n\n", diffTime);
//        NSLog(@"diffTime       : %llu\n\n", diffTime);


        double aacTime                              = ((double)(time) / (double)kDeviceTimeScale);
        NSData *rawAAC                              = [NSData dataWithBytes:aacOutBuffer.mBuffers[0].mData length:aacOutBuffer.mBuffers[0].mDataByteSize];
        
        // send to delegate
        [self.aacDelegate didConvertAACData:rawAAC time:aacTime];
        
//        free(_audioBuffer.mData);
    });
    
}

- (void)cmSampleBuffer:(AudioBufferList *)audioBufferList numberOfFrames:(UInt32)inNumberFrames time:(uint64_t)time {
    dispatch_sync(self.conversionQueue, ^{
        CMSampleBufferRef buff                      = NULL;
        CMTime presentationTime                     = CMTimeMake(time,  (UInt32)kDeviceTimeScale);
        CMSampleTimingInfo timing                   = {0};
        timing.presentationTimeStamp                = presentationTime;
        timing.duration                             = self.duration;
        timing.decodeTimeStamp                      = kCMTimeInvalid;
        
        CheckError(CMSampleBufferCreate(kCFAllocatorDefault,
                                        NULL,
                                        false,
                                        NULL,
                                        NULL,
                                        _cmformat,
                                        (CMItemCount)inNumberFrames,
                                        1,
                                        &timing,
                                        0,
                                        NULL,
                                        &buff),
                   "Could not create CMSampleBufferRef");
        
        CheckError(CMSampleBufferSetDataBufferFromAudioBufferList(buff,
                                                                  kCFAllocatorDefault,
                                                                  kCFAllocatorDefault,
                                                                  0,
                                                                  audioBufferList),
                   "Could not set data in CMSampleBufferRef");
        
        [self.sampleBufferDelegate didRenderAudioSampleBuffer:buff];
        CFRelease(buff);
    });
}

- (BOOL)isConfigured {
    return self.sampleRate > 0;
}

- (void)configure {
    @synchronized(self) {
        // USE THIS SESSION STUFF TO HANDLE INTERRUPTIONS FROM THE OS and ROUTE THROUGH BLUETOOTH, HEADPHONES, SPEAKERS
        AVAudioSession *session                     = [AVAudioSession sharedInstance];
       [session setActive:NO error:nil];
    
//        self.sampleRate                             = session.sampleRate;
        self.sampleRate                             = kAudioSampleRate;
        self.duration                               = CMTimeMake(1, self.sampleRate);
        
        self.aacSampleRate                          = kAACSampleRate;
        self.ioBufferDuration                       = (NSTimeInterval) ((double)kAACBufferSize / self.sampleRate);
        self.aacBufferSize                          = ceil(self.sampleRate * self.ioBufferDuration);

        NSError *e                                  = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&e];
        [session setPreferredInputNumberOfChannels:1 error:&e];
        [session setPreferredSampleRate:self.sampleRate error:&e];
        [session setPreferredIOBufferDuration:self.ioBufferDuration error:&e];
        [session setInputGain:0.142857f  error:&e];
        [session setMode:AVAudioSessionModeMeasurement  error:&e];
        
        [session setActive:YES error:nil];

//        NSLog(@"sampleRate : %u", (unsigned int)session.sampleRate);            // 44100
//        NSLog(@"ioBufferDuration : %f", session.IOBufferDuration);              // .023220
//        NSLog(@"aacBufferSize : %u\n\n", (unsigned int)self.aacBufferSize);     // 1024
        if (!session.inputAvailable) {
            UIAlertView *noInputAlert               = [[UIAlertView alloc] initWithTitle:@"No audio input"
                                                                                 message:@"No audio input device is currently attached"
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
            [noInputAlert show];
            return;
        }
        
        self.conversionQueue                        = dispatch_queue_create("com.capturemedia.ios.microphone.audioqueue", DISPATCH_QUEUE_SERIAL);
        mach_timebase_info(&info);
        
        [self setUpRecorder];
        [self setUpConverter];
        CheckError(AudioUnitInitialize(self.rioUnit), "Couldn't initialize RIO unit");
    }
}

- (void)setUpRecorder {
    AudioComponentDescription audioCompDesc;
    audioCompDesc.componentType                 = kAudioUnitType_Output;
    audioCompDesc.componentSubType              = kAudioUnitSubType_RemoteIO;
    audioCompDesc.componentManufacturer         = kAudioUnitManufacturer_Apple;
    audioCompDesc.componentFlags                = 0;
    audioCompDesc.componentFlagsMask            = 0;
    
    // get rio unit from audio component manager
    AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
    CheckError(AudioComponentInstanceNew(rioComponent,
                                         &_rioUnit),
               "Couldn't get RIO unit instance");
    
    //    // reset since openTOk
//        CheckError(AudioUnitReset(self.rioUnit,
//                                  kAudioUnitScope_Global,
//                                  kOutputBusU),
//                   "Could not reset Output bus of rioUnit");
//        CheckError(AudioUnitReset(self.rioUnit,
//                                  kAudioUnitScope_Global,
//                                  kInputBusU),
//                   "Could not reset Input bus of rioUnit");
    
    UInt32 oneFlag = 1;
    // enable rio input
    CheckError(AudioUnitSetProperty(self.rioUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Input,
                                    kInputBusU,
                                    &oneFlag,
                                    sizeof(oneFlag)),
               "Couldn't enable RIO input");
    
    // set up the rio unit for playback
    CheckError(AudioUnitSetProperty (self.rioUnit,
                                     kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Output,
                                     kOutputBusU,
                                     &oneFlag,
                                     sizeof(oneFlag)),
               "Couldn't enable RIO output");
    
    // setup an _pcmASBD in the iphone canonical format
    size_t bytesPerSample                       = sizeof(SInt16);
    _pcmASBD.mSampleRate                        = self.sampleRate;
    _pcmASBD.mFormatID                          = kAudioFormatLinearPCM;
    _pcmASBD.mFormatFlags                       = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _pcmASBD.mBytesPerPacket                    = (unsigned int)(bytesPerSample) * kNumChannels;
    _pcmASBD.mBytesPerFrame                     = (unsigned int)(bytesPerSample) * kNumChannels;
    _pcmASBD.mChannelsPerFrame                  = kNumChannels;
    _pcmASBD.mFramesPerPacket                   = 1;
    _pcmASBD.mBitsPerChannel                    = (unsigned int)(8 * bytesPerSample);
    
    // set asbd for mic input
    CheckError(AudioUnitSetProperty (self.rioUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Output,
                                     kInputBusU,
                                     &_pcmASBD,
                                     sizeof (_pcmASBD)),
               "Couldn't set ASBD for RIO on output scope / bus 1");
    
    // set format for output (bus 0) on rio's input scope
    CheckError(AudioUnitSetProperty (self.rioUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input,
                                     kOutputBusU,
                                     &_pcmASBD,
                                     sizeof (_pcmASBD)),
               "Couldn't set ASBD for RIO on input scope / bus 0");
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc                    = RecordingCallback; // callback function
    callbackStruct.inputProcRefCon              = (__bridge void *)(self);
    
    CheckError(AudioUnitSetProperty(self.rioUnit,
                                    kAudioOutputUnitProperty_SetInputCallback,
                                    kAudioUnitScope_Global,
                                    kInputBusU,
                                    &callbackStruct,
                                    sizeof (callbackStruct)),
               "Couldn't set RIO input callback on bus 1");
    
    UInt32 flag = 0;
    CheckError(AudioUnitSetProperty(self.rioUnit,
                                    kAudioUnitProperty_ShouldAllocateBuffer,
                                    kAudioUnitScope_Output,
                                    kInputBusU,
                                    &flag,
                                    sizeof(flag)),
               "Couldn't set shouldAlloceBuffer to no");
    
    // set up cmsamplebufferformat
    AudioStreamBasicDescription audioFormat     = self.pcmASBD;
    CheckError(CMAudioFormatDescriptionCreate(kCFAllocatorDefault,
                                              &audioFormat,
                                              0,
                                              NULL,
                                              0,
                                              NULL,
                                              NULL,
                                              &_cmformat),
               "Could not create format from AudioStreamBasicDescription");
    
    /*
     we set the number of channels to mono and allocate our block size to
     1024 bytes.
     */
}

- (void)setUpConverter {
    // configure _aacASBD
    _aacASBD.mSampleRate                        = self.aacSampleRate;
    _aacASBD.mFormatID                          = kAudioFormatMPEG4AAC;
    _aacASBD.mFormatFlags                       = kMPEG4Object_AAC_LC;
    _aacASBD.mBytesPerPacket                    = 0;
    _aacASBD.mFramesPerPacket                   = self.aacBufferSize;
    _aacASBD.mBytesPerFrame                     = 0;
    _aacASBD.mChannelsPerFrame                  = kNumChannels;
    _aacASBD.mBitsPerChannel                    = 0;
    _aacASBD.mReserved                          = 0;
    
    AudioClassDescription desc;
    UInt32 encoderSpecifier                     = kAudioFormatMPEG4AAC;
    UInt32 manufacturer                         = kAppleSoftwareAudioCodecManufacturer;
    
    UInt32 size;
    CheckError(AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                          sizeof(encoderSpecifier),
                                          &encoderSpecifier,
                                          &size),
               "Couldn't get Audio Format property size");
    
    // Search through device encoders to get description
    unsigned int count                      = size / sizeof(AudioClassDescription);
    AudioClassDescription descriptions[count];
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                      sizeof(encoderSpecifier),
                                      &encoderSpecifier,
                                      &size,
                                      descriptions),
               "Couldn't get Audio Format property of buffer");
    
    for (unsigned int i = 0; i < count; i++) {
        if ((encoderSpecifier == descriptions[i].mSubType) && (manufacturer == descriptions[i].mManufacturer)) {
            memcpy(&desc, &(descriptions[i]), sizeof(desc));
            break;
        }
    }
    
    // create converter
    CheckError(AudioConverterNewSpecific(&_pcmASBD,
                                         &_aacASBD,
                                         1,
                                         descriptions,
                                         &_audioConverter), "Couldn't create Convertor");
    
    //     set bitrate of convertor
    UInt32 bitRate                              = 64000; // 64kbs
    if (self.aacSampleRate >= 44100) {
        bitRate                                 = 192000; // 192kbs
    } else if (self.aacSampleRate < 22000) {
        bitRate                                 = 32000; // 32kbs
    }
    UInt32 propsize                             = sizeof(bitRate);
    AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, propsize, & bitRate);
}

- (void)myInterruptionListener:(NSNotification *)notification {
    AVAudioSessionInterruptionType inInterruptionState = [[[notification userInfo]
                                                           objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    printf("Interrupted! inInterruptionState=%u\n" , (unsigned int)inInterruptionState);
    switch (inInterruptionState) {
        case kAudioSessionBeginInterruption:
            //            [self stopRecordering];
            break;
        case kAudioSessionEndInterruption:
            //            [self startRecordering];
            break;
        default:
            break;
    }
}

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        [self configure];
//    }
//    return self;
//}

- (void)dealloc {
    if ( [self isConfigured] ){
        CheckError(AudioUnitUninitialize(self.rioUnit), "Couldn't uninitialize RIO unit");
        CheckError(AudioComponentInstanceDispose(self.rioUnit), "Couldn't dispose of component RIO unit");
        free(_aacBuffer);
        free(_audioBuffer.mData);
        CFRelease(_cmformat);
    }
}

- (void)startRecordering {
    [self configure];
    @synchronized(self) {
        _aacBuffer                              = malloc(self.aacBufferSize * sizeof(uint8_t));
        memset(_aacBuffer, 0, self.aacBufferSize);
        
        //        _audioBuffer.mNumberChannels                = kNumChannels;
        //        _audioBuffer.mDataByteSize                  = self.aacBufferSize;
        //        _audioBuffer.mData                          = malloc(self.aacBufferSize);
    }
    
    NSError *e                                  = nil;
    AVAudioSession *session                     = [AVAudioSession sharedInstance];
    BOOL success                                = [session setActive:YES error:&e];
    if (!success) {
        NSLog(@"Couldn't set audio active : YES");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myInterruptionListener:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:session];

    CheckError(AudioOutputUnitStart(self.rioUnit), "Couldn't start audio unit");
}

- (void)stopRecordering {
    CheckError(AudioOutputUnitStop(self.rioUnit), "Couldn't stop audio unit");
    
    AVAudioSession *session                     = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:session];
    
    NSError *e                                  = nil;
    BOOL success                                = [session setActive:NO error:&e];
    if (!success) {
        NSLog(@"Couldn't set audio active : NO");
    }
}

//*  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
+ (int)Channel {
    return kNumChannels; // 1 channel: front-center
    //    return 2; // 2 channels: front-left, front-right
}

+ (int)Profile {
    return 2; // AAC (low complexity)
}

+ (int)FrequencyIndex {
    switch ((int)kAACSampleRate) {
        case 64000:
            return 2;
            break;
        case 48000:
            return 3;
            break;
        case 44100:
            return 4;
            break;
        case 32000:
            return 5;
            break;
        case 24000:
            return 6;
            break;
        case 22050:
            return 7;
            break;
        case 16000:
            return 8;
            break;
        default:
            return 0;
            break;
    }
}


@end


