//
//  PurchaseCell.m
//  unWine
//
//  Created by Bryce Boesen on 10/17/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "PurchaseCell.h"
#import "MBProgressHUD.h"
#import "SlackHelper.h"

@interface PurchaseCell () <MBProgressHUDDelegate>

@end

@implementation PurchaseCell {
    UIView *purchaseView;
    MBProgressHUD *_activityView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        NSInteger buffer = 10;
        NSInteger dim = [self getHeight] - buffer * 2;
        self.iconImageView = [[PFImageView alloc] initWithFrame:CGRectMake(buffer, buffer, dim, dim)];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.iconImageView];
        
        NSInteger x = WIDTH(self.iconImageView) + X2(self.iconImageView) + buffer;
        NSInteger lHeight = 30;
        NSInteger lBuffer = ([self getHeight] - lHeight) / 2;
        self.purchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, lBuffer, 200, lHeight)];
        //self.purchaseLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //self.purchaseLabel.shadowColor = [UIColor whiteColor];
        [self.purchaseLabel setTextAlignment:NSTextAlignmentLeft];
        [self.purchaseLabel setTextColor:[UIColor whiteColor]];
        [self.purchaseLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [self addSubview:self.purchaseLabel];
    }
}

- (CGFloat)getHeight {
    return [self.delegate tableView:self.delegate.tableView heightForRowAtIndexPath:self.indexPath];
}

