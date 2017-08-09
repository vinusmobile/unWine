//
//  WineCell.m
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "WineCell.h"
#import "CheckinInterface.h"
#import "CastDetailTVC.h"
#import "CastCheckinTVC.h"
#import "CRToast.h"

#define WINE_CELL_BUFFER 4
#define WINE_CELL_BASE_EXTENSION 20

@interface WineCell ()

@property (nonatomic) PFImageView *wineView;
@property (nonatomic) UILabel *wineLabel;
@property (nonatomic) UILabel *wineSublabel;
@property (nonatomic) UIButton *defaultAccessory;

@end

@implementation WineCell {
    UITapGestureRecognizer *press;
    UILongPressGestureRecognizer *longPress;
    UIView *animateView;
    CALayer *border;
    BOOL inspecting;
}
@synthesize singleTheme;

static NSInteger buffer = WINE_CELL_BUFFER;
static NSInteger dim = WINE_CELL_HEIGHT - WINE_CELL_BUFFER * 2;
static NSInteger baseLabelHeight = 32;
static NSInteger offset = 4;

- (void)setDelegate:(UIViewController<WineCellDelegate> *)delegate {
    _delegate = delegate;
    self.singleTheme = unWineThemeDark;
}

- (void)setup:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.backgroundColor = [ThemeHandler getCellPrimaryColor:singleTheme];
    if(!_hasSetup) {
        _hasSetup = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _wineView = [[PFImageView alloc] initWithFrame:(CGRect){buffer, buffer, {dim, dim}}];
        _wineView.layer.cornerRadius = 6;
        [_wineView setContentMode:UIViewContentModeScaleAspectFill];
        _wineView.clipsToBounds = YES;
        [self.contentView addSubview:_wineView];
        
        _wineLabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, {0, 32}}];
        [_wineLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [_wineLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _wineLabel.clipsToBounds = YES;
        [self.contentView addSubview:_wineLabel];
        
        _wineSublabel = [[UILabel alloc] initWithFrame:(CGRect){0, 0, {0, 20}}];
        [_wineSublabel setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        [_wineSublabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        _wineSublabel.clipsToBounds = YES;
        [self.contentView addSubview:_wineSublabel];
        
        press = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interact:)];
        
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(interact:)];
        longPress.minimumPressDuration = .5;
        [press requireGestureRecognizerToFail:longPress];
        
        [self addGestureRecognizer:press];
        [self addGestureRecognizer:longPress];
        
        border = [CALayer layer];
        border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
        border.frame = CGRectZero;
        [self.contentView.layer addSublayer:border];
    
    } else {
        [_wineLabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
        [_wineSublabel setTextColor:[ThemeHandler getForegroundColor:singleTheme]];
    }
}

- (void)adjustLabels {
    [self adjustLabels:-1];
}

