//
//  RecentSearchCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "RecentSearchCell.h"
#import "CheckinInterface.h"

@implementation RecentSearchCell {
    UIButton *express;
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!_hasSetup) {
        _hasSetup = YES;
        self.backgroundColor = CI_MIDDGROUND_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger buffer = 12, offset = buffer * 2;//, buffer2 = 12;
        NSInteger size = RECENT_SEARCH_CELL_HEIGHT - offset;
        
        express = [UIButton buttonWithType:UIButtonTypeSystem];
        [express setTintColor:CI_FOREGROUND_COLOR];
        [express setFrame:(CGRect){SCREEN_WIDTH - size - buffer, buffer, {size, size}}];
        [express setImage:[UIImage imageNamed:@"expressIcon"] forState:UIControlStateNormal];
        [express.imageView setContentMode:UIViewContentModeScaleAspectFit];
        //[accessory setImageEdgeInsets:UIEdgeInsetsMake(buffer2 / 2, buffer2 / 2, buffer2 / 2, buffer2 / 2)];
        [express addTarget:self action:@selector(expressPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:express];
        
        self.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)configure:(NSString *)searchString {
    self.textLabel.text = searchString;
    [self.contentView bringSubviewToFront:express];
}

- (void)expressPressed {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(expressPressed:)])
        [self.delegate expressPressed:self.textLabel.text];
}

- (void)interact:(UIGestureRecognizer *)gesture {
    [self expressPressed];
}

@end
