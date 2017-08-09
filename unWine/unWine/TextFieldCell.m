//
//  TextFieldCell.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "TextFieldCell.h"
#import "RegistrationTVC.h"
#import "ParseSubclasses.h"
#import "Color_Helper.h"
#define TEXT_FIELD_USER_NAME    0
#define TEXT_FIELD_PASSWORD     1
#define TEXT_FIELD_PASSWORD2    2
#define TEXT_FIELD_EMAIL        3
#define TEXT_FIELD_EMAIL2       4
#define TEXT_FIELD_PHONE        5
#define TEXT_FIELD_LOCATION     6

@interface TextFieldCell () <UITextFieldDelegate>
@property (nonatomic, strong) RegistrationTVC *parent;
@property (nonatomic, strong) User *user;
@end

@implementation TextFieldCell

@synthesize parent, iconView, textField, mainView;


- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textField.delegate = self;
    //self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.backgroundColor = CELL_TEXT_BACKGROUND_COLOR;//[UIColor colorWithHexString:@"#9B9B9B"];//[UIColor clearColor];
    self.textField.textColor = [UIColor whiteColor];
    self.textField.tintColor = [UIColor whiteColor];
    self.textField.layer.borderColor = CELL_TEXT_BACKGROUND_COLOR.CGColor;
    self.textField.layer.borderWidth = 0.5;
    self.textField.font = UNWINE_FONT_TEXT_XSMALL;
    self.textField.layer.cornerRadius = 10;
    self.textField.layer.masksToBounds = YES;
    
    self.mainView.layer.cornerRadius = 10;
    self.mainView.layer.masksToBounds = YES;
    self.mainView.backgroundColor = CELL_BACKGROUND_COLOR;
    self.mainView.layer.borderColor = CELL_TEXT_BACKGROUND_COLOR.CGColor;
    self.mainView.layer.borderWidth = 1;
    
        self.iconView.contentMode = UIViewContentModeCenter;
    
    self.user = [User currentUser];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlaceHolderTextWithString:(NSString *)string {
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:string attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)setUpUsernameWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"username"];
    self.textField.tag = TEXT_FIELD_USER_NAME;
    self.textField.text = ISVALID(self.parent.form[FORM_USERNAME]) ? self.parent.form[FORM_USERNAME] : @"";
    
    self.iconView.image = [UIImage imageNamed:@"u_icon"];
}

- (void)setUpPasswordWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"password"];
    self.textField.secureTextEntry = YES;
    self.textField.tag = TEXT_FIELD_PASSWORD;
    self.textField.text = ISVALID(self.parent.form[FORM_PASSWORD]) ? self.parent.form[FORM_PASSWORD] : @"";
    
    self.iconView.image = [UIImage imageNamed:@"pwd_icon"];
}

- (void)setUpPassword2WithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"re-enter password"];
    self.textField.secureTextEntry = YES;
    self.textField.tag = TEXT_FIELD_PASSWORD2;
    self.textField.text = ISVALID(self.parent.form[FORM_PASSWORD2]) ? self.parent.form[FORM_PASSWORD2] : @"";
    
    self.iconView.image = [UIImage imageNamed:@"pwd_icon"];
}

- (void)setUpEmailWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"email"];
    self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField.tag = TEXT_FIELD_EMAIL;
    self.textField.text = ISVALID(self.parent.form[FORM_EMAIL]) ? self.parent.form[FORM_EMAIL] : @"";
    
    self.iconView.image = [UIImage imageNamed:@"e_icon"];
}

- (void)setUpEmail2WithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"re-enter email"];
    self.textField.keyboardType = UIKeyboardTypeEmailAddress;
    self.textField.tag = TEXT_FIELD_EMAIL2;
    self.textField.text = ISVALID(self.parent.form[FORM_EMAIL2]) ? self.parent.form[FORM_EMAIL2] : @"";
    
    self.iconView.image = [UIImage imageNamed:@"e_icon"];
}

- (void)setUpPhoneWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"(555) 555-5555"];
    self.textField.keyboardType = UIKeyboardTypePhonePad;
    self.textField.tag = TEXT_FIELD_PHONE;
    self.textField.text = ISVALID(self.parent.form[FORM_PHONE]) ? self.parent.form[FORM_PHONE] : @"";
    
    self.iconView.image = [UIImage imageNamed:@"p_icon"];
}

