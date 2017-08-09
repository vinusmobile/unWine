//
//  RegistrationTVC.h
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewController+Helper.h"

// Form Values Stuff
#define FORM_FB_URL     @"facebookURL"
#define FORM_PHOTO      @"photo"
#define FORM_NAME       @"name"
#define FORM_USERNAME   @"username"
#define FORM_PASSWORD   @"password"
#define FORM_PASSWORD2  @"password2"
#define FORM_EMAIL      @"email"
#define FORM_EMAIL2     @"email2"
#define FORM_PHONE      @"phone"
#define FORM_LOCATION   @"location"
#define FORM_BIRTHDAY   @"birthday"
#define FORM_GENDER     @"gender"
#define FORM_FB_ID      @"facebookID"

#define CELL_BACKGROUND_COLOR           [UIColor colorWithRed:.22 green:.22 blue:.22 alpha:.6]
#define CELL_TEXT_BACKGROUND_COLOR      [UIColor colorWithRed:.66 green:.66 blue:.66 alpha:.5]

#define EDIT_MODE       YES
#define SIGN_UP_MODE    NO

@interface RegistrationTVC : UITableViewController

@property (nonatomic,       )   BOOL mode;
@property (strong, nonatomic)   UITextField *activeTextField;
@property (nonatomic, strong)   NSMutableDictionary *form;
@property (nonatomic        )   BOOL userIsGuestAndUsingFacebook;

- (void)showImagePickerWithSource:(UIImagePickerControllerSourceType)source;
- (void)checkProfile;
@end
