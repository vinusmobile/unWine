//
//  unWineActionView.h
//  unWine
//
//  Created by Bryce Boesen on 9/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "customTabBarController.h"
#import "unWineAlertView.h"

@interface unWineAlertLoginView : NSObject <unWineAlertViewDelegate>

@property(nonatomic,copy) NSString *message;

+ (id)sharedInstance;
- (void)showFromViewController:(UIViewController *)controller;

@end