- (void)adjustLabels:(NSInteger)preHeight {
    BOOL hasSublabel = [self hasSublabel];
    [self configureSublabel];
    BOOL extended = self.assumeExtended || (self.delegate && self.delegate.extendedPath == self.indexPath);
    
    NSInteger x = dim + buffer * 2;
    NSInteger width = SCREEN_WIDTH - x - ([self hasAccessoryForCurrentMode] ? WINE_CELL_HEIGHT - 12 : 0);
    NSInteger height, shiftHeight;
    if(extended) {
        height = preHeight == -1 ? [WineCell getExtendedHeight:self.wine mode:self.mode] : preHeight;
        shiftHeight = height - (self.mode != WineCellModeCheckin && self.mode != WineCellModeVinecast ? WINE_CELL_BASE_EXTENSION : 0);
        _wineLabel.lineBreakMode = NSLineBreakByWordWrapping;
    } else {
        shiftHeight = height = WINE_CELL_HEIGHT;
        _wineLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    if(hasSublabel) {
        _wineLabel.numberOfLines = extended ? 0 : 1;
        [_wineLabel setFrame:(CGRect){x, 0, {width, baseLabelHeight * 4}}];
        [_wineLabel sizeToFit];
        
        _wineSublabel.numberOfLines = 1;
        [_wineSublabel setFrame:(CGRect){x, 0, {width, baseLabelHeight * 4}}];
        [_wineSublabel sizeToFit];
        
        NSInteger y = (shiftHeight - (HEIGHT(_wineLabel) + offset + HEIGHT(_wineSublabel))) / 2;
        [_wineLabel setFrame:(CGRect){x, y + offset / 2, {width, HEIGHT(_wineLabel)}}];
        [_wineSublabel setFrame:(CGRect){x, Y2(_wineLabel) + HEIGHT(_wineLabel) + offset / 2, {width, HEIGHT(_wineSublabel)}}];
        [_wineSublabel setAlpha:1];
    } else {
        _wineLabel.numberOfLines = extended ? 0 : 1;
        [_wineLabel setFrame:(CGRect){x, 0, {width, baseLabelHeight * 4}}];
        [_wineLabel sizeToFit];
        
        NSInteger y = (shiftHeight - HEIGHT(_wineLabel)) / 2;
        [_wineLabel setFrame:(CGRect){x, y, {width, HEIGHT(_wineLabel)}}];
        [_wineSublabel setAlpha:0];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if(self.mode == WineCellModeVinecast)
        [border setFrame:CGRectMake(20, shiftHeight - 1, SCREEN_WIDTH - 40, .5)];
    else
        [border setFrame:CGRectZero];
    [CATransaction commit];
}

- (void)setSubtitleMode:(WineCellSubtitleMode)subtitleMode {
    _subtitleMode = subtitleMode;
    
    [self adjustLabels];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _subtitleMode = WineCellSubtitleModeCustom;
    
    [self adjustLabels];
}

- (BOOL)hasAccessoryForCurrentMode {
    return [self getAccessoryForCurrentMode] != nil;
}

- (UIView *)getAccessoryForCurrentMode {
    if(!_defaultAccessory) {
        NSInteger aBuffer = 12;
        NSInteger size = WINE_CELL_HEIGHT;
        _defaultAccessory = [[UIButton alloc] initWithFrame:(CGRect){SCREEN_WIDTH - (size - aBuffer * 2) - 6, aBuffer, {size - aBuffer * 2, size - aBuffer * 2}}];
        [_defaultAccessory setImage:[UIImage imageNamed:@"moreDetailIcon"] forState:UIControlStateNormal];
        [_defaultAccessory.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_defaultAccessory addTarget:self action:@selector(interactMore) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self.mode == WineCellModeCheckin || self.mode == WineCellModeVinecast ? nil : _defaultAccessory;
}

- (BOOL)hasSublabel {
    if(self.subtitleMode == WineCellSubtitleModeWinery)
        return ISVALID([self.wine getVineYardName]);
    else if(self.subtitleMode == WineCellSubtitleModeRegion)
        return ISVALID(self.wine.region);
    else if(self.subtitleMode == WineCellSubtitleModeCustom)
        return ISVALID(self.subtitle);
    
    return NO;
}

- (void)configureSublabel {
    if([self hasSublabel]) {
        if(self.subtitleMode == WineCellSubtitleModeWinery)
            [_wineSublabel setText:[self.wine getVineYardName]];
        else if(self.subtitleMode == WineCellSubtitleModeRegion)
            [_wineSublabel setText:[self.wine.region capitalizedString]];
        else if(self.subtitleMode == WineCellSubtitleModeCustom)
            [_wineSublabel setText:self.subtitle];
        else
            [_wineSublabel setText:@""];
    } else
        [_wineSublabel setText:@""];
}

- (void)configureWithObjectId:(NSString *)objectId mode:(WineCellMode)mode {
    [_wineView setImage:nil];
    [_wineLabel setText:@""];
    [_wineSublabel setText:@""];
    
    BFTask *task = [unWine getWineObjectTask:objectId];
    [task continueWithBlock:^id(BFTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configure:(unWine *)task.result mode:mode];
        });
        
        return nil;
    }];
}

- (void)configure:(unWine *)wine {
    [self configure:wine mode:WineCellModeDefault];
}

- (void)configure:(unWine *)wine mode:(WineCellMode)mode {
    self.wine = wine;
    self.mode = mode;
    
    if(wine.isDataAvailable)
        [wine setWineImageForImageView:_wineView];
    else
        _wineView.image = WINE_PLACEHOLDER;
    [_wineLabel setText:[wine getWineName]];
    [self configureSublabel];
    [self adjustLabels];
    
    if([self hasAccessoryForCurrentMode] && ![self getAccessoryForCurrentMode].superview)
        [self.contentView addSubview:[self getAccessoryForCurrentMode]];
    else if(![self hasAccessoryForCurrentMode] && _defaultAccessory.superview)
        [_defaultAccessory removeFromSuperview];
}

/*!
 * BFTask wrapper for CastCheckinTVC to return after the wine.image is fetched
 */
- (BFTask *)prepareCheckinTVC:(CastCheckinSource)source {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"castCheckIn" bundle:nil];
    __block CastCheckinTVC *checkin = [storyboard instantiateViewControllerWithIdentifier:@"checkin"];
    checkin.wine = self.wine;
    checkin.registers = nil;
    checkin.isNew = NO;
    checkin.cameFrom = source;
    checkin.pushedFromNotification = NO;
    checkin.checkin = [NewsFeed prepareWithWine:self.wine];
    checkin.hudShowView = self.delegate.navigationController.view;
    
    PFFile *file = self.wine.image;
    if(file && ![file isKindOfClass:[NSNull class]]) {
        return [[file getDataInBackground] continueWithBlock:^id(BFTask *task) {
            if(!task.error) {
                checkin.wineImage = [UIImage imageWithData:(NSData *)task.result];
            }
            
            return [BFTask taskWithResult:checkin];
        }];
    } else {
        return [BFTask taskWithResult:checkin];
    }
}

