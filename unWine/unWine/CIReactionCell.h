//
//  CIReactionCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "ParseSubclasses.h"
#import "AWCell.h"

@interface CIReactionCell : UITableViewCell <ReactionViewDelegate>

@property (nonatomic) id delegate;
@property (nonatomic) BOOL hasSetup;

@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) unWine *wine;

@property (nonatomic, strong) UILabel *reactionLabel;

- (void)setup:(NSIndexPath *)indexPath;
- (void)configure:(unWine *)wine;

@end
