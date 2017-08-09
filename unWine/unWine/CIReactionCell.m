//
//  CIReactionCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CIReactionCell.h"
#import "CastCheckinTVC.h"

@implementation CIReactionCell {
    NSMutableArray<ReactionView *> *reacts;
    BOOL isAnimating, isShowingAll;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        [self setSelectedType:ReactionType0None];
        reacts = [[NSMutableArray alloc] init];
        
        self.reactionLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 16}}];
        self.reactionLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
        self.reactionLabel.text = @"Select your wine reaction!";
        self.reactionLabel.textAlignment = NSTextAlignmentCenter;
        self.reactionLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.reactionLabel];
        
        NSLog(@"iphone6 width %f", SCREEN_WIDTH);
        NSArray<ReactionObject *> *reactions = [Reaction reactions]; //[[[Reaction reactions] reverseObjectEnumerator] allObjects];
        CGFloat reactionBuffer = 4;
        CGFloat reactWidth = 68 * SCREEN_WIDTH / 375.0f;
        CGFloat reactHeight = 80;
        
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
    
    view.quantityLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    view.quantityLabel.text = @"";
    view.quantityLabel.textColor = [UIColor whiteColor];
    [view.quantityLabel.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [view.quantityLabel.layer setShadowOpacity:1];
    [view.quantityLabel.layer setShadowRadius:2];
    [view.quantityLabel.layer setShadowOffset:CGSizeMake(0, 0)];
    
    return view;
}

- (void)configure:(unWine *)wine {
    self.wine = wine;
}

- (ReactionType)getSelectedType {
    return [(CastCheckinTVC *)self.delegate selectedType];
}

- (void)setSelectedType:(ReactionType)type {
    [(CastCheckinTVC *)self.delegate setSelectedType:type];
}

- (void)reactionPressed:(ReactionType)type {
    //NSLog(@"reaction pressed! %u, %u", type, [self getSelectedType]);
    for(ReactionView *view in reacts) {
        if(view.type == type) {
            if(type == [self getSelectedType]) {
                view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                view.layer.borderWidth = .5;
                [self setSelectedType:ReactionType0None];
            } else {
                view.layer.borderColor = [UNWINE_RED CGColor];
                view.layer.borderWidth = 2;
                [self setSelectedType:type];
            }
            
            if(type == ReactionType1Great) {
                [self showPopover:view];
            }
        } else {
            view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            view.layer.borderWidth = .5;
        }
    }
}

- (void)showPopover:(ReactionView *)view {
    CastCheckinTVC *parent = (CastCheckinTVC *)self.delegate;
    
    if(![User hasSeen:WITNESS_ALERT_GREAT_REACT] && ![[PopoverVC sharedInstance] isDisplayed]) {
        //CGRect rectOfCellInTableView = [parent.tableView rectForRowAtIndexPath:self.indexPath];
        CGRect placer = view.frame;
        
        [[PopoverVC sharedInstance] showFrom:parent
                                  sourceView:self
                                  sourceRect:placer
                                        text:@"Hey, congrats on finding a Great wine! Smart Wish List automatically adds Great wines to itself if they're not already there. You can turn off Smart Wish List by going to your Profile > Cog Button > Settings!"];
        
        [User witnessed:WITNESS_ALERT_GREAT_REACT];
    }
}

@end
