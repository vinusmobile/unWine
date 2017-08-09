//
//  WineryContainerVC.m
//  unWine
//
//  Created by Bryce Boesen on 3/11/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineryContainerVC.h"
#import "ChevronView.h"
#import "WineryCell.h"

@import MapKit;
@import CoreLocation;

@interface WineryContainerVC () <ChevronViewDelegate, WineryCellDelegate>

@property (nonatomic) UIView *wineView;
@property (nonatomic) UIButton *settingsButton;
@property (nonatomic) UIImageView *verifiedView;
@property (nonatomic) UIView *footerView;

@property (strong, nonatomic) PFImageView *profileImage;
@property (strong, nonatomic) CascadingLabelView *profileDetails;
//@property (strong, nonatomic) UIView *profileView;

@property (strong, nonatomic) UIImageView *blurredBack;
@property (strong, nonatomic) UIView *blurredBackOverlay;

@end

@implementation WineryContainerVC

static NSInteger headerHeight = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ThemeHandler getDeepBackgroundColor:unWineThemeDark];
    
    self.wineryTable = [[WineryTVC alloc] initWithStyle:UITableViewStylePlain];
    self.wineryTable.parent = self;
    self.wineryTable.winery = self.winery;
    self.wineryTable.view.frame = CGRectMake(0, 0, SCREENWIDTH, [self getActualHeight] + 1);
    self.wineryTable.tableView.tableHeaderView = [self getWineView];
    
    [self addChildViewController:self.wineryTable];
    [self.view addSubview:self.wineryTable.view];
    [self.wineryTable didMoveToParentViewController:self];
    
    [self addUnWineTitleView];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (NSInteger)getActualHeight {
    return HEIGHT(self.view); // SCREENHEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT;
}

#pragma Subviews

- (void)addUnWineTitleView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}

- (UIView *)getWineView {
    if(!self.wineView) {
        self.wineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, headerHeight)];
        [self.wineView setBackgroundColor:[UIColor clearColor]];
        self.wineView.clipsToBounds = YES;
        self.wineView.userInteractionEnabled = YES;
        self.wineView.exclusiveTouch = NO;
    
        self.profileImage = [[PFImageView alloc] initWithFrame:(CGRect){(SCREEN_WIDTH - 108) / 2, 8, {108, 108}}];
        self.profileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.profileImage.layer.borderWidth = 3.0f;
        self.profileImage.layer.cornerRadius = SEMIWIDTH(self.profileImage);
        [self configureWineryImage];
        self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImage.userInteractionEnabled = YES;
        self.profileImage.clipsToBounds = YES;
        [self.wineView addSubview:self.profileImage];
        
        NSInteger startY = Y2(self.profileImage) + HEIGHT(self.profileImage);
        self.profileDetails = [[CascadingLabelView alloc] initWithFrame:CGRectMake(0, startY, SCREEN_WIDTH, headerHeight - startY)];
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = [self.winery getWineryName];
        nameLabel.textColor = [UIColor whiteColor];
        [nameLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:18]];
        nameLabel.numberOfLines = 2;
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.profileDetails addSubview:nameLabel];
        [self.profileDetails update];
        
        [self addVerifiedView:self.wineView];
        [self.wineView addSubview:self.profileDetails];
        
        [self.wineView addSubview:[self getSettingsButton]];
    }
    
    return self.wineView;
}

- (void)configureWineryImage {
    if(self.blurredBack == nil)
        self.blurredBack = [[UIImageView alloc] initWithFrame:self.wineView.frame];
    if(self.blurredBackOverlay == nil)
        self.blurredBackOverlay = [[UIView alloc] initWithFrame:self.wineView.frame];
    self.blurredBack.clipsToBounds = YES;
    self.blurredBackOverlay.clipsToBounds = YES;
    
    self.blurredBackOverlay.backgroundColor = [UIColor colorWithRed:.15 green:.15 blue:.15 alpha:.75];
    
    [[self.winery getWineryImage] continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            LOGGER(task.error);
            return nil;
        }
        UIImage *image = task.result;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileImage setImage:image];
        });
        
        CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [gaussianBlurFilter setDefaults];
        CIImage *inputImage = [CIImage imageWithCGImage:[image CGImage]];
        [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
        [gaussianBlurFilter setValue:@(1) forKey:kCIInputRadiusKey];
        
        CIImage *outputImage = [gaussianBlurFilter outputImage];
        CIContext *context   = [CIContext contextWithOptions:nil];
        CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];
        
        UIImage *blurredImage = [UIImage imageWithCGImage:cgimg];
        CGImageRelease(cgimg);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.blurredBack setImage:blurredImage];
            [self.blurredBack setContentMode:UIViewContentModeScaleAspectFill];
            [self.blurredBack setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(self.wineView))];
            [self.blurredBackOverlay setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(self.wineView))];
            
            [self.wineView addSubview:self.blurredBackOverlay];
            [self.wineView sendSubviewToBack:self.blurredBackOverlay];
            [self.wineView addSubview:self.blurredBack];
            [self.wineView sendSubviewToBack:self.blurredBack];
        });
        
        return nil;
    }];
    
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed)];
    [self.profileImage addGestureRecognizer:tapProfile];
}

