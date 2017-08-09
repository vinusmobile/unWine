//
//  SearchTVC.m
//  unWine
//
//  Created by Bryce Boesen on 12/31/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "SearchTVC.h"
#import "CheckinInterface.h"
#import "CastDetailTVC.h"

@interface SearchTVC () <UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, RecentSearchCellDelegate, WineCellDelegate, UserCellDelegate, WineryCellDelegate, WineWorldDelegate> {
    BFTask *_expectedTask;
    NSMutableArray <User *> *_displayedFriends;
    NSMutableArray *_displayedCheckins;
    NSMutableArray *_followedWineries;
    NSMutableArray *_nearbyWineries;
    NSMutableArray *_popularRegions;
    PFObject<SearchableSubclass> *topResult;
    UIView *resultsView;
    UIButton *addWineButton;
    BOOL _alreadySearched; // This is so we only track one search
}

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation SearchTVC
@synthesize extendedPath, _results;
//@synthesize searchController = self.searchController;

+ (UINavigationController *)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static UINavigationController* _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[UINavigationController alloc] initWithRootViewController:[[self alloc] init]];
        _sharedObject.title = @"Check In";
        _sharedObject.view.tag = 1;
    });
    
    return _sharedObject;
}

#pragma ViewController Delegate Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _alreadySearched = NO;
    self.definesPresentationContext = YES;
    
    if(!self.searchController)
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    if(self.mode == SearchTVCModeWines)
        self.searchController.searchBar.placeholder = @"Search for a wine";
    else if(self.mode == SearchTVCModeUsers)
        self.searchController.searchBar.placeholder = @"Search for a user";
    else if(self.mode == SearchTVCModeWinery)
        self.searchController.searchBar.placeholder = @"Search for a winery";
    else if(self.mode == SearchTVCModeRegion)
        self.searchController.searchBar.placeholder = @"Search by region";
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.backgroundColor = UNWINE_RED;
    self.searchController.searchBar.tintColor = UNWINE_RED;
    self.searchController.searchBar.returnKeyType = UIReturnKeyDone;
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    self.searchController.searchBar.enablesReturnKeyAutomatically = NO;
    self.searchController.definesPresentationContext = YES;
    self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //self.searchController.extendedLayoutIncludesOpaqueBars = YES;
    //self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.navigationItem.titleView = self.searchController.searchBar;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[RecentSearchCell class] forCellReuseIdentifier:@"RecentSearchCell"];
    [self.tableView registerClass:[WineCell class] forCellReuseIdentifier:@"WineCell"];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerClass:[WineryCell class] forCellReuseIdentifier:@"WineryCell"];
    
    self.tableView.backgroundColor = CI_DEEP_BACKGROUND_COLOR;
    self.tableView.separatorColor = [UIColor clearColor];
    
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.backgroundColor = UNWINE_RED;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    if (self.state == 0) {
        self.state = SearchTVCStateDefault;
    }
    //self.title = @"Check In";
    
    [self.view addSubview:[self emptyResultsView]];
}

- (void)viewWillLayoutSubviews {
    if(self.mode != SearchTVCModeRegion) {
        [self presentKeyboard];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.titleView = self.searchController.searchBar;
    
    if(self.mode != SearchTVCModeUsers || _user == nil)
        _user = [User currentUser];
    
    if(_displayedFriends)
        [_displayedFriends removeAllObjects];
    
    //Prefills for SearchTVC
    if(self.mode == SearchTVCModeUsers) {
        SHOW_HUD_FOR_VIEW(self.navigationController.view);
        [[_user getFriendUsers] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSArray<User *> *> * _Nonnull task) {
            HIDE_HUD_FOR_VIEW(self.navigationController.view);
            _displayedFriends = [[NSMutableArray alloc] initWithArray:task.result];
            [self.tableView reloadData];
            
            return nil;
        }];
    } else if(self.mode == SearchTVCModeWines) {
        [[unWine getWinesTask:[_user getRecentCheckinsObjects]] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            _displayedCheckins = task.result;
            //[self presentKeyboard];
            [self.tableView reloadData];
            
            return nil;
        }];
    } else if(self.mode == SearchTVCModeWinery) {
        NSArray<BFTask *> *tasks = @[[Winery getWinerysTask:[_user getFollowedWineries]], [WineWorldVC fetchNearbyWineries:self]];
        [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            BFTask *wineryTask = [tasks objectAtIndex:0];
            BFTask *nearbyTask = [tasks objectAtIndex:1];
            
            _followedWineries = wineryTask.result;
            _nearbyWineries = nearbyTask.result;
            
            //[self presentKeyboard];
            [self.tableView reloadData];
            
            return nil;
        }];
    } else if(self.mode == SearchTVCModeRegion) {
        //Popular Regions
    }
    
    //self.title = @"Check In";
}

