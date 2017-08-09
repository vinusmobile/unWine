//
//  CastCheckinTVC.m
//  unWine
//
//  Created by Bryce Boesen on 4/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastCheckinTVC.h"
#import "NSDate+CurrentDateString.h"
#import "ParseSubclasses.h"
#import "IQKeyboardManager.h"
#import "CaptureSessionManager.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "MediaHelper.h"
#import "CICellarCell.h"
#import "CIReactionCell.h"
#import "CIFilterVC.h"
#import "CheckinInterface.h"

#define FACEBOOK_SHARE_TAG 0
#define SAVING_TAG         1
#define CHECKIN_TAG        2
#define SHOW_TAB_BAR_TAG    3
#define CHAR_LIMIT_TAG     4

@interface CastCheckinTVC () <unWineAlertViewDelegate, FBSDKSharingDelegate, WineCellDelegate>
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@end

@import AssetsLibrary;
@import Photos;
@import PhotosUI;
@import MobileCoreServices;
@implementation CastCheckinTVC {
    UIImageView *background;
    PFObject *venue;
}
@synthesize wine, checkin, registers, newsFeedImage, progressHUD, isNew, filterName;
@synthesize mention, input, extendedPath, mentionIndicator;

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      WIDTH(self.tableView),
                                      HEIGHT(self.navigationController.view) - 50);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    if(!self.hudShowView)
        self.hudShowView = self.navigationController.view;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideMentions];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin-bg1.jpg"]];
    [background setContentMode:UIViewContentModeScaleAspectFill];
    background.frame = self.navigationController.view.frame;
    background.layer.zPosition = -1;
    background.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = background;
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    [MentionTVC setupMentionsView:self];
    self.checkin = [NewsFeed prepareWithWine:self.wine];
    [self setSelectedType:(ReactionType)[self.checkin.reactionType intValue]];
    
    [self basicAppeareanceSetup];
    self.newsFeedImage = nil;
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Check In"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(clickedCheckIn)];
    self.navigationItem.rightBarButtonItem = flipButton;
    
    [self.tableView registerClass:[WineCell class] forCellReuseIdentifier:@"WineCell"];
    [self.tableView registerClass:[CIReactionCell class] forCellReuseIdentifier:@"CIReactionCell"];
}


- (void)clickedCheckIn {
    //unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Are you sure you wish to check in with this information?"];
    /*unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Would you also like to share your checkin to Facebook?"];
    alert.delegate = self;
    alert.leftButtonTitle = @"No";
    alert.rightButtonTitle = @"Yes";
    alert.tag = CHECKIN_TAG;
    [alert show];
     */
    
    [self showFacebookAlert];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}