- (void)trackPressByMode {
    NSLog(@"Mode = %i", self.mode);
    switch (self.mode) {
        case WineCellModeRecentCheckin:
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_RECENT_CHECKIN_ON_CHECKIN_TAB);
            break;
        case WineCellModeTopResult:
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_TOP_RESULT_AFTER_SEARCHING_WINE);
            break;
        case WineCellModeResult:
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_WINE_AFTER_SEARCHING_SEARCHING);
            break;
        default:
            break;
    }
    
    if (self.source == WineCellSourceWinery) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_WINE_FROM_WINERY_VIEW);
    }
}

- (void)interact:(UIGestureRecognizer *)gesture {
    if(self.mode == WineCellModeCheckin || self.mode == WineCellModeVinecast) {
        [self inspectIt];
        if(self.mode == WineCellModeCheckin)
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_WINE_CELL_ON_CHECKIN_VIEW);
        return;
    }
    
    if(gesture == press) {
        User *user = [User currentUser];
        if([user isAnonymous]) {
            [self inspectIt];
            //[user promptGuest:self.delegate];
            return;
        }
        
        [self trackPressByMode];
        
        //NSLog(@"pressed wine");
        [[self prepareCheckinTVC:CastCheckinSourceSomewhere] continueWithBlock:^id(BFTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.delegate) {
                    [self.delegate presentViewControllerFromCell:task.result];
                }
            });
            
            return nil;
        }];
    } else if(gesture == longPress) {
        //NSLog(@"long pressed wine");
        if(longPress.state == UIGestureRecognizerStateBegan) {
            NSInteger maxHeight = [WineCell getExtendedHeight:self.wine mode:self.mode];
            if(!animateView) {
                animateView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, maxHeight}}];
                animateView.backgroundColor = [UIColor clearColor];
                animateView.clipsToBounds = YES;
                
                UIView *markView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {0, 4}}];
                markView.backgroundColor = UNWINE_RED;
                [animateView addSubview:markView];
                
                UILabel *expressLabel = [[UILabel alloc] initWithFrame:(CGRect){0, HEIGHT(animateView) - 20,  {SCREEN_WIDTH, 20}}];
                [expressLabel setText:@"Keep holding to checkin instantly!"];
                [expressLabel setTextAlignment:NSTextAlignmentCenter];
                [expressLabel setTextColor:CI_FOREGROUND_COLOR];
                [expressLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:13]];
                [animateView addSubview:expressLabel];
            } else {
                [animateView setFrame:(CGRect){0, 0, {SCREEN_WIDTH, maxHeight}}];
                UILabel *expressLabel = [[animateView subviews] objectAtIndex:1];
                [expressLabel setFrame:(CGRect){0, HEIGHT(animateView) - 20,  {SCREEN_WIDTH, 20}}];
            }
            
            if(self.delegate.extendedPath != nil)
                return;
            UIView *markView = [[animateView subviews] objectAtIndex:0];
            [markView setFrame:(CGRect){0, 0, {0, 4}}];
            
            [self setExtended:YES];
            /*[UIView animateWithDuration:.3 animations:^{
                [animateView setFrame:(CGRect){0, 0, {SCREEN_WIDTH, maxHeight}}];
            }];*/
            
            if(![animateView superview])
                [self.contentView addSubview:animateView];
            
            if([self.delegate respondsToSelector:@selector(resignIfNecessary)])
                [self.delegate resignIfNecessary];
            
            [UIView animateWithDuration:2.5
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
            animations: ^{
                [markView setFrame:(CGRect){0, 0, {SCREEN_WIDTH, 4}}];
            } completion:^(BOOL finished) {
                [animateView removeFromSuperview];
                if(self.delegate.extendedPath != nil)
                    [self setExtended:NO];
                
                if(finished) {
                    [self expressCheckin];
                }
            }];
        } else if(longPress.state == UIGestureRecognizerStateEnded) {
            [self.contentView.layer removeAllAnimations];
            [animateView removeFromSuperview];
            [self setExtended:NO];
        }
    }
}

