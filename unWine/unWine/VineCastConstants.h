//
//  VineCastConstants.h
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

#import "UIImageView+AFNetworking.h"
#import "CascadingLabelView.h"
#import "MeritAlertView.h"

#import "commentQueryTableViewController.h"

#define LOCATION_DEFAULT_MESSAGE    @"Venue Name"
#define FEELING_DEFAULT_MESSAGE     @"Select a Feeling"
#define OCCASION_DEFAULT_MESSAGE    @"Select an Occasion"
#define VINTAGE_DEFAULT_MESSAGE     @"Select a Vintage"

#define IMAGE_NATURAL_X 0
#define IMAGE_NATURAL_Y 0
#define IMAGE_NATURAL_MAX_HEIGHT [[UIScreen mainScreen] bounds].size.height * 3.0f / 4.0f
#define IMAGE_NATURAL_WIDTH [[UIScreen mainScreen] bounds].size.width
#define VIDEO_NATURAL_MAX_HEIGHT [[UIScreen mainScreen] bounds].size.width

#define VINECAST_FONT @"OpenSans"
#define VINECAST_FONT_BOLD @"OpenSans-Bold"
#define BACKGROUND_COLOR [UIColor colorWithRed:1 green:0.33333333333 blue:0.33333333333 alpha:1]
#define BACKGROUND_COLOR_2 [UIColor colorWithRed:210/255.0f green:210/255.0f blue:210/255.0f alpha:1]

typedef enum VineCells { // No Particular Order
    HEADER_CELL,
    CONTENT_CELL,
    WINE_DETAIL_CELL,
    TOGGLE_CELL,
    SPACER_CELL_1,
    WINE_NAME_CELL,
    RATING_CELL,
    INSPECT_WINE_CELL,
    SPACER_CELL_3,
    LIKE_COUNT_CELL,
    SPACER_CELL_2,
    MERIT_COUNT_CELL,
    MERIT_CELL,
    MERIT_EXPLORE_CELL,
    SPACER_CELL_4,
    COMMENT_COUNT_CELL,
    COMMENT_CELL,
    LIKE_CELL,
    SPACER_CELL_NO_LINE,
    EMPTY_CELL,
    CAPTION_CELL,
    REACTION_CELL,
    EARNED_MERIT_CELL
} VineCells;

@interface VineCastConstants : NSObject
@end
