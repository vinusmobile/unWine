//
//  EarnedMeritCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/29/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "EarnedMeritCell.h"
#import "ParseSubclasses.h"
#import "NSConcurrentMutableArray.h"

@interface EMeritView : UIView

@property (nonatomic) EarnedMeritCell *parent;
@property (nonatomic) Merits *merit;

@property (nonatomic) PFImageView *imageView;
@property (nonatomic) UILabel *earnedLabel;

- (instancetype)initWithFrame:(CGRect)frame parent:(EarnedMeritCell *)parent;

@end

@implementation EarnedMeritCell {
    CALayer *border;
    NSConcurrentMutableArray<EMeritView *> *imageViews;
    NSTimer *timedTask;
    NSInteger showingMerit;
}

- (void)setup {
    [super setup];
    self.clipsToBounds = YES;
    
    imageViews = [[NSConcurrentMutableArray alloc] init];
    
    border = [CALayer layer];
    border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border.frame = CGRectZero;
    //[self.contentView.layer addSublayer:border];
}

- (void)configureCell:(NewsFeed *)object {
    BOOL isNew = object == nil || ![self.object.objectId isEqualToString:object.objectId];
    [super configureCell:object];
    showingMerit = 0;
    
    [border setFrame:CGRectMake(20, EARNED_MERIT_CELL_HEIGHT - 1, SCREEN_WIDTH - 40, .5)];
    
    NSArray *merits = object.connectedMerits;
    [self ensureImageViewCount:object];
    
    for(NSUInteger i = [merits count]; i < [imageViews count]; i++) {
        EMeritView *view = [imageViews objectAtIndex:i];
        if(isNew)
            view.imageView.image = MERIT_PLACEHOLDER;
        view.alpha = 0;
        view.tag = -1;
        if(i != showingMerit)
            view.layer.affineTransform = CGAffineTransformMakeScale(1, -1);
    }
    
    //NSLog(@"EMC configure - %li, %lu, %li", [merits count], (unsigned long)[imageViews count], showingMerit);
    
    for(NSUInteger i = 0; i < [merits count]; i++) {
        Merits *merit = [merits objectAtIndex:i];
        if(merit && ![merit isKindOfClass:[NSNull class]]) {
            EMeritView *view = [imageViews objectAtIndex:i];
            if(i == showingMerit || [merits count] == 1) {
                view.layer.affineTransform = CGAffineTransformIdentity;
                [self.contentView bringSubviewToFront:view];
            }
            view.alpha = 1;
            view.tag = i;
            
            [view setMerit:merit];
        }
    }
    
    [self scheduleTimedTask:merits];
}

- (void)ensureImageViewCount:(NewsFeed *)object {
    NSArray *merits = object.connectedMerits;
    NSInteger c = [imageViews count];
    for(NSInteger i = c; i < [merits count]; i++) {
        CGRect rect = (CGRect){0, 0, {SCREEN_WIDTH, EARNED_MERIT_CELL_HEIGHT}};
        EMeritView *view = [[EMeritView alloc] initWithFrame:rect parent:self];
        if(c == 0) {
            UIView *background = [[UIView alloc] initWithFrame:rect];
            background.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:background];
            [self.contentView sendSubviewToBack:background];
        }
        
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meritPressed:)];
        [view addGestureRecognizer:gesture];
        
        [self.contentView addSubview:view];
        [imageViews addObject:view];
    }
}

- (void)scheduleTimedTask:(NSArray *)merits {
    if(timedTask) {
        [timedTask invalidate];
        timedTask = nil;
    }
    
    if([merits count] > 1) {
        timedTask = [NSTimer scheduledTimerWithTimeInterval:2.25
                                                     target:self
                                                   selector:@selector(switchEMeritView)
                                                   userInfo:nil
                                                    repeats:YES];
        [timedTask fire];
    }
}

