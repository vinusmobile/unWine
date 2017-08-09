//
//  VineCastTVC.m
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VineCastTVC.h"
//#import "VineCastTVC+Appboy.h"
#import "ParseSubclasses.h"
#import "WineCell.h"
#import <iRate/iRate.h>
#import <MessageUI/MessageUI.h>
#import "unWineSMSController.h"
#import "unWineEmailController.h"
#import "UIViewController+Social.h"
#import "MBProgressHUD+Emojis.h"
#import "Scanner.h"
#import "BetterWithFriendsView.h"
#import <Intercom/Intercom.h>

#import "RecentSearchCell.h"
#import "WineCell.h"
#import "CheckinInterface.h"

@interface VineCastTVC () <WineCellDelegate, unWineAlertViewDelegate, iRateDelegate, MultiWinesCellDelegate, RecentSearchCellDelegate>
@property (nonatomic) NSUInteger numberOfMerits;
@property (nonatomic) NSUInteger meritCounter;
@property (nonatomic, strong) UIButton *globalButton;
@property (nonatomic, strong) UIButton *friendsButton;
@property (nonatomic, strong) UIButton *featuredButton;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSArray *filteredObjects;
@property (nonatomic, strong) Scanner *scanner;
@property (nonatomic)         BOOL wasShownSocial;
@property (nonatomic, strong) UIBarButtonItem *checkinButton;
@property (nonatomic, strong) UIBarButtonItem *scannerButton;
@property (nonatomic, strong) UIBarButtonItem *cancelSearchButton;

@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation VineCastTVC {
    NSInteger page;
    NSInteger lastLoadCount;
    NSInteger preLoadCount;
    CGFloat defaultTableHeight;
    CALayer *bottomBorder;
    BOOL hadFirstLoad, hadFirstAppear, hasUpdateProfileCounts, stateChanged;
    
    ////// Search //////
    NSMutableArray *_displayedCheckins;
    BFTask *_expectedTask;
    PFObject<SearchableSubclass> *topResult;
    UIButton *addWineButton;
    UIView *resultsView;
    CGFloat keyboardHeight;

}
@synthesize cellImages, cellList, extendedPath, gridMode, _results;

- (void)viewWillLayoutSubviews {
    //LOGGER(@"Enter");
    [super viewWillLayoutSubviews];
    
    /*UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"Invite"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(showInvite)];
    */

    if (self == [self.navigationController.viewControllers objectAtIndex:0]) {
        if(!ISVALID(_singleObjectId)) {
            //self.navigationController.navigationBar.topItem.leftBarButtonItem = self.newsButton;
            //self.navigationController.navigationBar.topItem.leftBarButtonItem = inviteButton;
            
        } else {
            self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
        }
    } else {
       // self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
        //self.navigationController.navigationBar.topItem.leftBarButtonItem = inviteButton;
    }
    //self.edgesForExtendedLayout = UIRectEdgeTop;
    
    [self adjustFrame];
    [self adjustNegativeViews];
    
    // Set checkin button
    self.checkinButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"search"]
                          style:UIBarButtonItemStylePlain
                          target:self
                          action:@selector(showCheckin)];
    
    self.scannerButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"scanner"]
                          //initWithTitle: @"Scan Label"
                          style:UIBarButtonItemStylePlain
                          target:self
                          action:@selector(showScanner)];
    
    self.cancelSearchButton = [[UIBarButtonItem alloc]
                          initWithTitle:@"Cancel"
                          style:UIBarButtonItemStylePlain
                          target:self
                          action:@selector(cancelSearch)];
    
    if (self.singleObject == nil && self.state != VineCastStateGreatWines && self.profileTVC == nil) {
        self.navigationItem.leftBarButtonItem = nil;//self.checkinButton;
        self.navigationItem.rightBarButtonItem = self.searchMode? self.cancelSearchButton : self.scannerButton;
        
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)showInvite {
    LOGGER(@"Enter");
    @try {
        //UIViewController *vc = [[UIStoryboard storyboardWithName:@"Invite" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendInvite"];
        UINavigationController *vc = ((UINavigationController *)[[UIStoryboard storyboardWithName:@"Invite" bundle:nil] instantiateInitialViewController]);
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_OPENED_FRIEND_INVITE_VIEW_FROM_VINECAST);
        
        self.navigationItem.titleView.hidden = YES
        ;
        [self presentViewController:vc animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
    }
    
}

- (void)viewDidLoad {
    LOGGER(@"\n\n\n");
    //LOGGER(@"Enter");
    
    self.wasShownSocial = NO;
    self.gridMode = NO;
    self.gridState = VineCastGridStateGreatWines;
    self.filteredObjects = @[];
    
    [self setCurrentState];
    [super viewDidLoad];
    
    [self setupEdgeInsetsAndTableHeader];

    [self checkTheList:YES];
    cellImages = [[NSMutableDictionary alloc] init];
    page = 0;
    self.objectsPerPage = 20;
    self.loadingViewEnabled = NO;
    self.paginationEnabled = YES;
    self.pullToRefreshEnabled = YES;
    
    [self basicAppeareanceSetup];
    
    // Header view
    /*
    if(!ISVALID(_singleObjectId) && self.state != VineCastGridStateGreatWines && _profileTVC == nil) {
        LOGGER(@"Adding friends view");
        UIView *view = [self makeHeaderView];
        self.tableView.tableHeaderView = view;
        [self placeBottomBorder:[self getButtonFromState]];
    }*/
    
    //[self setUpNewsButton:self.newsButton];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedUpdatedNotificationReceived:)
                                                 name:ABKFeedUpdatedNotification
                                               object:nil];
    */
    defaultTableHeight = HEIGHT(self.tableView);
    self.navigationController.view.backgroundColor = self.tableView.backgroundColor;
    self.tabBarController.view.backgroundColor = self.tableView.backgroundColor;
    
    [self.tableView registerClass:[CaptionCell class] forCellReuseIdentifier:@"CaptionCell"];
    [self.tableView registerClass:[ReactionCell class] forCellReuseIdentifier:@"ReactionCell"];
    [self.tableView registerClass:[EarnedMeritCell class] forCellReuseIdentifier:@"EarnedMeritCell"];
    [self.tableView registerClass:[WineCell class] forCellReuseIdentifier:@"WineCell"];
    //[[SlideoutHandler sharedInstance] setDelegate:self];
    [iRate sharedInstance].delegate = self;
    
    [self setUpSearchBar];
}

- (void)setUpSearchBar {
    if (self.profileTVC != nil) {
        LOGGER(@"Not setting up Nav Bar");
        return;
    }
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.delegate = self;
    searchController.hidesNavigationBarDuringPresentation = NO;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.searchBar.backgroundColor = UNWINE_RED;
    searchController.searchBar.tintColor = UNWINE_RED;
    searchController.searchBar.returnKeyType = UIReturnKeyDone;
    searchController.searchBar.barTintColor = [UIColor whiteColor];
    searchController.searchBar.enablesReturnKeyAutomatically = NO;
    searchController.definesPresentationContext = YES;
    searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchController = searchController;
    
    self.navigationItem.titleView = searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[RecentSearchCell class] forCellReuseIdentifier:@"RecentSearchCell"];
    
    [self.view addSubview:[self emptyResultsView]];
    [self emptyResultsView].alpha = 0;
    
    self.searchMode = NO;
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    // Remove built-in Cancel button in UISearchBar
    [self.searchController.searchBar setShowsCancelButton:NO animated:NO];
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardHeight = [keyboardFrameBegin CGRectValue].size.height;
    
    [self setUpTableViewInsetWithKeyboardAction];
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    keyboardHeight = 0;
    [self setUpTableViewInsetWithKeyboardAction];
}

- (void)setUpTableViewInsetWithKeyboardAction {
    
    if (self.searchMode) {
        CGFloat top;
        if (self.searchState == SearchTVCStateDefault) {
            top = (_displayedCheckins.count > 0)? 10 : 0;
        } else {
            top = 44;
        }
        CGFloat bottom = (keyboardHeight == 0)? 20 : keyboardHeight - 30;
        
        self.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }
}


- (void)setupEdgeInsetsAndTableHeader {
    
    if (self.searchMode) {
        [self setUpTableViewInsetWithKeyboardAction];
        [self scrollTop];
        
    } else {
        //self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        //storage
        //if(self.profileTVC == nil) {
        self.tableView.contentSize = CGSizeMake(0, -(ISVALID(_singleObjectId) || self.gridState == VineCastGridStateGreatWines ? 20 : buttonHeight - 4));
        //self.tableView.contentInset = UIEdgeInsetsMake(ISVALID(_singleObjectId) || self.gridState == VineCastGridStateGreatWines ? 20 : buttonHeight - 4, 0, ISVALID(_singleObjectId) ? -20 : 20, 0);
        
        CGFloat bottom = ISVALID(_singleObjectId) ? -20 : 20;
        CGFloat top = buttonHeight - 4;
        
        if (ISVALID(_singleObjectId) || (self.profileTVC != nil && self.gridState == VineCastGridStateGreatWines)) {
            top = 20;
        } else if (self.profileTVC == nil && !ISVALID(_singleObjectId)) {
            top = 43;
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        //}
        
        //[self setTabBarButtons];
        
        if (self.profileTVC != nil || ISVALID(_singleObjectId)) {
            self.tableView.tableHeaderView = nil;
        } else {
            self.tableView.tableHeaderView = [[BetterWithFriendsView alloc] initWithDelegate:self];
        }
    }
    
}



#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    LOGGER(@"Enter");
    [self beginSearch];
    return YES;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(searchBar.text.length > 50 && text.length > 50) {
        searchBar.text = [text substringWithRange:NSMakeRange(0, 50)];
        return NO;
    }
    
    if([text isEqualToString:@"\n"]) {
        [self resignAndSave:YES];
        return NO;
    }
    
    return YES;
}


- (void)cancelSearch {
    [self.searchController.searchBar resignFirstResponder];
    self.searchMode = NO;
    
    [self setupEdgeInsetsAndTableHeader];
    
    self.navigationItem.rightBarButtonItem = self.scannerButton;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
    
    self.searchController.searchBar.text = @"";
    
    [Intercom setLauncherVisible: YES];
}

