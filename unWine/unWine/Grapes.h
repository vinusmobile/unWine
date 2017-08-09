//
//  Grapes.h
//  unWine
//
//  Created by Bryce Boesen on 7/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "ParseSubclasses.h"

#define GRAPES_VIEW_WIDTH 94

@protocol GrapesViewDelegate;
@interface Grapes : PFObject<PFSubclassing>
+ (NSString *)parseClassName;

@property (nonatomic, strong) User                  *user;
@property (nonatomic        ) NSInteger             grapes;
@property (nonatomic, strong) NSString              *reason;

+ (void)showLeaderboards:(UINavigationController *)controller;
+ (void)showPurchases:(UINavigationController *)controller;
+ (void)userUpdateCurrency:(void(^)(NSInteger))callback;
+ (void)userAddTransaction:(Grapes *)transaction;

+ (UIView *)getCustomView:(NSInteger)grapes delegate:(UIViewController *)delegate;
+ (void)showAnimateView:(UIViewController<GrapesViewDelegate> *)delegate amount:(NSInteger)amount;

+ (void)addCurrency:(NSInteger)amount reason:(NSString *)reason source:(UIViewController<GrapesViewDelegate> *)delegate;

+ (void)queueTransaction:(NSInteger)amount reason:(NSString *)reason;
+ (void)executeQueue:(UIViewController<GrapesViewDelegate> *)delegate;

@end

@protocol GrapesViewDelegate <NSObject>
//- (void)showLeaderboards;
- (void)showPurchases;
@end