//
//  UniqWinesCell.m
//  unWine
//
//  Created by Bryce Boesen on 8/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MultiWinesCell.h"
#import "CastDetailTVC.h"
#import "CheckinInterface.h"

@implementation MultiWinesCell {
    NSMutableArray *elements;
}
@synthesize singleTheme;

- (void)setDelegate:(UIViewController<MultiWinesCellDelegate> *)delegate {
    _delegate = delegate;
    self.singleTheme = unWineThemeDark;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.backgroundColor = [ThemeHandler getCellPrimaryColor:singleTheme];
    if(!self.hasSetup) {
        self.hasSetup = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
            UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){labelBuffer, height - labelHeight - labelBuffer - 2, {width - labelBuffer * 2, labelHeight + 2}}];
            label.tag = -1;
            [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
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
            imageView.layer.cornerRadius = 6;//WIDTH(imageView) / 2;
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

- (void)preconfigure:(NSArray<NSString *> *)objectIds {
    [[unWine getWinesTask:objectIds] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self configure:task.result];
        
        return nil;
    }];
}

- (void)configure:(NSArray *)wines {
    LOGGER(@"Enter");
    self.wines = wines;
    
    //LOGGER(wines.description);
    
    for(NSInteger i = 0; i < IMAGE_PER_CELL; i++) {
        UIView *view = [elements objectAtIndex:i];
        //LOGGER([view subviews]);
        
        UILabel *label = [[view subviews] objectAtIndex:0];
        PFImageView *imageView = [[view subviews] objectAtIndex:1];
        imageView.tag = i;
        if(i < [wines count]) {
            unWine *wine = [wines objectAtIndex:i];
            [wine setWineImageForImageView:imageView];
            [label setText:[wine getWineName]];
            
            imageView.alpha = 1;
            imageView.userInteractionEnabled = YES;
            
            label.alpha = 1;
        } else {
            imageView.alpha = 0;
            imageView.userInteractionEnabled = NO;
            
            label.alpha = 0;
        }
    }
    LOGGER(@"Done configuring cell");
}

- (void)viewPressed:(UITapGestureRecognizer *)gesture {
    if (ISVALIDARRAY(self.checkins)) {
        NewsFeed *nf = [self.checkins objectAtIndex:[gesture.view tag]];
        //VineCastTVC *vinecast = [[UIStoryboard storyboardWithName:@"VineCast" bundle:nil] instantiateViewControllerWithIdentifier:@"feed"];
        //ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GREAT_WINES_FROM_DISCOVER_VIEW);
        //vinecast.gridMode = false;
        //vinecast.state = VineCastStateGlobal;
        //vinecast.gridState = VineCastGridStateGreatWines;
        
        UIStoryboard *newsFeed = [UIStoryboard storyboardWithName:@"VineCast" bundle:nil];
        VineCastTVC *feed = [newsFeed instantiateViewControllerWithIdentifier:@"feed"];
        [feed setVineCastSingleObject:nf];
        feed.gridMode = false;
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_WINE_FROM_PROFILE_REACTION_VIEW);
        [self.delegate.navigationController pushViewController:feed animated:YES];
        
    } else {
        unWine *wine = [self.wines objectAtIndex:[gesture.view tag]];
        
        //UIStoryboard *checkIn = [UIStoryboard storyboardWithName:@"castCheckIn" bundle:nil];
        //CastDetailTVC *detail = [checkIn instantiateViewControllerWithIdentifier:@"detail"];
        WineContainerVC *detail = [[WineContainerVC alloc] init];
        detail.wine = wine;
        //detail.lockAllWines = [unWine areAllWinesLocked];
        detail.isNew = NO;
        detail.cameFrom = CastCheckinSourceUnique;
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_FEATURED_WINE_FROM_DISCOVER_VIEW);
        [self.delegate.navigationController pushViewController:detail animated:YES];
    }
}

- (void)updateTheme {
    
}

+ (NSInteger)getDefaultHeight {
    return UNIQ_WINES_CELL_HEIGHT;
}

@end