- (void)beginSearch {
    self.searchMode = YES;
    self.searchState = SearchTVCStateDefault;
    
    [self setupEdgeInsetsAndTableHeader];
    
    [self hideAddWineButton:NO];

    self.navigationItem.rightBarButtonItem = self.cancelSearchButton;
    self.tableView.backgroundColor = CI_DEEP_BACKGROUND_COLOR;
    [self.tableView reloadData];
    
    [Intercom setLauncherVisible: NO];
    
    [[unWine getWinesTask:[[User currentUser] getRecentCheckinsObjects]] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        _displayedCheckins = task.result;
        //[self presentKeyboard];
        [self.tableView reloadData];
        [self setupEdgeInsetsAndTableHeader];
        return nil;
    }];
}

- (void)resignIfNecessary {
    [self.searchController.searchBar resignFirstResponder];
}

- (void)resignAndSave:(BOOL)dismissKeyboard {
    if([self.searchController.searchBar isFirstResponder]) {
        NSString *text = self.searchController.searchBar.text;
        if(dismissKeyboard) {
            doNotUpdate = YES;
            [self.searchController.searchBar resignFirstResponder];
            [self updateRecents:text];
            doNotUpdate = NO;
        
        } else {
            doNotUpdate = YES;
            [self updateRecents:text];
            doNotUpdate = NO;
        }
    }
}

- (void)updateRecents:(NSString *)text {
    
    if(![text isEqualToString:@""]) {
        User *user = [User currentUser];
        if([[user getRecentSearchesObjects] containsObject:text])
            [user removeRecentSearchesObject:text];
        
        [user addRecentSearchesObject:text];
        [[user saveInBackground] continueWithBlock:^id(BFTask *task) {
            if(task.error) {
                LOGGER(task.error);
            } else {
                NSLog(@"debug recentSearches %@", [user getRecentSearchesObjects]);
            }
            return nil;
        }];
    }
}

static BOOL doNotUpdate = NO;


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    LOGGER(@"Enter");
    
    if (!self.searchMode) {
        return;
    }
    
    // update the filtered array based on the search text
    NSString *searchString = searchController.searchBar.text;
    LOGGER(searchString);
    
    if([[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        self.searchState = SearchTVCStateDefault;
        _expectedTask = nil;
        topResult = nil;
        _results = nil;
        [self hideAddWineButton:YES];
        [self emptyResultsView].alpha = 0;
        [self.tableView reloadData];
        
        return;
    }
    
    BFTask *task = [unWine findTask:[searchString lowercaseString]];
    _expectedTask = task;
    self.searchState = SearchTVCStateSearching;
    
    [[task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t != _expectedTask) {
            return nil;
        }
        //NSLog(@"results %@", _results);
        [self reloadDataWithResults:(NSArray *)t.result];
        
        return nil;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(t.error);
            NSString *s = @"Searching Wines";
            [Analytics trackError:task.error withName:@"Error searching" withMessage:s];
        }
        
        return nil;
    }];

    
    
    /*
    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController.sections objectAtIndex:0];
    
    if (searchText == nil) {
        
        // If empty the search results are the same as the original data
        self.searchResults = [sectionInfo.objects mutableCopy];
        
    } else {
        
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        NSArray *allObjects = sectionInfo.objects;
        
        for (PhoneNumber *phoneMO in allObjects) {
            
            if ([phoneMO.number containsString:searchText] || [[phoneMO.closrr_id filteredId] containsString:searchText] || [[phoneMO.contact.fullname lowercaseString] containsString:[searchText lowercaseString]]) {
                [searchResults addObject:phoneMO];
            }
        }
        
        self.searchResults = searchResults;
        
    }
    
    // hand over the filtered results to our search results table
    CLCustomerResultrowsItemsCellController *tableController = (CLCustomerResultrowsItemsCellController *)self.searchController.searchResultsController;
    tableController.filteredContacts = self.searchResults;
    [tableController.tableView reloadData];
     */
}

- (void)reloadDataWithResults:(NSArray *)results {
    LOGGER(@"Enter");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.searchState = SearchTVCStateSearched;
        
        topResult = nil;
        _results = results;
        [self getBottomResults];
        
        if([_results count] == 0) {
            [self showAddWineButton:YES];
            [self emptyResultsView].alpha = 1;
        } else {
            [self showAddWineButton:YES];
            [self emptyResultsView].alpha = 0;
        }
        
        [self.tableView reloadData];
        
    });
}

- (NSArray *)getBottomResults {
    if(topResult) {
        if(_results) {
            NSMutableArray *bottomResults = [_results mutableCopy];
            [bottomResults removeObject:topResult];
            return bottomResults;
        } else
            return nil;
    }
    
    if(_results) {
        if([_results count] > 1) {
            NSMutableArray *bottomResults = [_results mutableCopy];
            
            CGFloat maxSimilarity = 0.0;
            for(PFObject<SearchableSubclass> *obj in _results) {
                CGFloat sim = [SearchTVC similarityBetween:[self.searchController.searchBar text] and:[obj getSearchableName]];
                //NSLog(@"%@ and %@ have %f similarity", [self.searchController.searchBar text], [wine getWineName], sim);
                if(sim > maxSimilarity) {
                    maxSimilarity = sim;
                    topResult = obj;
                }
            }
            
            [bottomResults removeObject:topResult];
            
            return bottomResults;
        } else if([_results count] == 1) {
            topResult = [_results objectAtIndex:0];
            return [[NSMutableArray alloc] init];
        }
    }
    
    return nil;
}

static NSString *ummFace = @"😳";


- (UIView *)emptyResultsView {
    if(resultsView) {
        for(UILabel *view in [resultsView subviews])
            if(view.tag == 10)
                [view setText:[NSString stringWithFormat:@"No results found for \"%@\"", self.searchController.searchBar.text]];
        
        return resultsView;
    }
    
    resultsView = [[UIView alloc] initWithFrame:self.tableView.frame];
    resultsView.alpha = 0;
    
    NSInteger y = 60;
    UILabel *faceLabel = [[UILabel alloc] initWithFrame:(CGRect){0, y, {SCREEN_WIDTH, 64}}];
    [faceLabel setText:ummFace];
    [faceLabel setTextAlignment:NSTextAlignmentCenter];
    [faceLabel setFont:[UIFont fontWithName:@"OpenSans" size:48]];
    [resultsView addSubview:faceLabel];
    
    UILabel *noResultsLabel = [[UILabel alloc] initWithFrame:(CGRect){0, Y2(faceLabel) + HEIGHT(faceLabel) - 10, {SCREEN_WIDTH, 48}}];
    [noResultsLabel setText:[NSString stringWithFormat:@"No results found for \"%@\"", self.searchController.searchBar.text]];
    [noResultsLabel setTextAlignment:NSTextAlignmentCenter];
    [noResultsLabel setTextColor:CI_FOREGROUND_COLOR];
    [noResultsLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    noResultsLabel.numberOfLines = 0;
    noResultsLabel.tag = 10;
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [CI_FOREGROUND_COLOR CGColor];
    border.frame = CGRectMake(12, noResultsLabel.frame.size.height - 1, noResultsLabel.frame.size.width - 24, .5);
    [noResultsLabel.layer addSublayer:border];
    [resultsView addSubview:noResultsLabel];
    
    UILabel *helpLabel = [[UILabel alloc] initWithFrame:(CGRect){0, Y2(noResultsLabel) + HEIGHT(noResultsLabel), {SCREEN_WIDTH, 60}}];
    [helpLabel setText:@"Please make sure your words are spelled correctly, or use less or different keywords"];
    [helpLabel setTextAlignment:NSTextAlignmentCenter];
    [helpLabel setTextColor:CI_FOREGROUND_COLOR];
    [helpLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
    helpLabel.numberOfLines = 0;
    [resultsView addSubview:helpLabel];
    
    return resultsView;
}

- (void)showAddWineButton:(BOOL)animated {
    if(!addWineButton) {
        addWineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addWineButton setFrame:(CGRect){0, 20 + NAVIGATION_BAR_HEIGHT, {SCREEN_WIDTH, 28}}];
        [addWineButton setBackgroundColor:[UIColor whiteColor]];
        [addWineButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
        [addWineButton setTitle:@"Don't see your wine? Tap here to add it!" forState:UIControlStateNormal];
        [addWineButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        addWineButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        addWineButton.titleLabel.minimumScaleFactor = .6;
        addWineButton.layer.shadowColor = [UIColor blackColor].CGColor;
        addWineButton.layer.shadowOffset = CGSizeMake(0, 0);
        addWineButton.layer.shadowOpacity = 1;
        addWineButton.layer.shadowRadius = 1.7;
        addWineButton.clipsToBounds = YES;
        
        [addWineButton addTarget:self action:@selector(pressedAddWine) forControlEvents:UIControlEventTouchUpInside];
        
    }
    self.tableView.tableHeaderView = addWineButton;
    [self setupEdgeInsetsAndTableHeader];
}


- (void)hideAddWineButton:(BOOL)animated {
    self.tableView.tableHeaderView = nil;
    [self setupEdgeInsetsAndTableHeader];
}

- (void)pressedAddWine {
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = nil;
    container.isNew = YES;
    container.cameFrom = CastCheckinSourceSomewhere;
    
    [self presentViewControllerFromCell:container];
}

- (void)showCheckin {
    //LOGGER(@"Enter");
    dispatch_async(dispatch_get_main_queue(), ^{
        SearchTVC *sTVC = [[SearchTVC alloc] init]; //[[newSearchCheckinController viewControllers] objectAtIndex:0];
        sTVC.mode = SearchTVCModeWines;
        sTVC.title = @"Check in";
        
        [self.navigationController pushViewController:sTVC animated:YES];
    });
}

- (BFTask *)preprocessFriends {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    User *user = [User currentUser];
    
    [[user getFriendUsers] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSArray<User *> *> * _Nonnull task) {

        if (task.error) {
            [theTask setError:task.error];
            return nil;
        }

        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray:task.result];
        [friends addObject:user];

        self.friends = friends;

        [theTask setResult:@(TRUE)];
        
        return nil;
    }];
    
    return theTask.task;
}

// Sets some statuses before loading objects
// Updates profile table counts asynchronously when single user vinecast and hasn't already loaded
// Updates news button asynchronously (which might hold tableview stuff) on Global VineCast
- (void)objectsWillLoad {
    LOGGER(@"Enter");
    
    if (self.searchMode) {
        [super objectsWillLoad];
        return;
    }
    
    self.objectsPerPage = self.gridMode ? 1000 : 20;
    self.loadingViewEnabled = NO;
    [super objectsWillLoad];
    
    /*if(hadFirstLoad && !ISVALID(_singleObjectId) && _singleUser == nil) {
        LOGGER(@"Update news button with timer");
        [self updateNewsButtonWithTimer:NO];
    }*/
    
    if (self.profileTVC == nil) {
        [SHOW_HUD addLoadMessage].userInteractionEnabled = false;
    }
    
    if (hadFirstLoad && self.profileTVC != nil && !hasUpdateProfileCounts) {
        LOGGER(@"Update counts");
        [self.profileTVC updateCounts];
        hasUpdateProfileCounts = YES;
    }

    if (self.profileTVC == nil && hadFirstLoad == FALSE) {
        [GET_TAB_BAR disableInteraction];
        self.tableView.userInteractionEnabled = NO;
    }

    //preLoadCount = self.objects && !stateChanged ? [self.objects count] : 0;
    stateChanged = NO;
    
    LOGGER(@"Getting current state");
    [self setCurrentState];
}

// Build query based on state
- (PFQuery *)queryForTable {
    //LOGGER(@"Enter");
    //NSString *s = [NSString stringWithFormat:@"State = %u", self.state];
    //LOGGER(s);
    
    PFQuery *query = [NewsFeed query];
    
    if(ISVALID(_singleObjectId)) {
        [query whereKey:@"objectId" equalTo:_singleObjectId];
    }
    
    if (ISVALIDOBJECT(_singleUser)) {
        [query whereKey:@"authorPointer" equalTo:_singleUser];
        query.limit = 1000;
    }

    [query orderByDescending:@"createdAt"];
    [query whereKey:@"Type" containedIn:[NSArray arrayWithObjects:@"Wine", @"Merit", @"Game", nil]];
    
    if (self.state == VineCastStateFriends && self.gridMode == false) {
        [query whereKey:@"authorPointer" containedIn:self.friends ? self.friends : @[]];
        
    } else if (self.state == VineCastStateGreatWines && self.gridMode == false) {
        LOGGER(@"Querying great wines");
        [query whereKey:@"reactionType" equalTo:@(ReactionType1Great)];
    }
    
    [query includeKey:@"authorPointer.level"];
    [query includeKey:@"gamePointer"];
    [query includeKey:@"feelingPointer"];
    [query includeKey:@"occasionPointer"];
    [query includeKey:@"connectedMerits"];
    [query includeKey:@"venue"];
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    LOGGER(@"Enter");
    [super objectsDidLoad:error];
    if (self.searchMode) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        HIDE_ALL_HUDS;
        
        if(!error) {
            LOGGER(@"No error and doing grape thing");
            // Update reactions section
            NSString *s = [NSString stringWithFormat:@"Objects count = %lu", self.objects.count];
            LOGGER(s);
            
            if (self.profileTVC && self.profileTVC.delegate && self.gridMode) {
                LOGGER(@"Have profileTVC and delegate. Updating reaction view");
                [self refreshFilteredObjects];
                [self.profileTVC.delegate refreshHeaderViewWithReaction:!(self.objects.count == 0)];
            }
        } else {
            NSString *s = [NSString stringWithFormat:@"Something happened loading objects: %@", error];
            [unWineAlertView showAlertViewWithTitle:@"Error"
                                            message:@"Perhaps is a connection error. Try reloading."
                                  cancelButtonTitle:@"OK"];
            LOGGER(s);
        }
        
        LOGGER(@"Checking the list");
        [self checkTheList:YES];
        hasUpdateProfileCounts = NO;
        [self.tableView reloadData];
        
        if (self.profileTVC == nil && hadFirstLoad == NO) {
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(enableTabBarInteraction)
                                           userInfo:nil
                                            repeats:NO];
        }
        
        hadFirstLoad = YES;
        
    });
}

