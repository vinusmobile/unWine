//
//  AWReactionCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/12/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "AWReactionCell.h"

@implementation AWReactionCell {
    NSMutableArray<ReactionView *> *reacts;
}

- (void)setup:(NSIndexPath *)indexPath {
    [super setup:indexPath];
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        reacts = [[NSMutableArray alloc] init];
        
        self.reactionLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 16}}];
        self.reactionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
        self.reactionLabel.text = @"Total wine reactions!";
        self.reactionLabel.textAlignment = NSTextAlignmentCenter;
        self.reactionLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.reactionLabel];
        
        NSArray<ReactionObject *> *reactions = [Reaction reactions]; //[[[Reaction reactions] reverseObjectEnumerator] allObjects];
        CGFloat reactionBuffer = 4;
        CGFloat reactWidth = 68 * SCREEN_WIDTH / 375.0f;
        CGFloat reactHeight = 88;
        
        NSInteger topRow = 5;
        NSInteger bottomRow = [reactions count] - topRow;
        CGFloat reactX = SCREEN_WIDTH / 2 - (reactWidth * topRow + reactionBuffer * (topRow - 1)) / 2;
        CGFloat reactY = 24;
        for(NSInteger i = 0; i < topRow; i++) {
            ReactionObject *obj = [reactions objectAtIndex:i];
            ReactionView *view = [self reactionView:(CGRect){reactX, reactY, {reactWidth, reactHeight}} type:obj.type];
            reactX += reactWidth + reactionBuffer;
            
            [reacts addObject:view];
            [self.contentView addSubview:view];
        }
        
        reactX = SCREEN_WIDTH / 2 - (reactWidth * bottomRow + reactionBuffer * (bottomRow - 1)) / 2;
        reactY = 24 + reactHeight + reactionBuffer * 2;
        for(NSInteger i = topRow; i < [reactions count]; i++) {
            ReactionObject *obj = [reactions objectAtIndex:i];
            ReactionView *view = [self reactionView:(CGRect){reactX, reactY, {reactWidth, reactHeight}} type:obj.type];
            reactX += reactWidth + reactionBuffer;
            
            [reacts addObject:view];
            [self.contentView addSubview:view];
        }
    }
}

- (ReactionView *)reactionView:(CGRect)rect type:(ReactionType)type {
    ReactionView *view = [ReactionView reactWithFrame:rect type:type];
    
    view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    view.layer.cornerRadius = 6;
    view.layer.borderWidth = .5;
    view.backgroundColor = ALMOST_BLACK_2;
    view.tintColor = UNWINE_RED;
    view.delegate = self;
    view.descLabel.textColor = [UIColor whiteColor];
    
    view.quantityLabel.alpha = 1;
    view.quantityLabel.text = @"";
    view.quantityLabel.textColor = [UIColor whiteColor];
    /*view.quantityLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:10];
    [view.quantityLabel.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [view.quantityLabel.layer setShadowOpacity:1];
    [view.quantityLabel.layer setShadowRadius:2];
    [view.quantityLabel.layer setShadowOffset:CGSizeMake(0, 0)];*/
    
    return view;
}

- (void)configure:(unWine *)wine {
    [super configure:wine];
    self.wine = wine;
    
    //LOGGER(@"configuring AWReactionCell");
    [[wine checkinReactionTask] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
            return nil;
        }
        
        NSArray<ReactionObject *> *reactions = [Reaction reactions];
        
        NSMutableArray *counts = [NSMutableArray arrayWithArray:@[ @0, @0, @0, @0, @0 ]];
        for(NewsFeed *feed in task.result) {
            NSInteger i = [feed.reactionType integerValue];
            if(i >= [reactions count])
                continue;
            
            NSNumber *n = [counts objectAtIndex:i];
            [counts replaceObjectAtIndex:i withObject:@([n integerValue] + 1)];
        }
        
        for(NSInteger i = 0; i < [reactions count]; i++) {
            ReactionView *view = [reacts objectAtIndex:i];
            dispatch_async(dispatch_get_main_queue(), ^{
                [view.quantityLabel setText:[NSString stringWithFormat:@"%@", [counts objectAtIndex:i]]];
            });
        }
        
        return nil;
    }];
}

- (void)reactionPressed:(ReactionType)type {
    
}

@end
