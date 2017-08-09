//
//  AWCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "ParseSubclasses.h"

#define SCALE_SIZE 72
#define ICON_SIZE 24

#define ADD_WINE_PLACEHOLDER [AWCell imageWithImage:[UIImage imageNamed:@"castCheckin"] scaledToSize:CGSizeMake(SCALE_SIZE, SCALE_SIZE)]
//#define VINECAST_PLACEHOLDER [AWCell imageWithImage:[UIImage imageNamed:@"placeholder2.png"] scaledToSize:CGSizeMake(SCALE_SIZE, SCALE_SIZE)]

#define FIELD_EDITOR_HEIGHT 140
#define FIELD_EDITOR_WIDTH 220

#define ALMOST_BLACK [UIColor colorWithRed:0 green:0 blue:0 alpha:.4]
#define ALMOST_BLACK_2 [UIColor colorWithRed:0 green:0 blue:0 alpha:.338]

#define DEFAULT_WINE_NAME       @"Add a Wine Name"
#define DEFAULT_ADD_WINERY      @"Add a Winery"
#define DEFAULT_NO_WINERY       @"No Winery"
#define DEFAULT_ADD_REGION      @"Add a Region"
#define DEFAULT_NO_REGION       @"No Region"
#define DEFAULT_ADD_WINE_TYPE   @"Add a Wine Varietal"
#define DEFAULT_NO_WINE_TYPE    @"No Wine Varietal"

#define WINERY_ICON     [UIImage imageNamed:@"wineryIcon"]
#define REGION_ICON     [UIImage imageNamed:@"newRegionIcon"]
#define RATING_ICON     [UIImage imageNamed:@"newHeartIcon"]
#define GRAPE_ICON      [UIImage imageNamed:@"grapeIcon"]
#define SMALL_COG_ICON  [UIImage imageNamed:@"smallCogIcon"]

@interface AWCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) id delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) UIView *editView;
@property (nonatomic) NSIndexPath *myPath;
@property (nonatomic) UIPlaceHolderTextView *fieldEditor;
@property (nonatomic) BOOL canModify;
@property (nonatomic) UIToolbar *inputAccessoryView;
@property (nonatomic) unWine *wine;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wineObject;
- (void)completeModify;
- (void)cancelModify;
- (void)modifyField:(UITapGestureRecognizer *)gesture;

@end
