//
//  FacebookInviteAddAllCell.h
//  unWine
//
//  Created by Fabio Gomez on 6/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FacebookInviteTVC;
@interface FacebookInviteAddAllCell : UITableViewCell
@property (strong, nonatomic) IBOutlet  UIButton *addAllButton;
@property (strong, nonatomic) IBOutlet UIButton *addIndividuallyButton;
@property (strong, nonatomic)           FacebookInviteTVC *delegate;
- (IBAction)addAllUsers:(id)sender;
- (IBAction)addIndividually:(id)sender;

@end
