//
//  RatingCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"

@interface RatingCell : VineCastCell

@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UIView *ratingContainer;
@property (strong, nonatomic) IBOutlet UILabel *unratedLabel;

@end
