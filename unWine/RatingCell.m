//
//  RatingCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "RatingCell.h"
#import "ParseSubclasses.h"

@implementation RatingCell {
    NSMutableArray *barrels;
    UIImage *fullBarrel;
    UIImage *halfBarrel;
}

- (void) setup {
    [super setup];
    
    fullBarrel = [UIImage imageNamed:@"barrelSmall@2x.png"];
    halfBarrel = [UIImage imageNamed:@"barrelSmallHalf@2x.png"];
    
    barrels = [[NSMutableArray alloc] init];
    for(NSUInteger i = 0; i < 10; i++) {
        [barrels addObject:[self makeBarrel:i]];
        [self addSubview:[barrels objectAtIndex:i]];
    }
}

- (UIImageView *) makeBarrel:(NSInteger)index {
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(32 * index, 22, 30, 32)];
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.image = fullBarrel;
    view.alpha = 0;
    return view;
}

- (void)configureCell:(NewsFeed *)object {
    [super configureCell:object];
    
    PFObject *wine = [VineCastCell getWineForObject:object];
    if(wine[@"ratingObject"] != nil && wine[@"ratingObject"][@""] != nil) {
        self.unratedLabel.alpha = 0;
        CGFloat rating = [wine[@"ratingObject"][@""] floatValue];
        CGFloat halfRound = rating < 0.5f ? 0.5f : floorf(rating * 2) / 2;
        
        if(floor(halfRound) == halfRound) { // No halves
            self.ratingLabel.text = [NSString stringWithFormat:@"Rating %li/10", (long int)rating];
            for(NSUInteger i = 0; i < 10; i++) {
                UIImageView *iview = [barrels objectAtIndex:i];
                iview.image = fullBarrel;
                iview.alpha = (i < halfRound)? 1 : 0;
            }
        } else { // Has partial
            self.ratingLabel.text = [NSString stringWithFormat:@"Rating %.1f/10.0", rating];
            for(NSUInteger i = 0; i < 10; i++) {
                UIImageView *iview = [barrels objectAtIndex:i];
                iview.image = fullBarrel;
                iview.alpha = (i < floor(halfRound))? 1 : 0;
            }
            UIImageView *halfView = [barrels objectAtIndex:floor(halfRound)];
            halfView.image = halfBarrel;
            halfView.alpha = 1;
        }
    } else {
        self.ratingLabel.text = @"Rating";
        self.unratedLabel.alpha = 1;
    }
}

@end