- (UIButton *)getSettingsButton {
    if(!self.settingsButton) {
        self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.settingsButton.clipsToBounds = NO;
        [self.settingsButton setFrame:CGRectMake(12, 12, 48, 48)];
        [self.settingsButton setImage:[UIImage imageNamed:@"shareIcon"] forState:UIControlStateNormal]; //settingsicon
        [self.settingsButton addTarget:self action:@selector(settingsPressed) forControlEvents:UIControlEventTouchUpInside];
        self.settingsButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [self.settingsButton setContentMode:UIViewContentModeScaleAspectFit];
        self.settingsButton.layer.shadowColor = [[UIColor lightTextColor] CGColor];
        self.settingsButton.layer.shadowOffset = CGSizeMake(0, 1);
        self.settingsButton.layer.shadowOpacity = 1;
        self.settingsButton.layer.shadowRadius = 1;
    }
    
    return self.settingsButton;
}

- (void)addVerifiedView:(UIView *)parentView {
    if(!self.verifiedView) {
        NSInteger buffer = 8;
        NSInteger dim = 72;
        NSInteger size = WIDTH(self.wineView);
        self.verifiedView = [[UIImageView alloc] initWithFrame:CGRectMake(size - dim - buffer, headerHeight - dim - buffer, dim, dim)];
        [self.verifiedView setContentMode:UIViewContentModeScaleAspectFit];
        [parentView addSubview:self.verifiedView];
    }
    
    if(self.winery.verified) {
        [self.verifiedView setImage:[UIImage imageNamed:@"verifiedIcon@3x"]];
        [self.verifiedView setHidden:NO];
    } else
        [self.verifiedView setHidden:YES];
}

#pragma Actions

- (void)chevronPressed:(ChevronView *)chevronView {
    [self settingsPressed];
}

//static NSString *actionViewWW = @"Find in Wine World";
static NSString *actionViewMaps = @"Open in Maps";
static NSString *actionFollow = @"Follow Winery";
static NSString *actionUnfollow = @"Unfollow Winery";
static NSString *actionRecommend = @"Recommend Winery";

- (void)settingsPressed {
    //User *user = [User currentUser];
    //BOOL following = [user isFollowingWinery:self.winery];
    //NSMutableArray *titles = [[NSMutableArray array] initWithArray:following ? @[actionUnfollow, actionRecommend] : @[actionFollow, actionRecommend]];
   
    NSArray *titles = [self.winery hasLocation] ? @[actionViewMaps, actionRecommend] : @[actionRecommend];
    
    unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:[self.winery getWineryName]
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:titles];
    [sheet showFromTabBar:self.navigationController.view];
}


- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionFollow]) {
        User *user = [User currentUser];
        [user followWinery:self.winery];
        [user saveInBackground];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionUnfollow]) {
        User *user = [User currentUser];
        [user unfollowWinery:self.winery];
        [user saveInBackground];
    //} else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionViewWW]) {
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionViewMaps]) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.winery.location.latitude, self.winery.location.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[self.winery.name capitalizedString]];
        NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        [mapItem openInMapsWithLaunchOptions:options];
        ANALYTICS_TRACK_EVENT(EVENT_USER_RECOMMENDED_WINERY_FROM_WINERY_VIEW);
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionRecommend]) {
        [self recommendIt];
    }
}

- (void)recommendIt {
    WineryCell *cell = [[WineryCell alloc] init];
    cell.winery = self.winery;
    cell.delegate = self;
    cell.source = WineryCellSourceWineryView;
    [cell recommendIt];
}

- (void)profilePressed {
    
}

- (UIView *)wineMorePresentationView {
    return self.navigationController.view;
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIViewController *)actionSheetPresentationViewController {
    return self;
}

- (void)showHUD {
    SHOW_HUD_FOR_VIEW(self.navigationController.view);
}

- (void)hideHUD {
    HIDE_HUD_FOR_VIEW(self.navigationController.view);
}

@end
