//
//  CICameraVC.m
//  unWine
//
//  Created by Bryce Boesen on 10/10/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CICameraVC.h"
#import "CIMovieVC.h"
#import "CIFilterVC.h"
#import "CaptureSessionManager.h"

@interface CICameraVC () <CIFilterDelegate, unWineAlertViewDelegate>
@end

//static CGFloat brightness = 1;

@implementation CICameraVC
@synthesize cameraView = _cameraView, delegate = _delegate;

+ (CICameraVC *)cameraWithDelegate:(id<CICameraDelegate>)delegate {
    CICameraVC *camera = [[CICameraVC alloc] init];
    camera.delegate = delegate;
    camera.view.backgroundColor = [UIColor whiteColor];
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:camera];
    //[nav setNavigationBarHidden:YES animated:NO];
    return camera;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(status == AVAuthorizationStatusAuthorized) {
            [self promptCamera];
        } else if(status == AVAuthorizationStatusDenied) {
            [self promptCamera];
            [self promptAlert];
        } else if(status == AVAuthorizationStatusRestricted) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if(status == AVAuthorizationStatusNotDetermined) {
            [self promptCamera];
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted) {
                    //[_cameraView setNeedsDisplay];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }
}

- (void)promptCamera {
    _cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    _cameraView.delegate = self;
    _cameraView.videoEnabled = NO;
    [self.view addSubview:_cameraView];
}

- (void)promptAlert {
    unWineAlertView *alertView = [[unWineAlertView sharedInstance] prepareWithMessage:@"unWine can't take pictures without permission to use your camera, so... wanna change your mind?"];
    alertView.delegate = self;
    alertView.theme = unWineAlertThemeYesNo;
    alertView.title = @"No Camera Access";
    alertView.leftButtonTitle = @"No";
    alertView.rightButtonTitle = @"Yes";
    [alertView show];
}

- (void)leftButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightButtonPressed {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        self.delegate.showSettings = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didCaptureImage:(UIImage *)image {
    LOGGER(@"did receive image!");
    
    SHOW_HUD;
    CIFilterVC *filter = [[CIFilterVC alloc] init];
    [filter setImage:image];
    filter.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:filter];
    [self presentViewController:nav animated:YES completion:^{
        HIDE_HUD;
    }];
    
    LOGGER(@"did stuff with image!");
}

- (void)didCaptureMovieWithData:(NSData *)movieData url:(NSURL *)url thumbnail:(UIImage *)thumbnail {
    LOGGER(@"did receive movie!");
    if([_delegate respondsToSelector:@selector(cameraFinishedRecording:url:thumbnail:)]) {
        [self willDismissCameraSessionView:YES];
        [_delegate cameraFinishedRecording:movieData url:url thumbnail:thumbnail];
    }
}

/**
 * Method for returning from CIFilterVC
 */
- (void)finishedFiltering:(UIImage *)image withFilter:(NSString *)filter {
    HIDE_HUD;
    if([_delegate respondsToSelector:@selector(cameraFinishedFiltering:withFilter:)]) {
        [self willDismissCameraSessionView:YES];
        [_delegate cameraFinishedFiltering:image withFilter:filter];
    }
}

- (void)willEndEditting {
    //[self willDismissCameraSessionView:NO];
}

- (void)didEndEditting {
    HIDE_HUD;
}

- (void)willDismissCameraSessionView:(BOOL)animated {
    if(!self.isBeingDismissed)
        [self dismissViewControllerAnimated:animated completion:nil];
}

@end
