//
//  CastDetailTVC.m
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastDetailTVC.h"
#import "ParseSubclasses.h"
#import "CastEditTVC.h"

@interface CastDetailTVC ()

@end

@implementation CastDetailTVC {
    UIImageView *background;
    UIButton *lastEdit;
    __block NSArray *records;
    BOOL definitelyChecked;
}
@synthesize wine, checkinTVC, isNew, registers;

- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      WIDTH(self.tableView),
                                      HEIGHT(self.navigationController.view) - 64);
    
    [super viewWillLayoutSubviews];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //if(lastEdit == nil || ![lastEdit superview])
    //    [self.navigationController.view addSubview:[self makeFooterView]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[customTabBarController hideTabBar:self.tabBarController];
    
    if(self.wine == nil)
        self.wine = [unWine object];
    
    if(self.refreshControl == nil && !isNew) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor clearColor];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
    } //else if(!isNew) {
    //    [self refresh];
    //}
    
    //if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    //    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    //}
    
    [self configureLastEdit];
    lastEdit.alpha = 0;
    [UIView animateWithDuration:.2 animations:^{
        lastEdit.alpha = 1;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    //if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        //[customTabBarController showTabBar:self.tabBarController];
        //[self.tabBarController setSelectedIndex:0];
        if(lastEdit) {
            [[lastEdit superview] removeFromSuperview];
        }
    //}
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor          = [UIColor clearColor];

    background                             = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin-bg1.jpg"]];
    background.frame                       = self.navigationController.view.frame;
    background.layer.zPosition             = -1;
    background.backgroundColor             = [UIColor whiteColor];
    self.tableView.backgroundView          = background;
    self.tableView.contentInset            = UIEdgeInsetsMake(-20, 0, 0, 0);

    UIBarButtonItem *anotherButton         = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStylePlain target:self action:@selector(checkIn)];
    self.navigationItem.rightBarButtonItem = anotherButton;

    self.checkinForVerification            = -1;
    self.checkinForWeathered               = -1;
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        self.checkinForVerification = [config[@"CHECKIN_FOR_VERIFICATION"] intValue];
        self.checkinForWeathered    = [config[@"CHECKIN_FOR_WEATHERED"] intValue];
        [self updateHeaderCell];
    }];
    
    [self basicAppeareanceSetup];
    //[self performSelector:@selector(showPopover) withObject:nil afterDelay:.8];
    [self.tableView registerClass:[AWReactionCell class] forCellReuseIdentifier:@"AWReactionCell"];
    self.tableView.tableFooterView = [self makeFooterView];
    [self showPopover];
}

- (UIView *)makeFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 48, SCREEN_WIDTH, 48)];
    view.backgroundColor = [UIColor clearColor];
    
    if(lastEdit == nil) {
        lastEdit = [UIButton buttonWithType:UIButtonTypeSystem];
        [lastEdit setFrame:CGRectMake(0, 0, WIDTH(view), HEIGHT(view))];
        lastEdit.backgroundColor = [UIColor clearColor];
        [lastEdit setTintColor:[UIColor whiteColor]];
        [lastEdit setImage:SMALL_COG_ICON forState:UIControlStateNormal];
        [lastEdit.imageView setTintColor:[UIColor whiteColor]];
        [lastEdit.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [lastEdit.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [lastEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lastEdit setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [lastEdit setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [lastEdit addTarget:self action:@selector(viewEdits:) forControlEvents:UIControlEventTouchUpInside];
        
        /*lastEdit.layer.shadowColor = [UIColor blackColor].CGColor;
        lastEdit.layer.shadowOffset = CGSizeMake(0, 0);
        lastEdit.layer.shadowOpacity = 1;
        lastEdit.layer.shadowRadius = 1.8;*/
    }
    [lastEdit setTitle:@"Last edited by N/A" forState:UIControlStateNormal];
    [view addSubview:lastEdit];
    
    return view;
}

- (void)configureLastEdit {
    [self getLastEdit:^(PFObject *last) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(last == nil) {
                if(self.registers != nil && [self.registers count] > 0)
                    [lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", @"You"] forState:UIControlStateNormal];
                else
                    [lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", @"N/A"] forState:UIControlStateNormal];
            } else {
                [lastEdit setTitle:[NSString stringWithFormat:@"Last edited by %@", [last[@"editor"][@"canonicalName"] capitalizedString]] forState:UIControlStateNormal];
            }
        });
    }];
}

- (void)viewEdits:(id)sender {
    CastEditTVC *history = [self.storyboard instantiateViewControllerWithIdentifier:@"history"];
    
    [self getLastEdit:^(PFObject *last) {
        if(last == nil) {
            if(self.registers != nil && [self.registers count] > 0) {
                NSMutableArray *passedResults = [[NSMutableArray alloc] init];
                
                for(NSString *key in self.registers) {
                    PFObject *result = [CastCheckinTVC createObject:nil withField:key asValue:[self.registers objectForKey:key]];
                    [passedResults addObject:result];
                }
                
                history.results = passedResults;
                if([passedResults count] > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController pushViewController:history animated:YES];
                    });
                }
            }
        } else {
            history.wine = self.wine;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:history animated:YES];
            });
        }
    }];
}