- (void)configure:(PFProduct *)object {
    self.object = object;
    
    self.iconImageView.file = self.object[@"icon"];
    [self.iconImageView loadInBackground];
    
    [self.purchaseLabel setText:self.object[@"title"]];
    
    User *user = [User currentUser];
    if(!user.hasPhotoFilters) {
        if([self.delegate priceForProduct:self.object] != nil) {
            [self cleanup];
            
            purchaseView = [self purchaseView];
            [self addSubview:purchaseView];
        } else {
            [self cleanup];
            
            purchaseView = [self loadView];
            [self addSubview:purchaseView];
        }
    } else {
        [self cleanup];
        
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (NSString *)getProductIdentifier {
    return self.object.productIdentifier;
}

- (void)reconfigure {
    [self configure:self.object];
}

- (void)cleanup {
    if(_activityView) {
        [_activityView removeFromSuperview];
        _activityView = nil;
        //[_activityView hide:YES];
    }
    if(purchaseView) {
        [purchaseView removeFromSuperview];
        purchaseView = nil;
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    //[_activityView removeFromSuperview];
    //_activityView = nil;
}

- (UIView *)loadView {
    UIView *view = [UIView new];
    
    if(view) {
        NSInteger buffer = 12;
        NSInteger width = 100;
        [view setFrame:CGRectMake(WIDTH(self.delegate.tableView) - width - buffer * 3 / 4, buffer, width, [self getHeight] - buffer * 2)];
        
        view.layer.cornerRadius = 12;
        view.clipsToBounds = YES;
        view.backgroundColor = UNWINE_RED_LIGHT;
        view.userInteractionEnabled = NO;
        
        if(_activityView) {
            [_activityView removeFromSuperview];
            _activityView = nil;
        }
        
        _activityView = [[MBProgressHUD alloc] initWithView:view];
        _activityView.color = [UIColor clearColor];
        _activityView.activityIndicatorColor = [UIColor whiteColor];
        [view addSubview:_activityView];
        
        _activityView.delegate = self;
        [_activityView show:YES];
    }
    
    return view;
}

- (UIView *)purchaseView {
    UIView *view = [UIView new];
    
    if(view) {
        NSInteger buffer = 12;
        NSInteger width = 100;
        [view setFrame:CGRectMake(WIDTH(self.delegate.tableView) - width - buffer * 3 / 4, buffer, width, [self getHeight] - buffer * 2)];
        //NSLog(@"purchaseView - %@", NSStringFromCGRect(view.frame));
        
        view.layer.cornerRadius = 12;
        view.clipsToBounds = YES;
        view.backgroundColor = UNWINE_RED_LIGHT;
        view.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(attemptPurchase)];
        [view addGestureRecognizer:gesture];
        
        NSInteger lHeight = 22;
        UIButton *grapeLabel = [[UIButton alloc] initWithFrame:CGRectMake(0, buffer / 3, width, lHeight)];
        [grapeLabel setTitle:[NSString stringWithFormat:@"%@", self.object[@"grapes"]] forState:UIControlStateNormal];
        [[grapeLabel imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [grapeLabel setImage:[UIImage imageNamed:@"grapeIconWhite"] forState:UIControlStateNormal];
        [grapeLabel setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [grapeLabel setTitleEdgeInsets:UIEdgeInsetsMake(0, -32, 0, 0)];
        [grapeLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [grapeLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12]];
        [grapeLabel.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [grapeLabel addTarget:self action:@selector(attemptPurchase) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:grapeLabel];
        
        UIButton *priceLabel = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT(view) - lHeight - buffer / 3, width, lHeight)];
        [priceLabel setTitle:[NSString stringWithFormat:@"%@", [self.delegate priceForProduct:self.object]] forState:UIControlStateNormal];
        [priceLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [priceLabel.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12]];
        [priceLabel addTarget:self action:@selector(attemptPurchase) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:priceLabel];
        
        CALayer *line = [CALayer layer];
        line.borderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.6].CGColor;
        line.borderWidth = .5;
        line.frame = CGRectMake(30, SEMIHEIGHT(view), width - 40, .5);
        [view.layer addSublayer:line];
        
        UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(buffer / 2, SEMIHEIGHT(view) - lHeight / 2 - 2, lHeight, lHeight)];
        [orLabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        [orLabel setText:@" or "];
        [orLabel setTextAlignment:NSTextAlignmentCenter];
        [orLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:orLabel];
    }
    
    return view;
}

- (void)attemptPurchase {
    User *user = [User currentUser];
    if([user isAnonymous]) {
        [self.delegate dismissAsGuest];
    } else {
        unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Unlock all of the Photo Filters!"];
        alert.delegate = self;
        alert.theme = unWineAlertThemeGray;
        alert.emptySpaceDismisses = YES;
        alert.leftButtonTitle = [NSString stringWithFormat:@"%@ Grapes", self.object[@"grapes"]];
        alert.rightButtonTitle = [NSString stringWithFormat:@"%@", [self.delegate priceForProduct:self.object]];
        [alert shouldShowLogo:YES];
        [alert shouldShowOrLabel:YES];
        [alert show];
        ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_OPENED_IN_APP_PURCHASE_ALERT_VIEW);
    }
}

- (void)dismissedByEmptySpace {
    ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_DISMISSED_IN_APP_PURCHASE_ALERT_VIEW);
}

- (void)leftButtonPressed {
    LOGGER(@"use those grapes");

    User *user = [User currentUser];
    NSInteger amount = [self.object[@"grapes"] integerValue];
    if(user.currency >= amount) {
        [Grapes addCurrency:amount * -1 reason:@"boughtPhotoFilters" source:self.delegate];
        
        [SlackHelper notifyPhotoFiltersPurchased:[User currentUser] withMoney:NO];
        [self applyPurchaseAndReload:user];
    } else {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_DOES_NOT_HAVE_ENOUGH_GRAPES);
            [unWineAlertView showAlertViewWithTitle:@"Grape deficiency" message:@"Contribute to unWine's database to earn grapes!"];
        });
    }
}

- (void)applyPurchaseAndReload:(User *)user {
    user.hasPhotoFilters = YES;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_PURCHASED_FILTER_VIA_GRAPES);
                [self reconfigure];
            });
        }
    }];
}

- (void)rightButtonPressed {
    LOGGER(@"use those monies");
    
    SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
    [PFPurchase buyProduct:self.object.productIdentifier block:^(NSError *error) {
        HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
        if (error) {
            NSString *title = NSLocalizedString(@"Purchase Error", @"Purchase Error");
            NSLog(@"%@ - %@", title, error);
            
            if (error.code == SKErrorPaymentCancelled) {
                NSLog(@"The error");
                ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_CANCELLED_IN_APP_PURCHASE_VIA_APPLE);
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_FILTERS_ERROR_PURCHASING_IN_APP_PURCHASE_VIA_APPLE);
            }
            
            [unWineAlertView showAlertViewWithTitle:title error:error];
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_PURCHASED_FILTER_VIA_APPLE);
        }
    }];
}

@end