- (void)setExtended:(BOOL)extended {
    if(extended) {
        self.backgroundColor = CI_SEPERATOR_COLOR;
        self.delegate.extendedPath = self.indexPath;
    } else {
        self.backgroundColor = CI_MIDDGROUND_COLOR;
        self.delegate.extendedPath = nil;
    }
    [self adjustLabels];
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateCells)])
        [self.delegate updateCells];
}

- (void)expressCheckin {
    User *user = [User currentUser];
    if([user isAnonymous]) {
        [user promptGuest:self.delegate];
        return;
    }
    
    SHOW_HUD_FOR_VIEW(self.delegate.navigationController.view);
    [[[self prepareCheckinTVC:CastCheckinSourceExpress] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        CastCheckinTVC *checkin = task.result;
        return [checkin finalCheckin];
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
            HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
            return nil;
        }
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITH_XPRESS_CHECKIN_ON_CHECKIN_TAB);
        
        [CRToastManager showNotificationWithOptions:[CastCheckinTVC options] completionBlock:^{
            HIDE_HUD_FOR_VIEW(self.delegate.navigationController.view);
            //if(self.delegate)
            //    [self.delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            (GET_APP_DELEGATE).checkForMerits = YES;
            
            [[MainVC sharedInstance] dismissPresented:YES];
        }];
        return nil;
    }];
}

static NSString *actionWishListIt = @"Add to Wish List";
static NSString *actionUnWishListIt = @"Remove from Wish List";
static NSString *actionRecommandIt = @"Recommend Wine";
static NSString *actionInspectIt = @"Inspect Wine";
static NSString *actionShareIt = @"Share";

- (void)interactMore {
    if(!self.delegate)
        return;
    
    if([self.delegate respondsToSelector:@selector(showHUD)])
        [self.delegate showHUD];
    
    if([self.delegate respondsToSelector:@selector(resignIfNecessary)])
        [self.delegate resignIfNecessary];
    
    User *user = [User currentUser];
    PFQuery *query = [[user theCellar] query];
    [query whereKey:@"objectId" equalTo:self.wine.objectId];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if([self.delegate respondsToSelector:@selector(hideHUD)])
            [self.delegate hideHUD];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:[self.wine getWineName]
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:@[count > 0 ? actionUnWishListIt : actionWishListIt, actionRecommandIt, actionInspectIt]];
            [sheet showFromTabBar:[self.delegate wineMorePresentationView]];
        });
    }];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionWishListIt]) {
        User *user = [User currentUser];
        [[user theCellar] addObject:self.wine];
        [user saveInBackground];
        if (self.source == WineCellSourceWinery) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_ADDED_WINE_TO_CELLAR_FROM_WINERY_VIEW);
        }
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionUnWishListIt]) {
        User *user = [User currentUser];
        [[user theCellar] removeObject:self.wine];
        [user saveInBackground];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionInspectIt]) {
        [self inspectIt];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionRecommandIt]) {
        [self recommendIt];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionShareIt]) {
        [self shareIt:actionSheet];
    }
}

