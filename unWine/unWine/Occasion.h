//
//  Occasion.h
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface Occasion : PFObject

@property (nonatomic, strong) NSString       *name;
@property (nonatomic, strong) PFFile         *image;
@property (nonatomic, strong) User           *user;

+ (NSString *)parseClassName;

@end
