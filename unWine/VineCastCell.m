//
//  VineCastCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastCell.h"
#import "VineCastTVC.h"

@implementation VineCastCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)firstSetup:(id)delegate indexPath:(NSIndexPath *)indexPath {
    self.delegate = delegate;
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        [self setup];
        self.hasSetup = YES;
        //self.layer.zPosition = 1000;
    }
}

- (void)setup {
    //self.clipsToBounds = YES;
    //self.layer.masksToBounds = YES;
}

- (void)configureCell:(NewsFeed *)object {
    self.object = object;
}

- (void)notifyCompletelyVisible {
    self.isCompletelyVisible = YES;
}

- (void)notifyNotCompletelyVisible {
    self.isCompletelyVisible = NO;
}

+ (PFObject *)getWineForObject:(NewsFeed *)object {
    return object.unWinePointer;
}

@end