- (void)enableTabBarInteraction {
    self.tableView.userInteractionEnabled = YES;
    [GET_TAB_BAR enableInteraction];
}

- (void)refreshFilteredObjects {
    LOGGER(@"Enter");
    ReactionType type = ReactionType1Great;
    
    switch (self.gridState) {
        case VineCastGridStateGreatWines:
            type = ReactionType1Great;
            break;
        case VineCastGridStateGoodWines:
            type = ReactionType2Good;
            break;
        case VineCastGridStateOKWines:
            type = ReactionType3Okay;
            break;
        case VineCastGridStateBadWines:
            type = ReactionType4Bad;
            break;
        case VineCastGridStateAwfulWines:
            type = ReactionType5Aweful;
            break;
        case VineCastGridStateNoReactionWines:
            type = ReactionType0None;
            break;
        default:
            LOGGER(@"Default = ReactionType1Great");
            type = ReactionType1Great;
            break;
    }
    NSString *s = [NSString stringWithFormat:@"Reaction = %u", type];
    LOGGER(s);
    
    self.filteredObjects = [NewsFeed getNewsfeedObjectsWithReactionType:type fromArray:self.objects];
    s = [NSString stringWithFormat:@"self.filteredObjects.count = %lu", (unsigned long)self.filteredObjects.count];
    LOGGER(s);
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.titleView.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    //LOGGER(@"Enter");
    [super viewDidAppear:animated];
    
    [self checkTheList:NO];
    
    if (self.navigationController.view.tag == MOVE_TO_CHECKIN) {
        [((customTabBarController *)self.tabBarController) setSelectedIndex:1];
        return;
    }
    
    NSMutableArray *tasks = [[NSMutableArray alloc] initWithArray:@[[self preprocessFriends]]];
    
    if ((GET_APP_DELEGATE).checkForMerits == YES) {
        //self.navigationController.view.tag = DONT_REFRESH_NEWSFEED;
        LOGGER(@"Gonna check for merits");
        (GET_APP_DELEGATE).checkForMerits = NO;
        [tasks addObject:[self checkMerits]];
    
    } else if (self.navigationController.view.tag == REFRESH_NEWSFEED) {
        LOGGER(@"Just refreshing newsfeed");
        [tasks addObject:[self refreshVineCast]];
        
    }
    
    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        BFTask *t2 = nil;
        
        if (self.navigationController.view.tag == REFRESH_NEWSFEED) {
            LOGGER(@"Refreshing vinecast after merits?");
            t2 = [self refreshVineCast];
        } else {
            LOGGER(@"Not refreshing again");
            [BFTask taskWithResult:@(TRUE)];
        }
        
        return t2;
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Setting up rest of UI");
        
        if (self == [self.navigationController.viewControllers objectAtIndex:0] && !ISVALID(_singleObjectId)) {
            [self setNavBarButtons];
        } else {
            [self unsetNavBarButtons];
        }
        
        if(self.tabBarController.selectedIndex == 0 && ![self.tabBarController.tabBar isHidden]) {
            [self showPopover];
        }
        
        self.justReappeared = YES;
        [self checkVisibleCells:(UIScrollView *)self.tableView];
        self.justReappeared = NO;
        
        if ([User currentUser].isNew && !self.wasShownSocial && self.profileTVC == nil) {
            [self showSocialVC:TRUE];
            self.wasShownSocial = YES;
            ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_FRIEND_INVITE_VIEW_FROM_SIGN_UP);
            
        } else if ([User currentUser].isNew && self.wasShownSocial) {
            [self promptSurvey];
        }
        
        if (self.profileTVC == nil) {
            [Intercom setLauncherVisible: !self.searchMode];
        }

        return nil;
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    //LOGGER(@"Enter");
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    /*if(self != [self.navigationController.viewControllers objectAtIndex:0] && ISVALID(_singleObjectId)) {
        [UIView animateWithDuration:.2 animations:^{
            self.grapesButton.customView.alpha = 0;
        } completion:^(BOOL finished) {
            self.grapesButton.customView = nil;
            self.grapesButton = nil;
        }];
    }*/

    self.navigationItem.titleView.hidden = YES;
    
    [self unsetNavBarButtons];
    
    [Intercom setLauncherVisible:NO];
    
    [self animateNavBarTo:20];
    [self updateBarButtonItems:1];
    HIDE_HUD;
}

- (void)viewDidDisappear:(BOOL)animated {
    //LOGGER(@"Enter");
    [self unsetNavBarButtons];
    [super viewDidDisappear:animated];
}

- (VineCells)randomSpacer {
    NSArray *spacer = [NSArray arrayWithObjects:@(SPACER_CELL_1), @(SPACER_CELL_2), @(SPACER_CELL_3), @(SPACER_CELL_4), nil];
    return [[spacer objectAtIndex:[self randomIntegerBetweenMin:0 andMax:[spacer count]]] intValue];
}

- (NSInteger)randomIntegerBetweenMin:(NSInteger)min andMax:(NSInteger)max {
    return min + arc4random() % (max - min);
}

- (void)adjustFrame {
    ////LOGGER(@"Enter");
    CGRect table = self.tableView.frame;
    table.origin.y = 20;
    table.size.height = SCREENHEIGHT - 20;
    self.tableView.frame = table;
}

- (void)showPopover {
    //LOGGER(@"Enter");
    if(![User hasSeen:WITNESS_ALERT_VINECAST] && ![[PopoverVC sharedInstance] isDisplayed]) {
        //CGRect placer = CGRectMake(0, 0, SCREENWIDTH / 3, 44);
        
        /*[[PopoverVC sharedInstance] showFrom:self
         sourceView:self.tabBarController.tabBar
         sourceRect:placer
         text:@"Welcome to unWine! This page you're on now is the VineCast, a place where you can see recent checkins and maybe find wine suggestions!"];*/
        
        [User witnessed:WITNESS_ALERT_VINECAST];
        
        ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_VINECAST_BUBBLE);
    }
}

- (void)showLeaderboards {
    //LOGGER(@"Enter");
    [Grapes showLeaderboards:self.navigationController];
}

- (void)showPurchases {
    //LOGGER(@"Enter");
    [Grapes showPurchases:self.navigationController];
}

- (void)adjustNegativeViews {
    //LOGGER(@"Enter");
    for(UIView *someView in [self.view subviews]) {
        if([someView isKindOfClass:[UIImageView class]] || [someView isKindOfClass:[PFImageView class]]) {
            //NSLog(@"adjusting a UIImageView maybe");
            if(X2(someView) < 0) {
                CGRect frame = someView.frame;
                frame.origin.x = 0;
                [someView setFrame:frame];
            }
        }
    }
}

