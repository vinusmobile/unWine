//
//  WineContainerVC.m
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineContainerVC.h"
#import "CheckinInterface.h"
#import "ImageFullVC.h"
#import "CIFilterVC.h"
#import "ChevronView.h"

@interface WineContainerVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ChevronViewDelegate, WineCellDelegate>

@property (nonatomic) PFImageView *wineView;
@property (nonatomic) UIButton *settingsButton;
@property (nonatomic) UIImageView *verifiedView;
@property (nonatomic) UIView *footerView;
@property (nonatomic) BOOL isEditing;

@end

@implementation WineContainerVC {
    ImageFullVC *imageFullVC;
}
@synthesize extendedPath;

static NSInteger footerHeight = 52;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.wine) {
        self.wine = [unWine object];
        self.registers = [[NSMutableDictionary alloc] init];
        self.isEditing = YES;
    }
    
    self.view.backgroundColor = [ThemeHandler getDeepBackgroundColor:unWineThemeDark];
    
    NSInteger dim = SCREEN_WIDTH;
    self.wineView = [[PFImageView alloc] initWithFrame:CGRectMake(0, -28, dim, dim)];
    
    if (self.theWineImage) {
        LOGGER(@"Setting new wine image from Scanner");
        UIImage *image = self.theWineImage;
        NSInteger dim = MIN(MIN(image.size.width, image.size.height), 1024);
        UIImage *square = [CIFilterVC squareImageFromImage:image scaledToSize:dim];
        [self setWinePhoto:square];
        
    } else {
        LOGGER(@"Setting image from existing wine record");
        [[self.wine setWineImageForImageView:self.wineView] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            UIImage *ref = self.wineView.image;
            
            if(ref.size.width != ref.size.height) {
                UIImage *square = [CIFilterVC squareImageFromImage:self.wineView.image
                                                      scaledToSize:MIN(ref.size.width, ref.size.height)];
                
                [self.wineView setImage:square];
            }
            
            return nil;
        }];
    }
    
    
    [self.wineView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.wineTable = [[WineTVC alloc] initWithStyle:UITableViewStylePlain];
    self.wineTable.parent = self;
    self.wineTable.isEditingWine = self.isEditing;
    self.wineTable.wine = self.wine;
    self.wineTable.view.frame = CGRectMake(0, 0, 0, 0);
    
    [self addChildViewController:self.wineTable];
    //[self.view addSubview:self.wineTable.view];
    [self.wineTable didMoveToParentViewController:self];
    
    self.parallaxView = [[MDCParallaxView alloc] initWithBackgroundView:self.wineView
                                                         foregroundView:self.wineTable.view];
    self.parallaxView.userInteractionEnabled = YES;
    self.parallaxView.backgroundHeight = dim * 3 / 4.f;
    self.parallaxView.scrollView.scrollsToTop = YES;
    self.parallaxView.backgroundInteractionEnabled = YES;
    [self.view addSubview:self.parallaxView];
    
    self.wineView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedWine)];
    [self.wineView addGestureRecognizer:tapped];
    
    [self.parallaxView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self getActualHeight] + 1)];
    
    [self updateNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    LOGGER(@"Enter");
    if (self.cameFrom == CastCheckinSourceScanner && self.isNew) {
        LOGGER(@"Doing the thing");
        [self setUpEditView:YES];
    }
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (NSInteger)getActualHeight {
    return SCREENHEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT;
}

#pragma Subviews

- (void)addUnWineTitleView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
    self.navigationItem.title = @"Back";
}

