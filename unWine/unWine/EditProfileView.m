//
//  EditProfileView.m
//  unWine
//
//  Created by Bryce Boesen on 2/18/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "EditProfileView.h"
#import "ProfileTVC.h"
#import "CameraStyleKitClass.h"
#import "PHFComposeBarView.h"
#import "KeyboardManager.h"

#define NAME_TAG 1
#define LOCATION_TAG 2
#define BIRTHDAY_TAG 3

@interface EditProfileView () <PHFComposeBarViewDelegate, UITextFieldDelegate>

@end

@interface EditProfileCancelView : UIView

@property (nonatomic) EditProfileView *parent;

- (instancetype)initWithFrame:(CGRect)frame parent:(EditProfileView *)parent;

@end

@implementation EditProfileView {
    EditProfileCancelView *cancelView;
    
    UITextField *nameField;
    PHFComposeBarView *shadowNameField;
    
    UITextField *locationField;
    PHFComposeBarView *shadowLocationField;
    
    UITextField *birthdayField;
    UIDatePicker *birthdayPicker;
    NSDateFormatter *dateFormatter;
}
@synthesize singleTheme;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.singleTheme = unWineThemeDark;
        self.backgroundColor = [[ThemeHandler getCellPrimaryColor:self.singleTheme] colorWithAlphaComponent:.9];
        self.userInteractionEnabled = YES;
        
        NSInteger epcvBuffer = 4;
        NSInteger epcvDim = 56;
        cancelView = [[EditProfileCancelView alloc] initWithFrame:(CGRect){SCREEN_WIDTH - epcvBuffer - epcvDim, epcvBuffer, {epcvDim, epcvDim}} parent:self];
        [self addSubview:cancelView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFields)];
        [self addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dismissFields {
    [nameField resignFirstResponder];
    [locationField resignFirstResponder];
    [shadowNameField resignFirstResponder];
    [shadowLocationField resignFirstResponder];
    [birthdayField resignFirstResponder];
    [birthdayPicker resignFirstResponder];
}

#pragma View Helpers

- (void)addName:(UILabel *)nameLabel relativeFrame:(CGRect)frame {
    nameField = [self textViewFromLabel:nameLabel];
    [nameField setTag:NAME_TAG];
    [nameField setFrame:frame];
    nameField.inputAccessoryView = shadowNameField = [self makeComposeBarView];
    [shadowNameField setTag:NAME_TAG];
    shadowNameField.text = nameField.text;
    [self addSubview:nameField];
}

- (void)addLocation:(UIButton *)locationButton relativeFrame:(CGRect)frame {
    locationField = [self textViewFromLabel:locationButton.titleLabel];
    [locationField setTag:LOCATION_TAG];
    [locationField setFrame:frame];
    locationField.inputAccessoryView = shadowLocationField = [self makeComposeBarView];
    [shadowLocationField setTag:LOCATION_TAG];
    shadowLocationField.text = locationField.text;
    [self addSubview:locationField];
}

- (void)addBirthday {
    CGRect frame = locationField.frame;
    frame.origin.y += Y2(locationField) - Y2(nameField);
    birthdayField = [[UITextField alloc] initWithFrame:frame];
    birthdayField.font = locationField.font;
    birthdayField.textColor = locationField.textColor;
    birthdayField.textAlignment = locationField.textAlignment;
    [birthdayField addDoneOnKeyboardWithTarget:self action:@selector(birthdayPickerDone)];
    birthdayField.tintColor = UNWINE_RED;
    
    birthdayPicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [birthdayPicker setDatePickerMode:UIDatePickerModeDate];
    [birthdayPicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    birthdayField.inputView = birthdayPicker;
    birthdayPicker.maximumDate = [self getMaximumDate];
    
    User *user = [User currentUser];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    birthdayField.text = user.birthday ? [dateFormatter stringFromDate:user.birthday] : @"Tap here to add your birthday!";
    if(user.birthday)
        birthdayPicker.date = user.birthday;

    [self addSubview:birthdayField];
}

- (UITextField *)textViewFromLabel:(UILabel *)label {
    UITextField *field = [[UITextField alloc] init];
    field.delegate = self;
    field.font = label.font;
    field.textAlignment = label.textAlignment;
    field.textColor = label.textColor;
    field.text = label.text;
    field.backgroundColor = [UIColor clearColor];
    field.userInteractionEnabled = YES;
    
    //UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEditting:)];
    //[field addGestureRecognizer:gesture];
    
    return field;
}

#pragma Input Accessory Methods

- (PHFComposeBarView *)makeComposeBarView {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, PHFComposeBarViewInitialHeight);
    PHFComposeBarView *composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    
    [composeBarView setMaxCharCount:60];
    [composeBarView setMaxLinesCount:2];
    [composeBarView setPlaceholder:@"Type something..."];
    [composeBarView setDelegate:self];
    composeBarView.buttonTitle = @"Done";
    composeBarView.buttonTintColor = UNWINE_RED;
    composeBarView.tintColor = UNWINE_RED;
    
    composeBarView.textView.returnKeyType = UIReturnKeyDone;
    
    return composeBarView;
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    if(composeBarView == shadowNameField) {
        [self updateName];
    } else if(composeBarView == shadowLocationField) {
        [self updateLocation];
    }
    
    [self dismissFields];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == nameField) {
        [self updateName];
    } else if(textField == locationField) {
        [self updateLocation];
    }
    
    return NO;
}

