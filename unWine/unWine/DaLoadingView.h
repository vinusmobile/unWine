//
//  DaLoadingView.h
//  unWine
//
//  Created by Bryce Boesen on 5/21/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface DaLoadingView : UIView

@property (nonatomic, strong) FLAnimatedImageView *loading;

- (id)present:(CGRect)frame;
- (void)dismiss:(NSTimeInterval)time;

@end
