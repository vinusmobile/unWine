//
//  StyleKitView.m
//  unWine
//
//  Created by Fabio Gomez on 6/14/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "FriendStyleKitView.h"
#import "FriendsStyleKit.h"

@implementation FriendStyleKitView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.style == 0) {
        [FriendsStyleKit drawFacebookWithFrame:CGRectMake(0, 0, self.width, self.height) resizing:FriendsStyleKitResizingBehaviorAspectFit];

    } else if (self.style == 1) {
        //[FriendsStyleKit drawContactsCanvas];
        [FriendsStyleKit drawContactsCanvasWithFrame:CGRectMake(0, 0, self.width, self.height) resizing:FriendsStyleKitResizingBehaviorAspectFit];

    } else {
        //[FriendsStyleKit drawEmailCanvas];
        [FriendsStyleKit drawEmailCanvasWithFrame:CGRectMake(0, 0, self.width, self.height) resizing:FriendsStyleKitResizingBehaviorAspectFit];
    }
}


@end
