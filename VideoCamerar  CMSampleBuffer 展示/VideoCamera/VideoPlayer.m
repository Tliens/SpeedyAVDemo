//
//  VideoPlayer.m
//  VideoCamera
//
//  Created by Churchill Navigation on 2/17/16.
//  Copyright © 2016 Churchill Navigation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>

#import "VideoPlayer.h"

@implementation VideoPlayer

// Should video be encoded before displayed?
bool encodeVideo = false;

bool timebaseSet = false;

AVCaptureDeviceInput *cameraDeviceInput;
AVCaptureSession* captureSession;
AVSampleBufferDisplayLayer* displayLayer;

VTCompressionSessionRef compressionSession;

+ (id)sharedManager
{
    static VideoPlayer *sharedVideoPlayer = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
    ^{
        sharedVideoPlayer = [[self alloc] init];
    });
    
    return sharedVideoPlayer;
}

-(id) init
{
    self = [super init];
    
    if(self)
    {
        [self initializeDisplayLayer];
        [self initializeVideoCaptureSession];
    }
    
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // The video can either be encoded, decoded and then displayed... or just displayed with no encoding
    if(encodeVideo)
    {
        CFRetain(sampleBuffer);
        
        NSLog(@"PTS: %f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));
        
        CVPixelBufferRef pixelBuffer =CMSampleBufferGetImageBuffer(sampleBuffer);
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        
        VTEncodeInfoFlags flags;
        
        VTCompressionSessionEncodeFrame(compressionSession, pixelBuffer, pts, duration, NULL, NULL, &flags);
        
        CFRelease(sampleBuffer);
    }
    else
    {
        CFRetain(sampleBuffer);
        
        [displayLayer enqueueSampleBuffer:sampleBuffer];
        
        CFRelease(sampleBuffer);
    }
}


-(AVCaptureDevice *)frontFacingCameraIfAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if (!captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

-(void) initializeCompressionSession
{
    OSStatus err = noErr;
    
    err = VTCompressionSessionCreate(kCFAllocatorDefault, 1024,  576, kCMVideoCodecType_H264, NULL, NULL, NULL, &vtCallback, (__bridge void*) self, &compressionSession);
    
    if(err == noErr)
    {
        NSLog(@"Compression Session Create Success!");
    }
    else
    {
        NSLog(@"Compression Session Create Failed: %d", (int) err);
    }
}

-(void) initializeVideoCaptureSession
{
    // Create our capture session...
    captureSession = [AVCaptureSession new];
    
    // Get our camera device...
    //AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *cameraDevice = [self frontFacingCameraIfAvailable];
    
    NSError *error;
    
    // Initialize our camera device input...
    cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
    
    // Finally, add our camera device input to our capture session.
    if ([captureSession canAddInput:cameraDeviceInput])
    {
        [captureSession addInput:cameraDeviceInput];
    }
    
    // Initialize image output
    AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
    
    [output setAlwaysDiscardsLateVideoFrames:YES];
    
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("video_data_output_queue", DISPATCH_QUEUE_SERIAL);
    
    [output setSampleBufferDelegate:self queue:videoDataOutputQueue];
    [output setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA],(id)kCVPixelBufferPixelFormatTypeKey,nil]];
    
    
    if( [captureSession canAddOutput:output])
    {
        [captureSession addOutput:output];
    }
    AVCaptureConnection * connection = [output connectionWithMediaType:AVMediaTypeVideo];
    [connection setEnabled:true];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [connection setVideoMirrored:true];
    
}

-(void) initializeDisplayLayer
{
    NSLog(@"Initialize Display Layer");
    displayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    NSLog(@"Display Layer Initialized");
}

-(void) setView:(UIView*) view
{
    displayLayer.bounds = view.bounds;
    displayLayer.frame = view.frame;
    displayLayer.backgroundColor = [UIColor blackColor].CGColor;
    displayLayer.position = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // Remove from previous view if exists
    [displayLayer removeFromSuperlayer];
    
    [view.layer addSublayer:displayLayer];
}

-(void) startCaputureSession
{
    if(encodeVideo)
    {
        [self initializeCompressionSession];
    }
    
    [captureSession startRunning];
    
    // You must call flush when resuming!
    if(displayLayer)
    {
        [displayLayer flushAndRemoveImage];
    }
    
    NSLog(@"Start Video Capture Session....");
}

-(void) stopCaputureSession
{
    [captureSession stopRunning];
    [displayLayer flushAndRemoveImage];
    
    NSLog(@"Stop Video Capture Session....");
}

void vtCallback(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer )
{
    double pts = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
    
    if(!timebaseSet && pts != 0)
    {
        timebaseSet = true;
        
        CMTimebaseRef controlTimebase;
        CMTimebaseCreateWithMasterClock( CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase );
        
        displayLayer.controlTimebase = controlTimebase;
        CMTimebaseSetTime(displayLayer.controlTimebase, CMTimeMake(pts, 1));
        CMTimebaseSetRate(displayLayer.controlTimebase, 1.0);
    }
    
    
    if([displayLayer isReadyForMoreMediaData])
    {
            [displayLayer enqueueSampleBuffer:sampleBuffer];
    }
    else
    {
            NSLog(@"Not Ready...");
    }
}

@end
