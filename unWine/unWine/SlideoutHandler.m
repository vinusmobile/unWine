//
//  SlideoutHandler.m
//  unWine
//
//  Created by Bryce Boesen on 8/30/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "SlideoutHandler.h"
#import "ABKFeedViewControllerNavigationContext.h"

#define SLIDEOUT_LEFT -1
#define SLIDEOUT_DEFAULT 0
#define SLIDEOUT_RIGHT 1

static SlideoutHandler *singleton;
static NSInteger offset = 60;
static NSInteger state = SLIDEOUT_DEFAULT;

@implementation SlideoutHandler

+ (SlideoutHandler *)sharedInstance {
    if(singleton == nil)
        singleton = [[SlideoutHandler alloc] init];
    
    return singleton;
}

- (void)setDelegate:(UIViewController<SlideoutHandlerDelegate> *)delegate {
    _delegate = delegate;
    
    if(delegate != nil)
        [singleton setup];
}

- (void)setup {
    UIViewController *controller = (UIViewController *)self.delegate;
    self.gesturesLeft = [[NSMutableArray alloc] init];
    self.gesturesRight = [[NSMutableArray alloc] init];
    [self registerGestures:controller];
    
    if([self.delegate respondsToSelector:@selector(setupLeftButton)])
        self.leftButton = [self.delegate setupLeftButton];
    else
        [self setupLeftButton];
    
    if([self.delegate respondsToSelector:@selector(setupRightButton)])
        self.rightButton = [self.delegate setupRightButton];
    else
        [self setupRightButton];
    
    if([self.delegate respondsToSelector:@selector(setupLeftView)])
        self.leftView = [self.delegate setupLeftView];
    else
        [self setupLeftView];
    
    if([self.delegate respondsToSelector:@selector(setupRightView)])
        self.rightView = [self.delegate setupRightView];
    else
        [self setupRightView];

    [self addShadows];
    controller.navigationController.navigationItem.leftBarButtonItem = self.leftButton;
    controller.navigationController.navigationItem.rightBarButtonItem = self.rightButton;
}

- (void)setupRightButton {
    self.rightButton = nil;
}

- (void)setupLeftButton {
    NSLog(@"default setupLeftButton");
    UIImage *faceImage = [UIImage imageNamed:@"newsfeed.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height);
    [face setImage:faceImage forState:UIControlStateNormal];
    
    self.leftButton = [[UIBarButtonItem alloc] initWithCustomView:face];
}

- (void)setupRightView {
    self.rightView = nil;
}

- (void)setupLeftView {
    NSLog(@"default setupLeftView");
    ABKFeedViewControllerNavigationContext *genericFeed = [[ABKFeedViewControllerNavigationContext alloc] init];
    PFConfig *config = [PFConfig currentConfig];
    genericFeed.navigationItem.title = config[@"NEWSFEED_TITLE"];
    
    self.leftView = genericFeed;
}

- (void)registerGestures:(UIViewController *)controller {
    UISwipeGestureRecognizer *gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleRightView:)];
    gestureRight.direction = UISwipeGestureRecognizerDirectionLeft;
    
    controller.view.userInteractionEnabled = YES;
    controller.view.exclusiveTouch = NO;
    
    [controller.view addGestureRecognizer:gestureRight];
    [self.gesturesRight addObject:gestureRight];
    
    UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLeftView:)];
    gestureLeft.direction = UISwipeGestureRecognizerDirectionRight;
    
    controller.view.userInteractionEnabled = YES;
    controller.view.exclusiveTouch = NO;
    
    [controller.view addGestureRecognizer:gestureLeft];
    [self.gesturesLeft addObject:gestureLeft];
}

- (void)toggleRightView:(UIGestureRecognizer *)gesture {
    if(self.rightView == nil)
        return;
    
    if(state == SLIDEOUT_DEFAULT) {
        UIView *visibleView = [gesture view];
        
        [visibleView addSubview:self.rightView.view];
        [self.rightView.view setFrame:CGRectMake(SCREEN_WIDTH - offset - 1, 0, SCREEN_WIDTH - offset, SCREENHEIGHT)];
        [visibleView bringSubviewToFront:self.rightView.view];
        
        [UIView animateWithDuration:.2 animations:^{
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)toggleLeftView:(UIGestureRecognizer *)gesture {
    if(self.leftView == nil)
        return;
    
    if(state == SLIDEOUT_DEFAULT) {
        UIViewController *visibleView = self.delegate.navigationController;
        
        [visibleView addChildViewController:self.leftView];
        [visibleView.view addSubview:self.leftView.view];
        [self.leftView didMoveToParentViewController:visibleView];
        
        [self.leftView.view setFrame:CGRectMake(SCREEN_WIDTH - 1, 0, SCREEN_WIDTH - offset, SCREENHEIGHT)];
        [visibleView.view bringSubviewToFront:self.leftView.view];
        
        [UIView animateWithDuration:.2 animations:^{
            [self.leftView.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH - offset, SCREENHEIGHT)];
            [visibleView.view setFrame:CGRectMake(SCREEN_WIDTH - offset - 1, 0, SCREEN_WIDTH, SCREENHEIGHT)];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)addShadows {
    if(self.leftView != nil) {
        CAGradientLayer *shadowLeft = [CAGradientLayer layer];
        shadowLeft.frame = CGRectMake(-10, 0, 10, HEIGHT(self.leftView.view));
        shadowLeft.startPoint = CGPointMake(1.0, 0.5);
        shadowLeft.endPoint = CGPointMake(0, 0.5);
        shadowLeft.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.4f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        [self.leftView.view.layer addSublayer:shadowLeft];
    }
    
    if(self.rightView != nil) {
        CAGradientLayer *shadowRight = [CAGradientLayer layer];
        shadowRight.frame = CGRectMake(SCREENWIDTH, 0, 10, HEIGHT(self.leftView.view));
        shadowRight.startPoint = CGPointMake(1.0, 0.5);
        shadowRight.endPoint = CGPointMake(0, 0.5);
        shadowRight.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.4f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        [self.rightView.view.layer addSublayer:shadowRight];
    }
}

@end
