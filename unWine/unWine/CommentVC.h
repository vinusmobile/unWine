//
//  CommentVC.h
//  unWine
//
//  Created by Bryce Boesen on 1/12/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessengerVC.h"
#import "CommentTVC.h"

@interface CommentVC : MessengerVC

@property (nonatomic, strong) CommentTVC *commenter;
@property (nonatomic, retain) NewsFeed *newsfeed;

- (instancetype)initWithNewsFeed:(NewsFeed *)newsfeed;
- (void)activeReload;
- (void)presentComposeBarView;

@end
