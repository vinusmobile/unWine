//
//  Comment.h
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@class User, NewsFeed;
@interface Comment : PFObject <PFSubclassing>

@property (nonatomic, strong) User     *Author;
@property (nonatomic, strong) NewsFeed *newsfeedPointer;
@property (nonatomic, strong) NSString *Comment;
@property (nonatomic, strong) NSString *NewsFeed;
@property (nonatomic, strong) NSMutableArray *caption;
@property (nonatomic) BOOL hidden;

+ (NSString *)parseClassName;

@end
