//
//  BetterWithFriendsView.h
//  unWine
//
//  Created by Fabio Gomez on 6/29/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VineCastTVC;
@interface BetterWithFriendsView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *socialImageView;
@property (nonatomic, strong) UILabel *socialLabel;
@property (nonatomic, strong) VineCastTVC *delegate;
- (id)initWithDelegate:(VineCastTVC *)delegate;
@end