- (BFTask *)refreshVineCast {
    LOGGER(@"Enter");
    
    if (self.navigationController.view.tag == DONT_REFRESH_NEWSFEED || self.isLoading) {
        LOGGER(@"Not refreshing VineCast");
        return [BFTask taskWithResult:@(TRUE)];
    }
    
    LOGGER(@"refreshing vinecast");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    self.navigationController.view.tag = DONT_REFRESH_NEWSFEED;
    page = 0;
    
    [[self loadObjects] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSArray<__kindof PFObject *> *> * _Nonnull t) {
        LOGGER(@"Reloaded objects");
        TABLE_VIEW_SCROLL_TO_TOP;
        
        if (t.error) {
            NSString *s = [NSString stringWithFormat:@"Error loading objects:\n%@", t.error];
            LOGGER(s);
            [theTask setError:t.error];
        } else {
            LOGGER(@"Loaded objects successfully");
            [theTask setResult:t.result];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

static BOOL DONT_UPDATE = NO;

- (void)checkVisibilityOfCell:(VineCastCell *)cell inScrollView:(UIScrollView *)aScrollView {
    //LOGGER(@"Enter");
    if(cell == nil || ![cell isKindOfClass:[VineCastCell class]])
        return;
    
    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
    
    if (CGRectContainsRect(aScrollView.frame, cellRect))
        [cell notifyCompletelyVisible];
    else
        [cell notifyNotCompletelyVisible];
}

- (void)checkVisibleCells:(UIScrollView *)scrollView {
    //LOGGER(@"Enter");
    NSArray *cells = self.tableView.visibleCells;
    
    NSUInteger cellCount = [cells count];
    if (cellCount > 0) {
        // Check the visibility of the first cell
        [self checkVisibilityOfCell:[cells firstObject] inScrollView:scrollView];
        
        if (cellCount > 1) {
            // Check the visibility of the last cell
            [self checkVisibilityOfCell:[cells lastObject] inScrollView:scrollView];
            
            if (cellCount > 2) {
                // All of the rest of the cells are visible: Loop through the 2nd through n-1 cells
                for (NSUInteger i = 1; i < cellCount - 1; i++) {
                    UITableViewCell *cell = [cells objectAtIndex:i];
                    if(cell != nil && [cell isKindOfClass:[VineCastCell class]])
                        [self checkVisibilityOfCell:(VineCastCell *)cell inScrollView:scrollView];
                    //[(VineCastCell *)cell notifyCompletelyVisible];
                }
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //LOGGER(@"Enter");
    if (self.searchMode)
        return;
    
    // If reached end of table view, table is not loading,
    // and exceded count of available objects,
    // load the next page
    if (scrollView.contentSize.height - scrollView.contentOffset.y <
        (self.view.bounds.size.height) && !self.isLoading &&
        [self.objects count] >= (self.objectsPerPage * (page + 1))) {
       
        LOGGER(@"Reached the end of tableview. Loading next page");
        
        [self loadObjects:++page clear:NO];
        /*[
         continueWithExecutor:[BFExecutor mainThreadExecutor]
         withBlock:^id _Nullable(BFTask<NSArray<__kindof PFObject *> *> * _Nonnull t) {
             
             LOGGER(@"Returned from loading next page. Updating nav bar");
             [self updateNavBar:scrollView];
             return nil;
         }];*/
        
    } else {
        //LOGGER(@"Not at the end of scrolling");
        [self updateNavBar:scrollView];
        self.navigationController.navigationBar.backgroundColor = UNWINE_RED;
    }
    
}

- (void)updateNavBar:(UIScrollView *)scrollView {
    //LOGGER(@"Enter");
    
    //CGRect cframe = self.navigationController.navigationBar.frame;
    //NSLog(@"frame.origin.y = %f", cframe.origin.y);
    //NSLog(@"frame.size.height = %f", cframe.size.height);
    
    //NSLog(@"size.height = %f", backframe.height);
    
    [self checkVisibleCells:scrollView];
    
    if (DONT_UPDATE) {
        //LOGGER(@"Do not update");
        /*
         [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
         [self.navigationController.navigationBar setShadowImage:nil];
         [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
         [self.navigationController.navigationBar setShadowImage:[UIImage new]];
         
         
         [self showNavBar:1];
         */
        return;
    }
    
    if(scrollView.contentSize.height < HEIGHT(self.tableView)) {
        //LOGGER(@"Update bar button item");
        CGRect frame = self.navigationController.navigationBar.frame;
        frame.origin.y = 20;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:1];
        return;
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top) {
        //LOGGER(@"Log 1");
        frame.origin.y = 20;
    } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
        //LOGGER(@"Log 2");
        frame.origin.y = -size;
    } else {
        //LOGGER(@"Log 3");
        frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
    }
    
    //NSString *y = [NSString stringWithFormat:@"New Navbar y origin: %f", frame.origin.y];
    //LOGGER(y);
    //NSString *ph = [NSString stringWithFormat:@"New Percentage hidden: %f", framePercentageHidden];
    //LOGGER(ph);
    
    [self.navigationController.navigationBar setFrame:frame];
    if (framePercentageHidden == 0) {
        //LOGGER(@"Completely visible");
        [self updateBarButtonItems:1];
    } else {
        //LOGGER(@"Kinda visible");
        [self updateBarButtonItems:(1 - framePercentageHidden)];
    }
    self.previousScrollViewYOffset = scrollOffset;
    
}

// Made this for  testing
- (void)showNavBar:(CGFloat)alpha {
    //LOGGER(@"Enter");
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    /*[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];*/
    self.navigationController.navigationItem.titleView.alpha = alpha;
    self.grapesButton.customView.alpha = alpha;
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //LOGGER(@"Enter");
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    //LOGGER(@"Enter");
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling {
    //LOGGER(@"Enter");
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        LOGGER(@"Small origin?");
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
}

- (void)updateBarButtonItems:(CGFloat)alpha {
    //LOGGER(@"Enter");
    if(self.profileTVC == nil) {
        //LOGGER(@"No profile controller. Probably regular vinecast");
        [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
            item.customView.alpha = alpha;
        }];
        /*[self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
            item.customView.alpha = alpha;
        }];*/
        self.navigationController.navigationItem.titleView.alpha = alpha;
        self.grapesButton.customView.alpha = alpha;
        self.navigationItem.titleView.alpha = alpha;
        self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
    } else {
        //LOGGER(@"Update vinecast in profile");
        //[self.profileTVC.delegate updateBarButtonItems:alpha];
    }
}

// Changing the frame height
- (void)animateNavBarTo:(CGFloat)y {
    //CGRect before = self.navigationController.navigationBar.frame;
    //LOGGER(@"Enter");
    DONT_UPDATE = YES;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        
        if(self.tableView.contentOffset.y < 20 && alpha == 0) {
            CGFloat newY = frame.size.height - self.tableView.contentInset.top;
            //NSLog(@"y=%lu, offset=%@, alpha=%f, newY=%f", (long)y, NSStringFromCGPoint(self.tableView.contentOffset), alpha, newY);
            if(!(y == 20 && newY == 0))
                [self.tableView setContentOffset:(CGPoint){0, newY} animated:NO];
        } else if(self.tableView.contentOffset.y < 20 && alpha == 1) {
            CGFloat newY = -frame.size.height;
            //NSLog(@"y=%lu, offset=%@, alpha=%f, newY=%f", (long)y, NSStringFromCGPoint(self.tableView.contentOffset), alpha, newY);
            [self.tableView setContentOffset:(CGPoint){0, newY} animated:NO];
        }
        
        [self updateBarButtonItems:alpha];
    } completion:^(BOOL finished) {
        self.previousScrollViewYOffset = self.tableView.contentOffset.y;
        DONT_UPDATE = NO;
    }];
}

- (void)scrollTo:(NSInteger)tag {
    //LOGGER(@"Enter");
    //[self.tableView reloadData];
    [UIView animateWithDuration:.5 animations:^{
        self.view.alpha = .99;
    } completion:^(BOOL finished) {
        if([self tableView:self.tableView numberOfRowsInSection:0] > tag + 4)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:tag + 4 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
}

- (void)scrollTop {
    //LOGGER(@"Enter");
    CGFloat top ;
    if (self.searchState == SearchTVCStateDefault) {
        top = _displayedCheckins.count > 0 ? 10 : 0;
    } else {
        top = 44;
    }
    self.tableView.contentOffset = CGPointMake(0, - top);
}

- (void)setNavBarButtons {
    //LOGGER(@"Enter");
    /*self.grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
    [Grapes userUpdateCurrency:^(NSInteger grapes) {
        self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:self];
        self.navigationItem.rightBarButtonItem = self.grapesButton;
    }];*/
}

- (void)unsetNavBarButtons {
    //LOGGER(@"Enter");
    self.navigationController.navigationBar.topItem.leftBarButtonItem = nil;
    /*if(self.profileTVC == nil) {
        self.navigationController.navigationBar.topItem.title = @"Back";
    }*/
}

- (UIButton *)getButtonFromState {
    //LOGGER(@"Enter");
    if(self.state == VineCastStateGlobal)
        return self.globalButton;
    else if(self.state == VineCastStateFriends)
        return self.friendsButton;
    
    return nil;
}

static NSInteger buttonHeight = 48;

- (UIView *)makeHeaderView {
    //LOGGER(@"Enter");
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.view), buttonHeight + 8)];
    
    self.globalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.globalButton setFrame:CGRectMake(0, 0, WIDTH(self.view) / 2, buttonHeight)];
    self.globalButton.backgroundColor = UNWINE_GRAY_DARK;
    [self.globalButton setTitle:@"Global" forState:UIControlStateNormal];
    [self.globalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.globalButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [self.globalButton addTarget:self action:@selector(showGlobal) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.globalButton];
     
    self.friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.friendsButton setFrame:CGRectMake(WIDTH(self.view) * 1 / 2, 0, WIDTH(self.view) / 2, buttonHeight)];
    self.friendsButton.backgroundColor = UNWINE_GRAY_DARK;
    [self.friendsButton setTitle:@"Friends" forState:UIControlStateNormal];
    [self.friendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.friendsButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    [self.friendsButton addTarget:self action:@selector(showFriends) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.friendsButton];
    
    /*self.featuredButton = [UIButton buttonWithType:UIButtonTypeCustom];
     [self.featuredButton setFrame:CGRectMake(WIDTH(self.view) * 2 / 3, 0, WIDTH(self.view) / 3, buttonHeight)];
     self.featuredButton.backgroundColor = UNWINE_GRAY_DARK;
     [self.featuredButton setTitle:@"The Daily Toast" forState:UIControlStateNormal];
     [self.featuredButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [self.featuredButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
     [self.featuredButton addTarget:self action:@selector(showFeatured) forControlEvents:UIControlEventTouchUpInside];
     [headerView addSubview:self.featuredButton];*/
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //LOGGER(@"Enter");
    
    if (self.searchMode) {
        UIView *footer = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 10}}];
        footer.backgroundColor = [UIColor clearColor];
        footer.clipsToBounds = YES;
        
        if(section != [self getLastSectionNumber]) {
            CALayer *border = [CALayer layer];
            border.backgroundColor = [CI_DEEP_BACKGROUND_COLOR CGColor];
            border.frame = CGRectMake(0, HEIGHT(footer) - 1, footer.frame.size.width, .5);
            [footer.layer addSublayer:border];
            
            footer.layer.shadowColor = [[UIColor blackColor] CGColor];
            footer.layer.shadowOffset = CGSizeMake(0, 0);
            footer.layer.shadowOpacity = 1;
            footer.layer.shadowRadius = 2;
        }
        
        return footer;
        
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 7)];
        
        view.clipsToBounds = YES;
        view.layer.masksToBounds = YES;
        
        if(section < [self numberOfSectionsInTableView:tableView] - 1) {
            CALayer *border = [CALayer layer];
            border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
            border.frame = CGRectMake(2, 0, SCREEN_WIDTH - 4, .5);
            [view.layer addSublayer:border];
            
            view.layer.shadowColor = [UNWINE_GRAY_DARK CGColor];
            view.layer.shadowOffset = CGSizeMake(0, 0);
            view.layer.shadowOpacity = 1;
            view.layer.shadowRadius = 2;
        }
        
        return view;
    }
    
}