- (void)didChangeAuthorizationStatus {
    [[WineWorldVC fetchNearbyWineries:self] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {

        _nearbyWineries = task.result;
        [self presentKeyboard];
        [self.tableView reloadData];
        
        return nil;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //NSLog(@"showing SearchTVC");
    //[self presentKeyboard];
}

- (void)presentKeyboard {
    if(self.searchController) {
        if (self.searchController.searchBar.isFirstResponder == NO) {
            BOOL isFirstResponder = [self.searchController.searchBar becomeFirstResponder];
            NSString *s = [NSString stringWithFormat:@"Is first responder %@", isFirstResponder ? @"Yes" : @"No"];
            LOGGER(s);
        }

        if(ISVALID(self.presearch)) {
            [self.searchController.searchBar setText:self.presearch];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"will disappear %i, %i, %i", [self isFirstResponder] ? 1 : 0, [self.navigationController isFirstResponder] ? 1 : 0, [self.searchController isFirstResponder] ? 1 : 0);
    
    [self resignAndSave:NO];
    self.navigationItem.title = @"Back";
    //[self hideAddWineButton:NO];
}


/*- (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }*/

- (BOOL)hidesBottomBarWhenPushed {
    //return YES;//![self isRootVC];
    return NO;
}

- (BOOL)isRootVC {
    return self == [self.navigationController.viewControllers objectAtIndex:0];
}

#pragma Search Delegate Methods

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
 [self showAddWineButton:YES];
 }
 }*/

static BOOL doNotUpdate = NO;

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    //LOGGER(searchString);
    
    if(doNotUpdate) {
        return;
    }
    
    if([[searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        self.state = SearchTVCStateDefault;
        _expectedTask = nil;
        topResult = nil;
        _results = nil;
        [self hideAddWineButton:YES];
        [self emptyResultsView].alpha = 0;
        [self.tableView reloadData];
        
        return;
        
    }
    
    BFTask *task = nil;
    if(self.mode == SearchTVCModeWines) {
        task = [unWine findTask:[searchString lowercaseString]];
        
    } else if(self.mode == SearchTVCModeUsers) {
        task = [User findTask:[searchString lowercaseString]];
        
    } else if(self.mode == SearchTVCModeWinery) {
        task = [Winery findTask:[searchString lowercaseString]];
        
    } else if(self.mode == SearchTVCModeRegion) {
        task = [unWine findByRegionTask:[searchString lowercaseString]];
    }
    
    _expectedTask = task;
    self.state = SearchTVCStateSearching;
    
    [[task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t != _expectedTask) {
            return nil;
        }
        
        if (_alreadySearched == NO && self.mode == SearchTVCModeUsers) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_SEARCHED_USER_ON_FRIEND_VIEW);
        } else if (_alreadySearched == NO && self.mode == SearchTVCModeWinery) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_SEARCHED_WINERY_ON_WINERY_SEARCH_VIEW);
        }
        
        //NSLog(@"results %@", _results);
        [self reloadDataWithResults:(NSArray *)t.result];
        
        return nil;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(t.error);
            NSString *s = nil;
            if(self.mode == SearchTVCModeWines) {
                s = @"Searching Wines";
                
            } else if(self.mode == SearchTVCModeUsers) {
                s = @"Searching Users";
                
            } else if(self.mode == SearchTVCModeWinery) {
                s = @"Searching Wineries";
                
            } else if(self.mode == SearchTVCModeRegion) {
                s = @"Searching by Region";
            }
            [Analytics trackError:task.error withName:@"Error searching" withMessage:s];
        }
        
        return nil;
    }];

}

