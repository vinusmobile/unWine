//
//  ReactionCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/13/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "ReactionCell.h"

@implementation ReactionCell {
    NSMutableArray<ReactionView *> *reacts;
    UIActivityIndicatorView *activityView;
}

- (void)setup {
    [super setup];
    self.clipsToBounds = YES;
    
    reacts = [[NSMutableArray alloc] init];
    
    self.reactionLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 4, {SCREEN_WIDTH, 16}}];
    self.reactionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    self.reactionLabel.text = @"Total wine reactions!";
    self.reactionLabel.textAlignment = NSTextAlignmentCenter;
    self.reactionLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.reactionLabel];
    
    NSArray<ReactionObject *> *reactions = [Reaction reactions]; //[[[Reaction reactions] reverseObjectEnumerator] allObjects];
    CGFloat reactionBuffer = 4;
    CGFloat reactWidth = 68 * SCREEN_WIDTH / 375.0f;
    CGFloat reactHeight = 88;
    
    NSInteger topRow = 5;
    //NSInteger bottomRow = [reactions count] - topRow;
    CGFloat reactX = SCREEN_WIDTH / 2 - (reactWidth * topRow + reactionBuffer * (topRow - 1)) / 2;
    CGFloat reactY = 8;
    for(NSInteger i = 0; i < topRow; i++) {
        ReactionObject *obj = [reactions objectAtIndex:i];
        ReactionView *view = [self reactionView:(CGRect){reactX, reactY, {reactWidth, reactHeight}} type:obj.type];
        reactX += reactWidth + reactionBuffer;
        
        [reacts addObject:view];
        [self.contentView addSubview:view];
    }
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.center = self.contentView.center;
    [activityView startAnimating];
    [self.contentView addSubview:activityView];
}

- (void)relayoutReactionViews:(NSArray *)counts {
    NSInteger usable = 0;
    for(NSNumber *num in counts) {
        if([num integerValue] > 0)
            usable++;
    }
    
    CGFloat reactionBuffer = 4;
    CGFloat reactWidth = 68 * SCREEN_WIDTH / 375.0f;
    CGFloat reactHeight = 88;
    CGFloat reactX = SCREEN_WIDTH / 2 - (reactWidth * usable + reactionBuffer * (usable - 1)) / 2;
    CGFloat reactY = 8;
    
    [activityView stopAnimating];
    for(NSInteger i = 0; i < [reacts count]; i++) {
        if([[counts objectAtIndex:i] integerValue] > 0) {
            ReactionView *view = [reacts objectAtIndex:i];
            [view setFrame:(CGRect){reactX, reactY, {reactWidth, reactHeight}}];
            reactX += reactWidth + reactionBuffer;
            
            [UIView animateWithDuration:.2 animations:^{
                view.alpha = 1;
            }];
        }
    }
}

- (ReactionView *)reactionView:(CGRect)rect type:(ReactionType)type {
    ReactionView *view = [ReactionView reactWithFrame:rect type:type];
    view.alpha = 0;

    UIView *borderView = [[UIView alloc] initWithFrame:(CGRect){0, 18, rect.size.width, rect.size.height - 18}];
    borderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    borderView.layer.cornerRadius = 6;
    borderView.layer.borderWidth = .5;
    [view addSubview:borderView];
    
    view.backgroundColor = [UIColor clearColor];
    view.tintColor = UNWINE_RED;
    view.delegate = self;
    view.descLabel.alpha = 0;
    view.descLabel.textColor = [UIColor blackColor];
    
    view.quantityLabel.alpha = 1;
    view.quantityLabel.text = @"";
    view.quantityLabel.textColor = [UIColor blackColor];
    /*view.quantityLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:10];
     [view.quantityLabel.layer setShadowColor:[UIColor lightGrayColor].CGColor];
     [view.quantityLabel.layer setShadowOpacity:1];
     [view.quantityLabel.layer setShadowRadius:2];
     [view.quantityLabel.layer setShadowOffset:CGSizeMake(0, 0)];*/
    
    return view;
}

- (void)configureCell:(NewsFeed *)object {
    [super configureCell:object];
    
    [self configure:object.unWinePointer];
}

- (void)configure:(unWine *)wine {
    self.wine = wine;
    
    /*if(![activityView isAnimating]) {
        [activityView startAnimating];
    }
    
    for(ReactionView *view in reacts) {
        view.alpha = 0;
    }*/
    
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
                [self relayoutReactionViews:counts];
            });
        }
        
        return nil;
    }];
}

- (void)reactionPressed:(ReactionType)type {
    
}

@end
