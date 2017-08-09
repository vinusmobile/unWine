//
//  ParseSubclasses.h
//  unWine
//
//  Created by Fabio Gomez on 4/28/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#ifndef unWine_ParseSubclasses_h
#define unWine_ParseSubclasses_h
#import "User.h"
#import "Friendship.h"
#import "Partner.h"
#import "unWine.h"
#import "unwinePending.h"
#import "Grapes.h"
#import "Merits.h"
#import "Level.h"
#import "NewsFeed.h"
#import "Notification.h"
#import "Images.h"
#import "Conversations.h"
#import "Messages.h"
#import "Venue.h"
#import "Feeling.h"
#import "Occasion.h"
#import "Comment.h"
#import "Push.h"
#import "Reaction.h"
#import "Search.h"
#import "Records.h"
#import "Winery.h"

#endif
@protocol MessageDelegate;
@protocol MessageDelegate <NSObject>

@required - (User *)getAssociatedUser;
@required - (NSString *)getSenderName;
@required - (NSString *)getMessage;
@optional - (BOOL)hasAttributedString;
@optional - (NSAttributedString *)getAttributedString;

@end

@protocol PFObjectCell;
@protocol PFObjectCell <NSObject>

@required + (NSInteger)getDefaultHeight;
@optional + (NSInteger)getExtendedHeight:(PFObject *)object;

@end

@protocol SearchableSubclass;
@protocol SearchableSubclass <NSObject>

@required - (NSString *)getSearchableName;
@required - (Class<PFObjectCell>)getAssociatedCell;
@required + (PFQuery *)find:(NSString *)searchString;
@required + (BFTask *)findTask:(NSString *)searchString;

@end
