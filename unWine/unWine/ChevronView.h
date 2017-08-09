//
//  ChevronView.h
//  unWine
//
//  Created by Bryce Boesen on 3/9/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChevronViewDelegate;
@interface ChevronView : UIView

@property (nonatomic) id<ChevronViewDelegate> delegate;
@property (nonatomic) BOOL inverted;

- (instancetype)initWithFrame:(CGRect)frame;

@end

@protocol ChevronViewDelegate <NSObject>

@required - (void)chevronPressed:(ChevronView *)chevronView;

@end