//
//  PurchasesTVC.h
//  unWine
//
//  Created by Fabio Gomez on 10/15/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import "UITableViewController+Helper.h"
#import "ParseSubclasses.h"
#import "PurchaseCell.h"

@class PurchaseCell;
@interface PurchasesTVC : PFQueryTableViewController <GrapesViewDelegate, SKProductsRequestDelegate>

@property (strong, nonatomic) UIBarButtonItem *grapesButton;

- (instancetype)initWithStyle:(UITableViewStyle)style;
- (NSString *)priceForProduct:(PFProduct *)product;
- (int)downloadProgressForProduct:(PFProduct *)product;
- (void)dismissAsGuest;

@end
