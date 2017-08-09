//
//  CaptureSessionManager.m
//  CameraWithAVFoundation
//
//  Created by Gabriel Alvarado on 4/16/14.
//  Copyright (c) 2014 Gabriel Alvarado. All rights reserved.
//

#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import <Parse/Parse.h>
#import "MediaHelper.h"
#import "ParseSubclasses.h"

@import AssetsLibrary;
@implementation CaptureSessionManager

#pragma mark Capture Session Configuration

- (id)init {
    if ((self = [super init])) {
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return self;
}

- (void)addVideoPreviewLayer {
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)initiateCaptureSessionForCamera:(CameraType)cameraType {
    
    //Iterate through devices and assign 'active camera' per parameter
    for (AVCaptureDevice *device in AVCaptureDevice.devices)
        if ([device hasMediaType:AVMediaTypeVideo]) {
        switch (cameraType) {
            case RearFacingCamera:
                if ([device position] == AVCaptureDevicePositionBack)
                    _activeCamera = device;
                break;
            case FrontFacingCamera:
                if ([device position] == AVCaptureDevicePositionFront)
                    _activeCamera = device;
                break;
        }
    }
    
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    //AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    NSError *error          = nil;
    NSError *error2          = nil;
    BOOL deviceAvailability = YES;
    
    AVCaptureDeviceInput *cameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_activeCamera error:&error];
    
    if([self.delegate isVideoEnabled]) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error2];
        
        if (!error && [[self captureSession] canAddInput:cameraDeviceInput]) {
            [[self captureSession] addInput:cameraDeviceInput];
            if(!error2 && [[self captureSession] canAddInput:audioDeviceInput])
                [[self captureSession] addInput:audioDeviceInput];
            else
                deviceAvailability = NO;
        } else
            deviceAvailability = NO;
    } else {
        if (!error && [[self captureSession] canAddInput:cameraDeviceInput]) {
            [[self captureSession] addInput:cameraDeviceInput];
        } else
            deviceAvailability = NO;
    }
    
    //Report camera device availability
    if (self.delegate)
        [self.delegate cameraSessionManagerDidReportAvailability:deviceAvailability forCameraType:cameraType];
    
//    [self initiateStatisticsReportWithInterval:.125];
}

-(void)initiateStatisticsReportWithInterval:(CGFloat)interval {
    
    __block id blockSafeSelf = self;
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        do {
            [NSThread sleepForTimeInterval:interval];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (self.delegate) [self.delegate cameraSessionManagerDidReportDeviceStatistics:cameraStatisticsMake(_activeCamera.lensAperture, CMTimeGetSeconds(_activeCamera.exposureDuration), _activeCamera.ISO, _activeCamera.lensPosition)];
            }];
        } while (blockSafeSelf);
    }];
}

