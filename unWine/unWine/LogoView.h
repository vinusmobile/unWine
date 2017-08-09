//
//  LogoView.h
//  unWine
//
//  Created by Bryce Boesen on 2/22/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogoViewDelegate;
@interface LogoView : UIView

@property (nonatomic) id<LogoViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)flip;
//- (BFTask *)showFront:(BOOL)animated;
//- (BFTask *)showBack:(BOOL)animated;

@end

@protocol LogoViewDelegate <NSObject, UINavigationControllerDelegate>

- (void)didPressLogo:(LogoView *)view;

@end