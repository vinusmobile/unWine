//
//  WineryCell.m
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineryCell.h"
#import "WineryContainerVC.h"

#define WINERY_CELL_BUFFER 4
#define WINERY_CELL_HEIGHT 60

@import MapKit;
@import CoreLocation;

@interface WineryCell ()

@property (nonatomic) PFImageView *wineryView;
@property (nonatomic) UILabel *wineryLabel;
@property (nonatomic) UILabel *winerySublabel;
@property (nonatomic) UIButton *defaultAccessory;

@end

@implementation WineryCell
@synthesize singleTheme;

static NSInteger buffer = WINERY_CELL_BUFFER;
static NSInteger height = WINERY_CELL_HEIGHT;
static NSInteger dim = WINERY_CELL_HEIGHT - WINERY_CELL_BUFFER * 2;
static NSInteger bufferX = 12;

- (void)setDelegate:(UIViewController<WineryCellDelegate> *)delegate {
    _delegate = delegate;
    
    self.singleTheme = unWineThemeDark;
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.backgroundColor = [ThemeHandler getCellPrimaryColor:singleTheme];
    if(!self.hasSetup) {
        self.hasSetup = YES;
        
        _wineryView = [[PFImageView alloc] initWithFrame:(CGRect){buffer, buffer, {dim, dim}}];
        _wineryView.layer.cornerRadius = 6;
        [_wineryView setContentMode:UIViewContentModeScaleAspectFill];
        _wineryView.clipsToBounds = YES;
        [self.contentView addSubview:_wineryView];
        
        _wineryLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, {0, 32}}];
        [_wineryLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [_wineryLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _wineryLabel.clipsToBounds = YES;
        [self.contentView addSubview:_wineryLabel];
        
        /*_wineSublabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, {0, 20}}];
        [_wineSublabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        [_wineSublabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _wineSublabel.clipsToBounds = YES;
        [self.contentView addSubview:_wineSublabel];*/
        
        UITapGestureRecognizer *press = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interact:)];
        [self addGestureRecognizer:press];
    }
}

- (void)configure:(Winery *)winery {
    [self configure:winery mode:self.mode];
}

- (void)configure:(Winery *)winery mode:(WineryCellMode)mode {
    self.winery = winery;
    self.mode = mode;
    
    [winery setWineryImageForImageView:_wineryView];
    [_wineryLabel setText:[winery getWineryName]];
    [self adjustLabel];
    
    if([self hasAccessoryForCurrentMode] && ![self getAccessoryForCurrentMode].superview)
        [self.contentView addSubview:[self getAccessoryForCurrentMode]];
    else if(![self hasAccessoryForCurrentMode] && _defaultAccessory.superview)
        [_defaultAccessory removeFromSuperview];
}

- (void)adjustLabel {
    NSInteger startX = X2(_wineryView) + WIDTH(_wineryView) + bufferX;
    NSInteger width = [self hasAccessoryForCurrentMode] ? SCREEN_WIDTH - startX - WINERY_CELL_HEIGHT - bufferX : SCREEN_WIDTH - startX - bufferX;
    [_wineryLabel setFrame:CGRectMake(startX, 0, width, height)];
}

#pragma Accessory Stuff

- (BOOL)hasAccessoryForCurrentMode {
    return [self getAccessoryForCurrentMode] != nil;
}

- (UIView *)getAccessoryForCurrentMode {
    if(!_defaultAccessory) {
        NSInteger aBuffer = 12;
        NSInteger size = WINERY_CELL_HEIGHT;
        _defaultAccessory = [[UIButton alloc] initWithFrame:(CGRect){SCREEN_WIDTH - (size - aBuffer * 2) - 6, aBuffer, {size - aBuffer * 2, size - aBuffer * 2}}];
        [_defaultAccessory setImage:[UIImage imageNamed:@"moreDetailIcon"] forState:UIControlStateNormal];
        [_defaultAccessory.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_defaultAccessory addTarget:self action:@selector(interactMore) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _defaultAccessory;
}

#pragma Actions

- (void)interact:(UIGestureRecognizer *)gesture {
    WineryContainerVC *container = [[WineryContainerVC alloc] init];
    container.winery = self.winery;
    
    if(self.delegate) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_WINERY_NEARBY_ON_WINERY_SEARCH_VIEW);
        [self.delegate presentViewControllerFromCell:container];
    }
}

static NSString *actionViewMaps = @"Open in Maps";
static NSString *actionFollow = @"Follow Winery";
static NSString *actionUnfollow = @"Unfollow Winery";
static NSString *actionRecommend = @"Recommend Winery";
static NSString *actionShareIt = @"Share";

