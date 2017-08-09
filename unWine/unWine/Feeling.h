//
//  Feeling.h
//  unWine
//
//  Created by Fabio Gomez on 10/21/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface Feeling : PFObject

@property (nonatomic, strong) NSString       *name;
@property (nonatomic, strong) PFFile         *image;

+ (NSString *)parseClassName;

@end
