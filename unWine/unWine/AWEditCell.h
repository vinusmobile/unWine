//
//  AWEditCell.h
//  unWine
//
//  Created by Bryce Boesen on 6/9/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+NVTimeAgo.h"
#import "ProfileTVC.h"
#import "CastProfileVC.h"
#import "AWCell.h"

@interface AWEditCell : AWCell

@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (nonatomic) PFObject *history;

+ (NSString *)getHistory:(PFObject *)history;
- (void)configure:(PFObject *)object;

@end