- (void)reloadDataWithResults:(NSArray *)results {
    LOGGER(@"Enter");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.state = SearchTVCStateSearched;
        _alreadySearched = YES;
        
        topResult = nil;
        _results = results;
        [self getBottomResults];
        
        if([_results count] == 0) {
            if(self.mode == SearchTVCModeWines)
                [self showAddWineButton:YES];
            [self emptyResultsView].alpha = 1;
        } else {
            if(self.mode == SearchTVCModeWines)
                [self showAddWineButton:YES];
            [self emptyResultsView].alpha = 0;
        }
        
        [self.tableView reloadData];
        
    });
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(searchBar.text.length > 50 && text.length > 50) {
        searchBar.text = [text substringWithRange:NSMakeRange(0, 50)];
        return NO;
    }
    
    if([text isEqualToString:@"\n"]) {
        [self resignAndSave:NO];
        return NO;
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resignAndSave:YES];
}

- (void)resignIfNecessary {
    [self resignAndSave:NO];
}

- (void)resignAndSave:(BOOL)clear {
    if([self.searchController.searchBar isFirstResponder]) {
        NSString *text = self.searchController.searchBar.text;
        if(!clear) {
            doNotUpdate = YES;
            [self.searchController setActive:NO];
            [self.searchController.searchBar resignFirstResponder];
            self.searchController.searchBar.text = text;
            
            [self updateRecents:text];
            doNotUpdate = NO;
        } else {
            [self.searchController.searchBar resignFirstResponder];
        }
    }
}

