//
//  customTabBarController+Shake.m
//  unWine
//
//  Created by Fabio Gomez on 2/12/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "customTabBarController+Shake.h"
#import "customTabBarController+ActionSheet.h"
#import "customTabBarController+Appboy.h"
#import <AudioToolbox/AudioToolbox.h>
#import "User.h"
#import "UVRootViewController.h"

@implementation customTabBarController (Shake)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        UIViewController *controller = [unWineAppDelegate topMostController];
        if([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)controller;
            if(![[nav.viewControllers objectAtIndex:0] isKindOfClass:[UVRootViewController class]]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
                [self showCustomSlideUpWithMessage:@"Like shaking things up?\nPlease tell us how to make your experience better!" andURL:UNWINE_FEEDBACK_URL];
                ANALYTICS_TRACK_EVENT(EVENT_USER_SHOOK_PHONE_AND_SAW_FEEDBACK_POP_UP);
            }
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [self showCustomSlideUpWithMessage:@"Like shaking things up?\nPlease tell us how to make your experience better!" andURL:UNWINE_FEEDBACK_URL];
            ANALYTICS_TRACK_EVENT(EVENT_USER_SHOOK_PHONE_AND_SAW_FEEDBACK_POP_UP);
        }
    }
}

@end
