
#import "CastOccasionTVC.h"
#import "UITableViewController+Helper.h"
#define HAS_RECENT_OCCASIONS (self.recentOccasions != nil && self.recentOccasions.count > 0)

@implementation CastOccasionTVC

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      WIDTH(self.tableView),
                                      HEIGHT(self.navigationController.view) - 50);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    self.searchBar.placeholder = @"Create your own occasion";
    self.searchBar.barTintColor = UNWINE_RED;
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.searchBar action:@selector(resignFirstResponder)];
    barButton.tintColor = UNWINE_RED;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    self.searchBar.inputAccessoryView = toolbar;
    
    [self.searchBar setDelegate:self];
    
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self basicAppeareanceSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.delegate = self;
    [self.view endEditing:YES];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.searchBar.text length] > 0 ? 1 : HAS_RECENT_OCCASIONS ? 2 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([self.searchBar.text length] > 0)
        return 40;
    
    if(section == 0)
        return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 40 : 0;
    else
        return 40;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.searchBar.text length] > 0)
        return 1;
    else {
        
        return (section == 0 && HAS_RECENT_OCCASIONS) ? [self.recentOccasions count] : [self.occasions count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, [self tableView:tableView heightForHeaderInSection:section]}}];
    headerView.backgroundColor = [ThemeHandler getBackgroundColor:unWineThemeDark];
    headerView.clipsToBounds = YES;
    
    UILabel *header = [[UILabel alloc] initWithFrame:(CGRect){12, 0, {SCREEN_WIDTH - 24, 40}}];
    header.textColor = [UIColor whiteColor];
    [header setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    
    if([self.searchBar.text length] == 0) {
        [header setText: (section == 0 && HAS_RECENT_OCCASIONS) ? @"Recent Occasions" : @"Occasions"];
    } else
        [header setText:@"Custom Occasion"];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    [cell.textLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
    
    if ([self.searchBar.text length] > 0) {
        cell.textLabel.text = [self.searchBar.text capitalizedString];
    } else {
        if(indexPath.section == 0 && HAS_RECENT_OCCASIONS) {
            Occasion *occasion = [self.recentOccasions objectAtIndex:indexPath.row];
            //NSString *s = [NSString stringWithFormat:@"%li. RecentOcassion: %@\nDescription: %@\n\n", (long)indexPath.row, occasion, occasion.description];
            //LOGGER(s);
            cell.textLabel.text = occasion.name;
        } else {
            Occasion *occasion = [self.occasions objectAtIndex:indexPath.row];
            //NSString *s = [NSString stringWithFormat:@"%li. Ocassion: %@\nDescription: %@\n\n", (long)indexPath.row, occasion, occasion.description];
            //LOGGER(s);
            cell.textLabel.text = occasion.name;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchBar.text length] > 0) {
        Occasion *occasion = [Occasion new];
        occasion.name = [self.searchBar.text capitalizedString];
        occasion.user = [User currentUser];
        [occasion saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate updateOccasion:occasion];
            });
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if(indexPath.section == 0 && HAS_RECENT_OCCASIONS) {
            Occasion *occasion = [self.recentOccasions objectAtIndex:indexPath.row];
            [self.delegate updateOccasion:occasion];
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            Occasion *occasion = [self.occasions objectAtIndex:indexPath.row];
            [self.delegate updateOccasion:occasion];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end
