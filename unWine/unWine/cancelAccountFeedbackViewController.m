//
//  cancelAccountFeedbackViewController.m
//  unWine
//
//  Created by Fabio Gomez on 7/7/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "cancelAccountFeedbackViewController.h"
#import <Parse/Parse.h>

@interface cancelAccountFeedbackViewController ()

@end

@implementation cancelAccountFeedbackViewController

@synthesize feedBackTextView;

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
    
    feedBackTextView.placeholder = @"Tell us how we can improve";
    [feedBackTextView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Delete My Account";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"Back";
}

- (IBAction)sendFeedBackAndGoToFinalStep:(id)sender {
    
    // Call Cloud Function to send Email, then segue back
    
    if (ISVALID(feedBackTextView.text)) {
        [[User currentUser] sendFeedbackEmail:feedBackTextView.text];
    }
    
    [feedBackTextView resignFirstResponder];
    
    [self performSegueWithIdentifier:@"toFinalStep" sender:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