- (void)interactMore {
    //User *user = [User currentUser];
    //BOOL following = [user isFollowingWinery:self.winery];
    //NSArray *titles = following ? @[actionUnfollow, actionRecommend] : @[actionFollow, actionRecommend];
    
    NSArray *titles = [self.winery hasLocation] ? @[actionViewMaps, actionRecommend] : @[actionRecommend];
    
    unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:[self.winery getWineryName]
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:titles];
    [sheet showFromTabBar:[self.delegate wineMorePresentationView]];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionFollow]) {
        User *user = [User currentUser];
        [user followWinery:self.winery];
        [user saveInBackground];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionUnfollow]) {
        User *user = [User currentUser];
        [user unfollowWinery:self.winery];
        [user saveInBackground];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionViewMaps]) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.winery.location.latitude, self.winery.location.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[self.winery.name capitalizedString]];
        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        [mapItem openInMapsWithLaunchOptions:options];
        ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_WINERY_MAP_FROM_WINERY_SEARCH_VIEW);
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionRecommend]) {
        [self recommendIt];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionShareIt]) {
        [self shareIt:actionSheet];
    }
}

- (void)recommendIt {
    if(self.delegate && [self.delegate respondsToSelector:@selector(showHUD)])
        [self.delegate showHUD];
    
    [[[User currentUser] getFriends] continueWithBlock:^id(BFTask *task) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(hideHUD)])
            [self.delegate hideHUD];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL shouldAddShare = YES;
            NSMutableArray *content = [ScrollElementView scrollElementsFrom:task.result];
            
            if([content count] == 0) {
                shouldAddShare = NO;
            } else if([content count] > 1) {
                [content insertObject:[ScrollElementView makeElementFromObject:[ScrollElement selectAll]] atIndex:0];
            }
            
            [content addObject:[ScrollElementView makeElementFromObject:[ScrollElement inviteFriends]]];
            
            unWineActionSheet *actionSheet = [[unWineActionSheet alloc]
                                              initWithTitle:@"Recommend Winery"
                                              delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              customContent:content];
            
            if(shouldAddShare)
                actionSheet.otherButtonTitles = @[actionShareIt];
            
            [actionSheet showFromTabBar:[self.delegate wineMorePresentationView]];
        });
        return nil;
    }];
}
- (void)shareIt:(unWineActionSheet *)actionSheet {
    NSMutableArray *content = [actionSheet getSelectedElements];
    NSMutableArray *group = [[NSMutableArray alloc] init];
    if(content != nil) {
        for(ScrollElementView *element in content)
            if([element.object isKindOfClass:[User class]])
                [group addObject:(User *)element.object]; //Get user objects from selected elements
        
        if([group count] > 0) {
            NSString *pushMessage = [NSString stringWithFormat:@"%@ recommended a winery to you!", [[User currentUser] getName]];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(showHUD)])
                [self.delegate showHUD];
            
            if (self.source == WineryCellSourceWineryView) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_RECOMMENDED_WINERY_FROM_WINERY_VIEW);
            } else if (self.source == WineryCellSourceWinerySearchView) {
                ANALYTICS_TRACK_EVENT(EVENT_USER_RECOMMENDED_WINERY_FROM_WINERY_SEARCH_VIEW);
            }
            
            [[[Push sendPushNotification:NotificationTypeRecommendations toGroup:[BFTask taskWithResult:[group copy]] withMessage:pushMessage withURL:[NSString stringWithFormat:@"unwineapp://winery/%@", self.winery.objectId]] continueWithBlock:^id(BFTask *task) {
                
                if(task.error) {
                    if(self.delegate && [self.delegate respondsToSelector:@selector(hideHUD)])
                        [self.delegate hideHUD];
                    
                    [unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
                    return nil;
                }
                
                LOGGER(task.result);
                NSArray *childTasks = task.result;
                
                NSMutableArray *notificationObjectTasks = [[NSMutableArray alloc] init];
                
                for(id child in childTasks) {
                    if(child && [child isKindOfClass:[User class]]) {
                        NSLog(@"adding notification %@", [(User *)child objectId]);
                        
                        [notificationObjectTasks addObject:[Notification createRecommendationObjectForWinery:self.winery andUser:(User *)child]];
                    }
                }
                
                return [[BFTask taskForCompletionOfAllTasks:notificationObjectTasks] continueWithBlock:^id(BFTask *task) {
                    return [BFTask taskWithResult:@([notificationObjectTasks count])];
                }];
            }] continueWithBlock:^id(BFTask *task) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(hideHUD)])
                    [self.delegate hideHUD];
                
                NSInteger sent = [task.result integerValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [unWineAlertView showAlertViewWithTitle:@"Winery Shared"
                                                    message:@"Spreading your wine influence never felt better."
                                          cancelButtonTitle:@"Keep unWineing"
                                                      theme:unWineAlertThemeSuccess];
                });
                
                NSLog(@"actually sent %lu of %lu", (long)sent, (unsigned long)[group count]);
                
                return nil;
            }];
        } else {
            actionSheet.shouldDismiss = NO;
            //[unWineAlertView showAlertViewWithTitle:@"Recommendation" message:[NSString stringWithFormat:@"Looks like you didn't select any friends"] theme:unWineAlertThemeRed];
        }
    }
}

#pragma Delegate Methods

+ (NSInteger)getDefaultHeight {
    return height;
}

- (UIView *)getPresentationView {
    return self.delegate.navigationController.view;
}

- (void)updateTheme {
    
}

- (UIViewController *)actionSheetPresentationViewController {
    return self.delegate;
}
    
@end
