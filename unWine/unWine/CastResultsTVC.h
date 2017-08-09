//
//  CastResultsTVC.h
//  unWine
//
//  Created by Bryce Boesen on 4/19/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewController+Helper.h"
#import "CastDetailTVC.h"
#import "CastScannerVC.h"
#import "CastMergeTVC.h"
#import "DaLoadingView.h"
#import "SearchCell.h"
#import "ResultVerifCell.h"

#define DEFAULT_CELL_HEIGHT 38

@class CastScannerVC;
@interface CastResultsTVC : UITableViewController <CastMergeDelegate, unWineAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSArray *scannerResults;
@property (nonatomic) CastScannerVC *delegate;
@property (nonatomic) NSArray *results;
@property (nonatomic) CastDetailTVC *detail;
@property (nonatomic) __block BOOL lockAllWines;
@property (nonatomic) NSMutableArray *dupes;

@end
