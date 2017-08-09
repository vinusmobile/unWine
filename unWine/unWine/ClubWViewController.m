//
//  ClubWViewController.m
//  unWine
//
//  Created by Fabio Gomez on 2/17/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "ClubWViewController.h"
#import "TTTAttributedLabel.h"
#import "UILabel+UILabelDynamicHeight.h"

@interface ClubWViewController () <TTTAttributedLabelDelegate>
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *aboutLabel;

@end

@implementation ClubWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLabel{
    NSString *text = @"\nWe are proud to introduce our friend Club W!  What's better than drinking wine?  Drinking wine that's brought right to your door of course!  Like a magic wine fairy, Club W does just that.  They deliver wine right to your door which allows you more time to unWine!\n\nGo to www.clubW.com/unWine to get a bottle of wine on the house!  Or simply go to www.clubW.com and use the promo code \"unWine\".  Please do not forget to check in your Club W wine on our app to earn your Club W merit.";
    
    self.aboutLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.aboutLabel.font = [UIFont systemFontOfSize:18];
    self.aboutLabel.textColor = [UIColor blackColor];
    self.aboutLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.aboutLabel.numberOfLines = 0;
    self.aboutLabel.textAlignment = NSTextAlignmentJustified;
    [self.aboutLabel sizeToFit];
    //self.aboutLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    self.aboutLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
    self.aboutLabel.minimumLineHeight = [UIFont systemFontOfSize:14].lineHeight;
    self.aboutLabel.maximumLineHeight = [UIFont systemFontOfSize:14].lineHeight;
    self.aboutLabel.lineSpacing = 4;
    
    
    
    [self.aboutLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    
        NSRange clubWRange = [mutableAttributedString.string rangeOfString:@"Club W!"];
        NSRange unWineRange = [mutableAttributedString.string rangeOfString:@"\"unWine\""];
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:20];
        CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (boldFont) {
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:clubWRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:clubWRange];
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:unWineRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:unWineRange];
            
            CFRelease(boldFont);
        }
        
        return mutableAttributedString;
    }];
    
 
    NSRange range = [self.aboutLabel.text rangeOfString:@"www.clubW.com/unWine"];
    [self.aboutLabel addLinkToURL:[NSURL URLWithString:@"http://www.clubW.com/unWine"] withRange:range]; // Embedding a custom link in a substring
    
    range = [self.aboutLabel.text rangeOfString:@"www.clubW.com"];
    [self.aboutLabel addLinkToURL:[NSURL URLWithString:@"http://www.clubW.com"] withRange:range];
    self.aboutLabel.delegate = self;
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    NSLog(@"url = %@", url);
    
    [[UIApplication sharedApplication] openURL:url];
}

@end
