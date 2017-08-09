//
//  FacebookInviteTVC.h
//  unWine
//
//  Created by Fabio Gomez on 6/12/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendInviteTVC;
@interface FacebookInviteTVC : UITableViewController
@property (nonatomic, strong) FriendInviteTVC *delegate;
- (void)addAll;
- (void)addIndividually;
@end
