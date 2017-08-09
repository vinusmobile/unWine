//
//  AWHeaderCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWCell.h"
#import "APLViewController.h"

@class PFImageView, unWine;

@interface AWHeaderCell : AWCell <APLSelectionDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *wineImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *verifiedView;

- (void)configureVerified:(unWine *)wineObject;

@end
