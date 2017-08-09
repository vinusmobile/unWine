//
//  UniqWinesCell.h
//  unWine
//
//  Created by Bryce Boesen on 8/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ParseSubclasses.h"
#import "ThemeHandler.h"

#define UNIQ_WINES_CELL_HEIGHT 138

@protocol MultiWinesCellDelegate;
@interface MultiWinesCell : UITableViewCell <PFObjectCell, Themeable>

@property (nonatomic) UIViewController<MultiWinesCellDelegate> *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NSArray *checkins;
@property (nonatomic) NSArray *wines;

- (void)setup:(NSIndexPath *)indexPath;
- (void)preconfigure:(NSArray<NSString *> *)objectIds;
- (void)configure:(NSArray *)wines;

@end

@protocol MultiWinesCellDelegate <NSObject>

@end
