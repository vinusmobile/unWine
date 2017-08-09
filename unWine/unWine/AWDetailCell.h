//
//  AWDetailCell.h
//  unWine
//
//  Created by Bryce Boesen on 4/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWCell.h"

@class MarqueeLabel;
@interface AWDetailCell : AWCell

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet MarqueeLabel *title;


- (void) configure:(unWine *)wineObject path:(NSIndexPath *)indexPath;
- (void)modifyField;

@end
