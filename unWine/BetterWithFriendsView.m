//
//  BetterWithFriendsView.m
//  unWine
//
//  Created by Fabio Gomez on 6/29/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "BetterWithFriendsView.h"
#import "VineCastTVC.h"
//#import "UILabel+MultiLineAutoSize.h"

@implementation BetterWithFriendsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithDelegate:(VineCastTVC *)delegate {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    self = [super initWithFrame:frame];
    if (self) {
        // iPhone 7 320
        self.delegate = delegate;
        
        // Tap Gesture Recognizer
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        //tapGestureRecognizer.numberOfTapsRequired = 1;
        //tapGestureRecognizer.numberOfTouchesRequired = 0;
        tapGestureRecognizer.delegate = self;
        self.userInteractionEnabled = TRUE;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        // Frames
        CGRect cFrame = CGRectMake(8, 8, frame.size.width - 8 - 8, 44);
        CGRect imageFrame = CGRectMake(0, 0, 44, 44);
        CGRect labelFrame = CGRectMake(imageFrame.size.width + 8, 0, cFrame.size.width - imageFrame.size.width - 8 - 8, 44);
        
        // Setup container view
        self.containerView = [[UIView alloc] initWithFrame:cFrame];
        self.containerView.backgroundColor = UNWINE_PURPLE;
        self.containerView.userInteractionEnabled = TRUE;
        [self.containerView addGestureRecognizer:tapGestureRecognizer];
        
        // Image view
        self.socialImageView = [[UIImageView alloc] initWithFrame:imageFrame];
        self.socialImageView.image = [UIImage imageNamed:@"Share_Reviews_Image_Small.png"];
        self.socialImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.socialImageView.userInteractionEnabled = TRUE;
        [self.socialImageView addGestureRecognizer:tapGestureRecognizer];
        
        // Label
        BOOL isLargePhone = (IS_IPHONE_6P || IS_IPHONE_6);
        self.socialLabel = [[UILabel alloc] initWithFrame:labelFrame];
        self.socialLabel.textColor = [UIColor whiteColor];
        //self.socialLabel.text = @"Did you know wine is better shared with friends? Tap here to invite";
        self.socialLabel.text = [NSString stringWithFormat:@"Did you know wine is better shared with friends?%@Tap here to invite", isLargePhone ? @"\n" : @" "];
        self.socialLabel.font = [UIFont systemFontOfSize:12];
        self.socialLabel.userInteractionEnabled = TRUE;
        self.socialLabel.numberOfLines = 0;
        self.socialLabel.textAlignment = NSTextAlignmentLeft;
        self.socialLabel.lineBreakMode = NSLineBreakByWordWrapping;
        //[self.socialLabel resizeToFit];
        //CGSize maximumLabelSize = CGSizeMake(self.socialLabel.frame.size.width, self.socialLabel.frame.size.height);
        //CGSize expectSize = [self.socialLabel sizeThatFits:maximumLabelSize];
        //self.socialLabel.frame = CGRectMake(self.socialLabel.frame.origin.x, self.socialLabel.frame.origin.y, expectSize.width, expectSize.height);
        //self.socialLabel.frame = CGRectMake(self.socialLabel.frame.origin.x, self.socialLabel.frame.origin.y, expectSize.width, self.socialLabel.frame.size.height);
        [self.socialLabel addGestureRecognizer:tapGestureRecognizer];

        [self.containerView addSubview:self.socialImageView];
        [self.containerView addSubview:self.socialLabel];
        [self addSubview:self.containerView];
        
    }
    return self;
}

- (void)handleTapFrom: (UITapGestureRecognizer *)recognizer {
    //Code to handle the gesture
    LOGGER(@"Enter");
    [self.delegate showInvite];
}

@end