- (void)keyboardWillShow {
    if([nameField isFirstResponder]) {
        [shadowNameField becomeFirstResponder];
    } else if([locationField isFirstResponder]) {
        [shadowLocationField becomeFirstResponder];
        
        User *user = [User currentUser];
        shadowLocationField.text = ISVALID(user.location) ? user.location : @"";
    } /*else if([birthdayField isFirstResponder]) {
        [birthdayField resignFirstResponder];
    }*/
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker {
    birthdayField.text = [dateFormatter stringFromDate:datePicker.date];
}

- (void)birthdayPickerDone {
    User *user = [User currentUser];
    user.birthday = birthdayPicker.date;
    [user saveInBackground];
    
    [self dismissFields];
}

#pragma Action Methods

- (void)showEditting:(UIGestureRecognizer *)sender {
    LOGGER(@"editting!");
    if([sender view] == nameField || [[sender view] tag] == NAME_TAG)
        [nameField becomeFirstResponder];
    else if([sender view] == locationField || [[sender view] tag] == LOCATION_TAG)
        [locationField becomeFirstResponder];
}

- (void)updateName {
    NSString *name = [[NSString stringWithFormat:@"%@", shadowNameField.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([name isEqualToString:@""]) {
        [unWineAlertView showDisposableAlertView:@"Your name is required!" theme:unWineAlertThemeDefault];
    //} else if([textField.text containsString:@" "]) {
    //    [unWineAlertView showDisposableAlertView:@"First and Last name please!" theme:unWineAlertThemeDefault];
    } else {
        User *user = [User currentUser];
        user.canonicalName = name;
        [user saveInBackground];
        nameField.text = [name capitalizedString];
    }
}

- (void)updateLocation {
    NSString *location = [[NSString stringWithFormat:@"%@", shadowLocationField.text] capitalizedString];
    User *user = [User currentUser];
    user.location = location;
    [user saveInBackground];
    
    locationField.text = location;
}

- (void)hideEditProfileView {
    [self.parent hideEditProfileView];
}

- (void)updateTheme {
    
}

- (NSDate *)getMaximumDate {
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [gregorian components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:now];
    [comps setYear:[comps year] - 21];
    
    return [gregorian dateFromComponents:comps];
}

@end

@implementation EditProfileCancelView

- (instancetype)initWithFrame:(CGRect)frame parent:(EditProfileView *)parent {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.parent = parent;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.parent action:@selector(hideEditProfileView)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect bounds = CGRectMake((rect.size.width - 32) / 2, (rect.size.height - 32) - 8, 32, 32);
    [CameraStyleKitClass drawCameraDismissWithFrame:bounds];
}

@end
