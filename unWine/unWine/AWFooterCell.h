//
//  AWFooterCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "AWCell.h"
#import "CastEditTVC.h"
#import "CastCheckinTVC.h"
#import "PopoverVC.h"
#import "unWineActionSheet.h"

@interface AWFooterCell : AWCell <unWineActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *cellarButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UILabel *basicLabel;
@property (strong, nonatomic) __block IBOutlet UIButton *lastEdit;

- (void)configureLastEdit;

@end
