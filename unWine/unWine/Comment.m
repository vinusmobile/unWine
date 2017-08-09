//
//  Comment.m
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "Comment.h"
#import "ParseSubclasses.h"

@interface Comment() <MessageDelegate>

@end

@implementation Comment
@dynamic Author, Comment, NewsFeed, newsfeedPointer, caption, hidden;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Comment";
}

- (User *)getAssociatedUser {
    return self.Author;
}

- (NSString *)getMessage {
    return self.Comment;
}

- (BOOL)hasAttributedString {
    NSAttributedString *att = [self getAttributedString];
    return att != nil && ISVALID([att string]) && [att string].length > 0;
}

- (NSAttributedString *)getAttributedString {
    return [NewsFeed getFormattedCaption:self.caption color:[UIColor blackColor]];
}

- (NSString *)getSenderName {
    return [self.Author getName];
}

@end
