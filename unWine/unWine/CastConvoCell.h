//
//  CastConvoCell.h
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseSubclasses.h"
#import "InboxTVC.h"

@class InboxTVC;
@interface CastConvoCell : UITableViewCell

@property (nonatomic) InboxTVC *delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Conversations *object;

@property (weak, nonatomic) IBOutlet PFImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(Conversations *)object;

@end