- (void)updateRecents:(NSString *)text {
    NSLog(@"updateRecents mode - %u", self.mode);
    if(self.mode != SearchTVCModeWines)
        return;
    
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

#pragma TableView Delegate Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 40}}];
    headerView.backgroundColor = CI_BACKGROUND_COLOR;
    headerView.clipsToBounds = YES;
    
    UILabel *header = [[UILabel alloc] initWithFrame:(CGRect){12, 0, {SCREEN_WIDTH - 24, 40}}];
    header.textColor = [UIColor whiteColor];
    [header setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    if(self.state == SearchTVCStateDefault) {
        if(self.mode == SearchTVCModeWines) {
            if(section == 0)
                [header setText:@"Recent Checkins"];
            else if(section == 1)
                [header setText:@"Recent Searches"];
            else
                [header setText:@""];
        } else if(self.mode == SearchTVCModeUsers) {
            if(section == 0)
                [header setText:@"Invite Friends"];
            else if(section == 1) {
                if([self.user isTheCurrentUser])
                    [header setText:@"Friends"];
                else
                    [header setText:[NSString stringWithFormat:@"%@'s Friends", [self.user getShortName]]];
            } else
                [header setText:@""];
        } else if(self.mode == SearchTVCModeWinery) {
            if(section == 0)
                [header setText:@"Followed Wineries"];
            else if(section == 1)
                [header setText:@"Wineries Nearby"];
            else
                [header setText:@""];
        } else if(self.mode == SearchTVCModeRegion) {
            [header setText:@"Popular Regions"];
        }
    } else {
        if(topResult && section == 0)
            [header setText:@"Top Result"];
        else {
            if(self.mode == SearchTVCModeWines)
                [header setText:@"Wine Results"];
            else if(self.mode == SearchTVCModeUsers)
                [header setText:@"User Results"];
            else if(self.mode == SearchTVCModeWinery)
                [header setText:@"Winery Results"];
            else if(self.mode == SearchTVCModeRegion)
                [header setText:@"Wine Results by Region"];
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
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
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
}

- (NSInteger)getLastSectionNumber {
    for(NSInteger i = [self numberOfSectionsInTableView:self.tableView] - 1; i >= 0; i--) {
        if([self tableView:self.tableView numberOfRowsInSection:i] > 0)
            return i;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 2) // || (section == 0 && self.state == SearchTVCStateDefault && self.mode == SearchTVCModeUsers)
        return 0;
    else
        return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 40 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 10 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.state == SearchTVCStateDefault) {
        if(self.mode == SearchTVCModeWines) {
            if(indexPath.section == 0) {
                PFObject<SearchableSubclass> *object = _displayedCheckins ? [_displayedCheckins objectAtIndex:indexPath.row] : nil;
                return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [WineCell getExtendedHeight:object] : [WineCell getDefaultHeight];
            } else
                return RECENT_SEARCH_CELL_HEIGHT;
        } else if(self.mode == SearchTVCModeUsers) {
            if(indexPath.section == 0)
                return RECENT_SEARCH_CELL_HEIGHT;
            else
                return [UserCell getDefaultHeight];
        } else if(self.mode == SearchTVCModeWinery) {
            return [WineryCell getDefaultHeight];
        } else if(self.mode == SearchTVCModeRegion) {
            return 0;
        }
    } else {
        if(indexPath.section == 2)
            return 40;
        else {
            PFObject<SearchableSubclass> *object = _results ? [_results objectAtIndex:indexPath.row] : nil;
            return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [[object getAssociatedCell] getExtendedHeight:object] : [[object getAssociatedCell] getDefaultHeight];
        }
    }
    
    return 0;
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

+ (CGFloat)similarityBetween:(NSString *)string1 and:(NSString *)string2 {
    NSString *longer = string1, *shorter = string2;
    if(string1.length < string2.length) {
        longer = string2;
        shorter = string1;
    }
    
    CGFloat longerLength = (CGFloat)longer.length;
    if(longerLength == 0)
        return 1;
    
    return (longerLength - [self editDistance:longer and:shorter]) / longerLength;
}

+ (NSInteger)editDistance:(NSString *)s1 and:(NSString *)s2 {
    s1 = [s1 lowercaseString];
    s2 = [s2 lowercaseString];
    
    NSMutableArray<NSNumber *> *costs = [[NSMutableArray alloc] init];
    for (int i = 0; i <= s1.length; i++) {
        NSInteger lastValue = i;
        for (int j = 0; j <= s2.length; j++) {
            if(i == 0)
                [costs insertObject:@(j) atIndex:j];
            else {
                if (j > 0) {
                    NSInteger newValue = [[costs objectAtIndex:j - 1] integerValue];
                    if ([s1 characterAtIndex:i - 1] != [s2 characterAtIndex:j - 1])
                        newValue = MIN(MIN(lastValue, newValue), [[costs objectAtIndex:j] integerValue]) + 1;
                    
                    [costs replaceObjectAtIndex:j - 1 withObject:@(lastValue)];
                    lastValue = newValue;
                }
            }
        }
        
        if(i > 0)
            [costs replaceObjectAtIndex:s2.length withObject:@(lastValue)];
    }
    
    return [[costs objectAtIndex:s2.length] integerValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.state == SearchTVCStateDefault) {
        if(self.mode == SearchTVCModeWines) {
            if(section == 0) {
                return _displayedCheckins ? [_displayedCheckins count] : 0;
            } else {
                return [[_user getRecentSearchesObjects] count];
            }
        } else if(self.mode == SearchTVCModeUsers) {
            if(section == 0) {
                return 1;
            } else {
                return _displayedFriends != nil ? [_displayedFriends count] : 0;
            }
        } else if(self.mode == SearchTVCModeWinery) {
            if(section == 0) {
                return _followedWineries ? [_followedWineries count] : 0;
            } else {
                if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
                    return 1;
                else
                    return _nearbyWineries ? [_nearbyWineries count] : 0;
            }
        } else if(self.mode == SearchTVCModeRegion) {
            return _popularRegions ? [_popularRegions count] : 0;
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.state == SearchTVCStateDefault) {
        return self.mode == SearchTVCModeWines || self.mode == SearchTVCModeWinery || self.mode == SearchTVCModeUsers ? 2 : 1;
    } else {
        if(topResult)
            if([_results count] >= 20)
                return 3;
            else
                return 2;
            else
                return 1;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((self.mode == SearchTVCModeWines && indexPath.section == 1)) && self.state == SearchTVCStateDefault;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(((self.mode == SearchTVCModeWines && indexPath.section == 1)) &&
       self.state == SearchTVCStateDefault &&
       editingStyle == UITableViewCellEditingStyleDelete) {
        User *user = [User currentUser];
        NSString *searchString = [[user getRecentSearchesObjects] objectAtIndex:indexPath.row];
        
        NSLog(@"attempt to delete recentSearch: %@", searchString);
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell endEditing:YES];
        
        [user removeRecentSearchesObject:searchString];
        [user saveInBackground];
        [tableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    if(self.state == SearchTVCStateDefault) {
        User *user = [User currentUser];
        
        if(self.mode == SearchTVCModeWines) {
            if(indexPath.section == 0) {
                unWine *wine = [_displayedCheckins objectAtIndex:indexPath.row];
                WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
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
        } else if(self.mode == SearchTVCModeUsers) {
            if(indexPath.section == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundColor = CI_MIDDGROUND_COLOR;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tintColor = [UIColor whiteColor];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.text = @"Tap here to Invite Friends";
                [cell.textLabel sizeToFit];
                
                return cell;
            } else if(indexPath.section == 1) {
                UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
                cell.delegate = self;
                cell.singleTheme = unWineThemeDark;
                
                [cell setup:indexPath];
                [cell configure:_displayedFriends && [_displayedFriends count] ? [_displayedFriends objectAtIndex:indexPath.row] : [User currentUser]];
                
                return cell;
            }
        } else if(self.mode == SearchTVCModeWinery) {
            if(indexPath.section == 0) {
                Winery *winery = [_followedWineries objectAtIndex:indexPath.row];
                WineryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineryCell"];
                cell.source = WineryCellSourceWinerySearchView;
                cell.delegate = self;
                
                [cell setup:indexPath];
                [cell configure:winery];
                
                return cell;
            } else if(indexPath.section == 1) {
                if([_nearbyWineries count] > indexPath.row) {
                    Winery *winery = [_nearbyWineries objectAtIndex:indexPath.row];
                    WineryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineryCell"];
                    cell.source = WineryCellSourceWinerySearchView;
                    cell.delegate = self;
                    
                    [cell setup:indexPath];
                    [cell configure:winery];
                    
                    return cell;
                } else {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.backgroundColor = CI_MIDDGROUND_COLOR;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tintColor = [UIColor whiteColor];
                    cell.textLabel.textColor = [UIColor whiteColor];
                    cell.textLabel.numberOfLines = 0;
                    cell.textLabel.text = @"Tap here to enable Location Services, and find wineries nearby!";
                    [cell.textLabel sizeToFit];
                    
                    return cell;
                }
            }
        } else if(self.mode == SearchTVCModeRegion) {
            //TODO: cell to represent popular regions, similar to Recent Searches cell
        }
    } else {
        if(topResult && indexPath.section == 0) {
            if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion) {
                WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
                cell.delegate = self;
                if(self.mode == SearchTVCModeRegion)
                    cell.subtitleMode = WineCellSubtitleModeRegion;
                
                [cell setup:indexPath];
                [cell configure:(unWine *)topResult mode:WineCellModeTopResult];
                
                return cell;
            } else if(self.mode == SearchTVCModeUsers) {
                UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
                cell.delegate = self;
                cell.singleTheme = unWineThemeDark;
                
                [cell setup:indexPath];
                [cell configure:(User *)topResult];
                
                return cell;
            } else if(self.mode == SearchTVCModeWinery) {
                WineryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineryCell"];
                cell.delegate = self;
                
                [cell setup:indexPath];
                [cell configure:(Winery *)topResult];
                
                return cell;
            }
        } else {
            PFObject<SearchableSubclass> *object = [[self getBottomResults] objectAtIndex:indexPath.row];
            
            if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion) {
                WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
                cell.delegate = self;
                if(self.mode == SearchTVCModeRegion)
                    cell.subtitleMode = WineCellSubtitleModeRegion;
                
                [cell setup:indexPath];
                [cell configure:(unWine *)object mode:WineCellModeResult];
                
                return cell;
            } else if(self.mode == SearchTVCModeUsers) {
                UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
                cell.delegate = self;
                cell.singleTheme = unWineThemeDark;
                
                [cell setup:indexPath];
                [cell configure:(User *)object];
                
                return cell;
            } else if(self.mode == SearchTVCModeWinery) {
                WineryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineryCell"];
                cell.delegate = self;
                
                [cell setup:indexPath];
                [cell configure:(Winery *)object];
                
                return cell;
            }
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion) {
        if([cell isKindOfClass:[RecentSearchCell class]]){
            [(RecentSearchCell *)cell interact:nil];
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_RECENT_SEARCH);
        } else if(indexPath.section == 2) {
            MoreResultsTVC *results = [[MoreResultsTVC alloc] initWithStyle:UITableViewStylePlain];
            results.mode = self.mode;
            results.searchString = [[self.searchController.searchBar text] lowercaseString];
            [self.navigationController pushViewController:results animated:YES];
        }
    } else if(self.mode == SearchTVCModeUsers) {
        if([cell isKindOfClass:[UserCell class]]) {
            [self trackUserSelectionWithIndexPath:indexPath];
            [(UserCell *)cell profilePressed];
        } else {
            [self resignAndSave:NO];
            [[(GET_APP_DELEGATE).ctbc getProfileVC].profileTable inviteFriends:self];
        }
    } else if(self.mode == SearchTVCModeWinery) {
        if(indexPath.section == 1 && [_nearbyWineries count] <= indexPath.row) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

- (void)trackUserSelectionWithIndexPath:(NSIndexPath *)indexPath {
    if (self.mode != SearchTVCModeUsers) {
        return;
    }
    
    if (self.state == SearchTVCStateDefault) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_EXISTING_FRIEND_ON_FRIEND_VIEW);
    } else {
        if (indexPath.section == 0) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_TOP_USER_AFTER_SEARCHING);
        } else{
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_ON_USER_AFTER_SEARCHING);
        }
    }
}

#pragma Cell Delegate Methods

- (void)expressPressed:(NSString *)searchString {
    [self.searchController.searchBar setText:searchString];
    //if(![self.searchController.searchBar isFirstResponder])
    [self updateRecents:searchString];
    [self resignAndSave:NO];
}

- (UIView *)wineMorePresentationView {
    return self.navigationController.view;
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showHUD {
    SHOW_HUD_FOR_VIEW(self.navigationController.view);
}

- (void)hideHUD {
    HIDE_HUD_FOR_VIEW(self.navigationController.view);
}

- (void)updateCells {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)reconfigureCells {
    for(UITableViewCell *cell in self.tableView.visibleCells) {
        if([cell isKindOfClass:[UserCell class]]) {
            UserCell *userCell = (UserCell *)cell;
            [userCell reconfigure];
        }
    }
}

#pragma Other Stuff

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
    
    /*if(!self.isViewLoaded || !self.view.window) {
     [addWineButton removeFromSuperview];
     return;
     }
     
     if(![addWineButton superview]) {
     [addWineButton setFrame:(CGRect){0, 20 + NAVIGATION_BAR_HEIGHT, {SCREEN_WIDTH, 0}}];
     [self.navigationController.view addSubview:addWineButton];
     }
     
     if(animated) {
     [UIView animateWithDuration:.3 animations:^{
     [addWineButton setFrame:(CGRect){0, 20 + NAVIGATION_BAR_HEIGHT, {SCREEN_WIDTH, 28}}];
     }];
     } else
     [addWineButton setFrame:(CGRect){0, 20 + NAVIGATION_BAR_HEIGHT, {SCREEN_WIDTH, 28}}];*/
    
    self.tableView.tableHeaderView = addWineButton;
}

- (void)hideAddWineButton:(BOOL)animated {
    /*if(animated) {
     [UIView animateWithDuration:.3 animations:^{
     [addWineButton setFrame:(CGRect){0, 20 + NAVIGATION_BAR_HEIGHT, {SCREEN_WIDTH, 0}}];
     } completion:^(BOOL finished) {
     [addWineButton removeFromSuperview];
     }];
     } else {
     [addWineButton setFrame:(CGRect){0, 20 + NAVIGATION_BAR_HEIGHT, {SCREEN_WIDTH, 0}}];
     [addWineButton removeFromSuperview];
     }*/
    
    self.tableView.tableHeaderView = nil;
}

- (void)pressedAddWine {
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = nil;
    container.isNew = YES;
    container.cameFrom = CastCheckinSourceSomewhere;
    
    [self presentViewControllerFromCell:container];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
