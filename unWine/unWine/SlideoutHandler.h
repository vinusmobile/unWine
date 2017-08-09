//
//  SlideoutHandler.h
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol SlideoutHandlerDelegate;
@interface SlideoutHandler : NSObject

@property (nonatomic) UIViewController<SlideoutHandlerDelegate> *delegate;

@property (nonatomic) UIBarButtonItem *leftButton;
@property (nonatomic) UIBarButtonItem *rightButton;
@property (nonatomic) UIViewController *leftView;
@property (nonatomic) UIViewController *rightView;
@property (nonatomic) NSMutableArray *gesturesLeft;
@property (nonatomic) NSMutableArray *gesturesRight;

+ (SlideoutHandler *)sharedInstance;
- (void)toggleRightView:(UIGestureRecognizer *)gesture;
- (void)toggleLeftView:(UIGestureRecognizer *)gesture;

@end

@protocol SlideoutHandlerDelegate <NSObject>

@optional - (UIBarButtonItem *)setupRightButton;
@optional - (UIBarButtonItem *)setupLeftButton;
@optional - (UIViewController *)setupRightView;
@optional - (UIViewController *)setupLeftView;

@end

