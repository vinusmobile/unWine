//
//  DiscoverTVC.m
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "DiscoverTVC.h"
#import "DiscoverCell.h"
#import "MultiWinesCell.h"
#import "PopularWinesTVC.h"
#import "WineWorldVC.h"
#import "SearchTVC.h"
#import "VineCastTVC.h"

#define WINERY_ICON     [UIImage imageNamed:@"wineryIcon"]
#define REGION_ICON     [UIImage imageNamed:@"newRegionIcon"]
#define RATING_ICON     [UIImage imageNamed:@"newHeartIcon"]
#define FAVORITE_ICON     [UIImage imageNamed:@"newFavoriteIcon"]
#define WINE_WORLD_ICON     [UIImage imageNamed:@"newWorldIcon"]

@interface DiscoverTVC () <MultiWinesCellDelegate, WineWorldDelegate>

@end

@implementation DiscoverTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"default bg - %@", self.tableView.backgroundColor);
    self.view.backgroundColor = [ThemeHandler getDeepBackgroundColor:unWineThemeDark];
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView registerClass:[DiscoverCell class] forCellReuseIdentifier:@"DiscoverCell"];
    [self.tableView registerClass:[MultiWinesCell class] forCellReuseIdentifier:@"MultiWinesCell"];
    
    // Nav bar setup
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationItem.backBarButtonItem.title = @"Back";
    self.navigationItem.title = @"Discover";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tabBarController.tabBar.translucent = NO;
    
    // White Status Bar for controllers inside Navigation Controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // Not sure why this works lol
    
    //[self basicAppeareanceSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Discover";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Back";
}

#pragma Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? ([self hasFeaturedWines] ? 1 : 0) : 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? [MultiWinesCell getDefaultHeight] : DISCOVER_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 40 : 0;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 10 : 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Featured Wines";
    
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, section == 0 ? ([self hasFeaturedWines] ? 40 : 0) : 40}}];
    headerView.backgroundColor = [ThemeHandler getBackgroundColor:unWineThemeDark];
    headerView.clipsToBounds = YES;
    
    UILabel *header = [[UILabel alloc] initWithFrame:(CGRect){12, 0, {SCREEN_WIDTH - 24, 40}}];
    header.textColor = [UIColor whiteColor];
    [header setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    if(section == 0)
        [header setText:@"Featured Wines"];
    else
        [header setText:@""];
    [headerView addSubview:header];
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [[ThemeHandler getSeperatorColor:unWineThemeDark] CGColor];
    border.frame = CGRectMake(0, headerView.frame.size.height - 1, headerView.frame.size.width, .5);
    [headerView.layer addSublayer:border];
    
    CALayer *border2 = [CALayer layer];
    border2.backgroundColor = [[ThemeHandler getSeperatorColor:unWineThemeDark] CGColor];
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
        border.backgroundColor = [[ThemeHandler getDeepBackgroundColor:unWineThemeDark] CGColor];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        MultiWinesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiWinesCell"];
        cell.delegate = self;
        
        [cell setup:indexPath];
        [cell preconfigure:[unWine getFeaturedWines]];
        cell.clipsToBounds = YES;
        
        return cell;
    } else if(indexPath.section == 1) {
        DiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoverCell"];
        cell.delegate = self;

        [cell setup:indexPath];
        if(indexPath.row == 0)
            [cell configure:WINERY_ICON title:@"Search for Wineries" subtitle:@"Find the wineries, find the wines!"];
        //else if(indexPath.row == 1)
        //    [cell configure:REGION_ICON title:@"Search by Region" subtitle:@"Find wines by their region!"];
        //else if(indexPath.row == 2)
        //    [cell configure:RATING_ICON title:@"Popular Wines" subtitle:@"The most checked in wines!"];
        else if(indexPath.row == 1)
            [cell configure:FAVORITE_ICON title:@"Great Wines" subtitle:@"Wines that received the Great reaction!"];
        else if(indexPath.row == 2)
            [cell configure:WINE_WORLD_ICON title:@"Wines Nearby" subtitle:@"View the wineries/wine bars near you!"];
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    if([cell isKindOfClass:[DiscoverCell class]]) {
        DiscoverCell *discover = (DiscoverCell *)cell;
        if(discover.indexPath.row == 0) {
            SearchTVC *search = [[SearchTVC alloc] init];
            search.mode = SearchTVCModeWinery;
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_SEARCH_FOR_WINERIES_FROM_DISCOVER_VIEW);
            [self.navigationController pushViewController:search animated:YES];
        /*} else if(discover.indexPath.row == 1) {
            SearchTVC *search = [[SearchTVC alloc] init];
            search.mode = SearchTVCModeRegion;
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_SEARCH_BY_REGION_FROM_DISCOVER_VIEW);
            [self.navigationController pushViewController:search animated:YES];
        } else if(discover.indexPath.row == 2) {
            PopularWinesTVC *popular = [[PopularWinesTVC alloc] init];
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_POPULAR_WINES_FROM_DISCOVER_VIEW);
            [self.navigationController pushViewController:popular animated:YES];*/
        } else if(discover.indexPath.row == 1) {
            VineCastTVC *vinecast = [[UIStoryboard storyboardWithName:@"VineCast" bundle:nil] instantiateViewControllerWithIdentifier:@"feed"];
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_GREAT_WINES_FROM_DISCOVER_VIEW);
            vinecast.gridMode = false;
            vinecast.state = VineCastStateGreatWines;
            vinecast.gridState = VineCastGridStateGreatWines;
            [self.navigationController pushViewController:vinecast animated:YES];
        } else if(discover.indexPath.row == 2) {
            WineWorldVC *world = [[WineWorldVC alloc] init];
            world.delegate = self;
            ANALYTICS_TRACK_EVENT(EVENT_USER_TAPPED_WINE_WORLD_FROM_DISCOVER_VIEW);
            [self.navigationController pushViewController:world animated:YES];
        }
    }
}

- (BOOL)hasFeaturedWines {
    return [[unWine getFeaturedWines] count] > 0;
}

@end
