//
//  MeritsTVC.h
//  unWine
//
//  Created by Bryce Boesen on 2/15/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>
#import "MeritBaseCell.h"
#import "ProfileTVC.h"

@class ProfileTVC;
@interface MeritsTVC : PFQueryTableViewController

@property (nonatomic) ProfileTVC *profileTVC;

@property (nonatomic) NSUInteger meritMode;
@property (nonatomic) NSMutableArray *earnedMerits;
@property (nonatomic) NSMutableDictionary *counts;
@property (nonatomic) NSArray *types;
@property (nonatomic) BOOL earnedOnly;

- (NSArray *)getObjects:(NSIndexPath *)indexPath;
- (BFTask *)getMeritsTask;

@end
