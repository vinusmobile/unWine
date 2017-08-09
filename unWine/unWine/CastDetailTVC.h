//
//  CastDetailTVC.h
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewController+Helper.h"
#import "CastCheckinTVC.h"
#import "AWHeaderCell.h"
#import "AWDetailCell.h"
#import "AWFooterCell.h"
#import "AWReactionCell.h"
#import "PopoverVC.h"

@class CastCheckinTVC;
@interface CastDetailTVC : UITableViewController

@property (nonatomic) CastCheckinTVC *checkinTVC;
@property (nonatomic) unWine *wine;
@property (nonatomic) NSMutableDictionary *registers;
@property (strong, nonatomic) UIImage *wineImage;
@property (nonatomic) BOOL isNew;
@property (nonatomic) BOOL lockAllWines;
@property (nonatomic) BOOL pushedFromNotification;
@property (nonatomic) BOOL bidirectional;
@property (nonatomic) NSInteger checkinForVerification;
@property (nonatomic) NSInteger checkinForWeathered;
@property (nonatomic) CastCheckinSource cameFrom;

- (void)checkIn;
- (void)registerRecord:(NSString *)field asValue:(id)value;
- (void)getLastEdit:(void(^)(PFObject *))callback;
- (void)getRecords:(void(^)(void))callback;

@end
