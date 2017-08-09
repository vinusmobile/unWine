//
//  WineProfileTVC.m
//  unWine
//
//  Created by Bryce Boesen on 8/14/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineProfileTVC.h"
#import "WineProfileCell.h"
#import "WineContainerVC.h"
#import "UITableViewController+Helper.h"

@import Charts;

typedef enum WineProfileType {
    WineProfileTypeCheckinCount,
    WineProfileTypeCheckinLastWeek,
    WineProfileTypeFavorite,
    WineProfileTypeVarietalBreakdown,
    WineProfileTypeColorBreakdown,
    WineProfileTypeMeritCount,
    WineProfileTypeMeritLastWeek
} WineProfileType;

@interface WineProfileTVC () <ChartViewDelegate>

@end

@implementation WineProfileTVC {
    NSArray *sectionTitles;
    NSArray *cellTypes;
    
    NSArray *checkins;
    NSArray *merits;
    NSArray *wines;
    
    UIView *shadowView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *user = [User currentUser];
    if(user.checkIns < 5) {
        shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, HEIGHT(self.view))];
        shadowView.backgroundColor = [UIColor blackColor];
        shadowView.alpha = .92;
        
        UILabel *shadowLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, HEIGHT(self.view) / 2 - 200, SCREEN_WIDTH - 40, 200)];
        [shadowLabel setText:@"You need to perform 5 checkins to unlock this feature!"];
        [shadowLabel setTextColor:[UIColor whiteColor]];
        [shadowLabel setFont:[UIFont fontWithName:@"OpenSans" size:18]];
        [shadowLabel setTextAlignment:NSTextAlignmentCenter];
        shadowLabel.numberOfLines = 0;
        [shadowView addSubview:shadowLabel];
        
        [self.navigationController.view addSubview:shadowView];
        [Analytics trackGenericEvent:EVENT_USER_VIEWED_WINE_STATS_AND_BLOCKED];
    } else
        [Analytics trackGenericEvent:EVENT_USER_VIEWED_WINE_STATS];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(shadowView)
        [shadowView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sectionTitles = @[@"Checkins", @"Varietal Breakdown", @"Merits"];
    cellTypes = @[
                  @[@(WineProfileTypeCheckinCount), @(WineProfileTypeCheckinLastWeek), @(WineProfileTypeFavorite)],
                  @[@(WineProfileTypeVarietalBreakdown)],
                  @[@(WineProfileTypeMeritCount), @(WineProfileTypeMeritLastWeek)]
                ];
    
    [self fetchCheckins];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Feedback" style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedback)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[WineProfileCell class] forCellReuseIdentifier:@"WineProfileCell"];
    [self basicAppeareanceSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)sendFeedback {
    [Analytics trackGenericEvent:EVENT_USER_STARTED_TO_SEND_WINE_PROFILE_FEEDBACK];
    [(GET_APP_DELEGATE).ctbc showUserVoice];
}

- (void)fetchCheckins {
    User *user = [User currentUser];
    if(user.checkIns < 5)
        return;
    
    PFQuery *query = [NewsFeed query];
    [query whereKey:@"authorPointer" equalTo:user];
    [query whereKey:@"Type" equalTo:@"Wine"];
    [query includeKey:@"authorPointer"];
    [query includeKey:@"authorPointer.level"];
    [query includeKey:@"unWinePointer"];
    [query includeKey:@"unWinePointer.partner"];
    [query orderByAscending:@"name"];
    query.limit = 1000;
    
    PFQuery *query2 = [Merits query];
    [query2 whereKey:@"objectId" containedIn:user.earnedMerits];
    [query2 orderByAscending:@"name"];
    query2.limit = 1000;
    
    NSArray *tasks = @[[query findObjectsInBackground], [query2 findObjectsInBackground]];
    
    SHOW_HUD;
    [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        BFTask *checkinTask = [tasks objectAtIndex:0];
        BFTask *meritsTask = [tasks objectAtIndex:1];
        
        checkins = checkinTask.result;
        merits = meritsTask.result;
        wines = [user filterNewsFeedIntoWines:checkins];
        
        HIDE_HUD;
        [self.tableView reloadData];
        
        return nil;
    }];
}

