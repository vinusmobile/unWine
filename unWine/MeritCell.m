//
//  MeritCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/18/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MeritCell.h"
#import "MeritsTVC.h"

#define MERIT_IMAGE_BUFFER 20

@interface MeritView : UIView
@property (nonatomic) UIImageView *meritImage;
@property (nonatomic) UILabel *meritLabel;
@end

@implementation MeritView

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        self.meritImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - MERIT_IMAGE_BUFFER)];
        self.meritImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.meritImage];
        
        self.meritLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - MERIT_IMAGE_BUFFER, frame.size.width, MERIT_IMAGE_BUFFER)];
        self.meritLabel.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:16.0f];
        //self.meritLabel.numberOfLines = 0;
        self.meritLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.meritLabel];
        
        self.clipsToBounds = YES;
    }
    return self;
}

@end

@implementation MeritCell {
    CGRect aFrame;
}
@synthesize meritViews, containerView;

- (void) setup {
    [super setup];
    
    containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    containerView.scrollEnabled = YES;
    containerView.layoutMargins = UIEdgeInsetsZero;
    //containerView.contentSize = containerView.frame.size;
    
    meritViews = [[NSMutableArray alloc] init];
    
    [self addSubview:containerView];
    //containerView.backgroundColor = UNWINE_RED;
    
    NSLog(@"containerView %@", NSStringFromCGRect(containerView.frame));
}

- (MeritView *) getView:(NSInteger)index {
    if([meritViews count] > index)
        return (MeritView *)[meritViews objectAtIndex:index];
    
    NSUInteger width = 140, buffer = MERIT_IMAGE_BUFFER;
    NSInteger count = [MeritCell countMerits:self.object];
    MeritView *view;
    if(count == 1)
        view = [[MeritView alloc] initWithFrame:CGRectMake(SEMIWIDTH(containerView) - width / 2, buffer, width, width + buffer)];
    else
        view = [[MeritView alloc] initWithFrame:CGRectMake((width + buffer) * index, buffer, width, width + buffer)];
    
    view.tag = index;
    
    UITapGestureRecognizer *tapMerit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meritPressed:)];
    [view addGestureRecognizer:tapMerit];
    
    [meritViews addObject:view];
    CGFloat widthSum = width * count + buffer * (count - 1);
    CGFloat startX = (WIDTH(containerView) - widthSum) / 2;
    if(count > 1) {
        containerView.contentInset = UIEdgeInsetsMake(0, startX, 0, startX);
        containerView.contentSize = (CGSize) {width * count + buffer * (count - 1), HEIGHT(containerView)};
    } else
        containerView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    return view;
}

- (void)configureCell:(NewsFeed *)object {
    [super configureCell:object];
    
    //[[containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self configureMerits:object];
}

- (void)configureMerits:(NewsFeed *)object {
    NSArray *merits = object[@"connectedMerits"];
    
    if(object[@"connectedMerits"] != nil) {
        for(NSUInteger i = 0; i < [merits count]; i++) {
            PFObject *merit = [merits objectAtIndex:i];
            if(!merit || [merit isKindOfClass:[NSNull class]])
                continue;
            
            PFFile *theImage = merit[@"image"];
            MeritView *meritView = [self getView:i];
            if(theImage == nil || [theImage isKindOfClass:[NSNull class]])
                continue;
            
            [theImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    meritView.meritImage.image = [UIImage imageWithData:imageData];
                    meritView.meritImage.contentMode = UIViewContentModeScaleAspectFill;
                    meritView.meritLabel.text = [merit[@"name"] capitalizedString];
                    meritView.meritLabel.adjustsFontSizeToFitWidth = YES;
                    meritView.meritLabel.minimumScaleFactor = .5;
                    
                    if(![meritView isDescendantOfView:containerView]) {
                        [containerView addSubview:meritView];
                        NSInteger proposition = X2(meritView) + WIDTH(meritView) + MERIT_IMAGE_BUFFER / 2;
                        if(proposition > containerView.contentSize.width)
                            [containerView setContentSize:CGSizeMake(proposition, HEIGHT(meritView))];
                    }
                }
            }];
        }
    } else if(object[@"meritPointer"] != nil) {
        PFObject *merit = object[@"meritPointer"];
        
        PFFile *theImage = merit[@"image"];
        if(theImage == nil || [theImage isKindOfClass:[NSNull class]])
            return;
        [theImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
            if (!error) {
                MeritView *meritView = [self getView:0];
                meritView.meritImage.image = [UIImage imageWithData:imageData];
                meritView.meritImage.contentMode = UIViewContentModeScaleAspectFit;
                meritView.meritLabel.text = [merit[@"name"] capitalizedString];
                
                if(![meritView isDescendantOfView:containerView])
                    [containerView addSubview:meritView];
            }
        }];
    }
}

- (void)meritPressed:(UIGestureRecognizer *)recognizer {
    NSInteger index = [recognizer view].tag;
    
    Merits *merit = (self.object[@"meritPointer"]) ?
        self.object[@"meritPointer"] :
        [self.object[@"connectedMerits"] objectAtIndex:index];
    
    if(merit && ![merit isKindOfClass:[NSNull class]]) {
        LOGGER(@"Pressed it");
        [merit createCustomAlertView:MeritModeDiscover
                  andShowShareOption:[self.object.authorPointer isTheCurrentUser]];
    }
}

+ (NSInteger) countMerits:(PFObject *)object {
    if(object[@"connectedMerits"] != nil) {
        return [object[@"connectedMerits"] count];
    } else if(object[@"meritPointer"] != nil) {
        return 1;
    } else {
        return 0;
    }
}

@end
