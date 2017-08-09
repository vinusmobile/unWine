//
//  contactViewController.h
//  unWine
//
//  Created by Fabio Gomez on 6/11/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface contactViewController : UIViewController <UITextViewDelegate, unWineAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *feedbackTextView;
@property BOOL feedbackMode;
@end
