//
//  LabelCell.h
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BIRTHDAY_DEFAULT_VAL        @"Birthday"
#define GENDER_DEFAULT_VAL          @"Gender"
#define NOT_BDAY_DEFAULT(self)      ISVALID(self.label.text) && ![self.label.text isEqualToString:BIRTHDAY_DEFAULT_VAL]
#define NOT_GENDER_DEFAULT(self)    ISVALID(self.label.text) && ![self.label.text isEqualToString:GENDER_DEFAULT_VAL]

@class RegistrationTVC;

@interface LabelCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconView;
@property (strong, nonatomic) IBOutlet UILabel  *label;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic)          NSDate   *date;

- (void)setUpBirthdayWithParent:(RegistrationTVC *)parentTVC;
- (void)setUpGenderWithParent:(RegistrationTVC *)parentTVC;

- (void)showPicker;

@end
