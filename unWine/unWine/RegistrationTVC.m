//
//  RegistrationTVC.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "RegistrationTVC.h"

#import "TitleProfileCell.h"
#import "TextFieldCell.h"
#import "LabelCell.h"
#import "PhotoNameCell.h"
#import "DoneRegCell.h"
#import "TermsRegCell.h"
//#import "ImageCropView.h"
#import "ParseSubclasses.h"
#import "MainLogInViewController.h"
#import <Bolts/Bolts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "CastProfileVC.h"

#define TITLE_CELL_INDEX        0
#define PHOTO_CELL_INDEX        1
#define USERNAME_CELL_INDEX     2                   // textfield
#define PASSWORD_CELL_INDEX     3                   // textfield
#define PASSWORD2_CELL_INDEX    4                   // textfield
#define EMAIL_CELL_INDEX        5                   // textfield
#define EMAIL2_CELL_INDEX       6                   // textfield
#define PHONE_CELL_INDEX        7                   // textfield
#define LOCATION_CELL_INDEX     8                   // textfield
#define BIRTHDAY_CELL_INDEX     9                   // label
#define GENDER_CELL_INDEX       10                  // label
#define DONE_CELL_INDEX         11
#define TERMS_CELL_INDEX        12

#define ADD_BUTTON_ACTION_SHEET_TAG 11
#define FACEBOOK_ALERT_TAG  22

#define HAS_AT_LEAST_3_CHARS(string)  [string length] > 2
#define HAS_AT_LEAST_6_CHARS(string)  [string length] > 5
#define HAS_AT_MOST_16_CHARS(string)  [string length] < 16

#define PASSWORDS_ARE_SET       (self.form[FORM_PASSWORD] && self.form[FORM_PASSWORD2])
#define PASSWORDS_MATCH         [self.form[FORM_PASSWORD] isEqualToString:self.form[FORM_PASSWORD2]]
#define ONLY_ONE_PASSWORD_SET   ((!self.form[FORM_PASSWORD] && self.form[FORM_PASSWORD2]) || (self.form[FORM_PASSWORD] && !self.form[FORM_PASSWORD2]))
#define NO_PASSWORDS_SET        (!self.form[FORM_PASSWORD] && !self.form[FORM_PASSWORD2])

#define EMAILS_ARE_SET          (self.form[FORM_EMAIL] && self.form[FORM_EMAIL2])
#define EMAILS_MATCH            [self.form[FORM_EMAIL] isEqualToString:self.form[FORM_EMAIL2]]
#define ONLY_ONE_EMAIL_SET      ((!self.form[FORM_EMAIL] && self.form[FORM_EMAIL2]) || (self.form[FORM_EMAIL] && !self.form[FORM_EMAIL2]))
#define NO_EMAILS_SET           (!self.form[FORM_EMAIL] && !self.form[FORM_EMAIL2])

@interface RegistrationTVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>//, unWineAlertViewDelegate>
@property (nonatomic, strong) User *user;
@property (nonatomic, )       BOOL facebookInfoDownloaded;
@property (nonatomic, )       BOOL userIsGuest;

@end

@implementation RegistrationTVC