- (void)switchEMeritView {
    NSArray *merits = self.object.connectedMerits;
    if([merits count] <= 1)
        return;
    
    if([merits count] != [imageViews count])
        [self ensureImageViewCount:self.object];
    
    //get next index
    NSInteger next = showingMerit + 1;
    if(next >= [merits count])
        next = 0;
    
    //restage the elements
    //NSLog(@"next=%li, showing=%li", next, showingMerit);
    //NSLog(@"mCount=%li, ivCount=%li", [merits count], [imageViews count]);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for(NSInteger i = 0; i < [imageViews count] && i < [merits count]; i++) {
        EMeritView *view = [imageViews objectAtIndex:i];
        view.alpha = 1;
        if(i != showingMerit && i != next) {
            view.layer.affineTransform = CGAffineTransformMakeScale(1, -1);
            //view.alpha = 0;
        } else if(i == next) {
            view.layer.affineTransform = CGAffineTransformMakeScale(1, -1);
            /*CATransform3D xform = CATransform3DIdentity;
            xform = CATransform3DRotate(xform, M_PI_2, -1, 0, 0);
            view.layer.transform = xform;*/
            //view.alpha = 0;
        } else {
            view.layer.affineTransform = CGAffineTransformIdentity;
            //view.alpha = 1;
        }
    }
    [CATransaction commit];
    
    //perform the flip
    EMeritView *currView = [imageViews objectAtIndex:showingMerit];
    EMeritView *nextView = [imageViews objectAtIndex:next];
    nextView.alpha = 1;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^(void) {
         [self.contentView sendSubviewToBack:currView];
         currView.layer.affineTransform = CGAffineTransformMakeScale(1, -1);//CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
         nextView.layer.affineTransform = CGAffineTransformIdentity;//CATransform3DIdentity;
         [self.contentView bringSubviewToFront:nextView];
         currView.alpha = 0;
         /*CATransform3D xform = CATransform3DIdentity;
         xform = CATransform3DRotate(xform, M_PI_2, 0.5, 0, 0);
         currView.layer.transform = xform;
         nextView.layer.transform = CATransform3DIdentity;*/
     } completion:^(BOOL finished) {
         //currView.alpha = 0;
         //nextView.alpha = 1;
     }];
    showingMerit = next;
}

- (void)meritPressed:(UITapGestureRecognizer *)sender {
    //NSLog(@"meritPressed");
    Merits *merit = [self.object.connectedMerits objectAtIndex:[sender view].tag];
    if(merit && ![merit isKindOfClass:[NSNull class]]) {
        MeritAlertView *alert = [merit createCustomAlertView:MeritModeDiscoverMessage
                                          andShowShareOption:[self.object.authorPointer isTheCurrentUser]];
        alert.delegate = self.delegate;
    }
}

@end

@implementation EMeritView
@synthesize merit = _merit;

- (instancetype)initWithFrame:(CGRect)frame parent:(EarnedMeritCell *)parent {
    self = [super initWithFrame:frame];
    if (self) {
        self.parent = parent;
        self.clipsToBounds = YES;
        
        NSInteger ivBuffer = 2;
        NSInteger elBuffer = 8;
        NSInteger h = EARNED_MERIT_CELL_HEIGHT;
        
        NSInteger dim = h - ivBuffer * 2; //48 - 4
        self.imageView = [[PFImageView alloc] initWithFrame:(CGRect){ivBuffer + 6, ivBuffer, {dim, dim}}];
        //self.imageView.userInteractionEnabled = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        NSInteger x = X2(self.imageView) + WIDTH(self.imageView) + elBuffer;
        self.earnedLabel = [[UILabel alloc] initWithFrame:(CGRect){x, 0, {SCREEN_WIDTH - x - elBuffer, h}}];
        [self.earnedLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [self.earnedLabel setTextAlignment:NSTextAlignmentLeft];
        self.earnedLabel.backgroundColor = [UIColor whiteColor];
        self.earnedLabel.minimumScaleFactor = .75;
        self.earnedLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.earnedLabel];
        
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        layer.zPosition = 2;
        layer.doubleSided = NO;
        layer.affineTransform = CGAffineTransformMakeScale(1, -1);
        [self.layer addSublayer:layer];
    }
    return self;
}

- (Merits *)merit {
    return _merit;
}

- (void)setMerit:(Merits *)merit {
    _merit = merit;
    
    [merit setMeritImageForImageView:self.imageView];
    
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:14];
    UIFont *boldFont = [UIFont fontWithName:@"OpenSans-Bold" size:15];
    
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:@""];
    [formatted appendAttributedString:[self makeAttributed:@"Earned the " font:font]];
    [formatted appendAttributedString:[self makeAttributed:merit.name font:boldFont]];
    [formatted appendAttributedString:[self makeAttributed:@" merit!" font:font]];
    self.earnedLabel.attributedText = formatted;
}

- (NSAttributedString *)makeAttributed:(NSString *)string font:(UIFont *)font {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    return [[NSAttributedString alloc] initWithString:string attributes:dict];
}

@end
