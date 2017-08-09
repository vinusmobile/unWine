//
//  BubbleView.h
//  unWine
//
//  Created by Bryce Boesen on 2/22/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FB_SIZE 64
#define FB_OUTSET 80

@protocol BubbleViewDelegate;
@interface ExpandingBubbleView : UIView

@property (nonatomic) id<BubbleViewDelegate> delegate;

- (void)addBubble:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;

- (BFTask *)show;
- (BFTask *)hide;

@end

@protocol BubbleViewDelegate <NSObject>

@end