@synthesize mode, activeTextField, form, facebookInfoDownloaded, userIsGuestAndUsingFacebook, userIsGuest;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.title = @"Profile";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.user = [User currentUser] ? [User currentUser] : (User *)[User user];
    self.userIsGuest = [[User currentUser] isAnonymous] ? YES : NO;
    self.form = [[NSMutableDictionary alloc] init];
    self.facebookInfoDownloaded = NO;
    
    if (self.mode == EDIT_MODE) {
        [self setUpForm];
    } else {
        NSString *title = self != [self.navigationController.viewControllers objectAtIndex:0] ? @"Back" : @"Close";
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(backPressed)];
        self.navigationItem.leftBarButtonItem = newBackButton;
    }
    
    UIImage *bv = [UIImage imageNamed:@"loginBackground_5.png"];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:/*[UIImage imageNamed:@"su-background.png"]*/ bv];
    [tempImageView setFrame:self.tableView.bounds];
    
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = tempImageView;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self basicAppeareanceSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpForm {
    if (self.mode == SIGN_UP_MODE) {
        LOGGER(@"Nothing to do here");
        return;
    }
    
    if (self.user && self.user.acceptedTerms) {
        LOGGER(@"Setting up form in edit mode");
        
        if (self.user.imageFile) {
            self.form[FORM_PHOTO] = self.user.imageFile;
        }
        
        if (ISVALID(self.user.facebookPhotoURL)) {
            self.form[FORM_FB_URL] = self.user.facebookPhotoURL;
        }
        
        
        if (ISVALID([self.user getName])) {
            self.form[FORM_NAME] = [self.user getName];
        }
        
        if (ISVALID(self.user.username)) {
            self.form[FORM_USERNAME] = [self.user.username length] == 21 ? @"" : self.user.username;
        }
        
        /*// Email, special case
        if (ISVALID(self.user.email)) {
            self.form[FORM_EMAIL] = self.user.email;
            self.form[FORM_EMAIL2] = self.user.email;
        }*/
        
        if (ISVALID(self.user.phoneNumber)) {
            self.form[FORM_PHONE] = self.user.phoneNumber;
        }
        
        if (ISVALID([self.user getLocation])) {
            self.form[FORM_LOCATION] = [self.user getLocation];
        }
        
        if (self.user.birthday) {
            self.form[FORM_BIRTHDAY] = self.user.birthday;
        }
        
        if (ISVALID([self.user getGender])) {
            self.form[FORM_GENDER] = [self.user getGender];
        }
    }
}

- (void)backPressed {
    LOGGER(@"Back button pressed");
    if(self != [self.navigationController.viewControllers objectAtIndex:0]) {
        if (self.user && !self.user.acceptedTerms && [self.user hasFacebook]) {
            LOGGER(@"Deleting unfinished user");
            SHOW_HUD;
            [[[PFCloud callFunctionInBackground:@"deleteAccount" withParameters:@{@"currentUser": [User currentUser].objectId}] continueWithBlock:^id(BFTask *task) {
                
                LOGGER(task.result);
                return [User deleteAndLogoutUser];
            }] continueWithBlock:^id(BFTask *task) {
                LOGGER(task.result);
                HIDE_HUD;
                
                [Analytics trackUserCancelledRegistration];
                
                UIViewController *possiblyMain = [self.navigationController.viewControllers objectAtIndex:0];
                if([possiblyMain isKindOfClass:[MainLogInViewController class]]) {
                    MainLogInViewController *main = (MainLogInViewController *)possiblyMain;
                    main.isRegistering = NO;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
                return nil;
            }];
        } else {
            UIViewController *possiblyMain = [self.navigationController.viewControllers objectAtIndex:0];
            if([possiblyMain isKindOfClass:[MainLogInViewController class]]) {
                MainLogInViewController *main = (MainLogInViewController *)possiblyMain;
                main.isRegistering = NO;
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    LOGGER(@"will appear!");
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.mode == SIGN_UP_MODE && [self.user hasFacebook] && self.facebookInfoDownloaded == NO) {
        unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"You used Facebook to Sign Up, would you like to use Facebook to prefill your profile"];
        alert.delegate = self;
        alert.leftButtonTitle = @"No";
        alert.rightButtonTitle = @"Yes";
        alert.tag = FACEBOOK_ALERT_TAG;
        
        [alert show];
    }
}

- (void)rightButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == FACEBOOK_ALERT_TAG) {
        [self downloadFacebookInfo];
    }
}

#pragma mark - Table view data source

// Cell separator stuff
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger rows = 13;
    
    if (self.mode == EDIT_MODE) {
        rows--; // To get rid of Terms Cell
    }
    
    return rows;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 5;
    
    switch (section) {
        case TITLE_CELL_INDEX:
            height = 0;
            break;
        case PHOTO_CELL_INDEX:
            height = 1;
            break;
        case DONE_CELL_INDEX:
            height = .1;
            break;
        case TERMS_CELL_INDEX:
            height = 1;
            break;
        default:
            break;
    }
    
    return height; // you can have your own choice, of course
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    switch (section) {
        case PHOTO_CELL_INDEX:
            headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
            headerView.backgroundColor = [UIColor clearColor];
            
        default:
            break;
    }
    
    return headerView;
}





// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TitleCellIdentifier        =  @"TitleCell";
    static NSString *PhotoNameCellIdentifier    =  @"PhotoNameCell";
    static NSString *TextFieldCellIdentifier    =  @"TextFieldCell";
    static NSString *PickerCellIdentifier       =  @"PickerCell";
    static NSString *DoneCellIdentifier         =  @"DoneCell";
    static NSString *TermsCellIdentifier        =  @"TermsCell";
    
    
    UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"stuff" forIndexPath:indexPath];
    NSString *cellIdentifier = @"";
    
    
    // Configure the cell...
    switch (indexPath.section) {
        case TITLE_CELL_INDEX:
            cellIdentifier = TitleCellIdentifier;
            break;
        case PHOTO_CELL_INDEX:
            cellIdentifier = PhotoNameCellIdentifier;
            break;
        case USERNAME_CELL_INDEX:
        case PASSWORD_CELL_INDEX:
        case PASSWORD2_CELL_INDEX:
        case EMAIL_CELL_INDEX:
        case EMAIL2_CELL_INDEX:
        case PHONE_CELL_INDEX:
        case LOCATION_CELL_INDEX:
            cellIdentifier = TextFieldCellIdentifier;
            break;
        case BIRTHDAY_CELL_INDEX:
        case GENDER_CELL_INDEX:
            cellIdentifier = PickerCellIdentifier;
            break;
        case DONE_CELL_INDEX:
            cellIdentifier = DoneCellIdentifier;
            break;
        case TERMS_CELL_INDEX:
            cellIdentifier = TermsCellIdentifier;
            break;
            
        default:
            break;
    }
    
    // Deque cells here
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case TITLE_CELL_INDEX:
            [(TitleProfileCell *)cell setUp];
            break;
        case PHOTO_CELL_INDEX:
            [(PhotoNameCell *)cell setUpWithParent:self];
            break;
            
            
        case USERNAME_CELL_INDEX:
            [(TextFieldCell *)cell setUpUsernameWithParent:self];
            break;
        case PASSWORD_CELL_INDEX:
            [(TextFieldCell *)cell setUpPasswordWithParent:self];
            break;
        case PASSWORD2_CELL_INDEX:
            [(TextFieldCell *)cell setUpPassword2WithParent:self];
            break;
        case EMAIL_CELL_INDEX:
            [(TextFieldCell *)cell setUpEmailWithParent:self];
            break;
        case EMAIL2_CELL_INDEX:
            [(TextFieldCell *)cell setUpEmail2WithParent:self];
            break;
        case PHONE_CELL_INDEX:
            [(TextFieldCell *)cell setUpPhoneWithParent:self];
            break;
        case LOCATION_CELL_INDEX:
            [(TextFieldCell *)cell setUpLocationWithParent:self];
            break;
            
            
        case BIRTHDAY_CELL_INDEX:
            [(LabelCell *)cell setUpBirthdayWithParent:self];
            break;
        case GENDER_CELL_INDEX:
            [(LabelCell *)cell setUpGenderWithParent:self];
            break;
            
            
        case DONE_CELL_INDEX:
            [(DoneRegCell *)cell setUpWithParent:self];
            break;
        case TERMS_CELL_INDEX:
            [(TermsRegCell *)cell setUpWithParent:self];
            break;
            
        default:
            break;
    }
    
    
    
    
    // Setup cell here
    
    
    
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[LabelCell class]]) {
        [(LabelCell *)cell showPicker];
    }
}

- (void)showMinPasswordLengthDialogue {
    [unWineAlertView showAlertViewWithTitle:nil message:@"Password should be at least 6 characters long."];
}

- (void)showMaxPasswordLengthDialogue {
    [unWineAlertView showAlertViewWithTitle:nil message:@"Password should be at most 16 characters long."];
}

- (void)showMinUsernameLengthDialogue {
    [unWineAlertView showAlertViewWithTitle:nil message:@"Username should be at least 3 characters long."];
}

- (void)showMaxUsernameLengthDialogue {
    [unWineAlertView showAlertViewWithTitle:nil message:@"Username should be at most 16 characters long."];
}



// Profile Submission stuff

