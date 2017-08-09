//
//  PopoverVC.h
//  unWine
//
//  Created by Bryce Boesen on 9/28/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverDelegate;
@interface PopoverVC : UIViewController <UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) id<PopoverDelegate>delegate;

@property (nonatomic, retain) UIPopoverPresentationController *popover;

@property (nonatomic, readonly) BOOL displayed;

+ (PopoverVC *)sharedInstance;

- (BOOL)isDisplayed;
- (void)showFrom:(UIViewController *)host sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect text:(NSString *)text;
- (void)showFrom:(UIViewController *)host sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect direction:(UIPopoverArrowDirection)direction text:(NSString *)text;

@end

@protocol PopoverDelegate <NSObject>
- (void)popoverDismissed;
@end
