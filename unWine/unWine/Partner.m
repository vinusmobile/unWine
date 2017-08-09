//
//  Partner.m
//  unWine
//
//  Created by Fabio Gomez on 4/28/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Partner.h"
// Import this header to let Armor know that PFObject privately provides most
// of the methods for PFSubclassing.
#import <Parse/PFObject+Subclass.h>
#import <Parse/Parse.h>

@interface Partner () <PFSubclassing>

@end

@implementation Partner

@dynamic name, address, website, descriptionFile, logo, active, deeplink;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Partner";
}

// Loads an HTML page that describes the Partner
- (void)loadDescriptionWithWebView:(UIWebView *)webView {
    NSString *urlAddress = self.descriptionFile.url;
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
}

- (NSURL *)getDeeplinkURL {
    return self.deeplink ? [NSURL URLWithString:self.deeplink] : nil;
}

@end