/*
// Old version with video
- (BFTask *)finalCheckin {
    BFTaskCompletionSource *completion = [BFTaskCompletionSource taskCompletionSource];
    
    if (!self.newsFeedImage) {
        LOGGER(@"No photo to save");
        [self saveRecordsCheckinWineAndUser];
        return completion.task;
    }
    
    // Save User Image
    
    // Show uploading HUD
    self.progressHUD = SHOW_HUD_FOR_VIEW(self.hudShowView);
    self.progressHUD.mode = MBProgressHUDModeDeterminate;
    self.progressHUD.label.text = self.movieData == nil ? @"Uploading Photo" : @"Uploading Thumbnail";
    
    UIImage *image = self.newsFeedImage;
    
    self.IS_SAVING = YES;
    NSData *imageData = UIImageJPEGRepresentation(image, .3);
    PFFile *imageFile = [PFFile fileWithName:@"checkin_photo.jpg" data:imageData];
    
    if(imageFile == nil || imageData == nil || image == nil) {
        [unWineAlertView showAlertViewWithTitle:nil message:@"Spilled some wine"];
        [completion setError:[unWineError createGenericErrorWithMessage:@"Spilled some wine"]];
        return completion.task;
    }
    
    LOGGER(@"Saving image");
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        self.IS_SAVING = NO;
        
        if (error) {
            HIDE_HUD_FOR_VIEW(self.hudShowView);
            LOGGER(@"Error saving checkin image");
            [Analytics trackError:error withName:@"Saving checkin image" withMessage:@"Something happened"];
            
            [unWineAlertView showAlertViewWithTitle:nil error:error];
            [completion setError:error];
            
            return;
        }
        
        self.checkin[@"photo"] = imageFile;
        self.checkin[@"photoDims"] = [VCWineCell arrayFromSize:image.size];
        
        // Not using MOVIE DATA
        if (!self.movieData) {
            HIDE_HUD_FOR_VIEW(self.hudShowView);
            LOGGER(@"Successfully added photo!");
            [self saveRecordsCheckinWineAndUser];
            return;
        }
        
        // Using movie data
        PFFile *videoFile = [PFFile fileWithName:self.movieFileName data:self.movieData];
        self.progressHUD.label.text = @"Uploading Media";
        
        [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            HIDE_HUD_FOR_VIEW(self.hudShowView);
            if(!error) {
                self.checkin[@"video"] = videoFile;
                self.checkin[@"videoURL"] = videoFile.url;
                self.parseMovieURL = [NSURL URLWithString:videoFile.url];
            }
            LOGGER(@"Successfully added video!");
            
            [self saveEverything:completion];
            
        } progressBlock: ^(int percentDone) {
            // Update your progress spinner here. percentDone will be between 0 and 100.
            self.progressHUD.progress = (float)percentDone/100;
        }];
        
        
    } progressBlock: ^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        self.progressHUD.progress = (float)percentDone/100;
    }];
    
    return completion.task;
}
*/

- (BFTask *)finalCheckin {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    // Save User Image
    
    PFProgressBlock imageProgressBlock =  ^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        self.progressHUD.progress = (float)percentDone/100;
    };
    
    if (!self.newsFeedImage) {
        LOGGER(@"No photo to save");
        SHOW_HUD;
    } else {
        LOGGER(@"Saving image");
        // Show uploading HUD
        // The actual image saving will take place in the NewsFeed class
        self.progressHUD = SHOW_HUD_FOR_VIEW(self.hudShowView);
        self.progressHUD.mode = MBProgressHUDModeDeterminate;
        self.progressHUD.label.text = self.movieData == nil ? @"Uploading Photo" : @"Uploading Thumbnail";
    }

    self.IS_SAVING = YES;
    
    [[self.checkin finalCheckinWithImage:self.newsFeedImage
                                     wine:self.wine
                                wineImage:self.wineImage
                                registers:self.registers
                                    venue:(Venue *)venue
                                 mentions:self.mention.mentions
                                  express:self.cameFrom == CastCheckinSourceExpress
                         andProgressBlock:imageProgressBlock] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        self.IS_SAVING = NO;
        LOGGER(@"Finished everything. Now doing Analytics, then dismissing");
        
        HIDE_HUD_FOR_VIEW(self.hudShowView);
        [self.mention.mentions removeAllObjects];

        if (t.error) {
            LOGGER(@"Error saving checkin image");
            LOGGER(t.error);
            [Analytics trackError:t.error withName:@"Final Checkin" withMessage:@"Something happened"];
            [unWineAlertView showAlertViewWithTitle:nil error:t.error];
            [theTask setError:t.error];
            
            return nil;
        }

        // Analytics stuff
        NSString *s = [NSString stringWithFormat:@"checkin %@", self.checkin];
        LOGGER(s);
        [Analytics trackNewCheckinUsingNewsFeedObject:self.checkin];
        
        if (self.isNew) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITH_NEW_WINE);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITH_EXISTING_WINE);
        }
        
        [Analytics trackCheckInSource: self.cameFrom];
        
        if (self.newsFeedImage) {
            if (ISVALID(self.filterName)) {
                [Analytics trackFilterCheckin:self.filterName];
            } else {
                ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_CHECKED_IN_WITH_NO_FILTER);
            }
            ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITH_PHOTO);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITH_NO_PHOTO);
        }
        
        if([self.checkin.reactionType integerValue] != ReactionType0None) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITH_REACTION);
        } else {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CHECKED_IN_WITHOUT_REACTION);
        }
        
        // DONE & Dismiss
        s = [NSString stringWithFormat:@"CameFrom: %u", self.cameFrom];
        LOGGER(s);

        if(self.cameFrom == CastCheckinSourceExpress) {
            LOGGER(@"Came from Express Checkin");
            [theTask setResult:@(true)];
            return nil;
        }

        LOGGER(@"Showing successful checkin top bar");
        [CRToastManager showNotificationWithOptions:[CastCheckinTVC options] completionBlock:^{
            [self showTabBar];
            [theTask setResult:@(YES)];
        }];
    
        return nil;
        
    }];
    
    return theTask.task;
}

