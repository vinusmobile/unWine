//
//  CaptureSessionManager.h
//  CameraWithAVFoundation
//
//  Created by Gabriel Alvarado on 4/16/14.
//  Copyright (c) 2014 Gabriel Alvarado. All rights reserved.
//
#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>

///Protocol Definition
@protocol CaptureSessionManagerDelegate <NSObject>
@required - (void)cameraSessionManagerDidCaptureImage;
@required - (void)cameraSessionManagerDidCaptureMovie;
@required - (void)cameraSessionManagerFailedToCaptureImage;
@required - (void)cameraSessionManagerFailedToCaptureMovie;
@required - (void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType;
@required - (void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics; //Report every .125 seconds

@required - (BOOL)isVideoEnabled;

@end

@interface CaptureSessionManager : NSObject <AVCaptureFileOutputRecordingDelegate>

//Weak pointers
@property (nonatomic, weak) id<CaptureSessionManagerDelegate>delegate;
@property (nonatomic, weak) AVCaptureDevice *activeCamera;

//Strong Pointers
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) UIImage *stillImage;
@property (nonatomic, strong) NSData *stillImageData;
@property (nonatomic, strong) UIImage *movieThumbnail;
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, strong) NSData *movieData;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

//Primative Variables
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;

//API Methods
- (void)addMovieFileOutput;
- (void)addStillImageOutput;
- (void)captureVideoData;
- (void)stopCaptureVideoData;
- (void)captureStillImage;
- (void)addVideoPreviewLayer;
- (void)initiateCaptureSessionForCamera:(CameraType)cameraType;
- (void)stop;
- (BOOL)isRecording;

+ (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end
