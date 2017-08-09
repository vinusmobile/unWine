//
//  UniqueWinesTVC.m
//  unWine
//
//  Created by Bryce Boesen on 8/25/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "UniqWinesTVC.h"
#import "ParseSubclasses.h"

@interface UniqWinesTVC () <MultiWinesCellDelegate, UISearchBarDelegate>

@property (nonatomic) UISearchBar *searchBar;

@end

@implementation UniqWinesTVC {
    NSArray *uniqueWines;
    UIView *resultsView;
    BOOL hadFirstLoad;
    NSArray *filtered;
}

- (void)viewWillAppear:(BOOL)animated {
    if(hadFirstLoad)
        [self loadObjects];
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadObjects];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    self.searchBar.placeholder = @"Filter your checked in wines by name or varietal";
    self.searchBar.barTintColor = UNWINE_RED;
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.searchBar action:@selector(resignFirstResponder)];
    barButton.tintColor = UNWINE_RED;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    self.searchBar.inputAccessoryView = toolbar;
    
    [self.searchBar setDelegate:self];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.view.backgroundColor = [ThemeHandler getDeepBackgroundColor:unWineThemeDark];
    self.tableView.separatorColor = [UIColor clearColor];
    
    if(self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor clearColor];
        //self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(pullRefresh)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    [self.tableView registerClass:[MultiWinesCell class] forCellReuseIdentifier:@"MultiWinesCell"];
    [self basicAppeareanceSetup];
    
    [self.view addSubview:[self emptyResultsView]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterWines];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    //[self filterWines];
    
    [self.tableView reloadData];
}

- (void)filterWines {
    filtered = uniqueWines;
    
    if(![self.searchBar.text isEqualToString:@""]) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(unWine *wine in uniqueWines) {
            BOOL passing = YES;
            
            NSArray *split = [self.searchBar.text componentsSeparatedByString:@" "];
            for(NSString *word in split)
                passing &= [wine.words containsObject:[word lowercaseString]];
            
            passing |= [wine.name containsString:[self.searchBar.text lowercaseString]];
            
            if(passing)
                [arr addObject:wine];
        }
        filtered = arr;
    }
}

- (NSInteger)uniqueCount {
    return self.user.uniqueWines;
}

- (void)pullRefresh {
    [self loadObjects];
}

- (void)loadObjects {
    [[self.user getUniqWines] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id (BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
            if(!uniqueWines)
                uniqueWines = @[];
            return nil;
        }
        uniqueWines = task.result;
        [self filterWines];
        
        [self emptyResultsView].alpha = [filtered count] == 0 ? 1 : 0;
        
        [self.profileTVC updateCount:[uniqueWines count] atIndex:1];
        if([self.user isTheCurrentUser]) {
            self.user.uniqueWines = [uniqueWines count];
            [self.user saveInBackground];
        }
        [self.tableView reloadData];
        
        if(self.refreshControl != nil && [self.refreshControl isRefreshing])
            [self.refreshControl endRefreshing];
        
        hadFirstLoad = YES;
        
        return nil;
    }];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [filtered count] > 0 ? 40 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 40}}];
    headerView.backgroundColor = [ThemeHandler getBackgroundColor:unWineThemeDark];
    headerView.clipsToBounds = YES;
    
    UILabel *header = [[UILabel alloc] initWithFrame:(CGRect){12, 0, {SCREEN_WIDTH - 24, 40}}];
    header.textColor = [UIColor whiteColor];
    [header setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    [header setText:@"Unique Wines"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filtered != nil ? ([filtered count] + IMAGE_PER_CELL - 1) / IMAGE_PER_CELL : 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MultiWinesCell getDefaultHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MultiWinesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UniqWinesCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    [cell setup:indexPath];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for(NSInteger i = IMAGE_PER_CELL * indexPath.row;
        i < IMAGE_PER_CELL * indexPath.row + IMAGE_PER_CELL && i < [filtered count]; i++) {
        unWine *object = [filtered objectAtIndex:i];
        if(object != nil)
            [objects addObject:object];
    }
    [cell configure:[objects copy]];
    
    return cell;
}

#pragma Other Stuff

- (UIView *)emptyResultsView {
    UILabel *noResultsLabel;
    if(!resultsView) {
        resultsView = [[UIView alloc] initWithFrame:self.tableView.frame];
        resultsView.alpha = filtered && [filtered count] == 0 ? 1 : 0;
        
        noResultsLabel = [[UILabel alloc] initWithFrame:(CGRect){20, (HEIGHT(resultsView) - 128) / 2, {SCREEN_WIDTH - 40, 128}}];
        [noResultsLabel setTextAlignment:NSTextAlignmentCenter];
        [noResultsLabel setTextColor:[ThemeHandler getForegroundColor:unWineThemeDark]];
        [noResultsLabel setFont:[UIFont fontWithName:@"OpenSans-Italics" size:16]];
        noResultsLabel.numberOfLines = 0;
        noResultsLabel.tag = 10;
        [resultsView addSubview:noResultsLabel];
    } else
        noResultsLabel = [[resultsView subviews] objectAtIndex:0];
    
    if([filtered count] == 0 && [uniqueWines count] > 0)
        [noResultsLabel setText:@"No results found."];
    else if([self.user isTheCurrentUser])
        [noResultsLabel setText:@"Don't be timid. Do your palate a favor by exploring new wines! All of the unique wines you check-in will go here!"];
    else
        [noResultsLabel setText:@"This user hasn't checked in any wines."];
    
    return resultsView;
}

@end
