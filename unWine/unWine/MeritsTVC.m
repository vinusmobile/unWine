//
//  MeritsTVC.m
//  unWine
//
//  Created by Bryce Boesen on 2/15/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "MeritsTVC.h"
#import "MeritAlertView.h"
#import "UITableViewController+Helper.h"
#import "UIViewController+Social.h"

@implementation MeritsTVC {
    BOOL pastFirstLoad;
}
@synthesize earnedMerits, counts, types;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    [self countStuff];
    [self loadObjects];
    
    self.title = @"Merits";
    self.navigationItem.title = @"Merits";
    [self basicAppeareanceSetup];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.937255 green:0.937255 blue:0.956863 alpha:1];
}

- (void) countStuff {
    for(NSString *type in types)
        if(counts[type] == nil)
            counts[type] = [[NSMutableArray alloc] init];
    
    for(PFObject *merit in self.objects) {
        NSString *type = [merit[@"type"] lowercaseString];
        
        BOOL needsAdding = YES;
        for(PFObject *added in counts[type])
            if([[added objectId] isEqualToString:[merit objectId]])
                needsAdding = NO;
        
        if(needsAdding)
            [counts[type] addObject:merit];
    }
    
    //for(NSString *type in types)
    //    NSLog(@"count %@: %i", type, [counts[type] count]);
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) objectsWillLoad {
    [super objectsWillLoad];
    
    self.objectsPerPage = 1000;
    
    if(earnedMerits == nil) {
        earnedMerits = [[NSMutableArray alloc] init];
        [earnedMerits addObjectsFromArray:[User currentUser].earnedMerits];
    }
    if(counts == nil)
        counts = [[NSMutableDictionary alloc] init];
    
    if(types == nil)
        types = [NSArray arrayWithObjects:@"level", @"wine", @"special", @"exclusive", nil];
    
    if(pastFirstLoad && self.profileTVC != nil)
        [self.profileTVC updateCounts];
    
    pastFirstLoad = YES;
}

- (BFTask *) getMeritsTask {
    return [[self queryForTable] countObjectsInBackground];
}

- (PFQuery *) queryForTable {
    PFQuery *query = [Merits query];
    query.limit = 1000;
    [query orderByAscending:@"Index"];
    
    if(self.earnedOnly || self.meritMode == MeritModeSelfShowOnly) {
        [query whereKey:@"objectId" containedIn:self.earnedMerits];
    }
    
    return query;
}

- (void) objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if(self.profileTVC != nil)
        [self.profileTVC updateCount:[self.profileTVC.profileUser.earnedMerits count] atIndex:3];
    [self countStuff];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [types count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *type = [types objectAtIndex:section];
    NSInteger count = ([counts[type] count] + IMAGE_PER_CELL - 1) / IMAGE_PER_CELL;
    //NSLog(@"%@ - %i: elems %i rowCount %i", type, section, [counts[type] count], count);
    return count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *type = [types objectAtIndex:section];
    
    return [counts[type] count] > 0 || section == 0 ? 40 : 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MERIT_BASE_CELL_HEIGHT;
}

- (NSArray *)getObjects:(NSIndexPath *)indexPath {
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSString *type = [types objectAtIndex:indexPath.section];
    for(NSUInteger i = indexPath.row * IMAGE_PER_CELL;
        i < (indexPath.row + 1) * IMAGE_PER_CELL && i < [counts[type] count]; i++) {
        Merits *merit = [counts[type] objectAtIndex:i];
        NSLog(@"Merit: \n%@", merit.description);
        NSLog(@"Merit image url: %@", merit.image.url);
        if(merit != nil)
            [objects addObject:merit];
    }
    
    return objects;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 40)];
    headerView.backgroundColor = UNWINE_GRAY_DARK;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, WIDTH(self.tableView), 40)];
    [headerLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setText:[[types objectAtIndex:section] capitalizedString]];

    [headerView addSubview:headerLabel];
    
    NSString *type = [types objectAtIndex:section];
    
    if([counts[type] count] > 0 || section == 0) {
        if([counts[type] count] == 0 && section == 0)
            [headerLabel setText:@"Merits"];
        
        return headerView;
    } else
        return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeritBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeritsBaseCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    [cell setup:indexPath];
    [cell configure:[self getObjects:indexPath]];
    
    return cell;
}

@end
