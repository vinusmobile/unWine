//
//  MoreResultsTVC.m
//  unWine
//
//  Created by Bryce Boesen on 1/6/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "MoreResultsTVC.h"
#import "CheckinInterface.h"
#import "UITableViewController+Helper.h"

@interface MoreResultsTVC () <WineCellDelegate, UserCellDelegate, WineryCellDelegate>

@end

@implementation MoreResultsTVC {
    NSInteger page;
    NSInteger preCount;
    NSInteger lastLoadCount;
}
@synthesize extendedPath;

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
    
    page = 0;
    lastLoadCount = 0;
    
    [self addUnWineTitleView];
    
    [self.tableView registerClass:[WineCell class] forCellReuseIdentifier:@"WineCell"];
    [self.tableView registerClass:[UserCell class] forCellReuseIdentifier:@"UserCell"];
    [self.tableView registerClass:[WineryCell class] forCellReuseIdentifier:@"WineryCell"];
    self.tableView.backgroundColor = CI_DEEP_BACKGROUND_COLOR;
    self.tableView.separatorColor = [UIColor clearColor];
    
    if(!ISVALID(self.searchString))
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Class<SearchableSubclass>)getAssociatedObject {
    if(self.mode == SearchTVCModeUsers)
        return [User class];
    else if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion)
        return [unWine class];
    else if(self.mode == SearchTVCModeWinery)
        return [Winery class];
    
    return nil;
}

- (Class<PFObjectCell>)getAssociatedCell {
    if(self.mode == SearchTVCModeUsers)
        return [UserCell class];
    else if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion)
        return [WineCell class];
    else if(self.mode == SearchTVCModeWinery)
        return [WineryCell class];
    
    return nil;
}

#pragma PF Delegate Methods

- (PFQuery *)queryForTable {
    if(self.mode == SearchTVCModeRegion)
        return [unWine findByRegion:self.searchString];
    else
        return [[self getAssociatedObject] find:self.searchString];
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = YES;
    self.objectsPerPage = 20;
    self.loadingViewEnabled = NO;
    
    lastLoadCount = 0;
    preCount = self.objects ? [self.objects count] : 0;
    SHOW_HUD;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    lastLoadCount = [self.objects count] - preCount;
    preCount = 0;
    HIDE_HUD;
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

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 10}}];
    header.backgroundColor = [UIColor clearColor];
    header.clipsToBounds = YES;
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 10}}];
    footer.backgroundColor = [UIColor clearColor];
    footer.clipsToBounds = YES;
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects ? [self.objects count] : 0;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.mode == SearchTVCModeUsers) {
        return [UserCell getDefaultHeight];
    } else if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion) {
        PFObject<SearchableSubclass> *object = self.objects && [self.objects count] > 0 && [self.objects count] > indexPath.row ? [self.objects objectAtIndex:indexPath.row] : nil;
        return self.extendedPath && [self.extendedPath isEqual:indexPath] ? [WineCell getExtendedHeight:object] : [WineCell getDefaultHeight];
    } else if(self.mode == SearchTVCModeWinery) {
        return [WineryCell getDefaultHeight];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < [self.objects count]) {
        PFObject<SearchableSubclass> *object = [self.objects objectAtIndex:indexPath.row];
        if(self.mode == SearchTVCModeUsers) {
            UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
            cell.delegate = self;
            cell.singleTheme = unWineThemeDark;
            
            [cell setup:indexPath];
            [cell configure:(User *)object];
            
            return cell;
        } else if(self.mode == SearchTVCModeWines || self.mode == SearchTVCModeRegion) {
            WineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineCell"];
            cell.delegate = self;
            if(self.mode == SearchTVCModeRegion)
                cell.subtitleMode = WineCellSubtitleModeRegion;
            
            [cell setup:indexPath];
            [cell configure:(unWine *)object mode:WineCellModeResult];
            
            return cell;
        } else if(self.mode == SearchTVCModeWinery) {
            WineryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WineryCell"];
            cell.delegate = self;
            
            [cell setup:indexPath];
            [cell configure:(Winery *)object mode:WineryCellModeDefault];
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma Cell Delegate Methods

- (UIView *)wineMorePresentationView {
    return self.navigationController.view;
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reconfigureCells {
    for(UITableViewCell *cell in self.tableView.visibleCells) {
        if([cell isKindOfClass:[UserCell class]]) {
            UserCell *userCell = (UserCell *)cell;
            [userCell reconfigure];
        }
    }
}

@end