- (NSInteger)getLastSectionNumber {
    for(NSInteger i = [self numberOfSectionsInTableView:self.tableView] - 1; i >= 0; i--) {
        if([self tableView:self.tableView numberOfRowsInSection:i] > 0)
            return i;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (self.searchMode) {
        UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 40}}];
        headerView.backgroundColor = CI_BACKGROUND_COLOR;
        headerView.clipsToBounds = YES;
        
        UILabel *header = [[UILabel alloc] initWithFrame:(CGRect){12, 0, {SCREEN_WIDTH - 24, 40}}];
        header.textColor = [UIColor whiteColor];
        [header setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
        if(self.searchState == SearchTVCStateDefault) {
            if(section == 0)
                [header setText:@"Recent Checkins"];
            else if(section == 1)
                [header setText:@"Recent Searches"];
            else
                [header setText:@""];
        } else {
            if(topResult && section == 0)
                [header setText:@"Top Result"];
            else {
                [header setText:@"Wine Results"];
            }
        }
        [headerView addSubview:header];
        
        CALayer *border = [CALayer layer];
        border.backgroundColor = [CI_SEPERATOR_COLOR CGColor];
        border.frame = CGRectMake(0, headerView.frame.size.height - 1, headerView.frame.size.width, .5);
        [headerView.layer addSublayer:border];
        
        CALayer *border2 = [CALayer layer];
        border2.backgroundColor = [CI_SEPERATOR_COLOR CGColor];
        border2.frame = CGRectMake(0, 0, headerView.frame.size.width, .5);
        [headerView.layer addSublayer:border2];
        return headerView;
        
    } else {
        return nil;
    }
}

- (void)setCurrentState {
    LOGGER(@"Enter");
    VineCastState before = self.state;
    /*if(before == VineCastStateGreatWines) {
        LOGGER(@"Great Wines");
        return;
    }*/
    
    if (self.profileTVC == nil) {
        LOGGER(@"No Profile TVC");
        if([User hasSeen:WITNESS_VINECAST_LAST] && self.state != VineCastStateGreatWines) {
            self.state = (VineCastState)[[User getWitnessValue:WITNESS_VINECAST_LAST] integerValue];
            NSString *s = [NSString stringWithFormat:@"Setting new state = %u", self.state];
            LOGGER(s);
            
        } else if (self.state != VineCastStateGreatWines) {
            self.state = VineCastStateGlobal;
            [User setWitnessValue:@(self.state) key:WITNESS_VINECAST_LAST];
        }
    }
    
    if(self.state != before)
        stateChanged = YES;
}

- (void)showGlobal {
    LOGGER(@"Enter");
    ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GLOBAL_TAB_ON_VINECAST);
    self.state = VineCastStateGlobal;
    self.gridMode = false;
    stateChanged = YES;
    [User setWitnessValue:@(self.state) key:WITNESS_VINECAST_LAST];
    
    page = 0;
    [self loadObjects];
    
    [self placeBottomBorder:self.globalButton];
}

- (void)showFriends {
    LOGGER(@"Enter");
    ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_FRIENDS_TAB_ON_VINECAST);
    self.state = VineCastStateFriends;
    self.gridMode = false;
    stateChanged = YES;
    [User setWitnessValue:@(self.state) key:WITNESS_VINECAST_LAST];
    
    page = 0;
    [self loadObjects];
    
    [self placeBottomBorder:self.friendsButton];
}

- (void)placeBottomBorder:(UIButton *)button {
    //LOGGER(@"Enter");
    if(!bottomBorder)
        bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, buttonHeight - 4, WIDTH(button), 4);
    bottomBorder.backgroundColor = UNWINE_RED.CGColor;
    
    if([bottomBorder superlayer])
        [bottomBorder removeFromSuperlayer];
    [button.layer addSublayer:bottomBorder];
}

/*- (void)feedUpdatedNotificationReceived:(NSNotification *)notification {
    //NSLog(@"%s - Checking to see if update was successful", FUNCTION_NAME);
    LOGGER(@"Enter");
    BOOL updateIsSuccessful = [[notification.userInfo objectForKey:ABKFeedUpdatedIsSuccessfulKey] boolValue];
    
    if (updateIsSuccessful) {
        //NSLog(@"%s - updateIsSuccessful", FUNCTION_NAME);
        
        if(!ISVALID(_singleObjectId) && _singleUser == nil && [User currentUser])
            [self updateNewsButtonWithTimer:YES];
    }
}*/

