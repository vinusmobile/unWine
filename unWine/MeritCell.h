//
//  MeritCell.h
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"
#import "ParseSubclasses.h"

@interface MeritCell : VineCastCell

@property (strong, nonatomic) NSMutableArray *meritViews;
@property (strong, nonatomic) UIScrollView *containerView;

+ (NSInteger)countMerits:(NewsFeed *)object;

@end
