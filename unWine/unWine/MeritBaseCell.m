//
//  MeritBaseCell.m
//  unWine
//
//  Created by Bryce Boesen on 2/15/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MeritBaseCell.h"

@implementation MeritBaseCell {
    NSMutableArray<UIView *> *elements;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    self.backgroundColor = [UIColor whiteColor];
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        elements = [[NSMutableArray alloc] init];
        
        NSInteger labelBuffer = 4;
        NSInteger buffer = 0;
        NSInteger width = SCREEN_WIDTH / IMAGE_PER_CELL, height = MERIT_BASE_CELL_HEIGHT;
        NSInteger x = (SCREEN_WIDTH - IMAGE_PER_CELL * width - (IMAGE_PER_CELL - 1) * buffer) / 2;
        NSInteger y = (MERIT_BASE_CELL_HEIGHT - height) / 2;
        
        for(NSInteger i = 0; i < IMAGE_PER_CELL; i++) {
            UIView *view = [[UIView alloc] initWithFrame:(CGRect){x, y, {width, height}}];
            view.backgroundColor = [UIColor clearColor];
            x += width + buffer;
            
            NSInteger labelHeight = 45 - labelBuffer * 2;
            UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){labelBuffer, height - labelHeight - labelBuffer, {width - labelBuffer * 2, labelHeight}}];
            label.tag = -1;
            [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor blackColor]];
            label.numberOfLines = 0;
            label.minimumScaleFactor = .4;
            label.adjustsFontSizeToFitWidth = YES;
            
            NSInteger w = 80;
            NSInteger h = 80;
            PFImageView *imageView = [[PFImageView alloc] initWithFrame:CGRectMake((width - w) / 2,
                                                                                   (height - h) / 2 - 20,
                                                                                   w, h)];
            imageView.tag = 0;//i;
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            
            imageView.backgroundColor = [UIColor clearColor];
            imageView.layer.borderWidth = .5f;
            imageView.layer.cornerRadius = WIDTH(imageView) / 2;
            imageView.clipsToBounds = YES;
            
            //imageView.image = [UIImage imageNamed:@"default.png"];
            UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPressed:)];
            [imageView addGestureRecognizer:tapped];
            
            [view addSubview:label];
            [view addSubview:imageView];
            [self.contentView addSubview:view];
            [elements addObject:view];
        }
    }
}

- (void)configure:(NSArray *)merits {
    self.merits = merits;
    
    for(NSInteger i = 0; i < IMAGE_PER_CELL; i++) {
        UIView *view = [elements objectAtIndex:i];
        //LOGGER([view subviews]);
        
        UILabel *label = [[view subviews] objectAtIndex:0];
        PFImageView *imageView = [[view subviews] objectAtIndex:1];
        imageView.tag = i;
        if(i < [merits count]) {
            Merits *merit = [merits objectAtIndex:i];
            if(merit && ![merit isKindOfClass:[NSNull class]] && [self.delegate.earnedMerits containsObject:merit.objectId])
                [merit setMeritImageForImageView:imageView];
            else
                imageView.image = MERIT_PLACEHOLDER;
            
            imageView.alpha = 1;
            imageView.userInteractionEnabled = YES;
            
            [label setText:merit.name];
            label.alpha = 1;
        } else {
            imageView.alpha = 0;
            imageView.userInteractionEnabled = NO;
            
            label.alpha = 0;
        }
    }
}

- (void)viewPressed:(UITapGestureRecognizer *)recognizer {
    Merits *merit = [self.merits objectAtIndex:[recognizer.view tag]];
    if(merit && ![merit isKindOfClass:[NSNull class]]) {
        if([self.delegate.earnedMerits containsObject:[merit objectId]] || self.delegate.meritMode != MeritModeUserOnly) {
            LOGGER(@"Pressed the merit");
            User *user = self.delegate.profileTVC.profileUser;
            BOOL showShare = ([user isTheCurrentUser] && [user.earnedMerits containsObject:merit.objectId]);
            
            MeritAlertView *alert = [merit createCustomAlertView:self.delegate.meritMode
                               andMerits:self.delegate.earnedMerits
                      andShowShareOption:showShare];
            alert.delegate = self.delegate;
        }
    }
}

@end
