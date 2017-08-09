//
//  Grapes.m
//  unWine
//
//  Created by Bryce Boesen on 7/26/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Grapes.h"
#import "LeaderboardTVC.h"
#import <Parse/Parse.h>
#import "PurchasesTVC.h"

@interface Grapes ()<PFSubclassing>

@end

@interface TransactionObject : NSObject

@property (nonatomic)           NSInteger amount;
@property (nonatomic, strong)   NSString *reason;

+ (TransactionObject *)amount:(NSInteger)amount reason:(NSString *)reason;

@end

static BOOL enabled = NO;

@implementation Grapes
@dynamic reason, grapes, user;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Grapes";
}

+ (NSString *)asString:(NSInteger)grapes {
    if(grapes >= 10000 && grapes < 100000)
        return [NSString stringWithFormat:@"%.1fK", (double)(grapes / 1000.0f)];
    if(grapes >= 100000 && grapes < 1000000)
        return [NSString stringWithFormat:@"%.0fK", (double)(grapes / 100000.0f)];
    else if(grapes >= 1000000)
        return [NSString stringWithFormat:@"%.1fM", (double)(grapes / 1000000.0f)];
    
    return [NSString stringWithFormat:@"%li", (long)grapes];
}

static BOOL isSaving = NO;
+ (void)userAddTransaction:(Grapes *)transaction {
    User *curr = [User currentUser];
    
    isSaving = YES;
    [transaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            PFRelation *currGrapes = [curr relationForKey:@"grapes"];
            [currGrapes addObject:transaction];
            
            NSInteger transVal = [transaction[@"grapes"] integerValue];
            curr[@"currency"] = @([curr[@"currency"] integerValue] + transVal);
            if(transVal > 0)
                curr[@"currencyTotal"] = @([curr[@"currencyTotal"] integerValue] + transVal);
            
            [curr saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                isSaving = NO;
            }];
        }
    }];
}

+ (void)showLeaderboards:(UINavigationController *)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Leaderboards" bundle:nil];
    
    UINavigationController *lbd = [storyboard instantiateViewControllerWithIdentifier:@"Leaderboards"];
    
    //LeaderboardTVC *leaderboard = [lbd.viewControllers objectAtIndex:0];
    
    [controller presentViewController:lbd animated:YES completion:nil];
}

+ (void)showPurchases:(UINavigationController *)controller {
    PurchasesTVC *purchases = [[PurchasesTVC alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:purchases];
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Purchase" bundle:nil];
    //UINavigationController *nav = [storyboard instantiateInitialViewController];
    
    [controller presentViewController:nav animated:YES completion:nil];
}

+ (NSMutableArray *)queue {
    static NSMutableArray * _queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _queue = [[NSMutableArray alloc] init];
    });
    
    return _queue;
}

+ (void)queueTransaction:(NSInteger)amount reason:(NSString *)reason {
    //[[self queue] addObject:[TransactionObject amount:amount reason:reason]];
    
    Grapes *test = [Grapes object];
    test[@"grapes"] = @(amount);
    test[@"reason"] = reason;
    [test pinInBackground];
}

+ (void)executeQueue:(UIViewController<GrapesViewDelegate> *)delegate {
    /*if([self queue] && [[self queue] count] > 0) {
        NSArray *queue = [[self queue] copy];
        [[self queue] removeAllObjects];
        
        for(TransactionObject *object in queue) {
            [Grapes addCurrency:object.amount reason:object.reason source:delegate];
        }
    }*/
    if(!enabled)
        return;
    
    PFQuery *query = [Grapes query];
    [query fromLocalDatastore];
    [[query findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        for(Grapes *object in task.result) {
            [Grapes addCurrency:object.grapes reason:object.reason source:delegate];
            [object unpinInBackground];
        }
        
        return nil;
    }];
}

+ (void)addCurrency:(NSInteger)amount reason:(NSString *)reason source:(UIViewController<GrapesViewDelegate> *)delegate {
    
    PFConfig *config = [PFConfig currentConfig];
    
    if (config[@"GRAPES_MULTIPLIER"] && [config[@"GRAPES_MULTIPLIER"] integerValue] > 0) {
        if(amount > 0)
            amount = amount * [config[@"GRAPES_MULTIPLIER"] integerValue];
    }
    
    Grapes *test = [Grapes object];
    test[@"user"] = [User currentUser];
    test[@"grapes"] = @(amount);
    test[@"reason"] = reason;
    [Grapes userAddTransaction:test];
    [Grapes showAnimateView:delegate amount:amount];
    
    [Analytics trackUserWasAwardedGrapes:amount forReason:reason];
    
    /*UIBarButtonItem *grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
    grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:delegate];
    delegate.navigationItem.rightBarButtonItem = grapesButton;*/
}