- (void)inspectIt {
    if(inspecting)
        return;
    inspecting = YES;
    
    WineContainerVC *container = [[WineContainerVC alloc] init];
    
    //UIStoryboard *checkIn = [UIStoryboard storyboardWithName:@"castCheckIn" bundle:nil];
    //CastDetailTVC *detail = [checkIn instantiateViewControllerWithIdentifier:@"detail"];
    
    container.wine = self.wine;
    container.isNew = NO;
    container.bidirectional = self.mode == WineCellModeCheckin;
    container.cameFrom = CastCheckinSourceSomewhere;
    
    if(self.delegate) {
        [self.delegate presentViewControllerFromCell:container];
        inspecting = NO;
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
                                              initWithTitle:@"Recommend Wine"
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
            NSString *pushMessage = [NSString stringWithFormat:@"%@ recommended a wine to you!", [[User currentUser] getName]];
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(showHUD)])
                [self.delegate showHUD];
            
            [[[Push sendPushNotification:NotificationTypeRecommendations toGroup:[BFTask taskWithResult:[group copy]] withMessage:pushMessage withURL:[NSString stringWithFormat:@"unwineapp://wine/%@", self.wine.objectId]] continueWithBlock:^id(BFTask *task) {
                
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
                        
                        [notificationObjectTasks addObject:[Notification createRecommendationObjectFor:self.wine andUser:(User *)child]];
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
                    [unWineAlertView showAlertViewWithTitle:@"Wine Experience Shared"
                                                    message:@"Spreading your wine influence never felt better."
                                          cancelButtonTitle:@"Keep unWineing"
                                                      theme:unWineAlertThemeSuccess];
                });
                
                [Analytics trackUserSharedWine:self.wine withFriends:sent];
                NSLog(@"actually sent %lu of %lu", (long)sent, (unsigned long)[group count]);
                
                return nil;
            }];
        } else {
            actionSheet.shouldDismiss = NO;
            //[unWineAlertView showAlertViewWithTitle:@"Recommendation" message:[NSString stringWithFormat:@"Looks like you didn't select any friends"] theme:unWineAlertThemeRed];
        }
    }
}

+ (NSInteger)getDefaultHeight {
    return WINE_CELL_HEIGHT;
}

+ (NSInteger)getExtendedHeight:(PFObject *)object {
    return [WineCell getExtendedHeight:object mode:WineCellModeHeightCheck];
}

+ (NSInteger)getExtendedHeight:(PFObject *)object mode:(WineCellMode)mode {
    unWine *wine = (unWine *)object;
    WineCell *cell = [[WineCell alloc] init];
    cell.assumeExtended = YES;
    cell.mode = mode;
    cell.wine = wine;
    [cell setup:nil];
    
    [cell.wineLabel setText:[wine getWineName]];
    [cell configureSublabel];
    [cell adjustLabels:WINE_CELL_HEIGHT_EXTENDED];
    
    NSInteger sublabel = offset + HEIGHT(cell.wineSublabel);
    NSInteger height = HEIGHT(cell.wineLabel) + sublabel + buffer * 2 + WINE_CELL_BASE_EXTENSION;
    
    if(mode == WineCellModeCheckin || mode == WineCellModeVinecast)
        return MAX(MAX(WINE_CELL_HEIGHT_EXTENDED, height) - WINE_CELL_BASE_EXTENSION, WINE_CELL_HEIGHT);
    else
        return MAX(WINE_CELL_HEIGHT_EXTENDED, height);
}

- (void)updateTheme {
}

- (UIViewController *)actionSheetPresentationViewController {
    return self.delegate;
}

@end
