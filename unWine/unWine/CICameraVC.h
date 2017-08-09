//
//  CICameraVC.h
//  unWine
//
//  Created by Bryce Boesen on 10/10/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraSessionView.h"

@protocol CICameraDelegate;
@interface CICameraVC : UIViewController <CACameraSessionDelegate>

@property (nonatomic, strong) CameraSessionView *cameraView;
@property (nonatomic, strong) id<CICameraDelegate> delegate;
@property (nonatomic) BOOL scannerMode;

+ (CICameraVC *)cameraWithDelegate:(id)delegate;
- (void)finishedFiltering:(UIImage *)image withFilter:(NSString *)filter;

@end

@protocol CICameraDelegate <NSObject>

@property (nonatomic) BOOL showSettings;

@required - (void)cameraFinishedRecording:(NSData *)movieData url:(NSURL *)url thumbnail:(UIImage *)thumbnail;
@required - (void)cameraFinishedFiltering:(UIImage *)image withFilter:(NSString *)filter;

@end