+ (void)userUpdateCurrency:(void(^)(NSInteger))callback {
    User *curr = [User currentUser];
    
    PFRelation *currGrapes = [curr relationForKey:@"grapes"];
    PFQuery *query = [currGrapes query];
    
    if(!isSaving) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                NSInteger grapes = 0;
                for(Grapes *object in objects) {
                    grapes += [object[@"grapes"] integerValue];
                }
                
                curr[@"currency"] = @(grapes);
                if(curr[@"currencyTotal"] == nil || [curr[@"currencyTotal"] integerValue] < grapes)
                    curr[@"currencyTotal"] = @(grapes);
                [curr saveInBackground];
                
                callback(grapes);
            } else
                callback([curr[@"currency"] integerValue]);
        }];
    } else {
        callback([curr[@"currency"] integerValue]);
    }
}

+ (void)showAnimateView:(UIViewController<GrapesViewDelegate> *)delegate amount:(NSInteger)amount {
    UINavigationController *navigationController = delegate.navigationController;
    NSInteger displayAmount = isSaving ? [User currentUser].currency + amount : [User currentUser].currency;
    
    CGRect start1 = CGRectMake(SCREEN_WIDTH - GRAPES_VIEW_WIDTH + 32, 26, GRAPES_VIEW_WIDTH, 32);
    CGRect start2 = CGRectMake(SCREEN_WIDTH - GRAPES_VIEW_WIDTH + 32, SCREENHEIGHT / 3, GRAPES_VIEW_WIDTH, 32);
    
    UIView *view = [[UIView alloc] initWithFrame:(amount < 0) ? start1 : start2];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *change = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GRAPES_VIEW_WIDTH, 32)];
    change.backgroundColor = [UIColor clearColor];
    change.clipsToBounds = YES;
    change.textAlignment = NSTextAlignmentLeft;
    [change setFont:[UIFont fontWithName:@"OpenSans-Bold" size:20]];
    if(amount > 0)
        [change setText:[NSString stringWithFormat:@"+%@", [Grapes asString:amount]]];
    else
        [change setText:[NSString stringWithFormat:@"%@", [Grapes asString:amount]]];
    [change setShadowColor:[UIColor whiteColor]];
    [change setShadowOffset:CGSizeMake(1, 1)];
    [view addSubview:change];
    
    [navigationController.view insertSubview:view aboveSubview:navigationController.view];
    
    [UIView animateWithDuration:1.25 animations:^{
        [view setFrame:(amount > 0) ? start1 : start2];
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [delegate navigationItem].rightBarButtonItem.customView = [Grapes getCustomView:displayAmount delegate:delegate];
    }];
}

+ (UIView *)getCustomView:(NSInteger)grapes delegate:(UIViewController<GrapesViewDelegate> *)delegate {
    UIView *holdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GRAPES_VIEW_WIDTH, 44)];
    holdView.bounds = CGRectOffset(holdView.bounds, -30, 0);
    if(!enabled)
        return holdView;
    
    //return holdView;
    //holdView.clipsToBounds = YES;
    
    //Grapes on UINavigationController

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 6, GRAPES_VIEW_WIDTH, 32)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = [[UIColor clearColor] CGColor];
    view.layer.borderWidth = .5f;
    view.layer.cornerRadius = 10;
    view.userInteractionEnabled = YES;
    view.exclusiveTouch = YES;
    
    if(delegate != nil) {
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(showPurchases)];
        [view addGestureRecognizer:gesture];
    }
    
    UIImageView *grapeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 3, 32, HEIGHT(view) - 6)];
    UIImage *grapeImage = [Grapes getGrapeImage];
    [grapeImageView setImage:grapeImage];
    [grapeImageView setContentMode:UIViewContentModeScaleAspectFit];
    grapeImageView.userInteractionEnabled = NO;
    
    UILabel *grapeLabel = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, 64, HEIGHT(view))];
    [grapeLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
    [grapeLabel setTextColor:[UIColor blackColor]];
    [grapeLabel setText:(grapes == -1 ? @"?" : [Grapes asString:grapes])];
    [grapeLabel setTextAlignment:NSTextAlignmentLeft];
    //grapeLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    //grapeLabel.contentEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    //[grapeLabel addTarget:delegate action:@selector(showPurchases) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:grapeImageView];
    [view addSubview:grapeLabel];
    
    [holdView addSubview:view];
    
    return holdView;
}

+ (UIImage *)getGrapeImage {
    return [UIImage imageNamed:@"grapeIconRed"];
}

@end

@implementation TransactionObject

+ (TransactionObject *)amount:(NSInteger)amount reason:(NSString *)reason {
    TransactionObject *obj = [[TransactionObject alloc] init];
    obj.amount = amount;
    obj.reason = reason;
    return obj;
}

@end