//
//  meritsTableViewController.h
//  unWine
//
//  Created by Fabio Gomez on 12/21/13.
//  Copyright (c) 2013 LION Mobile. All rights reserved.
////

#import <UIKit/UIKit.h>

#define MERIT_LEVEL_SECTION     1
#define MERIT_WINE_SECTION      2
#define MERIT_SPECIAL_SECTION   3
#define MERIT_EXCLUSIVE_SECTION 4

static NSString *iMeritsTabCellIdentifier = @"MeritsTabCell";
static NSString *iMeritsBasicCellIdentifier = @"MeritsBasicCell";
static CGFloat headerHeight     = 24.;

@interface meritsTableViewController : UITableViewController{
    
    int gNumberOfLevelMeritCells;
    int gNumberOfSpecialMeritCells;
    int gNumberOfOtherMeritCells;
    int gNumberOfExclusiveMeritCells;
    
    NSMutableArray *LevelMeritObjects;
    NSMutableDictionary *LevelMeritImages;
    int LevelImagesCounter;
    
    NSMutableArray *specialMeritObjects;
    NSMutableDictionary *specialMeritImages;
    int specialImagesCounter;
    
    NSMutableArray *otherMeritObjects;
    NSMutableDictionary *otherMeritImages;
    int otherImagesCounter;
    
    NSMutableArray *exclusiveMeritObjects;
    NSMutableDictionary *exclusiveMeritImages;
    int exclusiveImagesCounter;
    
    NSMutableArray *userEarnedMeritObjects;
    
}

@property (nonatomic, strong) NSMutableArray *LevelMeritObjects;
@property (nonatomic, strong) NSMutableDictionary *LevelMeritImages;

@property (nonatomic, strong) NSMutableArray *specialMeritObjects;
@property (nonatomic, strong) NSMutableDictionary *specialMeritImages;

@property (nonatomic, strong) NSMutableArray *otherMeritObjects;
@property (nonatomic, strong) NSMutableDictionary *otherMeritImages;

@property (nonatomic, strong) NSMutableArray *exclusiveMeritObjects;
@property (nonatomic, strong) NSMutableDictionary *exclusiveMeritImages;

@property (nonatomic, strong) NSMutableArray *userEarnedMeritObjects;

@end
