//
//  CastMergeTVC.h
//  unWine
//
//  Created by Bryce Boesen on 6/9/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewController+Helper.h"
#import "MergeNextCell.h"
#import "MergeCell.h"
#import "ParseSubclasses.h"

#define DEFAULT_MERGE_CELL_HEIGHT 30

@protocol CastMergeDelegate;
@class CastScannerVC;

@interface CastMergeTVC : UITableViewController

@property (nonatomic) id<CastMergeDelegate> delegate;
@property (nonatomic) NSArray *wines;
@property (nonatomic) NSMutableArray *fields;
@property (nonatomic) NSMutableDictionary *progress;
@property (nonatomic) unWine *wine;

- (void)clickNext;

@end

@protocol CastMergeDelegate <NSObject>
- (void)mergeComplete:(NSInteger)responseCode;
- (void)updateScannerResults:(NSArray *)scannerResults;
- (CastScannerVC *)getCastScannerVC;
@end
