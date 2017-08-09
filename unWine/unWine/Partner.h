//
//  Partner.h
//  unWine
//
//  Created by Fabio Gomez on 4/28/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface Partner : PFObject

+ (NSString *)parseClassName;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *address;
@property (nonatomic, strong) NSString  *website;
@property (nonatomic, strong) PFFile    *descriptionFile;
@property (nonatomic, strong) PFFile    *logo;
@property (nonatomic, assign) BOOL       active;
@property (nonatomic, strong) NSString  *deeplink;

- (void)loadDescriptionWithWebView:(UIWebView *)webView;
@end