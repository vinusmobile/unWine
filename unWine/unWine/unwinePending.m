//
//  unwinePending.m
//  unWine
//
//  Created by Fabio Gomez on 5/21/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "unwinePending.h"
// Import this header to let Armor know that PFObject privately provides most
// of the methods for PFSubclassing.
#import <Parse/PFObject+Subclass.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface unwinePending ()<PFSubclassing>

@end

@implementation unwinePending

@dynamic imageSquare, imageLarge, name, region, vineyard, wineType, trending, verified, barrels, ratingObject, image;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"unwinePending";
}

- (PFImageView *)getLargeImageView {
    PFImageView *view = [[PFImageView alloc] initWithImage:WINE_PLACEHOLDER];
    view.file = self.image;
    [view loadInBackground];
    return view;
}

- (void)setWineImageForImageView:(PFImageView *)imageView {
    NSURL *imageURL;
    
    if (ISVALID(self.imageSquare)) {
        NSLog(@"%s - using imageSquare", FUNCTION_NAME);
        imageURL = [NSURL URLWithString:self.imageSquare];
        [imageView setImageWithURL: imageURL placeholderImage:WINE_PLACEHOLDER];
    } else if (self.image) {
        NSLog(@"%s - using image", FUNCTION_NAME);
        imageView.image = WINE_PLACEHOLDER;
        imageView.file = self.image;
        [imageView loadInBackground];
    } else if (ISVALID(self.imageLarge)) {
        NSLog(@"%s - using imageLarge", FUNCTION_NAME);
        imageURL = [NSURL URLWithString:self.imageLarge];
        [imageView setImageWithURL: imageURL placeholderImage:WINE_PLACEHOLDER];
    }
}



@end