- (void)addVerifiedView:(UIView *)parentView {
    [self.wine checkIfVerified];
    
    if(!self.verifiedView) {
        NSInteger buffer = 8;
        NSInteger dim = 92;
        NSInteger size = WIDTH(self.wineView);
        self.verifiedView = [[UIImageView alloc] initWithFrame:CGRectMake(size - dim - buffer, size - dim * 1.75 - buffer, dim, dim)];
        [self.verifiedView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    if(parentView && ![self.verifiedView superview])
        [parentView addSubview:self.verifiedView];
    
    if(self.wine.checkinCount > [unWine getWeatheredCount]) {
        [self.verifiedView setImage:[UIImage imageNamed:@"verifiedWeathered@3x"]];
        [self.verifiedView setHidden:NO];
    } else if(self.wine.checkinCount > [unWine getVerifiedCount]) {
        [self.verifiedView setImage:[UIImage imageNamed:@"verifiedIcon@3x"]];
        [self.verifiedView setHidden:NO];
    } else if(self.wine.verified) {
        [self.verifiedView setImage:[UIImage imageNamed:@"verifiedIcon@3x"]];
        [self.verifiedView setHidden:NO];
    } else
        [self.verifiedView setHidden:YES];
}

- (UIView *)getFooterView {
    if(!self.footerView) {
        ChevronView *arrow = [[ChevronView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - footerHeight, [self getActualHeight] - footerHeight, footerHeight, footerHeight)];
        arrow.delegate = self;
        arrow.backgroundColor = UNWINE_RED;
        arrow.tintColor = [UIColor whiteColor];
        arrow.layer.shadowColor = [[UIColor blackColor] CGColor];
        arrow.layer.shadowOffset = CGSizeMake(0, 0);
        arrow.layer.shadowOpacity = 1;
        arrow.layer.shadowRadius = 3.0f;
        self.footerView = arrow;
    }
    
    return self.footerView;
}

#pragma Gestures

static NSString *actionWishListIt = @"Add to Wish List";
static NSString *actionUnWishListIt = @"Remove from Wish List";
static NSString *actionEditIt = @"Edit Wine";
static NSString *actionRecommendIt = @"Recommend Wine";

static NSString *dialogViewPhoto = @"View Photo";
static NSString *dialogTakePhoto = @"Take a Photo";
static NSString *dialogChoosePhoto = @"Choose a Photo";

- (void)tappedWine {
    LOGGER(@"tapped");
    if(!self.isEditing) {
        [self viewWinePhoto];
    } else {
        unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:[self.wine getWineName]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@[dialogViewPhoto, dialogTakePhoto, dialogChoosePhoto]];
        [sheet showFromTabBar:self.navigationController.view];
    }
}

- (void)viewWinePhoto {
    if(imageFullVC == nil)
        imageFullVC = [[UIStoryboard storyboardWithName:@"ImageFull" bundle:nil] instantiateInitialViewController];
    
    imageFullVC.view.alpha = 0;
    
    [imageFullVC setImage:self.wineView.image];
    
    [self.navigationController.view addSubview:imageFullVC.view];
    [UIView animateWithDuration:.3 animations:^{
        imageFullVC.view.alpha = 1;
    }];
}

- (void)tappedReactions {
    
}

- (void)tappedCheckins {
    
}

- (void)chevronPressed:(ChevronView *)chevronView {
    if (self.isEditing) {
        LOGGER(@"User is editing. Don't do anything");
        return;
    }
    
    //throw an action sheet: edit wine, add to/remove from wish list, recommend wine
    User *user = [User currentUser];
    
    SHOW_HUD;
    [[user hasWineInWishList:self.wine] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        HIDE_HUD;
        BOOL inWishList = t.result.boolValue;
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        
        [buttons addObject:(inWishList ? actionUnWishListIt : actionWishListIt)];
        
        [self.wine checkIfVerified];
        
        if(![user isAnonymous] && !self.wine.verified)
            [buttons addObject:actionEditIt];
        
        [buttons addObject:actionRecommendIt];
        
        unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:[self.wine getWineName]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:buttons];
        [sheet showFromTabBar:self.navigationController.view];
        
        return nil;
    }];
}

- (void)actionSheet:(unWineActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionWishListIt]) {
        User *user = [User currentUser];
        [user addWineToCellar:self.wine];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionUnWishListIt]) {
        User *user = [User currentUser];
        [user removeWineFromCellar:self.wine];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionRecommendIt]) {
        [self recommendIt];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:actionEditIt]) {
        [self editIt];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogViewPhoto]) {
        [self viewWinePhoto];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogTakePhoto]) {
        [self showImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogChoosePhoto]) {
        [self showImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma Photo Stuff

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)source {
    if ([UIImagePickerController isSourceTypeAvailable:source] == NO) {
        LOGGER(@"Source not available");
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = source;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.userInteractionEnabled = YES;
    imagePicker.view.tintColor = [UIColor whiteColor];
    imagePicker.navigationController.view.tintColor = [UIColor whiteColor];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMediaWithInfo");
    UIImage *image = info[UIImagePickerControllerEditedImage];// = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(image && ![image isKindOfClass:[NSNull class]]) {
            NSInteger dim = MIN(MIN(image.size.width, image.size.height), 1024);
            UIImage *square = [CIFilterVC squareImageFromImage:image scaledToSize:dim];
            [self setWinePhoto:square];
        }
    }];
}

