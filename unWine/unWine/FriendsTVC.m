//
//  FriendsTVC.m
//  unWine
//
//  Created by Bryce Boesen on 8/8/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "FriendsTVC.h"
#import "ParseSubclasses.h"

@implementation FriendsTVC {
    NSArray *friends;
}
@synthesize imageFullVC;

- (void)viewWillAppear:(BOOL)animated {
    [self loadObjects];
    
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.refreshControl == nil) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor clearColor];
        //self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(pullRefresh)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    self.profileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.profileImage.layer.borderWidth = 3.0f;
    self.profileImage.layer.cornerRadius = SEMIWIDTH(self.profileImage);
    [self configureUserImage];
    
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImage.userInteractionEnabled = YES;
    self.profileImage.clipsToBounds = YES;
    
    [self.profileView setBackgroundColor:self.tableView.backgroundColor];
    self.profileView.clipsToBounds = YES;
    
    self.profileName.text = [self.user getName];
    self.profileName.textColor = [UIColor whiteColor];
    [self.profileName setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
    self.profileName.numberOfLines = 2;
    [self.profileName setTextAlignment:NSTextAlignmentCenter];
    
    [self basicAppeareanceSetup];
}

- (void)configureUserImage {
    [[self.user taskForDownloadingUserImage] continueWithSuccessBlock:^id(BFTask *task) {
        UIImage *image = (UIImage *)task.result;
        [self.profileImage setImage:image];
        
        return nil;
    }];
    
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed:)];
    [self.profileImage addGestureRecognizer:tapProfile];
}

- (BFTask *)getFriendsTask {
    return [self.user getFriends];
}

- (void)pullRefresh {
    if(self.profileTVC != nil)
        [self.profileTVC updateCounts];
    [self loadObjects];
}

- (void)loadObjects {
    [[self.user getFriends] continueWithBlock:^id(BFTask *task) {
        if(!task.error) {
            if(task.result != nil && [task.result count] > 0) {
                friends = [self filterFriendshipIntoUsers:(NSArray *)task.result];
                NSLog(@"friends - %@", task.result);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            
            if(self.refreshControl != nil && [self.refreshControl isRefreshing])
                [self.refreshControl endRefreshing];
        } else {
            NSLog(@"friends error - %@", task.error);
        }
        
        return nil;
    }];
}

- (NSArray *)filterFriendshipIntoUsers:(NSArray *)objects {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    
    for(Friendship *friendship in objects) {
        User *friend = [friendship getTheFriend:self.user];
        if(friend != nil) {
            [filtered addObject:friend];
        }
    }
    
    return [filtered copy];
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
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 40)];
    headerView.backgroundColor = UNWINE_GRAY_DARK;
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SEMIWIDTH(self.tableView), 40)];
    [headerTitle setText:@"Friends"];
    [headerTitle setTextColor:[UIColor whiteColor]];
    [headerTitle setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
    
    [headerView addSubview:headerTitle];
    
    NSInteger buttonWidth = 110;
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    [inviteButton setTitleColor:UNWINE_RED forState:UIControlStateNormal];
    [inviteButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:14]];
    inviteButton.titleLabel.textAlignment = NSTextAlignmentRight;
    inviteButton.frame = CGRectMake(WIDTH(headerView) - buttonWidth - 10, 0, buttonWidth, 40);
    [inviteButton addTarget:self.profileTVC action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
    
    if([self.user isTheCurrentUser])
        [headerView addSubview:inviteButton];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return friends != nil ? ([friends count] + IMAGE_PER_CELL - 1) / IMAGE_PER_CELL : 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 138.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    [cell setup:indexPath];
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for(NSInteger i = IMAGE_PER_CELL * indexPath.row;
        i < IMAGE_PER_CELL * indexPath.row + IMAGE_PER_CELL && i < [friends count]; i++) {
        User *object = [friends objectAtIndex:i];
        if(object != nil)
            [objects addObject:object];
    }
    [cell configure:[objects copy]];
    
    
    return cell;
}

- (void)profilePressed:(UITapGestureRecognizer *)gesture {
    //NSLog(@"Profile Pressed.");
    if(imageFullVC == nil)
        imageFullVC = [[UIStoryboard storyboardWithName:@"ImageFull" bundle:nil] instantiateInitialViewController];
    
    [imageFullVC setImage:self.profileImage.image];
    
    [self.navigationController.view addSubview:imageFullVC.view];
    [UIView animateWithDuration:.3 animations:^{
        imageFullVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [imageFullVC setImage:self.profileImage.image];
    }];
}

@end