- (void)checkProfile {
    
    [self.activeTextField resignFirstResponder];
    
    NSMutableArray *missingFields = [[NSMutableArray alloc] initWithArray:@[]];
    NSMutableArray *nonMatchingFields = [[NSMutableArray alloc] initWithArray:@[]];
    
    if (!self.form[FORM_NAME]) {
        [missingFields addObject:@"Name"];
    } else {
        self.user.canonicalName = [self.form[FORM_NAME] lowercaseString];
    }
    
    if (!self.form[FORM_USERNAME]) {
        [missingFields addObject:@"Username"];
    } else if (self.form[FORM_USERNAME] && HAS_AT_LEAST_3_CHARS(self.form[FORM_USERNAME])
                                        && HAS_AT_MOST_16_CHARS(self.form[FORM_USERNAME])) {
        self.user.username = self.form[FORM_USERNAME];
    } else if (self.form[FORM_USERNAME] && HAS_AT_LEAST_3_CHARS(self.form[FORM_USERNAME]) == NO) {
        [self showMinUsernameLengthDialogue];
    } else if (self.form[FORM_USERNAME] && HAS_AT_MOST_16_CHARS(self.form[FORM_USERNAME]) == NO) {
        [self showMaxUsernameLengthDialogue];
        return;
    }
    
    NSString *string = [NSString stringWithFormat:@"Pass = \"%@\", Pass2 = \"%@\"", self.form[FORM_PASSWORD], self.form[FORM_PASSWORD2]];
    LOGGER(string);
    
    if (NO_PASSWORDS_SET && self.mode == SIGN_UP_MODE) {
        [missingFields addObject:@"Password"];
    } else if ((PASSWORDS_ARE_SET && PASSWORDS_MATCH == NO) || (ONLY_ONE_PASSWORD_SET == YES)) {
        [nonMatchingFields addObject:@"Password"];
    } else if (PASSWORDS_ARE_SET && PASSWORDS_MATCH && HAS_AT_LEAST_6_CHARS(self.form[FORM_PASSWORD])
                                                    && HAS_AT_MOST_16_CHARS(self.form[FORM_USERNAME])) {
        self.user.password = self.form[FORM_PASSWORD];
    } else if (PASSWORDS_ARE_SET && PASSWORDS_MATCH && HAS_AT_LEAST_6_CHARS(self.form[FORM_PASSWORD]) == NO) {
        [self showMinPasswordLengthDialogue];
        return;
    } else if (PASSWORDS_ARE_SET && PASSWORDS_MATCH && HAS_AT_MOST_16_CHARS(self.form[FORM_PASSWORD]) == NO) {
        [self showMaxPasswordLengthDialogue];
        return;
    }

    string = [NSString stringWithFormat:@"Email = \"%@\", Email2 = \"%@\"", self.form[FORM_EMAIL], self.form[FORM_EMAIL2]];
    LOGGER(string);
    
    if (NO_EMAILS_SET && self.mode == SIGN_UP_MODE) {
        [missingFields addObject:@"Email"];
    } else if ((EMAILS_ARE_SET && EMAILS_MATCH == NO) || (ONLY_ONE_EMAIL_SET == YES)) {
        [nonMatchingFields addObject:@"Email"];
    } else if (EMAILS_ARE_SET && EMAILS_MATCH) {
        self.user.email = self.form[FORM_EMAIL];
    }
    
    
    // Check if we need new fields
    if (missingFields.count > 0) {
        [self showMissingFieldsAlertWithArray:missingFields];
        return;
    }
    
    // Check if fields don't match
    if (nonMatchingFields.count > 0) {
        [self showNonMatchingFieldsAlertWithArray:nonMatchingFields];
        return;
    }
    
    LOGGER(@"User entered all required fields");
    
    // Optional stuff
    
    if (self.form[FORM_PHOTO] && [self.form[FORM_PHOTO] isKindOfClass:[PFFile class]] == FALSE) {
        [self.user setProfileImageWithImage:self.form[FORM_PHOTO]];
        [self.user removeObjectForKey:@"facebookPhotoURL"];
    }
    
    if (self.form[FORM_FB_URL]) {
        self.user.facebookPhotoURL = self.form[FORM_FB_URL];
        [self.user removeObjectForKey:@"imageFile"];
    }
    
    if (self.form[FORM_FB_ID]) {
        self.user.facebookId = self.form[FORM_FB_ID];
    }
    
    if (self.form[FORM_PHONE]) {
        self.user.phoneNumber    = self.form[FORM_PHONE];
    }
    
    if (self.form[FORM_LOCATION]) {
        self.user.location       = self.form[FORM_LOCATION];                // TODO: Convert this to coordinates on CLOUD CODE
    }
    
    if (self.form[FORM_BIRTHDAY]) {
        self.user.birthday       = self.form[FORM_BIRTHDAY];                // TODO: Convert the old birthday string to NSDate via CLOUD CODE
    }
    if (self.form[FORM_GENDER]) {
        self.user.gender         = self.form[FORM_GENDER];
    }
    
    
    [self saveOrUploadProfile];
    
}

