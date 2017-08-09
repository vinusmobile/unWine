//
//  PopularWinesTVC.m
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "PopularWinesTVC.h"
#import "CheckinInterface.h"

@interface PopularWinesTVC () <WineCellDelegate>

@property (nonatomic) NSArray *objects;

@end

@implementation PopularWinesTVC
@synthesize extendedPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ThemeHandler getDeepBackgroundColor:unWineThemeDark];
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView registerClass:[WineCell class] forCellReuseIdentifier:@"WineCell"];
    
    [self basicAppeareanceSetup];
    [self loadObjects];
}

- (void)loadObjects {
    PFQuery *query = [unWine query];
    [query includeKey:@"partner"];
    [query orderByDescending:@"checkinCount"];
    [query setLimit:25];
    
    SHOW_HUD;
    [[query findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if(task.error)
            LOGGER(task.error);
        
        HIDE_HUD;
        dispatch_async(dispatch_get_main_queue(), ^{
            _objects = task.result;
            [self.tableView reloadData];
        });
        
        return nil;
    }];
}

#pragma TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects ? [self.objects count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 40 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 10 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject<SearchableSubclass> *object = _objects ? [_objects objectAtIndex:indexPath.row] : nil;
    return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [WineCell getExtendedHeight:object] : [WineCell getDefaultHeight];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Featured Wines";
    
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 40}}];
    headerView.backgroundColor = [ThemeHandler getBackgroundColor:unWineThemeDark];
    headerView.clipsToBounds = YES;
    
    UILabel *header = [[UILabel alloc] initWithFrame:(CGRect){12, 0, {SCREEN_WIDTH - 24, 40}}];
    header.textColor = [UIColor whiteColor];
    [header setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    if(section == 0)
        [header setText:@"Most Popular Wines"];
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
    unWine *object = [self.objects objectAtIndex:indexPath.row];
    WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
    cell.delegate = self;
    [cell setSubtitle:[NSString stringWithFormat:@"Checked in %li times!", object.checkinCount]];
    
    [cell setup:indexPath];
    [cell configure:(unWine *)object];
    
    return cell;
}

#pragma WineCell Delegate

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

@end
