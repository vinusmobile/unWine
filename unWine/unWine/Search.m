//
//  Search.m
//  unWine
//
//  Created by Fabio Gomez on 12/23/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Search.h"
#import <Parse/PFObject+Subclass.h>
#import "User.h"

@interface Search ()<PFSubclassing>

@end

@implementation Search

@dynamic author, searchString;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Search";
}

+ (void)createSearchHistoryWithString:(NSString *)string {
    
    if (!ISVALID(string)) {
        return;
    }
    
    Search *searchObject = [Search object];
    
    searchObject.searchString = string.lowercaseString;
    searchObject.author = [User currentUser];
    
    [searchObject saveInBackground];
}
@end
