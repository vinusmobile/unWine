//
//  FriendsTVC.m
//  unWine
//
//  Created by Bryce Boesen on 8/8/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CellarTVC.h"
#import "ParseSubclasses.h"

@interface CellarTVC () <MultiWinesCellDelegate, UISearchBarDelegate>

@property (nonatomic) UISearchBar *searchBar;

@end

@implementation CellarTVC {
    NSArray *cellar;
    UIView *resultsView;
    NSArray *filtered;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    self.searchBar.placeholder = @"Filter your Wish List by name or varietal";
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
    filtered = cellar;
    
    if(![self.searchBar.text isEqualToString:@""]) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(unWine *wine in cellar) {
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

- (BFTask *)getCellarTask {
    PFQuery *cellarList = [self.user.theCellar query];
    [cellarList includeKey:@"partner"];
    return [cellarList countObjectsInBackground];
}

- (void)pullRefresh {
    if(self.profileTVC != nil)
        [self.profileTVC updateCounts];
    [self loadObjects];
}

- (NSInteger)cellarCount {
    return self.user.cellarCount;
}

- (void)loadObjects {
    PFQuery *cellarList = [self.user.theCellar query];
    [cellarList includeKey:@"partner"];
    SHOW_HUD;
    [cellarList findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        HIDE_HUD;
        cellar = [objects copy];
        [self filterWines];
        if([self.user isTheCurrentUser]) {
            self.user.cellarCount = [cellar count];
            [self.user saveInBackground];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self emptyResultsView].alpha = [filtered count] == 0 ? 1 : 0;
            [self.profileTVC updateCount:[cellar count] atIndex:2];
            
            [self.tableView reloadData];
            
            if(self.refreshControl != nil && [self.refreshControl isRefreshing])
                [self.refreshControl endRefreshing];
        });
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
    [header setText:@"Wish List"];
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
    return 138.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MultiWinesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiWinesCell"];
    
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
    
    if([filtered count] == 0 && [cellar count] > 0)
        [noResultsLabel setText:@"No results found."];
    else if([self.user isTheCurrentUser])
        [noResultsLabel setText:@"Every aspiring Maestro needs a Wine Wish List, this one is yours! Add wines and remember them for later."];
    else
        [noResultsLabel setText:@"This user has nothing in their Wish List, how drab!"];
    
    return resultsView;
}

@end