- (void)showProgressHUDWithCustomView {
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.progressHUD];
    
    // The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
    // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    self.progressHUD.customView = [[UIImageView alloc] initWithImage:G_CHECKMARK_IMAGE];
    
    // Set custom view mode
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    
    //self.progressHUD.delegate = self;
    self.progressHUD.label.text = @"Completed";
    
    [self.progressHUD showAnimated:YES];
    [self.progressHUD hideAnimated:YES afterDelay:1];
}

+ (NSDictionary *)options {
    NSMutableDictionary *options =
        [@{kCRToastNotificationTypeKey: @(CRToastTypeNavigationBar),
           kCRToastNotificationPresentationTypeKey: @(CRToastPresentationTypePush),
           kCRToastUnderStatusBarKey: @(YES),
           kCRToastTextKey: @"You've Checked In this wine!",
           kCRToastTimeIntervalKey: @(1.0f),
           kCRToastTextAlignmentKey: @(NSTextAlignmentCenter),
           kCRToastTextColorKey: UNWINE_RED,
           kCRToastFontKey: [UIFont fontWithName:@"OpenSans" size:17],
           kCRToastBackgroundColorKey: [UIColor whiteColor],
           kCRToastAnimationInTypeKey: @(CRToastAnimationTypeLinear),
           kCRToastAnimationOutTypeKey: @(CRToastAnimationTypeLinear),
           kCRToastAnimationInDirectionKey: @(CRToastAnimationDirectionLeft),
           kCRToastAnimationOutDirectionKey: @(CRToastAnimationDirectionRight)} mutableCopy];

    return [NSDictionary dictionaryWithDictionary:options];
}

- (void)showTabBar {
    NSLog(@"%s - Completed", FUNCTION_NAME);
    NSLog(@"%s - Setting userIsOnScanner to NO", FUNCTION_NAME);
    //(GET_APP_DELEGATE).ctbc.userIsOnScanner = NO;
    GET_TAB_BAR.userIsOnScanner = NO;
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if(self.isNew) {
        User *user = [User currentUser];
        [Grapes queueTransaction:MIN(5, [self.registers count]) reason:@"AddingNewWine"];
        [[user getCreditedWines] addObject:[self.wine objectId]];
        [user saveInBackground];
    } else if(self.registers != nil && [self.registers count] > 0) {
        User *user = [User currentUser];
        if(![[user getCreditedWines] containsObject:[self.wine objectId]]) {
            [Grapes queueTransaction:MIN(4, [self.registers count]) reason:@"EditingWine"];
            [[user getCreditedWines] addObject:[self.wine objectId]];
            [user saveInBackground];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        (GET_APP_DELEGATE).checkForMerits = YES;
        
        if (self.tabBarController.selectedIndex != 0) {
            [self.tabBarController setSelectedIndex:0];
        }
        
        //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        [[MainVC sharedInstance] dismissPresented:YES];
    });
}

- (void)leftButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == FACEBOOK_SHARE_TAG) {
        //[self showTabBar];
        [self finalCheckin];
    }
}

