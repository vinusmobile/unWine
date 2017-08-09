//
//  PartnersQueryTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 4/28/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "PartnersQueryTableViewController.h"
#import "UITableViewController+Helper.h"
#import "PartnerViewController.h"
#import "PartnerCell.h"
#import "ParseSubclasses.h"

@implementation PartnersQueryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ELIMINATE_TABLE_FOOTER_VIEW
    
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = YES;
    self.objectsPerPage = 25;
    
    [self basicAppeareanceSetup];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [Partner query];//[PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"active" equalTo:[NSNumber numberWithBool:YES]];
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //if (self.objects.count == 0) {
    //    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    //}
    
    [query orderByAscending:@"name"];
    
    return query;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Partners";
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(Partner *)object {
    static NSString *identifier = @"PartnerCell";
    PartnerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PartnerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.nameLabel.text = object.name;
    
    PFFile *thumbnail = object.logo;
    cell.logoImageView.image = USER_PLACEHOLDER;
    cell.logoImageView.file = thumbnail;
    [cell.logoImageView loadInBackground];
    cell.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Partner *partner = [self.objects objectAtIndex: self.tableView.indexPathForSelectedRow.row];
    
    PartnerViewController *pvc = (PartnerViewController *)[segue destinationViewController];
    pvc.partner = partner;
    
}

@end