- (void)saveOrUploadProfile {
    if (self.user.isDirty == NO) {
        LOGGER(@"Nothing to do here");
        [self dismissView];
        return;
    }
    
    if (self.mode == EDIT_MODE || ([self.user isAuthenticated] && [self.user hasFacebook])) {
        // Save image (if any), then save
        [[self.user updateProfileWithHUD:SHOW_HUD] continueWithBlock:^id(BFTask *task) {
            HIDE_HUD;
            if (task.error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithError:task.error];
                });
            } else {
                
                // Track whether user just singed up via Facebook
                if (self.userIsGuestAndUsingFacebook) {
                    [Analytics trackGuestSignUpFacebook];
                }
                
                [self dismissView];
            }
            
            return nil;
        }];
    } else {
        LOGGER(@"Signing Up new account as usual");
        
        if (self.userIsGuest) {
            [Analytics trackGuestSignUp];
        }
        
        [[self.user signUpUserWithHUD:SHOW_HUD] continueWithBlock:[self handleSignUpBlock]];
    }
}



- (id)handleSignUpBlock {
    id (^resultsBlock)(BFTask *task) = ^id(BFTask *task) {
        
        HIDE_HUD;
        if (task.error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithError:task.error];
            });
        } else {
            CastProfileVC *profile = [[GET_APP_DELEGATE ctbc] getProfileVC];
            
            if (profile) {
                profile.shouldRefresh = YES;
            }
            
            [self dismissView];
        }
        
        return nil;
    };
    
    return resultsBlock;
}

- (void)showAlertWithError:(NSError *)error {
    if(error.code == kPFErrorUsernameTaken) {
        [unWineAlertView showAlertViewWithTitle:@"Signup Error" message:@"This username has already been taken."];
    } else if(error.code == kPFErrorUserEmailTaken) {
        [unWineAlertView showAlertViewWithTitle:@"Signup Error" message:@"This email address has already been taken."];
    } else {
        [unWineAlertView showAlertViewWithTitle:@"Signup Error" error:error];
    }
}

- (void)showMissingFieldsAlertWithArray:(NSMutableArray *)array {
    
    NSMutableString *errorString = [[NSMutableString alloc] initWithString:@"Please enter the following:\n\n"];
    
    for (NSString *string in array) {
        [errorString appendString:[NSString stringWithFormat:@"- %@\n", string]];
    }
    
    [unWineAlertView showAlertViewWithTitle:@"Missing profile information" message:errorString];
    
}

- (void)showNonMatchingFieldsAlertWithArray:(NSMutableArray *)array {
    
    NSString *title = @"Sometimes wine gets the best of us";
    NSMutableString *errorString = [[NSMutableString alloc] initWithString:@"The following does not match:\n\n"];
    
    for (NSString *string in array) {
        [errorString appendString:[NSString stringWithFormat:@"- %@\n", string]];
    }
    
    //[errorString appendString:@"\nPlease make sure they match"];
    
    // display a notification or something to indicate the error
    [unWineAlertView showAlertViewWithTitle:title message:errorString cancelButtonTitle:@"Keep unWineing"];
}









// Keyboard stuff
- (void)keyboardWillShow:(NSNotification *)sender {
    //printf("\n\n");
    //NSLog(@"keyboardWillShow\n\n");
    
    
    NSDictionary* info = [sender userInfo];
    
    CGSize kbSize =    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGPoint kbOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    
    CGFloat sbHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat nbHeight = self.navigationController.navigationBar.frame.size.height;
    //CGFloat cHeight = PHFComposeBarViewInitialHeight;
    CGFloat tbHeight = self.tabBarController.tabBar.frame.size.height;
    
    //NSLog(@"kbOrigin.x    = %f", kbOrigin.x);
    //NSLog(@"kbOrigin.y    = %f  , tableViewHeight + sbHeight + nbHeight = %f", kbOrigin.y, (self.tableView.contentSize.height + sbHeight + nbHeight));
    //NSLog(@"kbSize.width  = %f", kbSize.width);
    //NSLog(@"kbSize.height = %f", kbSize.height);
    
    if ((self.tableView.contentSize.height + sbHeight + nbHeight) < kbOrigin.y) {
        return;
    }
    
    CGFloat screenOffset = 0;
    
    if (IS_IPHONE_4) {
        screenOffset = 86;
    }
    
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height - kbSize.height - tbHeight - sbHeight + screenOffset) animated:YES];
}