- (void)centerButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == SHOW_TAB_BAR_TAG)
        [self showTabBar];
}

- (void)rightButtonPressed {

    if([[unWineAlertView sharedInstance] tag] == CHAR_LIMIT_TAG) {
        LOGGER(@"CHAR_LIMIT_TAG pressed");
        return;
    }
    
    if([[self getCaptionCell].realInputView.text length] > CAPTION_CHAR_LIMIT) {
        unWineAlertView *alert = [[unWineAlertView sharedInstance]
                                  prepareWithMessage:@"Your caption has exceeded the character limit!"];
        alert.delegate = self;
        alert.centerButtonTitle = @"Ok";
        alert.tag = CHAR_LIMIT_TAG;
        [alert show];
        return;
    }
    
    if([[unWineAlertView sharedInstance] tag] == CHECKIN_TAG) {
        [self finalCheckin];
    
    } else if([[unWineAlertView sharedInstance] tag] == FACEBOOK_SHARE_TAG) {
        [self showFacebookShareDialogue];
    
    } else {
        [self showTabBar];
    }
}

#pragma mark - Facebook Stuff

- (void)showFacebookAlert {
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Would you also like to share your checkin on Facebook?"];
    alert.delegate = self;
    alert.leftButtonTitle = @"No";
    alert.rightButtonTitle = @"Yes";
    alert.tag = FACEBOOK_SHARE_TAG;
    [alert show];
}

- (void)showFacebookShareDialogue {
    NSLog(@"%s - showing Facebook Share dialogue", FUNCTION_NAME);
    SHOW_HUD_FOR_VIEW(self.hudShowView);
    
    UIImage *image = nil;
    
    if (self.newsFeedImage) {
        LOGGER(@"Get user provided image");
        image = self.newsFeedImage;
        
    } else {
        LOGGER(@"Getting wine image");
        image = [self.wine getImage];
    }
    
    [[MediaHelper getContentForFacebookWithThumbnail:image andMovieURL:self.movieURL andRefURL:self.refMovieURL] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {

        HIDE_HUD_FOR_VIEW(self.hudShowView);

        if(task.error) {
            [unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:task.error];
            [[unWineAlertView sharedInstance] setTag:SHOW_TAB_BAR_TAG];
            return nil;
        }
        
        [FBSDKShareDialog showFromViewController:self
                                     withContent:(id<FBSDKSharingContent>)task.result
                                        delegate:self];
        
        return nil;
    }];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"%s - Sharing completed", FUNCTION_NAME);
    [Analytics trackPostToFacebookUsingWineObject:self.wine];
    //[self showTabBar];
    [self finalCheckin];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"%s - Sharing failed", FUNCTION_NAME);
    LOGGER(error);
    [Analytics trackError:error withName:@"Checkin - Facebook Share Error" withMessage:@"Something happened"];
    
    [unWineAlertView showAlertViewWithTitle:@"Facebook Error" error:error];
    [[unWineAlertView sharedInstance] setTag:SHOW_TAB_BAR_TAG];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"%s - Sharing cancelled", FUNCTION_NAME);
    //[self showTabBar];
    [self finalCheckin];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section) {
        case 0:
            return self.wine && ISVALID(self.wine.name) ? [WineCell getExtendedHeight:self.wine mode:WineCellModeCheckin] : 0;
        case 1:
            return 160;
        case 2:
            return 88;
        case 3:
            return 120;
        default:
            return 44;
    }
}

- (NSString *)getCellIdentifierFromIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    
    switch (indexPath.section) {
        case 0:
            identifier = @"WineCell";
            break;
        case 1:
            identifier = @"CIHeaderCell";
            break;
        case 2:
            identifier = @"CICaptionCell";
            break;
        case 3:
            identifier = @"CIReactionCell";
            break;
            
        default:
            break;
    }
    
    
    return identifier;
}

