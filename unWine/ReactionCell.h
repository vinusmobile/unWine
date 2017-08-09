//
//  ReactionCell.h
//  unWine
//
//  Created by Bryce Boesen on 12/13/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"
#import "ParseSubclasses.h"

@interface ReactionCell : VineCastCell <ReactionViewDelegate>

@property (nonatomic, strong) UILabel *reactionLabel;
@property (nonatomic) unWine *wine;

@end
