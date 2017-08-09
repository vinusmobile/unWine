//
//  ToggleCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"

@interface TargetCell : VineCastCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (void)pushSingle:(UIGestureRecognizer *)recognizer;
- (void)inspectWine:(UIGestureRecognizer *)recognizer;
- (void)exploreMerits:(UIGestureRecognizer *)recognizer;

@end
