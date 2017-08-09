//
//  Images.h
//  unWine
//
//  Created by Fabio Gomez on 9/11/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface Images : PFObject
+ (NSString *)parseClassName;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) PFFile    *image;

+ (BFTask *)getFBInviteImage;
@end
