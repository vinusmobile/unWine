//
//  Search.h
//  unWine
//
//  Created by Fabio Gomez on 12/23/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class User;

@interface Search : PFObject

@property (nonatomic, strong) User     *author;
@property (nonatomic, strong) NSString *searchString;

+ (NSString *)parseClassName;
+ (void)createSearchHistoryWithString:(NSString *)string;

@end