#pragma Checkin

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
    
    if (![self wineHasName]) {
        [unWineAlertView showAlertViewWithTitle:nil message:@"People want to know what you're drinking, please include a wine name!"];
        return;
    }
    
    BFTask *saveTask = nil;
    
    if (self.wine.isDirty) {
        LOGGER(@"Saving wine");
        SHOW_HUD;
        saveTask = [self.wine saveInBackground];
    } else {
        LOGGER(@"Nothing to save");
        saveTask = [BFTask taskWithResult:@(true)];
    }
    
    [saveTask continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        HIDE_HUD;
        
        if (t.error) {
            LOGGER(@"Something happened");
            LOGGER(t.error);
            return nil;
        }

        LOGGER(@"Saved wine successfully");

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"castCheckIn" bundle:nil];
        CastCheckinTVC *checkinTVC = [storyboard instantiateViewControllerWithIdentifier:@"checkin"];
        checkinTVC.wine            = self.wine;
        checkinTVC.isNew           = NO;//self.isNew;
        checkinTVC.cameFrom        = self.cameFrom;
        [self.navigationController pushViewController:checkinTVC animated:YES];
        
        return nil;
    }];

}

- (BOOL)wineHasName {
    return (ISVALID([self.wine getWineName])) || ISVALID(self.registers[@"capitalizedName"]);
}

#pragma Recommend Wine

- (void)recommendIt {
    WineCell *cell = [[WineCell alloc] init];
    cell.wine = self.wine;
    cell.delegate = self;
    [cell recommendIt];
}

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
    [self.wineTable.tableView beginUpdates];
    [self.wineTable.tableView endUpdates];
}

#pragma Add/Edit Wine

- (void)editIt {
    self.isEditing = YES;
    
    if(!self.registers)
        self.registers = [[NSMutableDictionary alloc] init];
    else
        [self.registers removeAllObjects];
}

- (void)editDone {
    if (!([self wineHasName] && [self.registers count] > 0)) {
        [unWineAlertView showAlertViewWithTitle:nil message:@"People want to know what you're drinking, please include a wine name!"];
        return;
    }
    
    __block NSMutableArray<Records *> *records = [[NSMutableArray alloc] init];
    
    MBProgressHUD *hud = SHOW_HUD_FOR_VIEW(self.navigationController.view);
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = @"Saving...";
    
    LOGGER(@"Saving potentially new wine");
    BFTask *wineSaveTask = self.wine.isDirty ? [self.wine saveInBackground] : [BFTask taskWithResult:@(true)];
    
    [[[[wineSaveTask continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        LOGGER(@"Done saving potentially new wine");
        NSMutableArray<BFTask *> *saveTasks = [[NSMutableArray alloc] init];
    
        for(NSString *key in [self.registers allKeys]) {
            Records *record = [Records object];
            record.wine = self.wine;
            record.editor = [User currentUser];
            record.field = key;
            record.value = @[[self.registers objectForKey:key]];
            
            [saveTasks addObject:[record saveInBackground]];
            [records addObject:record];
        }

        LOGGER(@"Saving Record objects...");

        return [BFTask taskForCompletionOfAllTasksWithResults:saveTasks];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        LOGGER(@"Done saving Record objects");
        
        //PFRelation *history = [self.wine relationForKey:@"history"];
        PFRelation *history = self.wine.history;
        for(Records *record in records)
            [history addObject:record];
        
        LOGGER(@"Saving wine with new Record Objects");
        return self.wine.isDirty ? [self.wine saveInBackground] : [BFTask taskWithResult:@(true)];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull task) {
        
        LOGGER(@"Done saving wine");
        BFTask *saveTask = nil;
        User *user = [User currentUser];
        
        if(self.isNew) {
            LOGGER(@"Wine is new. Adding to user's credited wines");
            //[Grapes queueTransaction:MIN(5, [self.registers count]) reason:@"AddingNewWine"];
            [user addCreditedWines:self.wine];
            saveTask = [user saveInBackground];
            
        } else if(self.registers != nil && [self.registers count] > 0 && ![[user getCreditedWines] containsObject:[self.wine objectId]]) {
            LOGGER(@"User edited old wine. Adding to credited wines.");
            //[Grapes queueTransaction:MIN(4, [self.registers count]) reason:@"EditingWine"];
            [user addCreditedWines:self.wine];
            saveTask = [user saveInBackground];
            
        } else {
            LOGGER(@"No wines to save. Saving user if dirty");
            saveTask = user.isDirty ? [user saveInBackground] : [BFTask taskWithResult:@(true)];
        }
        
        LOGGER(@"Saving user...");
        
        return saveTask;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull task) {
        
        HIDE_HUD_FOR_VIEW(self.navigationController.view);
        if (task.error) {
            LOGGER(@"Something happened");
            LOGGER(task.error);
            [unWineAlertView showAlertViewWithTitle:@"Error saving wine" error:task.error];
            [Analytics trackError:task.error withName:@"Error saving new wine" withMessage:task.error.localizedDescription];
            
            return nil;
        }
        
        if (self.cameFrom == CastCheckinSourceScanner && self.isNew) {
            ANALYTICS_TRACK_EVENT(EVENT_CREATED_NEW_WINE_FROM_SCANNER);
        }
        
        self.isNew = NO;
        [self setUpEditView:NO];
        
        return nil;
    }];
}

- (void)setUpEditView:(BOOL)edit {
    self.isEditing = edit;
    _wineTable.isEditingWine = edit;
    
    [_wineTable.tableView reloadData];
    
    [self updateNavigationBar];
    
    /*if (self.cameFrom == CastCheckinSourceScanner && self.isEditing) {
     [unWineAlertView showAlertViewWithTitle:@"Help unWine get better" message:@"We created a new wine record for you. Can you please verify that everything is correct?"];
     }*/
}

- (void)updateNavigationBar {
    if(self.isEditing) {
        UIBarButtonItem *anotherButton         = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(editDone)];
        self.navigationItem.rightBarButtonItem = anotherButton;
        
        self.navigationItem.titleView = nil;
        self.navigationItem.title = @"Edit Mode";
        
        [self.verifiedView removeFromSuperview];
        [[self getFooterView] removeFromSuperview];
    } else {
        UIBarButtonItem *anotherButton         = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStylePlain target:self action:@selector(checkIn)];
        self.navigationItem.rightBarButtonItem = anotherButton;
        
        [self addUnWineTitleView];
        
        [self addVerifiedView:self.parallaxView];
        [self.view addSubview:[self getFooterView]];
    }
}

