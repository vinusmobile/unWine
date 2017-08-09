//
//  AWReactionCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/12/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "AWCell.h"
#import "ParseSubclasses.h"

@interface AWReactionCell : AWCell <ReactionViewDelegate>

@property (nonatomic, strong) UILabel *reactionLabel;

@end