- (unWine *)wineWithId:(NSString *)objectId {
    for(unWine *wine in wines)
        if([wine.objectId isEqualToString:objectId])
            return wine;
    
    return nil;
}

- (NSArray *)getMostCheckedIn {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    for(NewsFeed *checkin in checkins) {
        if(checkin.unWinePointer && ![checkin.unWinePointer isKindOfClass:[NSNull class]]) {
            CGFloat adjuster = checkin.reactionType && [checkin.reactionType doubleValue] > 0 ? [checkin.reactionType doubleValue] / 2.5f : 1;
            unWine *wine = checkin.unWinePointer;
            if([[data allKeys] containsObject:wine.objectId])
                data[wine.objectId] = @([data[wine.objectId] doubleValue] + 1 * adjuster);
            else
                data[wine.objectId] = @(1 * adjuster);
        }
    }
    
    NSArray *sorted = [data keysSortedByValueUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 doubleValue] < [obj2 doubleValue])
            return (NSComparisonResult)NSOrderedDescending;
        
        if ([obj1 doubleValue] > [obj2 doubleValue])
            return (NSComparisonResult)NSOrderedAscending;
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sorted;
}

- (NSDictionary *)getVarietalBreakdown {
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    NSArray *supported = @[@"cabernet sauvignon",
                           @"pinot noir",
                           @"malbec",
                           @"blush",
                           @"pinot grigio",
                           @"merlot",
                           @"syrah",
                           @"riesling",
                           @"grenache",
                           @"sauvignon blanc",
                           @"chardonnay",
                           @"moscato"];
    for(unWine *wine in wines) {
        if(!ISVALID(wine.varietal))
            continue;
        
        NSString *varietal = [[wine.varietal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        //special circumstances
        if([varietal isEqualToString:@"red blend"])
            varietal = @"blush";
        if([varietal isEqualToString:@"pinot gris"])
            wine.varietal = @"pinot grigio";
        if([wine.varietal isEqualToString:@"grenacha"])
            wine.varietal = @"grenache";
        
        if([supported containsObject:varietal]) {
            if([[data allKeys] containsObject:varietal])
                data[varietal] = @([data[varietal] integerValue] + 1);
            else
                data[varietal] = @(1);
        } else {
            if([[data allKeys] containsObject:@"other"])
                data[@"other"] = @([data[@"other"] integerValue] + 1);
            else
                data[@"other"] = @(1);
        }
    }
    
    CGFloat sum = 0;
    for(NSString *key in [data allKeys])
        sum += [data[key] integerValue];
    
    for(NSString *key in [data allKeys])
        data[key] = @([data[key] floatValue] / sum);
    
    return data;
}

- (NSArray *)getLastWeeksMerits {
    NSMutableArray *lastWeek = [[NSMutableArray alloc] init];
    
    NSDate *sevenDaysAgo = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    for(NewsFeed *checkin in checkins)
        if([checkin.createdAt compare:sevenDaysAgo] == NSOrderedDescending) {
            if(checkin.meritPointer && ![checkin.meritPointer isKindOfClass:[NSNull class]])
                [lastWeek addObject:checkin.meritPointer];
            
            if(checkin.connectedMerits && [checkin.connectedMerits count] > 0) {
                for(Merits *merit in checkin.connectedMerits)
                    if(merit)
                       [lastWeek addObject:merit];
            }
        }
    
    //NSLog(@"lastWeek merits - %@", lastWeek);
    
    return lastWeek;
}

- (NSArray *)getLastWeeksCheckins {
    NSMutableArray *lastWeek = [[NSMutableArray alloc] init];
    
    NSDate *sevenDaysAgo = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    for(NewsFeed *checkin in checkins)
        if([checkin.createdAt compare:sevenDaysAgo] == NSOrderedDescending)
            [lastWeek addObject:checkin];
    
    //NSLog(@"lastWeek checkins - %@", lastWeek);
    
    return lastWeek;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return checkins && [checkins count] > 0 ? [cellTypes count] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[cellTypes objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionTitles objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WineProfileType cellType = (WineProfileType)[[[cellTypes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    if(cellType == WineProfileTypeVarietalBreakdown || cellType == WineProfileTypeColorBreakdown)
        return 180;
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WineProfileType cellType = (WineProfileType)[[[cellTypes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    
    if(cellType == WineProfileTypeCheckinCount) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"You've checked in %lu time%@!", (unsigned long)[checkins count], [checkins count] == 1 ? @"" : @"s"];
        
        return cell;
    } else if(cellType == WineProfileTypeCheckinLastWeek) {
        NSArray *lastWeek = [self getLastWeeksCheckins];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"%lu checkin%@ in the past week!", (unsigned long)[lastWeek count], [lastWeek count] == 1 ? @"" : @"s"];
        
        return cell;
    } else if(cellType == WineProfileTypeFavorite) {
        NSArray *topCheckins = [self getMostCheckedIn];
        NSString *favorite = [[self wineWithId:[topCheckins firstObject]].name capitalizedString];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"Your go-to wine is %@!", favorite];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if(cellType == WineProfileTypeVarietalBreakdown) {
        WineProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineProfileCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        PieChartView *pieChart = [self pieChart:@"" fromData:[self getVarietalBreakdown]];
        [cell addSubview:pieChart];
        
        return cell;
    }else if(cellType == WineProfileTypeMeritCount) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"You have %lu merit%@!", (unsigned long)[merits count], [merits count] == 1 ? @"" : @"s"];
        return cell;
    } else if(cellType == WineProfileTypeMeritLastWeek) {
        NSArray *lastWeek = [self getLastWeeksMerits];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [NSString stringWithFormat:@"You earned %lu merit%@ this past week!", (unsigned long)[lastWeek count], [lastWeek count] == 1 ? @"" : @"s"];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WineProfileType cellType = (WineProfileType)[[[cellTypes objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    if(cellType == WineProfileTypeFavorite) {
        NSArray *topCheckins = [self getMostCheckedIn];
        unWine *wine = [self wineWithId:[topCheckins firstObject]];
        if(wine) {
            [Analytics trackGenericEvent:EVENT_USER_VIEWED_FAVORITE_WINE];
            WineContainerVC *container = [[WineContainerVC alloc] init];
            container.wine = wine;
            container.isNew = NO;
            container.cameFrom = CastCheckinSourceWineProfileFavorite;
            [self.navigationController pushViewController:container animated:YES];
        }
    }
}

- (PieChartView *)pieChart:(NSString *)title fromData:(NSDictionary *)data {
    PieChartView *pieChart = [[PieChartView alloc] initWithFrame:CGRectMake(4, 4, SCREEN_WIDTH, 172)];
    pieChart.delegate = self;
    pieChart.descriptionText = @"";
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for(NSString *key in [data allKeys]) {
        [values addObject:[[ChartDataEntry alloc] initWithX:(NSInteger)([data[key] doubleValue] * 100) y:i++]];
    }

    PieChartDataSet *dataset = [[PieChartDataSet alloc] initWithValues:values label:title];
    PieChartData *pieChartData = [[PieChartData alloc] initWithDataSets:@[dataset]];
    dataset.colors = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor],
                       [UIColor purpleColor], [UIColor orangeColor], [UIColor grayColor],
                       [UIColor cyanColor], [UIColor magentaColor], [UIColor yellowColor]];
    dataset.valueColors = @[[UIColor whiteColor]];
    dataset.valueFont = [UIFont fontWithName:@"OpenSans" size:10];
    //dataset.highlightEnabled = NO;
    dataset.valueTextColor = [UIColor clearColor];
    
    //pieChart.usePercentValuesEnabled = YES;
    pieChart.data = pieChartData;
    return pieChart;
}

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * _Nonnull)highlight {
    [chartView setHighlighter:nil];
}

@end
