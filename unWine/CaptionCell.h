//
//  CaptionCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/9/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"
#import "ParseSubclasses.h"

@interface CaptionCell : VineCastCell <UITextViewDelegate>

@property (nonatomic) UITextView *captionView;

+ (CGFloat)getAppropriateHeight:(NewsFeed *)object;

@end
