//
//  castCheckInVC.h
//  unWine
//
//  Created by Bryce Boesen on 2/1/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTBBarcodeScanner.h"
#import "UITableViewController+Helper.h"
#import "CastResultsTVC.h"

@class CastResultsTVC;
@interface CastScannerVC : UIViewController

@property (nonatomic) MTBBarcodeScanner *scanner;
@property (nonatomic) CastResultsTVC *results;
@property (nonatomic) BOOL backFromResults;
@property (nonatomic) __block PFObject *scanned;

- (void)revert;
+ (NSMutableArray *)filterDuplicateScans:(NSArray *)response;

@end