- (void)setUpLocationWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    
    [self setPlaceHolderTextWithString:@"City, State, Country"];
    self.textField.tag = TEXT_FIELD_LOCATION;
    self.textField.text = [self.user getLocation];
    self.textField.text = ISVALID(self.parent.form[FORM_LOCATION]) ? self.parent.form[FORM_LOCATION] : @"";
    self.iconView.image = [UIImage imageNamed:@"l_icon"];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)theTextField{
    
    self.parent.activeTextField = theTextField;
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField{
    [theTextField resignFirstResponder];
    self.parent.activeTextField = nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    /*printf("\n");
    NSLog(@"shouldChangeCharactersInRange");
    NSLog(@"location = %lu, length = %lu", (unsigned long)range.location, (unsigned long)range.length);
    NSLog(@"replacementString = \"%@\"", string);
    NSLog(@"range.location = %lu, range.length= %lu", (unsigned long)range.location, (unsigned long)range.length);*/
    
    NSMutableString *str = [NSMutableString stringWithString:theTextField.text];
    
    if ([string isEqualToString:@""]) {
        if (theTextField.tag == TEXT_FIELD_PASSWORD || theTextField.tag == TEXT_FIELD_PASSWORD2) {
            [str setString:@""];
        } else {
            [str deleteCharactersInRange:NSMakeRange(range.location, range.length)];
        }
    } else if ([string isEqualToString:@"\n"] == NO) {
        [str insertString:string atIndex:range.location];
    }
    
    //NSLog(@"theText = \"%@\"", str);
    
    switch (theTextField.tag) {
        case TEXT_FIELD_USER_NAME:
            self.parent.form[FORM_USERNAME] = str;
            break;
        case TEXT_FIELD_PASSWORD:
            self.parent.form[FORM_PASSWORD] = str;
            break;
        case TEXT_FIELD_PASSWORD2:
            self.parent.form[FORM_PASSWORD2] = str;
            break;
        case TEXT_FIELD_EMAIL:
            self.parent.form[FORM_EMAIL] = str;
            break;
        case TEXT_FIELD_EMAIL2:
            self.parent.form[FORM_EMAIL2] = str;
            break;
        case TEXT_FIELD_PHONE:
            self.parent.form[FORM_PHONE] = str;
            break;
        case TEXT_FIELD_LOCATION:
            self.parent.form[FORM_LOCATION] = str;
            break;
            
        default:
            break;
    }
    
    
    
    if ([string isEqualToString:@"\n"]) {
        
        [theTextField resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    
    // Email
    //if ([theTextField isEqual:gEmailCellTextFieldReference] == YES) {
    if (theTextField.tag == TEXT_FIELD_EMAIL || theTextField.tag == TEXT_FIELD_EMAIL2) {
        
        //NSLog(@"Email Text Field");
        NSCharacterSet *unacceptedInput = nil;
        
        if ([[theTextField.text componentsSeparatedByString:@"@"] count] > 1) {
            
            unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:[ALPHA_NUMERIC stringByAppendingString:@".-"]] invertedSet];
            
        } else {
            
            unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:[ALPHA_NUMERIC stringByAppendingString:@".!#$%&'*+-/=?^_`{|}~@"]] invertedSet];
            
        }
        
        return ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] <= 1);
        
    }
    
    
    // Phone Number
    else if (theTextField.tag == TEXT_FIELD_PHONE == YES) {
        
        //NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:PHONE_CHARACTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        // Return if non numeric
        if ([string isEqualToString:filtered] == NO) {
            return NO;
        }
        
        
        //return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
        
        
        //NSLog(@"Phone Text Field");
        
        int length = [self getLength:theTextField.text];
        //NSLog(@"Length  =  %d ",length);
        
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:theTextField.text];
            theTextField.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                theTextField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
            self.parent.form[FORM_PHONE] = theTextField.text;
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:theTextField.text];
            theTextField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                theTextField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
            
            self.parent.form[FORM_PHONE] = theTextField.text;
        }
    }
    
    // Guess should never get here
    return YES;
}


- (NSString*)formatNumber:(NSString*)mobileNumber {
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    //NSLog(@"%@", mobileNumber);
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        //NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


- (int)getLength:(NSString*)mobileNumber {
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
    
}



@end








