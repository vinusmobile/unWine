//
//  GameCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/19/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "GameCell.h"
#import "VineCastTVC.h"

@implementation GameCell {
    CascadingLabelView *clv;
    UILabel *label1, *label2, *label3;
}

- (void) setup {
    [super setup];
    
    clv = [[CascadingLabelView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self), HEIGHT(self))];
    clv.backgroundColor = [UIColor clearColor];
    //[clv setPadding:PaddingMake(0, 10, 0, 10)];
    
    label1 = [[UILabel alloc] init];
    label1.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:16.0f];
    label1.textAlignment = NSTextAlignmentCenter;
    [clv addSubview:label1];
    
    label2 = [[UILabel alloc] init];
    label2.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:30.0f];
    label2.textAlignment = NSTextAlignmentCenter;
    [clv addSubview:label2];
    
    label3 = [[UILabel alloc] init];
    label3.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:14.0f];
    label3.text = @"Personal Best!";
    label3.textAlignment = NSTextAlignmentCenter;
    [clv addSubview:label3];
    
    [self addSubview:clv];
    [clv update];
    [clv setFrame:CGRectMake(0, 0, WIDTH(self), HEIGHT(self))];
    
    //UITapGestureRecognizer *tapGame = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gamePressed:)];
    //[self addGestureRecognizer:tapGame];
}

- (void)configureCell:(PFObject *)object {
    [super configureCell:object];
    
    PFObject *game = object[@"gamePointer"];
    if(game != nil) {
        NSString *gameTitle = [game[@"name"] capitalizedString];
        NSString *highscore = [NSString stringWithFormat:@"%@", [object[@"savedScore"] stringValue]];
        
        label1.text = gameTitle;
        label2.text = highscore;
        [clv update];
    }
}

- (void)gamePressed:(UITapGestureRecognizer *)recognizer {
    self.delegate.tabBarController.view.tag = GAME_VIEW;
    //[self.delegate.navigationController popToRootViewControllerAnimated:NO];
    [self.delegate.tabBarController setSelectedIndex:4];
}

@end
