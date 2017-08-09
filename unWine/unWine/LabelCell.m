//
//  LabelCell.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "LabelCell.h"
#import "RegistrationTVC.h"
#import "ActionSheetPicker.h"

#define BIRTHDAY    0
#define GENDER      1

@interface LabelCell ()
@property (nonatomic, strong) RegistrationTVC *parent;
@end

@implementation LabelCell
@synthesize parent, iconView, label, date, mainView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = UNWINE_FONT_TEXT_XSMALL;
    
    self.mainView.layer.cornerRadius = 10;
    self.mainView.layer.masksToBounds = YES;
    self.mainView.backgroundColor = CELL_BACKGROUND_COLOR;
    self.mainView.layer.borderColor = CELL_TEXT_BACKGROUND_COLOR.CGColor;
    self.mainView.layer.borderWidth = 1;
    
    self.iconView.contentMode = UIViewContentModeCenter;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    [super setSelected:NO animated:YES];
}



- (void)setUpBirthdayWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    self.tag = BIRTHDAY;
    
    if (self.parent.form[FORM_BIRTHDAY]) {
        NSDateFormatter *formatter;
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        
        self.label.text = [formatter stringFromDate: self.parent.form[FORM_BIRTHDAY]];
    } else {
        self.label.text = BIRTHDAY_DEFAULT_VAL;
    }
    
    self.iconView.image = [UIImage imageNamed:@"b_icon"];
}


- (void)setUpGenderWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    self.tag = GENDER;
    
    self.label.text = self.parent.form[FORM_GENDER] ? self.parent.form[FORM_GENDER] : GENDER_DEFAULT_VAL;
    
    self.iconView.image = [UIImage imageNamed:@"g_icon"];
}



- (void)showPicker {
    [self.parent.activeTextField resignFirstResponder];
    if (self.tag == BIRTHDAY) {
        [self showBirthdayPicker];
    } else if (self.tag == GENDER) {
        [self showGenderPicker];
    }
}

- (void)showBirthdayPicker {
    ActionSheetStringPicker *picker = [ActionSheetDatePicker showPickerWithTitle:@"What's your birthday?"
                                                                  datePickerMode:UIDatePickerModeDate
                                                                    selectedDate:[NSDate date]
                                                                     minimumDate:nil
                                                                     maximumDate:nil
                                                                       doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                                                           self.parent.form[FORM_BIRTHDAY] = selectedDate;
                                                                           [self setUpBirthdayWithParent:self.parent];
                                                                       }
                                                                     cancelBlock:nil
                                                                          origin:self];
    picker.toolbar.translucent = YES;
    picker.toolbar.tintColor = UNWINE_RED;
}

- (void)showGenderPicker {
    NSArray *genders = [NSArray arrayWithObjects:@"Male", @"Female", @"Don't want to share", nil];
    
    ActionSheetStringPicker *picker = [ActionSheetStringPicker showPickerWithTitle:@"What's your gender?"
                                                                              rows:genders
                                                                  initialSelection:0
                                                                         doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                                                             self.parent.form[FORM_GENDER] = selectedValue;
                                                                             [self setUpGenderWithParent:self.parent];
                                                                         }
                                                                       cancelBlock:nil
                                                                            origin:self];
    picker.toolbar.translucent = YES;
    picker.toolbar.tintColor = UNWINE_RED;
}


@end