- (void)checkIn {
    if(self.bidirectional) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    User *user = [User currentUser];
    if([user isAnonymous]) {
        [user promptGuest:self];
        return;
    }
    
    if((ISVALID([self.wine getWineName])) || ISVALID(registers[@"capitalizedName"])) {
        if (self.wine.isDirty) {
            [self.wine save];
            LOGGER(@"Just saved wine");
        }
    
        [self goToCheckin];
    } else {
        [unWineAlertView showAlertViewWithTitle:nil message:@"People want to know what you're drinking, please include a wine name!"];
        //NSLog(@"alert: a name must be provided to check in");
    }
}

- (void)goToCheckin {
    checkinTVC                 = [self.storyboard instantiateViewControllerWithIdentifier:@"checkin"];
    checkinTVC.wine            = self.wine;
    checkinTVC.wineImage       = self.wineImage;
    checkinTVC.registers       = registers;
    checkinTVC.isNew           = self.isNew;
    checkinTVC.cameFrom        = self.cameFrom;
    checkinTVC.pushedFromNotification = self.pushedFromNotification; // || self.navigationController.view.tag == 10;

    [self.navigationController pushViewController:checkinTVC animated:YES];
}

- (void)refresh {
    [self.tableView reloadData];
    
    if (self.refreshControl && self.refreshControl.isRefreshing) {
        NSDateFormatter *formatter          = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];

        NSString *title                     = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary       = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey: NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        if(!isNew) {
            [self.wine fetchInBackgroundWithBlock:^(PFObject *user, NSError *error) {
                [self getRecords:^{
                    [self.refreshControl endRefreshing];
                }];
            }];
        } else {
            [self getRecords:^{
                [self.refreshControl endRefreshing];
            }];
        }
    }
}

- (void)registerRecord:(NSString *)field asValue:(id)value {
    if(registers == nil)
        registers = [[NSMutableDictionary alloc] init];
    
    [registers setObject:value forKey:field];
    
    [self updateFooterCell];
}

- (void)getLastEdit:(void(^)(PFObject *))callback {
    [self getRecords:^{
        if(records != nil && [records count] > 0) {
            callback([records objectAtIndex:0]);
        } else
            callback(nil);
    }];
}

- (void)getRecords:(void(^)(void))callback {
    if(!isNew) {
        PFRelation *history = self.wine.history;
        
        PFQuery *historyQuery = [history query];
        [historyQuery orderByDescending:@"updatedAt"];
        [historyQuery includeKey:@"editor"];
        [historyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error)
                records = objects;
            
            callback();
        }];
    } else
        callback();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 1;
        case 1:
            return 3;
        case 2:
            return 1;
        case 3:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 0:
            return 154;
        case 2:
            return 108;
        case 3:
            return 96;
        default:
            return 36;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    switch(indexPath.section) {
        case 0:
            cellIdentifier = @"AWHeaderCell";
            break;
        case 1:
            cellIdentifier = @"AWDetailCell";
            break;
        case 2:
            cellIdentifier = @"AWReactionCell";
            break;
        case 3:
            cellIdentifier = @"AWFooterCell";
            break;
        default:
            cellIdentifier = @"AWFooterCell";
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == 0) {
        AWHeaderCell *headerCell = (AWHeaderCell *) cell;
        headerCell.delegate      = self;

        [headerCell setup:indexPath];
        [headerCell configure:self.wine];

        return headerCell;
    } else if(indexPath.section == 1) {
        AWDetailCell *detailCell = (AWDetailCell *) cell;
        detailCell.delegate      = self;

        [detailCell setup:indexPath];
        [detailCell configure:self.wine path:indexPath];

        return detailCell;
    } else if(indexPath.section == 2) {
        AWReactionCell *reactCell = (AWReactionCell *) cell;
        reactCell.delegate      = self;
        
        [reactCell setup:indexPath];
        [reactCell configure:self.wine];
        
        return reactCell;
    } else if(indexPath.section == 3) {
        AWFooterCell *footerCell = (AWFooterCell *) cell;
        footerCell.delegate      = self;

        [footerCell setup:indexPath];
        [footerCell configure:self.wine];

        return footerCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        AWDetailCell *cell = (AWDetailCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell modifyField];
    }
}

- (void) updateHeaderCell {
    AWHeaderCell *header = (AWHeaderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [header configureVerified:self.wine];
}

- (void) updateFooterCell {
    AWFooterCell *footer = [self getFooterCell];
    if(footer == nil)
        return;
    
    [footer configureLastEdit];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!definitelyChecked)
        [self showPopover];
}

- (void)showPopover {
    definitelyChecked = YES;
    if(![User hasSeen:WITNESS_ALERT_WISH_LIST] && ![[PopoverVC sharedInstance] isDisplayed]) {
        AWFooterCell *footer = [self getFooterCell];
        if(footer == nil)
            return;
        
        CGRect placer = footer.frame;
        placer.origin.y += Y2(footer.cellarButton) - 20;
        
        [[PopoverVC sharedInstance] showFrom:self.navigationController
                                  sourceView:self.tableView
                                  sourceRect:placer
                                        text:@"This is your personal Wish List! Save your favorite wines, wines you have in your actual wine collection, or even wines you just want to try some day!"];
        
        [User witnessed:WITNESS_ALERT_WISH_LIST];
        ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_ADD_TO_CELLAR_BUBBLE);
    }
}

- (AWFooterCell *)getFooterCell {
    BOOL footerVisible = NO;
    for(NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) {
        footerVisible |= path.row == 0 && path.section == 3;
    }
    
    if(footerVisible && self.tableView) {
        return (AWFooterCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    } else {
        return nil;
    }
}

@end
