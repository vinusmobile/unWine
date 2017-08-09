//
//  CellarCell.m
//  unWine
//
//  Created by Bryce Boesen on 8/19/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CellarCell.h"
#import "CastDetailTVC.h"
#import "CheckinInterface.h"

@implementation CellarCell {
    NSMutableArray *elements;
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

- (void)configure:(NSArray *)wines {
    self.wines = wines;
    
    for(NSInteger i = 0; i < IMAGE_PER_CELL; i++) {
        UIView *view = [elements objectAtIndex:i];
        //LOGGER([view subviews]);
        
        UILabel *label = [[view subviews] objectAtIndex:0];
        PFImageView *imageView = [[view subviews] objectAtIndex:1];
        imageView.tag = i;
        if(i < [wines count]) {
            unWine *wine = [wines objectAtIndex:i];
            [wine setWineImageForImageView:imageView];
            
            imageView.alpha = 1;
            imageView.userInteractionEnabled = YES;
            
            [label setText:[wine getWineName]];
            label.alpha = 1;
        } else {
            imageView.alpha = 0;
            imageView.userInteractionEnabled = NO;
            
            label.alpha = 0;
        }
    }
}

- (void)viewPressed:(UITapGestureRecognizer *)gesture {
    unWine *wine = [self.wines objectAtIndex:[gesture.view tag]];
    
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = wine;
    container.isNew = NO;
    container.cameFrom = CastCheckinSourceWishList;
    [self.delegate.navigationController pushViewController:container animated:YES];
    
    /*[PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        UIStoryboard *checkIn = [UIStoryboard storyboardWithName:@"castCheckIn" bundle:nil];
        CastDetailTVC *detail = [checkIn instantiateViewControllerWithIdentifier:@"detail"];
        
        detail.wine = wine;
        detail.lockAllWines = [config[@"LOCK_ALL_WINES"] boolValue];
        detail.isNew = NO;
        detail.cameFrom = CastCheckinSourceWishList;
        
        [self.delegate.navigationController pushViewController:detail animated:YES];
    }];*/
}


@end
