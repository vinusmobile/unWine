//
//  DaLoadingView.m
//  unWine
//
//  Created by Bryce Boesen on 5/21/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "DaLoadingView.h"

//#define SHIFT_DELAY .200

@implementation DaLoadingView {
    //UIImageView *load2;
    //UIImageView *load3;
    //NSUInteger stage;
    //NSTimer *myTimer;
}

- (id)present:(CGRect)frame {
    self.frame = frame;
    //stage = 0;
    
    if (!self.loading) {
        self.loading = [[FLAnimatedImageView alloc] init];
        self.loading.contentMode = UIViewContentModeScaleAspectFill;
        self.loading.clipsToBounds = YES;
    }
    [self addSubview:self.loading];
    self.loading.frame = self.frame;
    
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"loadinggif@3x" withExtension:@"gif"];
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data1];
    self.loading.animatedImage = animatedImage1;
    
    
    /*loading = [[UIImageView alloc] initWithFrame:frame];
    loading.image = [UIImage imageNamed:@"loadinggif"];
    loading.contentMode = UIViewContentModeScaleAspectFill;
    loading.alpha = 1;
    [self addSubview:loading];
    [self bringSubviewToFront:loading];*/
    
    /*load2 = [[UIImageView alloc] initWithFrame:frame];
    load2.image = [UIImage imageNamed:@"load2"];
    load2.contentMode = UIViewContentModeScaleAspectFill;
    load2.alpha = 0;
    [self addSubview:load2];
    [self bringSubviewToFront:load2];
    
    load3 = [[UIImageView alloc] initWithFrame:frame];
    load3.image = [UIImage imageNamed:@"load3"];
    load3.contentMode = UIViewContentModeScaleAspectFill;
    load3.alpha = 0;
    [self addSubview:load3];
    [self bringSubviewToFront:load3];
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval: SHIFT_DELAY
                                               target: self
                                             selector: @selector(animateFrame)
                                             userInfo: nil
                                              repeats: YES];*/
    
    return self;
}

/*- (void)animateFrame {
    if(stage == 0) {
        [UIView animateWithDuration:SHIFT_DELAY animations:^{
            loading.alpha = 1;
        }];
    } else if(stage == 1) {
        [UIView animateWithDuration:SHIFT_DELAY animations:^{
            load2.alpha = 1;
        }];
    } else if(stage == 2) {
        [UIView animateWithDuration:SHIFT_DELAY animations:^{
            load3.alpha = 1;
        }];
    } else if(stage >= 3) {
        [UIView animateWithDuration:SHIFT_DELAY animations:^{
            load2.alpha = 0;
            load3.alpha = 0;
        }];
        stage = -1;
    }
    stage++;
}*/

- (void)dismiss:(NSTimeInterval)time {
    [UIView animateWithDuration:time animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        //[myTimer invalidate];
        [self removeFromSuperview];
    }];
}

@end
