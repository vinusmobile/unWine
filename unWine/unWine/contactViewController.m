//
//  contactViewController.m
//  unWine
//
//  Created by Fabio Gomez on 6/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "contactViewController.h"
#import <Parse/Parse.h>
#define CONTACT_ALERT_VIEW_TAG 4473920
#define TEXTVIEW_DEFAULT_TEXT @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."

#define PLACEHOLDER @"How can we help you?"
#define PLACEHOLDER_FEEDBACK @"What is thy bidding Master"

@interface contactViewController ()


@end

@implementation contactViewController

@synthesize feedbackMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.feedbackMode) {
        self.feedbackTextView.text = PLACEHOLDER_FEEDBACK;
    } else {
        self.feedbackTextView.text = PLACEHOLDER;
    }
    
    self.feedbackTextView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendFeedback:(id)sender {
    
    // Check if user entered any data
    if ([self.feedbackTextView.text isEqualToString:PLACEHOLDER] == YES || [self.feedbackTextView.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"You forgot to write your feedback"
                              message:nil
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        [self sendFeedbackEmail];
    }
    
}

- (void)sendFeedbackEmail{
    
    // Call Cloud Function to send Email, then segue back
    
    NSMutableDictionary *feedbackDictionary = [[NSMutableDictionary alloc] init];
    
    [feedbackDictionary setObject:self.feedbackTextView.text forKey:@"feedback"];
    [feedbackDictionary setObject:GET_UNWINE_VERSION forKey:@"appversion"];
    
    
    [PFCloud callFunctionInBackground:@"sendUserFeedback" withParameters:feedbackDictionary block:^(id result, NSError *error){
        
        if (!error) {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Thank You"
                                  message:nil
                                  delegate: self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            alert.tag = CONTACT_ALERT_VIEW_TAG;
            [alert show];
            
        }else{
            NSLog(@"Error: %@", error);
            
        }
        
    }];
    
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == CONTACT_ALERT_VIEW_TAG)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}


#pragma mark - UITextViewDelegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
}


@end