- (void)setWinePhoto:(UIImage *)image {
    PFFile *file = [PFFile fileWithName:@"image.jpeg" data:UIImageJPEGRepresentation(image, .5)];
    self.registers[@"image"] = file;
    self.wine.image = file;
    
    _wineView.image = image;
    [self.wineTable configureLastEdit];
}

- (void)setWineName:(NSString *)text {
    LOGGER(text);
    if(![text isEqualToString:@""] && ![[self.wine.name lowercaseString] isEqualToString:[text lowercaseString]]) {
        self.registers[@"name"] = text;
        self.wine.name = [text lowercaseString];
        self.wine.capitalizedName = [text capitalizedString];
    }
    
    [self.wineTable.tableView reloadData];
    [self.wineTable configureLastEdit];
}

- (void)setWineDetail:(WineDetail)detail toText:(NSString *)text {
    switch(detail) {
            /*case WineDetailGrape:
             if(![[self.wine.wineType lowercaseString] isEqualToString:[text lowercaseString]]) {
             self.registers[@"wineType"] = text;
             self.wine.wineType = [text lowercaseString];
             }
             break;*/
        case WineDetailPrice:
            if(![[self.wine.price lowercaseString] isEqualToString:[text lowercaseString]]) {
                NSString *pre = [text stringByReplacingOccurrencesOfString:@"$" withString:@""];
                self.registers[@"price"] = pre;
                self.wine.price = [pre lowercaseString];
            }
            break;
        case WineDetailRegion:
            if(![[self.wine.region lowercaseString] isEqualToString:[text lowercaseString]]) {
                NSString *pre = [text stringByReplacingOccurrencesOfString:@"," withString:@" >"];
                self.registers[@"region"] = pre;
                self.wine.region = [pre lowercaseString];
            }
            break;
        case WineDetailVarietal:
            if(![[self.wine.varietal lowercaseString] isEqualToString:[text lowercaseString]]) {
                self.registers[@"varietal"] = text;
                self.wine.varietal = [text lowercaseString];
            }
            break;
        case WineDetailVineyard:
            if(![[self.wine.vineyard lowercaseString] isEqualToString:[text lowercaseString]]) {
                self.registers[@"vineyard"] = text;
                self.wine.vineyard = [text lowercaseString];
            }
            break;
    }
    
    [self.wineTable.tableView reloadData];
    [self.wineTable configureLastEdit];
}

- (UIViewController *)actionSheetPresentationViewController {
    return self;
}

@end
