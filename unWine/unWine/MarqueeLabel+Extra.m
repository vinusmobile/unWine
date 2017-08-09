//
//  MarqueeLabel+Extra.m
//  unWine
//
//  Created by Fabio Gomez on 7/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MarqueeLabel+Extra.h"

@implementation MarqueeLabel (Extra)
- (void)setClassicSpeed {
    self.rate = [self.text length] / 4.0f;
    self.fadeLength = 3.0f;
    self.animationDelay = 3.0f;
}
@end
