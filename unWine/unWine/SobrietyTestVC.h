//
//  ViewController.h
//  Sobriety
//
//  Created by Bryce Boesen on 8/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>
#import "customTabBarController.h"
#import "unWineAppDelegate.h"

@interface SobrietyTestVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *lview;
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UITextView *textBox;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet UILabel *failure;
@property (weak, nonatomic) IBOutlet UILabel *highscore;
@property (weak, nonatomic) IBOutlet UITextField *answer;

@property (nonatomic) NSString *fTitle;
@property (nonatomic) NSInteger count, currentHighscore;
@property (nonatomic) BOOL purchased;

@end
