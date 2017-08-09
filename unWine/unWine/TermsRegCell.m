//
//  TermsRegself.m
//  unWine
//
//  Created by Fabio Gomez on 8/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "TermsRegCell.h"
#import "RegistrationTVC.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#define TO_TERMS_SEGUE @"profileToTerms"
#define TO_PRIVACY_SEGUE @"profileToPrivacy"

@interface TermsRegCell () <TTTAttributedLabelDelegate>
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (nonatomic, strong) RegistrationTVC *parent;
@end

@implementation TermsRegCell
@synthesize parent, messageLabel;


- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithParent:(RegistrationTVC *)parentTVC {
    self.parent = parentTVC;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.messageLabel.delegate = self;
    self.messageLabel.font = UNWINE_FONT_TEXT_XSMALL;
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.messageLabel.numberOfLines = 0;
    
    self.messageLabel.shadowOffset = CGSizeMake(0, 0);
    self.messageLabel.shadowRadius = 0.15;
    self.messageLabel.shadowColor = [UIColor blackColor];
    
    self.messageLabel.linkAttributes = @{ (id)kCTForegroundColorAttributeName : UNWINE_RED};
    self.messageLabel.textColor = [UIColor whiteColor];
    
    
    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    NSString *text = @"By tapping Done, you are indicating that you have read the Privacy Policy and agree to the Terms of Service";
    
    self.messageLabel.text = text;
    
    NSRange range = [self.messageLabel.text rangeOfString:@"Privacy Policy"];
    [self.messageLabel addLinkToURL:[NSURL URLWithString:TO_PRIVACY_SEGUE] withRange:range];
    
    range = [self.messageLabel.text rangeOfString:@"Terms of Service"];
    [self.messageLabel addLinkToURL:[NSURL URLWithString:TO_TERMS_SEGUE] withRange:range];
 
    
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"%s - %@", FUNCTION_NAME, url.absoluteString);
    NSString *urlString = url.absoluteString;
    
    if ([urlString isEqualToString:TO_PRIVACY_SEGUE]) {
        [self.parent performSegueWithIdentifier:TO_PRIVACY_SEGUE sender:self];
    } else if ([urlString isEqualToString:TO_TERMS_SEGUE]) {
        [self.parent performSegueWithIdentifier:TO_TERMS_SEGUE sender:self];
    }
}

@end