// Image Picker Stuff
#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)source {
    
    if ([UIImagePickerController isSourceTypeAvailable:source] == NO) {
        LOGGER(@"Source not available");
        return;
    }
    
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType = source;
    
    // Delegate is self
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.userInteractionEnabled = YES;
    
    // Show image picker
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"didFinishPickingMediaWithInfo");

    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.form[FORM_PHOTO] = image;
        [self.form removeObjectForKey:FORM_FB_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[cell setUpWithParent:self]; // or tableview reload
            [self.tableView reloadData];
            
        });
        
    }];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController.navigationItem setTitle:@"Select Profile Picture"];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.translucent = NO;
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [unWineAlertView showAlertViewWithTitle:@"Failed to save" error:error];
}


- (void)dismissView {
    LOGGER(@"Showing Main Tab Bar");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self != [self.navigationController.viewControllers objectAtIndex:0]) {
            UIViewController *possiblyMain = [self.navigationController.viewControllers objectAtIndex:0];
            if([possiblyMain isKindOfClass:[MainLogInViewController class]]) {
                MainLogInViewController *main = (MainLogInViewController *)possiblyMain;
                if(main.isGuestLoggingIn)
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                else
                    [self.navigationController popViewControllerAnimated:YES];
            } else
                [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}



// FACEBOOK STUFF


- (void)downloadFacebookInfo{
    
    if (self.mode == EDIT_MODE) {
        LOGGER(@"Only works on registration");
        return;
    }
    
    if ([self.user hasFacebook] == NO || [FBSDKAccessToken currentAccessToken] == nil) {
        LOGGER(@"User needs to have Facebook for this");
        return;
    }
    
    // Fill the user Profile by using Facebook if the user selected Facebook
     
    SHOW_HUD;
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email, location, gender, birthday"}]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
         HIDE_HUD;
         if (!error) {
             // Parse the data received
             NSDictionary *userData = (NSDictionary *)result;
             
             //NSLog(@"profileTableViewController - setProfile - userData = %@", userData);
             NSString *facebookID = userData[@"id"];
             
             // Creates a URL to get the profile picture id using the user id
             
             NSString *pictureURL = [User getFacebookFetchURL:facebookID];
             
             
             if (facebookID) {
                 self.form[FORM_FB_ID] = facebookID;
             }
             
             if (userData[@"name"]) {
                 self.form[FORM_NAME] = userData[@"name"];
             }
             
             // Email, special case
             if (userData[@"email"]) {
                 self.form[FORM_EMAIL] = userData[@"email"];
             }
             
             if (userData[@"location"][@"name"]) {
                 self.form[FORM_LOCATION] = userData[@"location"][@"name"];
             }
             
             if (userData[@"gender"]) {
                 self.form[FORM_GENDER] = [userData[@"gender"] capitalizedString];
             }
             
             if (userData[@"birthday"]) {
                 NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                 [formatter setDateFormat:@"MM/dd/yyyy"];
                 //NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                 //[formatter setTimeZone:gmt];
                 NSDate *date = [formatter dateFromString:userData[@"birthday"]];
                 
                 NSLog(@"%@",date);
                 self.form[FORM_BIRTHDAY] = date;
             }
             
             /*
             if (userData[@"relationship_status"]) {
                 self.form[FORM_RELATIONSHIP_STATUS] = userData[@"relationship_status"];
             }*/
             
             if (pictureURL) {
                 self.form[FORM_FB_URL] = pictureURL;//[pictureURL absoluteString];
                 [self.form removeObjectForKey:FORM_PHOTO];
             }
             
             // This object will be passed to the profileTableViewController
             printf("\n\n");
             LOGGER(@"Facebook Info:");
             LOGGER(userData);
             
             self.facebookInfoDownloaded = YES;
             [self.tableView reloadData];
             
         } else if ([[error userInfo][@"error"][@"type"] isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
             NSLog(@"The facebook session was invalidated");
             [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
         } else {
             [self showAlertWithError:error];
         }
     }];
    
}

/*
- (void)ImageCropViewController:(UIViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    LOGGER(@"even called1?");
}

- (void)ImageCropViewControllerDidCancel:(UIViewController *)controller {
    LOGGER(@"even called2?");
}
*/

@end












