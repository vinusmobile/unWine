//
//  WineryTVC.m
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineryTVC.h"
#import "WineCell.h"

@interface WineryTVC () <WineCellDelegate>

@end

@implementation WineryTVC {
    NSInteger page;
    NSInteger preCount;
    NSInteger lastLoadCount;
}
@synthesize singleTheme, extendedPath;

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 20;
        self.loadingViewEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    singleTheme = unWineThemeDark;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
    self.tableView.backgroundColor = [ThemeHandler getDeepBackgroundColor:singleTheme];
    self.tableView.separatorColor = [UIColor clearColor];//[ThemeHandler getSeperatorColor:singleTheme];
    self.tableView.clipsToBounds = NO;
    [self.tableView registerClass:[WineCell class] forCellReuseIdentifier:@"WineCell"];
    
    [self loadObjects];
}
#pragma PF Delegate Methods

- (PFQuery *)queryForTable {
    PFQuery *query = [unWine query];
    [query includeKey:@"partner"];
    [query whereKey:@"vineyard" equalTo:[self.winery.name lowercaseString]];
    return query;
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    lastLoadCount = 0;
    preCount = self.objects ? [self.objects count] : 0;
    SHOW_HUD_FOR_VIEW(self.parent.view);
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    lastLoadCount = [self.objects count] - preCount;
    preCount = 0;
    HIDE_HUD_FOR_VIEW(self.parent.view);
}

#pragma ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            if(lastLoadCount >= self.objectsPerPage)
                [self loadNextPage];
        }
    }
}

#pragma TableView Stuff

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}*/

/*- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects ? [self.objects count] : 0;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.objects && [self.objects count] > indexPath.row) {
        PFObject<SearchableSubclass> *object = self.objects ? [self.objects objectAtIndex:indexPath.row] : nil;
        return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [WineCell getExtendedHeight:object] : [WineCell getExtendedHeight:object] - 20;//self.extendedPath && [self.extendedPath isEqual:indexPath] ? [WineCell getExtendedHeight:object] : [WineCell getDefaultHeight];
    } else
        return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.objects && [self.objects count] > indexPath.row) {
        unWine *wine = [self.objects objectAtIndex:indexPath.row];
        WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
        if(!cell)
            cell = [[WineCell alloc] init];
        cell.delegate = self;
        cell.assumeExtended = YES;
        cell.source = WineCellSourceWinery;
        
        [cell setup:indexPath];
        [cell configure:wine];
        
        return cell;
    }
    
    UITableViewCell *basic = [[UITableViewCell alloc] init];
    basic.backgroundColor = [UIColor clearColor];
    return basic;
}

#pragma Delegate Stuff

- (void)updateTheme {
    
}

- (UIView *)wineMorePresentationView {
    return self.parent.navigationController.view;
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    [self.parent.navigationController pushViewController:controller animated:YES];
}

- (void)showHUD {
    SHOW_HUD_FOR_VIEW(self.parent.navigationController.view);
}

- (void)hideHUD {
    HIDE_HUD_FOR_VIEW(self.parent.navigationController.view);
}

- (void)updateCells {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