- (NSIndexPath *)getLastIndexPath {
    NSInteger section = [self.tableView numberOfSections] - 1;
    NSInteger row = [self.tableView numberOfRowsInSection:section] - 1;
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:(CGRect){0, 0, {SCREEN_WIDTH, 10}}];
    footer.backgroundColor = [UIColor clearColor];
    footer.clipsToBounds = YES;
    
    if(section == 0) {
        CALayer *border = [CALayer layer];
        border.backgroundColor = [CI_DEEP_BACKGROUND_COLOR CGColor];
        border.frame = CGRectMake(0, 0, footer.frame.size.width, .5);
        [footer.layer addSublayer:border];
        
        /*footer.layer.shadowColor = [[UIColor blackColor] CGColor];
        footer.layer.shadowOffset = CGSizeMake(0, 0);
        footer.layer.shadowOpacity = 1;
        footer.layer.shadowRadius = 2;*/
    }
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.section == 0 ? @"CIHeaderCell" : (indexPath.section == 1 ? @"CICaptionCell" : @"CIShareCell"))];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self getCellIdentifierFromIndexPath:indexPath]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == 0) {
        self.extendedPath = indexPath;
        WineCell *wineCell = (WineCell *)cell;
        wineCell.delegate = self;
        wineCell.singleTheme = unWineThemeDark;
        
        [wineCell setup:indexPath];
        [wineCell configure:self.wine mode:WineCellModeCheckin];
        
        wineCell.layer.shadowRadius = 3;
        wineCell.layer.shadowColor = [UIColor blackColor].CGColor;
        wineCell.layer.shadowOffset = CGSizeMake(0, 0);
        
        if(self.wine && ISVALID(self.wine.name)) {
            wineCell.alpha = 1;
            wineCell.clipsToBounds = NO;
            wineCell.layer.shadowOpacity = 1;
        } else {
            wineCell.alpha = 0;
            wineCell.clipsToBounds = YES;
            wineCell.layer.shadowOpacity = 0;
        }
        
        return wineCell;
    } else if(indexPath.section == 1) {
        CIHeaderCell *headerCell = (CIHeaderCell *)cell;
        headerCell.delegate = self;
        
        [headerCell setup:indexPath];
        [headerCell configure:self.wine];
        
        return headerCell;
    } else if(indexPath.section == 2) {
        CICaptionCell *captionCell = (CICaptionCell *)cell;
        captionCell.delegate = self;
        self.input = captionCell;
        
        [captionCell setup:indexPath];
        [captionCell configure:self.wine];
        
        return captionCell;
    } else if(indexPath.section == 3) {
        CIReactionCell *captionCell = (CIReactionCell *)cell;
        captionCell.delegate = self;
        
        [captionCell setup:indexPath];
        [captionCell configure:self.wine];
        
        return captionCell;
    }
    
    return cell;
}

- (void)addVintage:(NSString *)vintage {
    self.checkin[@"vintage"] = vintage;
}

- (void)addOccasion:(PFObject *)occasion {
    self.checkin[@"occasionPointer"] = occasion;
}

- (void)addLocation:(PFObject *)location {
    venue = location;
    venue[@"user"] = [User currentUser];
    self.checkin[@"venue"] = venue;
}

/*
- (void)addPhoto:(UIImage *) image {
    self.IS_SAVING = YES;
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    PFFile *imageFile = [PFFile fileWithName:@"upload.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL success, NSError * error) {
        if(!error) {
            self.checkin[@"photo"] = imageFile;
            self.checkin[@"photoDims"] = [WineCell arrayFromSize:image.size];
            NSLog(@"Successfully added photo!");
        }
        
        self.IS_SAVING = NO;
    }];
}*/

- (void)setSelectedType:(ReactionType)selectedType {
    _selectedType = selectedType;
    self.checkin.reactionType = @(selectedType);
}

- (void)addCaption:(NSString *)caption mentions:(NSMutableArray<MentionObject *> *)_mentions {
    self.mention.mentions = _mentions;
    self.checkin.caption = [[NewsFeed makeRawCaption:caption mentions:_mentions] mutableCopy];
}

