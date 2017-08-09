//
//  MBProgressHUD+Emojis.m
//  unWine
//
//  Created by Fabio Gomez on 5/27/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "MBProgressHUD+Emojis.h"
#import <Parse/Parse.h>

@implementation MBProgressHUD (Emojis)

- (MBProgressHUD *)addLoadMessage {
    //self.label.text
    PFConfig *config = [PFConfig currentConfig];
    NSArray *messages = config[@"LOAD_MESSAGES"];
    NSString *loadMessage = [messages objectAtIndex:arc4random_uniform((int)messages.count)];
    
    LOGGER(loadMessage);
    self.label.text = loadMessage;

    return self;
}

@end
