//
//  MessengerTVC.m
//  unWine
//
//  Created by Bryce Boesen on 10/3/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "MessengerTVC.h"
#import "MessengerCell.h"
#import "MessengerSelfCell.h"
#import "MessengerUserCell.h"
#import "PHFComposeBarView.h"

@interface MessengerTVC () <MessageCellDelegate>

@end

@implementation MessengerTVC {
    CGRect tableFrame;
    BOOL hasPerformed;
}
@synthesize convo, focusPath, groups;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!hasPerformed) {
        hasPerformed = YES;
        self.tableView.transform = CGAffineTransformMakeScale(1, -1);
        self.paginationEnabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicAppeareanceSetup];
    
    [self setLoadingViewEnabled:NO];
    
    //self.tableView.estimatedRowHeight = DEFAULT_MESSAGE_CELL_HEIGHT;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-24, 0, 0, 0);
    
    [self.tableView registerClass:[MessengerUserCell class] forCellReuseIdentifier:@"MessengerUserCell"];
    [self.tableView registerClass:[MessengerSelfCell class] forCellReuseIdentifier:@"MessengerSelfCell"];
    
    self.focusPath = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [[convo messages] query];
    [query includeKey:@"sender"];
    [query orderByDescending:@"createdAt"];
    return query;
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    if(!self.loadQuietly)
        SHOW_HUD;
    
    if(!self.groups)
        self.groups = [[NSMutableArray alloc] init];
    else
        [self.groups removeAllObjects];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if(error) {
        LOGGER(error);
        return;
    }
    
    if([self.objects count] > 0) {
        BOOL lastGroupWasCurrentUser = NO;
        for(PFObject<MessageDelegate> *message in self.objects) {
            if([[message getAssociatedUser] isTheCurrentUser]) {
                NSMutableArray *subgroup;
                if(!lastGroupWasCurrentUser) {
                    lastGroupWasCurrentUser = YES;
                    subgroup = [[NSMutableArray alloc] init];
                    [self.groups addObject:subgroup];
                } else if([self.groups count] == 0) {
                    subgroup = [[NSMutableArray alloc] init];
                    [self.groups addObject:subgroup];
                } else
                    subgroup = [self.groups lastObject];
                
                [subgroup addObject:message];
            } else {
                if([[message parseClassName] isEqualToString:[Messages parseClassName]]) {
                    Messages *msg = (Messages *)message;
                    if(!msg.seen) {
                        [msg markRead];
                    }
                }
                
                NSMutableArray *subgroup;
                if(lastGroupWasCurrentUser) {
                    lastGroupWasCurrentUser = NO;
                    subgroup = [[NSMutableArray alloc] init];
                    [self.groups addObject:subgroup];
                } else if([self.groups count] == 0) {
                    subgroup = [[NSMutableArray alloc] init];
                    [self.groups addObject:subgroup];
                } else
                    subgroup = [self.groups lastObject];
                
                [subgroup addObject:message];
            }
        }
        
        HIDE_HUD;
        [UIView transitionWithView:self.tableView
                          duration:.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^(void)
        {
            [self.tableView reloadData];
        } completion:nil];
    } else {
        HIDE_HUD;
    }
    if(self.loadQuietly)
        self.loadQuietly = NO;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath == nil || [self.groups count] <= indexPath.section || [[self.groups objectAtIndex:indexPath.section] count] <= indexPath.row) {
        //NSLog(@"not even sure how this is possible given the tableview delegate's constraints..");
        return 0;
    }
    
    PFObject<MessageDelegate> *object = [[self.groups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if(self.focusPath) {
        //LOGGER(@"has focus'd path");
        if(self.focusPath.row == indexPath.row && self.focusPath.section == indexPath.section)
            return [MessengerCell calculateMessageHeight:self message:object indexPath:indexPath] + EXTENDED_MESSAGE_CELL_HEIGHT;
        else
            return [MessengerCell calculateMessageHeight:self message:object indexPath:indexPath];
    } else
        return [MessengerCell calculateMessageHeight:self message:object indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 7;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 7)];
    view.clipsToBounds = YES;
    view.layer.masksToBounds = YES;
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border.frame = CGRectMake(2, 7 - .5, SCREEN_WIDTH - 4, .5);
    [view.layer addSublayer:border];
    
    view.layer.shadowColor = [UNWINE_GRAY_DARK CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 2;
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 7)];
    
    //CALayer *border = [CALayer layer];
    //border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    //border.frame = CGRectMake(2, 0, SCREEN_WIDTH - 4, .5);
    //[view.layer addSublayer:border];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.groups count] > section) {
        CGFloat c = [[self.groups objectAtIndex:section] count];
        //NSLog(@"group %ld: %f", (long)section, c);
        return c;
    } else
        return 0;
}

- (BOOL)isLastInGroup:(NSIndexPath *)path {
    NSArray *subgroup = [self.groups objectAtIndex:path.section];
    return [subgroup count] - 1 == path.row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath == nil || [self.groups count] <= indexPath.section || [[self.groups objectAtIndex:indexPath.section] count] <= indexPath.row) {
        //NSLog(@"not even sure how this is possible given the tableview delegate's constraints..");
        return [[UITableViewCell alloc] init];
    }
    
    PFObject<MessageDelegate> *message = [[self.groups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if([[message getAssociatedUser] isTheCurrentUser]) {
        MessengerSelfCell *cell = (MessengerSelfCell *)[tableView dequeueReusableCellWithIdentifier:@"MessengerSelfCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        
        [cell setup:indexPath];
        [cell configure:message];
        
        cell.transform = CGAffineTransformMakeScale(1, -1);
        
        return cell;
    } else {
        MessengerUserCell *cell = (MessengerUserCell *)[tableView dequeueReusableCellWithIdentifier:@"MessengerUserCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        
        [cell setup:indexPath];
        [cell configure:message];
        
        cell.transform = CGAffineTransformMakeScale(1, -1);
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //LOGGER(indexPath);
    NSIndexPath *last = self.focusPath;
    if(last && last.section == indexPath.section && last.row == indexPath.row) {
        self.focusPath = nil;
    } else {
        self.focusPath = indexPath;
    }
    
    [self.tableView reloadData];
}

@end