- (void)addMovieFileOutput {
    [self setMovieFileOutput:[[AVCaptureMovieFileOutput alloc] init]];
    
    //Float64 seconds = 10;
    //int32_t preferredTimeScale = 600;
    //CMTime inTime = CMTimeMakeWithSeconds(seconds, preferredTimeScale);
    //[[self movieFileOutput] setMaxRecordedDuration:inTime];
    //[[self movieFileOutput] setMinFreeDiskSpaceLimit:10000000]; //about 100mb
    //NSLog(@"set max time and min file size");
    
    //[self getOrientationAdaptedCaptureConnection:[self movieFileOutput]];
    
    [[self captureSession] addOutput:[self movieFileOutput]];
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    [self getOrientationAdaptedCaptureConnection];
    
    [[self captureSession] addOutput:[self stillImageOutput]];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    
    if([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    if([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    
    [device unlockForConfiguration];
}

- (BOOL)isRecording {
    return [[self movieFileOutput] isRecording];
}

- (void)captureVideoData {
    LOGGER(@"starting to record!");
    
    if (![[self movieFileOutput] isRecording]) {
        
        //__strong NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"Test" stringByAppendingPathExtension:@"mov"]];
        //__strong NSURL *outputURL = [NSURL URLWithString:outputFilePath];
        //LOGGER(outputFilePath);
        
        NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[MediaHelper outputFileName:CIVideoQuality720p]];
        
        NSFileManager *manager = [[NSFileManager alloc] init];
        if ([manager fileExistsAtPath:outputPath]) {
            [manager removeItemAtPath:outputPath error:nil];
        }
        
        [[self movieFileOutput] startRecordingToOutputFileURL:[[NSURL alloc] initFileURLWithPath:outputPath] recordingDelegate:self];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    
    LOGGER(error);
    [self stopCaptureVideoData];
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
    LOGGER(recordedSuccessfully ? @"YES" : @"NO");
    NSLog(@"OutputFileUrl %@", outputFileURL);
    if(recordedSuccessfully) {
        NSData *data = [NSData dataWithContentsOfURL:outputFileURL];
        
        [self setMovieData:data];
        [self setMovieURL:outputFileURL];
        [self setMovieThumbnail:[CaptureSessionManager thumbnailImageForVideo:outputFileURL atTime:(NSTimeInterval)0]];
        
        if (self.delegate)
            [self.delegate cameraSessionManagerDidCaptureMovie];
        /*PFFile *file = [PFFile fileWithName:@"output.mp4" data:data];
        
        Images *test = [Images object];
        test.image = file;
        test.name = @"test";
        [test saveInBackground];
        
        //UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
        //[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error)
                NSLog(@"%@", error);
            
            [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
            
            //if (backgroundRecordingID != UIBackgroundTaskInvalid)
            //    [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        }];*/
    }
}

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetIG = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef = [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                                        actualTime:NULL
                                             error:&igError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", igError );
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

- (void)stopCaptureVideoData {
    [[self movieFileOutput] stopRecording];
}

- (void)captureStillImage
{
    AVCaptureConnection *videoConnection = [self getOrientationAdaptedCaptureConnection];
    
    if (videoConnection) {
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
         ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments) {
                 //Attachements Found
             } else {
                 //No Attachments
             }
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self setStillImage:image];
             [self setStillImageData:imageData];
             
             if (self.delegate)
                 [self.delegate cameraSessionManagerDidCaptureImage];
         }];
    }
    
    //Turn off the flash if on
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (void)setEnableTorch:(BOOL)enableTorch
{
    _enableTorch = enableTorch;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash])
    {
        [device lockForConfiguration:nil];
        if (enableTorch) { [device setTorchMode:AVCaptureTorchModeOn]; }
        else { [device setTorchMode:AVCaptureTorchModeOff]; }
        [device unlockForConfiguration];
    }
}

#pragma mark - Helper Method(s)

- (void)assignVideoOrienationForVideoConnection:(AVCaptureConnection *)videoConnection
{
    AVCaptureVideoOrientation newOrientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            newOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            newOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            newOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            newOrientation = AVCaptureVideoOrientationPortrait;
    }
    [videoConnection setVideoOrientation: newOrientation];
}

- (AVCaptureConnection *)getOrientationAdaptedCaptureConnection
{
    AVCaptureConnection *videoConnection = nil;
    
    AVCaptureOutput *output = [self stillImageOutput] != nil ? [self stillImageOutput] : [self movieFileOutput];
    for (AVCaptureConnection *connection in [output connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                [self assignVideoOrienationForVideoConnection:videoConnection];
                break;
            }
        }
        if (videoConnection) {
            [self assignVideoOrienationForVideoConnection:videoConnection];
            break;
        }
    }
    
    return videoConnection;
}

#pragma mark - Cleanup Functions

// stop the camera, otherwise it will lead to memory crashes
- (void)stop {
    [self.captureSession stopRunning];
    
    if(self.captureSession.inputs.count > 0) {
        for(AVCaptureInput *input in self.captureSession.inputs) {
            [self.captureSession removeInput:input];
        }
    }
    if(self.captureSession.outputs.count > 0) {
        for(AVCaptureOutput *output in self.captureSession.outputs) {
            [self.captureSession removeOutput:output];
        }
    }
    
}

- (void)dealloc {
    [self stop];
}

@end