- (void)showMentions:(CGFloat)offset {
    if(self.mention)
        [self.mention showMentions:offset];
}

- (void)hideMentions {
    if(self.mention) {
        [self.mention.tableView removeFromSuperview];
        [self.mention hideMentions];
    }
}

- (UITableView *)getTableView {
    return self.tableView;
}

- (CICaptionCell *)getCaptionCell {
    return (CICaptionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
}

- (CIHeaderCell *)getHeaderCell {
    return (CIHeaderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    SHOW_HUD_FOR_VIEW(self.hudShowView);
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    //ios 9
    if(NSClassFromString(@"PHLivePhoto"))
        imagePickerController.mediaTypes = @[/*(NSString *)kUTTypeMovie, */(NSString *)kUTTypeImage, (NSString *)kUTTypeLivePhoto];
    else
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    imagePickerController.navigationBar.tintColor = [UIColor whiteColor];
    imagePickerController.navigationBar.translucent = NO;
    imagePickerController.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        HIDE_HUD_FOR_VIEW(self.hudShowView);
    }];
    //[self.navigationController presentViewController:self.imagePickerController animated:YES completion:nil];
    //[self.navigationController pushViewController:self.imagePickerController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    self.refMovieURL = nil;
    if(CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *preprocess = [info valueForKey:UIImagePickerControllerOriginalImage];
        if(preprocess != nil) {
            NSInteger photoDim = MIN(preprocess.size.width, preprocess.size.height);
            NSInteger dim = photoDim > 1024 ? 1024 : photoDim;
            UIImage *image = [CIFilterVC squareImageFromImage:preprocess scaledToSize:dim];
            
            if(image != nil) {
                CIHeaderCell *cell = [self getHeaderCell];
                [cell presentPhotoForFiltering:image];
            } else {
                [unWineAlertView showAlertViewWithTitle:@"Upload Error" message:@"Photo failed to render."];
            }
        }
    } else if(CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        //NSURL *url = [[NSURL alloc] initFileURLWithPath:[(NSURL *)[info objectForKey:UIImagePickerControllerMediaURL] path]];
        self.refMovieURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
        NSData *data = [NSData dataWithContentsOfURL:self.refMovieURL];
        LOGGER(self.refMovieURL);
        UIImage *thumbnail = [CaptureSessionManager thumbnailImageForVideo:self.refMovieURL atTime:(NSTimeInterval)0];
        
        CIHeaderCell *cell = [self getHeaderCell];
        [cell cameraFinishedRecording:data url:self.refMovieURL thumbnail:thumbnail];
    } else if(NSClassFromString(@"PHLivePhoto") && CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeLivePhoto, 0) == kCFCompareEqualTo) {
        SHOW_HUD_FOR_VIEW(self.hudShowView);
        PHLivePhoto *livePhoto = [info valueForKey:UIImagePickerControllerLivePhoto];
        if(livePhoto != nil) {
            LOGGER(@"tried to add a live photo");
            UIImage *preprocess = [UIImage imageWithCGImage:[[info valueForKey:UIImagePickerControllerOriginalImage] CGImage]];
            NSInteger photoDim = MIN(preprocess.size.width, preprocess.size.height);
            NSInteger dim = photoDim > 1024 ? 1024 : photoDim;
            UIImage *image = [CIFilterVC squareImageFromImage:preprocess scaledToSize:dim];
            
            if(image != nil) {
                HIDE_HUD_FOR_VIEW(self.hudShowView);
                CIHeaderCell *cell = [self getHeaderCell];
                [cell presentPhotoForFiltering:image];
            } else {
                [unWineAlertView showAlertViewWithTitle:@"Upload Error" message:@"Live Photo failed to render."];
            }
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)wineMorePresentationView {
    return self.navigationController.view;
}

- (void)presentViewControllerFromCell:(UIViewController *)controller {
    [self.navigationController pushViewController:controller animated:YES];
}

@end
