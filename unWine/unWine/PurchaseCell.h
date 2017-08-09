//
//  PurchaseCell.h
//  unWine
//
//  Created by Bryce Boesen on 10/17/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "PurchasesTVC.h"
#import "unWineAlertView.h"

@class PurchasesTVC;
@interface PurchaseCell : UITableViewCell <unWineAlertViewDelegate>

@property (strong, nonatomic) PFImageView *iconImageView;
@property (strong, nonatomic) UILabel *purchaseLabel;

@property (nonatomic) PurchasesTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) PFProduct *object;
@property (nonatomic) PFPurchaseTableViewCellState state;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(PFProduct *)object;
- (void)reconfigure;
- (NSString *)getProductIdentifier;
- (void)applyPurchaseAndReload:(User *)user;

@end