- (void)checkTheList:(BOOL)refresh {
    //LOGGER(@"Enter");
    if(cellList == nil || refresh) {
        if(ISVALID(_singleObjectId)) {
            // Single wine type newsfeed
            if(_singleObjectType == nil || ![_singleObjectType isEqualToString:@"Wine"]) {
                cellList = [[NSMutableArray alloc] initWithObjects:
                            @(HEADER_CELL), @(CONTENT_CELL), @(CAPTION_CELL), @(WINE_DETAIL_CELL), @([self randomSpacer]),
                            @(LIKE_COUNT_CELL), @([self randomSpacer]),
                            @(MERIT_COUNT_CELL), nil];
                
                NSInteger count = [MeritCell countMerits:_singleObject];
                if(count > 1 && [_singleObject[@"Type"] isEqualToString:@"Merit"])
                    [cellList addObject:@(MERIT_CELL)];
                else if(count > 0 && ![_singleObject[@"Type"] isEqualToString:@"Merit"])
                    [cellList addObject:@(MERIT_CELL)];
                [cellList addObject:@(MERIT_EXPLORE_CELL)];
            } else {
                // Merit?
                cellList = [[NSMutableArray alloc] initWithObjects:
                            @(HEADER_CELL), @(CONTENT_CELL), @(CAPTION_CELL), @(WINE_DETAIL_CELL), @([self randomSpacer]),
                            @(WINE_NAME_CELL), @(REACTION_CELL), @(INSPECT_WINE_CELL), @(SPACER_CELL_NO_LINE),
                            @(LIKE_COUNT_CELL), @([self randomSpacer]),
                            @(MERIT_COUNT_CELL), nil];
                
                if([MeritCell countMerits:_singleObject] > 0)
                    [cellList addObject:@(MERIT_CELL)];
                [cellList addObject:@(MERIT_EXPLORE_CELL)];
            }
        } else {
            if([self.objects count] > 0 || self.isLoading) {
                cellList = [[NSMutableArray alloc] initWithObjects:
                            @(HEADER_CELL), @(CONTENT_CELL), @(EARNED_MERIT_CELL), @(CAPTION_CELL), @(WINE_DETAIL_CELL), nil];
            } else {
                cellList = [[NSMutableArray alloc] initWithObjects: @(EMPTY_CELL), nil];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    //LOGGER(@"Enter");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBottomBarWhenPushed {
    //LOGGER(@"Enter");
    return ISVALID(_singleObjectId);
}

#pragma mark - Table view data source
- (BFTask *) getVineCastTask {
    //LOGGER(@"Enter");
    return [[self queryForTable] countObjectsInBackground];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //LOGGER(@"Enter");
    
    if (self.searchMode) {
        if(self.searchState == SearchTVCStateDefault) {
            return 2;
        } else {
            if(topResult)
                if([_results count] >= 20)
                    return 3;
                else
                    return 2;
                else
                    return 1;
        }
        
    } else {
        if(([self.objects count] == 0 && !self.isLoading) || self.gridMode) {
            return 1;
            
        } else {
            return [self.objects count];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //LOGGER(@"Enter");
    
    if (self.searchMode) {
        if(self.searchState == SearchTVCStateDefault) {
            if(indexPath.section == 0) {
                PFObject<SearchableSubclass> *object = _displayedCheckins ? [_displayedCheckins objectAtIndex:indexPath.row] : nil;
                return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [WineCell getExtendedHeight:object] : [WineCell getDefaultHeight];
            } else
                return RECENT_SEARCH_CELL_HEIGHT;
        } else {
            if(indexPath.section == 2)
                return 40;
            else {
                PFObject<SearchableSubclass> *object = _results ? [_results objectAtIndex:indexPath.row] : nil;
                return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [[object getAssociatedCell] getExtendedHeight:object] : [[object getAssociatedCell] getDefaultHeight];
            }
        }
        return 0;
        
    } else {
        if([self.objects count] == 0 && !self.isLoading && self.state == VineCastStateFriends) {
            return 150;
        } else if([self.objects count] == 0 && !self.isLoading) {
            return 120;
        } else if([self.objects count] == 0) {
            return 120;
        }
        
        // Grid mode stuff
        if (self.gridMode) {
            return [MultiWinesCell getDefaultHeight];;
        }
        
        // List mode stuff
        NewsFeed *object = [self.objects objectAtIndex:indexPath.section];
        VineCells cellType = [[cellList objectAtIndex:indexPath.row] intValue];
        
        if(cellType == HEADER_CELL) {
            return VC_HEADER_CELL_HEIGHT;
        } else if(cellType == CONTENT_CELL) {
            if([object[@"Type"] isEqualToString:@"Wine"]) {
                if([object hasPhoto]) {
                    if(object.photoDims) {
                        CGFloat preHeight = [VCWineCell getImageFrame:self.view withDims:object.photoDims].size.height + IMAGE_NATURAL_Y * 2;
                        
                        if([object hasMovie])
                            preHeight = MIN(preHeight, VIDEO_NATURAL_MAX_HEIGHT);
                        
                        return preHeight;
                    } else {
                        if([cellImages objectForKey:[object objectId]]) {
                            CGFloat preHeight = [VCWineCell getImageFrame:self.view withImage:cellImages[[object objectId]]].size.height + IMAGE_NATURAL_Y * 2;
                            
                            if([object hasMovie])
                                preHeight = MIN(preHeight, VIDEO_NATURAL_MAX_HEIGHT);
                            
                            return preHeight;
                        } else {
                            return 4; //IMAGE_NATURAL_Y * 2;
                        }
                    }
                } else {
                    return [WineCell getExtendedHeight:object.unWinePointer mode:WineCellModeVinecast];
                }
            } else if([object[@"Type"] isEqualToString:@"Merit"]) {
                return 200;
            } else
                return 108;
        } else if(cellType == RATING_CELL) {
            return 60;
        } else if(cellType == MERIT_CELL) {
            if([MeritCell countMerits:[self.objects objectAtIndex:indexPath.section]] > 0)
                return 200;
            else
                return 44;
        } else if(cellType == SPACER_CELL_1 || cellType == SPACER_CELL_2 || cellType == SPACER_CELL_3 || cellType == SPACER_CELL_4 || cellType == SPACER_CELL_NO_LINE) {
            return 20;
        } else if(cellType == WINE_DETAIL_CELL) {
            return 64;
        } else if(cellType == EARNED_MERIT_CELL) {
            if(object.connectedMerits && [object.connectedMerits count] > 0)
                return EARNED_MERIT_CELL_HEIGHT;
            else
                return 0;
        } else if(cellType == CAPTION_CELL) {
            if([object hasCaption])
                return [CaptionCell getAppropriateHeight:object];
            else
                return 0;
        } else if(cellType == REACTION_CELL) {
            return [object.unWinePointer.reactions count] > 0 ? 108 : 0;
        } else {
            return 44;
        }
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.searchMode) {
        if(section == 2) // || (section == 0 && self.state == SearchTVCStateDefault && self.mode == SearchTVCModeUsers)
            return 0;
        else
            return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 40 : 0;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.searchMode) {
        return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 10 : 0;
    } else {
        return 0;
    }
}

- (NSArray *) getComments {
    //LOGGER(@"Enter");
    return [[NSArray alloc] init];
}

- (NSInteger) getCommentCount {
    //LOGGER(@"Enter");
    return [[self getComments] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //LOGGER(@"Enter");

    if (self.searchMode) {
        if(self.searchState == SearchTVCStateDefault) {
            if(section == 0) {
                return _displayedCheckins ? [_displayedCheckins count] : 0;
            } else {
                return [[[User currentUser] getRecentSearchesObjects] count];
            }
        } else {
            if(section == 2)
                return 1;
            else if(topResult && section == 0)
                return 1;
            else if(topResult && section == 1)
                return _results != nil ? [_results count] - 1 : 0;
            else
                return _results != nil ? [_results count] : 0;
        }
        return 0;
        
    } else {
        if([self.objects count] == 0 && !self.isLoading) {
            [self checkTheList:YES];
            return [cellList count];
            
        } else if (self.gridMode == FALSE) {
            [self checkTheList:YES];
            return [cellList count];
        } else {
            // GRID MODE
            // One extra cell to select
            
            NSInteger count = (self.filteredObjects.count % 3 == 0) ?
            (self.filteredObjects.count / 3) : (self.filteredObjects.count / 3) + 1;
            NSString *s = [NSString stringWithFormat:@"self.filteredObjects.count = %lu \nnumberOfRows = %lu",
                           self.filteredObjects.count, count];
            LOGGER(s);
            return (count > 0) ? count : 1;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //LOGGER(@"Enter");
    
    //NSString *s = [NSString stringWithFormat:@"state = %u \ngridMode = %@ \ngridState = %u \nobjects = %lu \nfilteredObjects = %lu", self.state, self.gridMode ? @"YES" : @"NO", self.gridState, self.objects.count, (unsigned long)self.filteredObjects.count];
    //LOGGER(s);
    
    if (self.searchMode) {
        if(indexPath.section == 2) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            [cell.textLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
            cell.textLabel.textColor = CI_FOREGROUND_COLOR;
            cell.backgroundColor = CI_MIDDGROUND_COLOR;
            cell.textLabel.text = @"See more wines";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.tintColor = CI_FOREGROUND_COLOR;
            
            return cell;
        }
        
        if(self.searchState == SearchTVCStateDefault) {
            User *user = [User currentUser];
            
                if(indexPath.section == 0) {
                    unWine *wine = [_displayedCheckins objectAtIndex:indexPath.row];
                    WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
                    cell.assumeExtended = NO;
                    cell.delegate = self;
                    
                    [cell setup:indexPath];
                    [cell configure:wine mode:WineCellModeRecentCheckin];
                    
                    return cell;
                } else if(indexPath.section == 1) {
                    NSString *searchString = [[user getRecentSearchesObjects] objectAtIndex:indexPath.row];
                    
                    RecentSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentSearchCell"];
                    cell.delegate = self;
                    [cell setup:indexPath];
                    [cell configure:searchString];
                    
                    return cell;
                }
        } else {
            if(topResult && indexPath.section == 0) {
                    WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
                    cell.delegate = self;
                    cell.assumeExtended = NO;
                    [cell setup:indexPath];
                    [cell configure:(unWine *)topResult mode:WineCellModeTopResult];
                    return cell;
            } else {
                PFObject<SearchableSubclass> *object = [[self getBottomResults] objectAtIndex:indexPath.row];
                    WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
                    cell.assumeExtended = NO;
                    cell.delegate = self;
                    [cell setup:indexPath];
                    [cell configure:(unWine *)object mode:WineCellModeResult];
                    
                    return cell;
            }
        }
        
        return [[UITableViewCell alloc] init];
        
    } else {
        if((self.objects.count == 0 || (self.gridMode && self.filteredObjects.count == 0)) && !self.isLoading) {
            LOGGER(@"Object count == 0 and view is not loading");
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(self.state == VineCastStateFriends) {
                if(self.friends == nil) {
                    LOGGER(@"No friends");
                    cell.backgroundColor = self.tableView.backgroundColor;
                    [cell.textLabel setText:@""];
                } else {
                    LOGGER(@"Have friends");
                    cell.backgroundColor = [UIColor whiteColor];
                    //[cell.textLabel setText:@"Haha you have no friends, nerd. Invite some you loner."];
                    [cell.textLabel setText:@"This is where you can see your friend's unique wine experiences. Whenever a friend checks in a wine it will show here! It's a great way to get a wine recommendation.\n\nTap this message to start adding your friends!"];
                    cell.textLabel.numberOfLines = 0;
                    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                    cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    cell.textLabel.minimumScaleFactor = .75;
                    
                    UITapGestureRecognizer *tapTarget = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStuff)];
                    tapTarget.delaysTouchesEnded = NO;
                    [cell addGestureRecognizer:tapTarget];
                }
            } else if(self.singleUser != nil && [self.singleUser isTheCurrentUser]) {
                LOGGER(@"Single user and current user");
                cell.backgroundColor = [UIColor whiteColor];
                if (self.objects.count == 0) {
                    [cell.textLabel setText:@"Wines you check in with will show here. Don't wither on the vine, check in your first wine by tapping the red button below!"];
                } else {
                    [cell.textLabel setText:@"Looks like you don't have any wines in this category! Try another one by tapping the button above."];
                }
                cell.textLabel.numberOfLines = 0;
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.minimumScaleFactor = .75;
            } else {
                LOGGER(@"Single user and NOT current user");
                cell.backgroundColor = [UIColor whiteColor];
                if (self.objects.count == 0) {
                    [cell.textLabel setText:@"This grapenut hasn't checked in their first wine yet!"];
                } else {
                    [cell.textLabel setText:@"This grapenut doesn't have any wines in this category! Try another one by tapping the button above."];
                }
                cell.textLabel.numberOfLines = 0;
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.minimumScaleFactor = .75;
            }
            
            return cell;
        } else if([self.objects count] == 0) {
            /*UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
             cell.selectionStyle = UITableViewCellSelectionStyleNone;
             return cell;*/
            LOGGER(@"No objects");
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = self.tableView.backgroundColor;
            [cell.textLabel setText:@""];
            return cell;
            
        } else if (self.gridMode == FALSE) {
            //LOGGER(@"Grid mode NOT ENABLED");
            NewsFeed *object = [self.objects objectAtIndex:indexPath.section];
            return [self tableView:tableView cellForRowAtIndexPath:indexPath withObject:object];
            
        } else {
            //LOGGER(@"Grid mode ENABLED");
            MultiWinesCell *cell = [self getMultiWinesCellFromTableView:tableView andIndexPath:indexPath];
            
            /*if (cell) {
             LOGGER(@"Got a cell");
             } else {
             LOGGER(@"Cell is nil");
             }*/
            
            return cell;
        }

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.searchMode) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
        if([cell isKindOfClass:[RecentSearchCell class]]){
            [(RecentSearchCell *)cell interact:nil];
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_RECENT_SEARCH);
        } else if(indexPath.section == 2) {
            MoreResultsTVC *results = [[MoreResultsTVC alloc] initWithStyle:UITableViewStylePlain];
            results.mode = SearchTVCModeWines;
            results.searchString = [[self.searchController.searchBar text] lowercaseString];
            [self.navigationController pushViewController:results animated:YES];
        }
}


- (MultiWinesCell *)getMultiWinesCellFromTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    LOGGER(@"Enter");
    MultiWinesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniqWinesCell"];
    
    if (!cell) {
        LOGGER(@"Nil cell, re-dequeing");
        cell = [[MultiWinesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UniqWinesCell"];
    }
    
    if (cell) {
        LOGGER(@"Got a cell");
    } else {
        LOGGER(@"Cell is nil");
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    [cell setup:indexPath];
    
    NSMutableArray *checkins = [[NSMutableArray alloc] init];
    NSMutableArray *wines = [[NSMutableArray alloc] init];
    
    for (int i = (int)indexPath.row * 3; i < ((indexPath.row + 1) * 3); i++) {
        if (i >= self.filteredObjects.count) {
            LOGGER(@"Ran out of wines... break");
            break;
        }
        
        NewsFeed *nf = [self.filteredObjects objectAtIndex:i];
        unWine *object = nf.unWinePointer;
        if(wines != nil)
            [wines addObject:object];
        
        if (checkins != nil) {
            [checkins addObject:nf];
        }
    }
    
    cell.checkins = [checkins copy];
    [cell configure:[wines copy]];
    
    return cell;
}

- (void)showStuff {
    //LOGGER(@"Enter");
    [[(GET_APP_DELEGATE).ctbc getProfileVC].profileTable inviteFriends:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpacerCell"];
    
    VineCells cellType = [[cellList objectAtIndex:indexPath.row] intValue];
    
    if(cellType == SPACER_CELL_NO_LINE) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SpacerCell2"];
        /*cell.layer.shadowColor = [UNWINE_GRAY_DARK CGColor];
         cell.layer.shadowOffset = CGSizeMake(0, 0);
         cell.layer.shadowOpacity = .76;
         cell.layer.shadowRadius = 1.5;
         cell.clipsToBounds = YES;*/
        
    } else if(cellType == HEADER_CELL) {
        
        cell = [self setupHeaderCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == CONTENT_CELL) {
        
        cell = [self setupContentCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == EARNED_MERIT_CELL) {
        
        cell = [self setupEarnedMeritCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == CAPTION_CELL) {
        
        cell = [self setupCaptionCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == REACTION_CELL) {
        
        cell = [self setupReactionCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == WINE_DETAIL_CELL) {
        
        cell = [self setupDetailCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == TOGGLE_CELL) {
        
        NSString *title = (ISVALID(_singleObjectId))? @"Less" : @"More";
        cell = [self setupTargetCell:tableView cellForRowAtIndexPath:indexPath withData:[NSArray arrayWithObjects:object, title, nil] andAction:@selector(pushSingle:)];
        
    } else if(cellType == WINE_NAME_CELL) {
        
        NSString *title = [TitleCell getWineName:object];
        cell = [self setupTitleCell:tableView cellForRowAtIndexPath:indexPath withData:[NSArray arrayWithObjects:object, title, nil]];
        
    } else if(cellType == RATING_CELL) {
        
        cell = [self setupRatingCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == INSPECT_WINE_CELL) {
        
        cell = [self setupTargetCell:tableView cellForRowAtIndexPath:indexPath withData:[NSArray arrayWithObjects:object, @"Inspect Wine", nil] andAction:@selector(inspectWine:)];
        
    } else if(cellType == MERIT_COUNT_CELL) {
        
        NSArray *connectedMerits = object[@"connectedMerits"];
        NSInteger count = connectedMerits == nil ? 0 : [connectedMerits count];
        NSString *title;
        if([object[@"Type"] isEqualToString:@"Merit"]) {
            title = [NSString stringWithFormat: @"%li Additional %@ Earned", (long)count, (count == 1)? @"Merit" : @"Merits", nil];
        } else {
            title = [NSString stringWithFormat: @"%li %@ Earned", (long)count, (count == 1)? @"Merit" : @"Merits", nil];
        }
        cell = [self setupTitleCell:tableView cellForRowAtIndexPath:indexPath withData:[NSArray arrayWithObjects:object, title, nil]];
        
    } else if(cellType == MERIT_EXPLORE_CELL) {
        
        cell =  [self setupTargetCell:tableView cellForRowAtIndexPath:indexPath withData:[NSArray arrayWithObjects:object, @"Explore Merits", nil] andAction:@selector(exploreMerits:)];
        
    } else if(cellType == MERIT_CELL) {
        
        cell = [self setupMeritCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == LIKE_COUNT_CELL) {
        
        BOOL userLikes = [[User currentUser] didToastPost:_singleObject];
        
        NSInteger count = [object[@"Likes"] integerValue];
        NSString *title = @"";
        if(count > 2 && userLikes) {
            title = [NSString stringWithFormat: @"You and %li others toasted this post", (long)(count - 1), nil];
        } else if(count == 2 && userLikes) {
            title = [NSString stringWithFormat: @"You and %li other toasted this post", (long)(count - 1), nil];
        } else if(count == 1 && userLikes) {
            title = [NSString stringWithFormat: @"You toasted this post", nil];
        } else if(!userLikes) {
            title = [NSString stringWithFormat: @"%li %@ toasted this post", (long)count, (count == 1)? @"person" : @"people", nil];
        }
        cell = [self setupTitleCell:tableView cellForRowAtIndexPath:indexPath withData:[NSArray arrayWithObjects:object, title, nil]];
        
    } else if(cellType == LIKE_CELL) {
        
        cell = [self setupLikeCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == COMMENT_COUNT_CELL) {
        
        cell = [self setupCommentCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    } else if(cellType == COMMENT_CELL) {
        
        cell = [self setupCommentCell:tableView cellForRowAtIndexPath:indexPath withObject:object];
        
    }
    cell.tag = indexPath.section;
    
    return cell;
}

- (HeaderCell *)setupHeaderCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(PFObject *)object {
    //LOGGER(@"Enter");
    HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    [cell configureCell:object withPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)setupContentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    if([object[@"Type"] isEqualToString:@"Wine"]) {
        if([object hasPhoto]) {
            VCWineCell *cell = (VCWineCell *)[tableView dequeueReusableCellWithIdentifier:@"VCWineCell"];
            
            [cell firstSetup:self indexPath:indexPath];
            [cell configureCell:object];
            
            return cell;
        } else {
            WineCell<Themeable> *cell = (WineCell *)[tableView dequeueReusableCellWithIdentifier:@"WineCell"];
            cell.delegate = self;
            cell.singleTheme = unWineThemeLight;
            cell.assumeExtended = YES;
            
            [cell setup:indexPath];
            [cell configure:(unWine *)object.unWinePointer mode:WineCellModeVinecast];
            
            return cell;
        }
    } else if([object[@"Type"] isEqualToString:@"Game"]) {
        GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameCell"];
        
        [cell firstSetup:self indexPath:indexPath];
        [cell configureCell:object];
        
        return cell;
    } else if([object[@"Type"] isEqualToString:@"Merit"]) {
        return [self setupMeritCell:tableView cellForRowAtIndexPath:indexPath withObject:object];;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpacerCell"];
        
        return cell;
    }
}

- (EarnedMeritCell *)setupEarnedMeritCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    EarnedMeritCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EarnedMeritCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    
    [cell configureCell:object];
    
    return cell;
}

- (CaptionCell *)setupCaptionCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    CaptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CaptionCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    
    [cell configureCell:object];
    
    return cell;
}

- (ReactionCell *)setupReactionCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    ReactionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReactionCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    
    [cell configureCell:object];
    
    return cell;
}

- (FooterCell *)setupDetailCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    FooterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    
    [cell configureCell:object];
    
    if(self.view.tag > 0 && ISVALID(_singleObjectId)) {
        //[self scrollTo:indexPath.row - 2];
        self.view.tag = 0;
    }
    
    return cell;
}

- (VCWineCell *)getWineCell:(NSIndexPath *)path {
    //LOGGER(@"Enter");
    NSIndexPath *winePath = [NSIndexPath indexPathForRow:1 inSection:path.section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:winePath];
    if([cell isKindOfClass:[VCWineCell class]]) {
        return (VCWineCell *)cell;
    } else {
        return nil;
    }
}

- (void)sudoToast:(NSIndexPath *)path {
    //LOGGER(@"Enter");
    NSIndexPath *footerPath = [NSIndexPath indexPathForRow:path.row + 2 inSection:path.section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:footerPath];
    LOGGER(cell);
    if([cell isKindOfClass:[FooterCell class]]) {
        FooterCell *footer = (FooterCell *)cell;
        [footer toastPressed:nil];
    } else {
        NewsFeed *object = [self.objects objectAtIndex:footerPath.section];
        FooterCell *footer = [self setupDetailCell:self.tableView cellForRowAtIndexPath:footerPath withObject:object];
        [footer toastPressed:nil];
    }
}

- (TitleCell *)setupTitleCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withData:(NSArray *)data {
    //LOGGER(@"Enter");
    //NSLog(@"%@", data);
    TitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    [cell configureCell:[data objectAtIndex:0] andTitle:[data objectAtIndex:1]];
    
    return cell;
}

- (RatingCell *)setupRatingCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    RatingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RatingCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    
    [cell configureCell:object];
    
    return cell;
}

- (TargetCell *)setupTargetCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withData:(NSArray *)data andAction:(SEL)action {
    //LOGGER(@"Enter");
    TargetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TargetCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    [cell configureCell:[data objectAtIndex:0]];
    
    cell.titleLabel.text = [data objectAtIndex:1];
    
    UITapGestureRecognizer *tapTarget = [[UITapGestureRecognizer alloc] initWithTarget:cell action:action];
    tapTarget.delaysTouchesEnded = NO;
    [cell addGestureRecognizer:tapTarget];
    
    return cell;
}

- (UITableViewCell *)setupMeritCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    //if([MeritCell countMerits:object] > 0) {
    MeritCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeritCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    [cell configureCell:object];
    
    return cell;
    //} else {
    //}
}

- (LikeCell *)setupLikeCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    LikeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    [cell configureCell:object];
    
    return cell;
}

- (VineCommentCell *)setupCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    VineCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    
    [cell firstSetup:self indexPath:indexPath];
    [cell configureCell:object];
    
    return cell;
}

- (void)checkGrapes {
    //LOGGER(@"Enter");
    [Grapes executeQueue:self];
}

#define STEP_ONE 1001 //prompt
#define STEP_TWO 1002 //first question
#define STEP_THREE 1003 //second question
#define STEP_FOUR 1004 //third question
#define STEP_FIVE 1005 //closing

- (void)promptSurvey {
    //LOGGER(@"Enter");
    User *user = [User currentUser];
    if(!user.palateData)
        user.palateData = [[NSMutableDictionary alloc] init];
    
    if(!user.palateData[@"didSurvey"] || ![user.palateData[@"didSurvey"] boolValue]) {
        unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"We have 3 quick questions to help determine your wine palate, it will only take 30 seconds."];
        alert.title = @"Wine Palate Questionnaire";
        alert.delegate = self;
        alert.leftButtonTitle = @"No";
        alert.rightButtonTitle = @"Continue";
        alert.tag = STEP_ONE;
        [alert show];
    } else {
        user.palateData[@"didSurvey"] = @(YES);
        
        user.palateData = [[NSMutableDictionary alloc] initWithDictionary:user.palateData];
        [user saveInBackground];
    }
}

- (void)showSurveyQuestionOne {
    //LOGGER(@"Enter");
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"If you had to choose between the two, would you drink unsweetened ice tea or Coca Cola?"];
    alert.title = @"Wine Palate (1/3)";
    alert.delegate = self;
    alert.leftButtonTitle = @"Ice Tea";
    alert.rightButtonTitle = @"Coca Cola";
    alert.tag = STEP_TWO;
    [alert show];
}

- (void)showSurveyQuestionTwo {
    //LOGGER(@"Enter");
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Do you love desserts or do you generally avoid sweets?"];
    alert.title = @"Wine Palate (2/3)";
    alert.delegate = self;
    alert.leftButtonTitle = @"Love sweets";
    alert.rightButtonTitle = @"Avoid sweets";
    alert.tag = STEP_THREE;
    [alert show];
}

- (void)showSurveyQuestionThree {
    //LOGGER(@"Enter");
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Do you prefer to add cream or milk to your coffee or do you like it black?"];
    alert.title = @"Wine Palate (3/3)";
    alert.delegate = self;
    alert.leftButtonTitle = @"Cream or Milk";
    alert.rightButtonTitle = @"Black Coffee";
    alert.tag = STEP_FOUR;
    [alert show];
}

- (void)leftButtonPressed {
    //LOGGER(@"Enter");
    User *user = [User currentUser];
    //NSLog(@"tag: %ld - %@", (long)[[unWineAlertView sharedInstance] tag], user.palateData);
    if([[unWineAlertView sharedInstance] tag] == STEP_ONE) {
        user.palateData[@"didSurvey"] = @(YES);
        
        [unWineAlertView showAlertViewWithBasicSuccess:@"Ok, no problem!"];
    } else if([[unWineAlertView sharedInstance] tag] == STEP_TWO) {
        user.palateData[@"first"] = [[unWineAlertView sharedInstance] leftButtonTitle];
        
        [self showSurveyQuestionTwo];
    } else if([[unWineAlertView sharedInstance] tag] == STEP_THREE) {
        user.palateData[@"second"] = [[unWineAlertView sharedInstance] leftButtonTitle];
        
        [self showSurveyQuestionThree];
    } else if([[unWineAlertView sharedInstance] tag] == STEP_FOUR) {
        user.palateData[@"third"] = [[unWineAlertView sharedInstance] leftButtonTitle];
        
        [unWineAlertView showAlertViewWithTitle:@"Questionnaire Complete" message:@"Thanks!"];
    }
    //NSLog(@"tag: %ld - %@", (long)[[unWineAlertView sharedInstance] tag], user.palateData);
    
    user.palateData = [[NSMutableDictionary alloc] initWithDictionary:user.palateData];
    [user saveInBackground];
}

- (void)rightButtonPressed {
    //LOGGER(@"Enter");
    User *user = [User currentUser];
    //NSLog(@"tag: %ld - %@", (long)[[unWineAlertView sharedInstance] tag], user.palateData);
    if([[unWineAlertView sharedInstance] tag] == STEP_ONE) {
        user.palateData[@"didSurvey"] = @(YES);
        
        [self showSurveyQuestionOne];
    } else if([[unWineAlertView sharedInstance] tag] == STEP_TWO) {
        user.palateData[@"first"] = [[unWineAlertView sharedInstance] rightButtonTitle];
        
        [self showSurveyQuestionTwo];
    } else if([[unWineAlertView sharedInstance] tag] == STEP_THREE) {
        user.palateData[@"second"] = [[unWineAlertView sharedInstance] rightButtonTitle];
        
        [self showSurveyQuestionThree];
    } else if([[unWineAlertView sharedInstance] tag] == STEP_FOUR) {
        user.palateData[@"third"] = [[unWineAlertView sharedInstance] rightButtonTitle];
        
        [unWineAlertView showAlertViewWithTitle:@"Questionnaire Complete" message:@"Thanks!"];
    }
    
    user.palateData = [[NSMutableDictionary alloc] initWithDictionary:user.palateData];
    [user saveInBackground];
}

/*
 *
 * MERIT STUFF
 *
 */

- (BFTask *)checkMerits {
    //LOGGER(@"Enter");
    LOGGER(@"Checking merits");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    User *user = [User currentUser];
    __block NSMutableArray *merits = nil;
    
    [[[PFCloud callFunctionInBackground:@"checkUserMerits" withParameters:@{@"currentUser": user.objectId}] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<id> * _Nonnull task) {
        LOGGER(@"Cloud Function Returned");
        merits = (NSMutableArray *)task.result;
        self.numberOfMerits = merits ? [merits count] : 0;
        self.meritCounter = 0;
        
        LOGGER(task.result);
        
        if(self.numberOfMerits == 0)
        LOGGER(@"***** No merits earned *****");
        
        // Create custom alert views
        for(Merits *merit in merits) {
            if(merit && ![merit isKindOfClass:[NSNull class]]) {
                MeritAlertView *alert = [merit createCustomAlertView:MeritModeDiscoverMessage andShowShareOption:YES];
                alert.delegate = self;
            }
        }
        
        return [self saveMeritNewsfeed:task.result withUser:[User currentUser]];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
    
        if (t.error) {
            LOGGER(t.error);
            [theTask setError:t.error];
            return nil;
            
        } else if ([[iRate sharedInstance] shouldPromptForRating]) {
            [[iRate sharedInstance] promptIfNetworkAvailable];
            
        } else {
            LOGGER(@"Should not rate app");
            iRate *ir = [iRate sharedInstance];
            NSString *s = [NSString stringWithFormat:@"usesCount: %lu, eventCount: %lu", (unsigned long)ir.usesCount, (unsigned long)ir.eventCount];
            LOGGER(s);
            [ir logEvent:true];
        }
        
        [theTask setResult:@(TRUE)];
        
        return nil;
    }];
    
    /*
     else
     */
    
    return theTask.task;
}





// iRate stuff
- (void)iRateDidPromptForRating {
    //LOGGER(@"Enter");
    ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_APP_RATING);
}

- (void)iRateUserDidAttemptToRateApp {
    //LOGGER(@"Enter");
    [[User currentUser] ratedTheApp];
    ANALYTICS_TRACK_EVENT(EVENT_USER_RATED_APP);
}

- (void)iRateUserDidRequestReminderToRateApp{
    //LOGGER(@"Enter");
    LOGGER(@"User requested to be reminded to rate the app");
    [iRate sharedInstance].eventCount = 0;
    ANALYTICS_TRACK_EVENT(EVENT_USER_DEFERRED_RATING_APP);
}

- (void)iRateUserDidDeclineToRateApp {
    //LOGGER(@"Enter");
    ANALYTICS_TRACK_EVENT(EVENT_USER_DECLINED_RATING_APP);
}

// End iRate stuff

- (BFTask *)saveMeritNewsfeed:(NSArray *)merits withUser:(User *)user{
    //LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block Merits *levelMerit = nil;
    PFQuery *lastCheckIn = [PFQuery queryWithClassName:@"NewsFeed"];
    [lastCheckIn whereKey:@"authorPointer" equalTo:user];
    [lastCheckIn orderByDescending:@"createdAt"];
    
    [[[lastCheckIn getFirstObjectInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        PFObject *checkin = (PFObject *)t.result;
        if (checkin[@"connectedMerits"] == nil) {
            checkin[@"connectedMerits"] = [[NSMutableArray alloc] init];
        }
        for(Merits *merit in merits) {
            [checkin[@"connectedMerits"] addObject:merit];
            
            if([merit.type isEqualToString:@"level"]){
                levelMerit = merit;
            }
        }
        self.meritCounter++;
        
        return [checkin saveInBackground];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (task.error) {
            NSString *s = [NSString stringWithFormat:@"Something happened:\n%@", task.error];
            LOGGER(s);
            return nil;
        }
        
        if (levelMerit) {
            NSString *meritName = [[levelMerit.name capitalizedString]
                                   stringByReplacingOccurrencesOfString:@" "
                                   withString:@""];
            [Grapes queueTransaction:50 reason:[NSString stringWithFormat:@"LevelUp%@", meritName]];
        }
        
        self.navigationController.view.tag = REFRESH_NEWSFEED;
        //[self refreshVineCast];
        
        [theTask setResult:@(TRUE)];
        return nil;
    }];
    
    return theTask.task;
}

- (void)updateWithObject:(NewsFeed *)object {
    //LOGGER(@"Enter");
    @synchronized(self) {
        for(NSInteger i = 0; i < [self.objects count]; i++) {
            NewsFeed *pos = [self.objects objectAtIndex:i];
            if([pos isEqual:object]) {
                //update obj
                break;
            }
        }
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (void)setVineCastSingleObject:(NewsFeed *)singleObject {
    //LOGGER(@"Enter");
    _singleObject = singleObject;
    _singleObjectId = [singleObject objectId];
    _singleObjectType = singleObject[@"Type"];
}

- (UIView *)wineMorePresentationView {
    //LOGGER(@"Enter");
    return self.navigationController.view;
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    //LOGGER(@"Enter");
    [self.navigationController pushViewController:controller animated:YES];
}

// SCANNER STUFF
- (void)showScanner {
    //[self presentViewController:[CICameraVC cameraWithDelegate:self] animated:YES completion:nil];
    // set custom tint color
    LOGGER(@"Enter");
    self.scanner = [[Scanner alloc] init];
    self.scanner.delegate = self;
    [self.scanner showScanner];
    ANALYTICS_TRACK_EVENT(EVENT_OPENED_SCANNER);
}

// RecentCell Delegate Method
- (void)expressPressed:(NSString *)searchString {
    [self.searchController.searchBar setText:searchString];
    [self resignAndSave:NO];
}

@end
