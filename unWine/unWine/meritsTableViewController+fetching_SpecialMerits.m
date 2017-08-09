//
//  meritsTableViewController+fetching_SpecialMerits.m
//  unWine
//
//  Created by Fabio Gomez on 7/29/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritsTableViewController+fetching_SpecialMerits.h"

#import "UIImageView+AFNetworking.h"
#import "meritsTableViewController+fetching_LevelMerits.h"
#import "meritsTableViewController+fetching_OtherMerits.h"
#import "meritsTableViewController+fetching_ExclusiveMerits.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>

@implementation meritsTableViewController (fetching_SpecialMerits)

- (void)fetchSpecialMerits{
    printf("\n\n");
    NSLog(@"fetchSpecialMerits");
    PFQuery *specialMeritsQuery = [PFQuery queryWithClassName:@"Merits"];
    
    [specialMeritsQuery whereKey:@"type" equalTo:@"Special"];
    [specialMeritsQuery orderByAscending:@"Index"];
    
    [specialMeritsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu specialMerits.", (unsigned long)objects.count);
            
            if (objects.count == 0) {
                [self fetchOtherMerits];
                return;
            }
            
            [specialMeritObjects removeAllObjects];
            [specialMeritObjects addObjectsFromArray:objects];
            
            // Start fetching the images, then fetch the other wines.
            [self fetchSpecialMeritImages];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)fetchSpecialMeritImages{
    
    printf("\n\n");
    NSLog(@"Fetching Special Merit Images");
    
    [specialMeritImages removeAllObjects];
    
    // Go through each of the objects
    for (PFObject *specialMerit in specialMeritObjects) {
        
        PFFile *imageFile = specialMerit[@"image"];
        
        BOOL meritFoundOnEarnedMerits = NO;
        
        for (NSString *earnedMeritObjectId in self.userEarnedMeritObjects) {
            
            if ([earnedMeritObjectId isEqualToString:specialMerit.objectId] == TRUE) {
                NSLog(@"fetchSpecialMeritImages - Merit Found in userEarnedMeritObjects");
                [self setImageForSpecialMerit:specialMerit usingFile:imageFile];
                meritFoundOnEarnedMerits = YES;
                break;
                
            }
            
        }
        
        // Set the image to be default
        if (meritFoundOnEarnedMerits == NO) {
            NSLog(@"fetchSpecialMeritImages - Merit NOT Found in userEarnedMeritObjects");
            [self setImageForSpecialMerit:specialMerit usingFile:nil];
            specialImagesCounter++;
        }
        
        // Check If added all images already
        [self checkIfAllSpecialImagesAreSet];
        
        
    }
    
}

// This function assumes that there is an image if Merit is valid
// Else, it will set the image to the the default image

- (void)setImageForSpecialMerit:(PFObject *)merit usingFile:(PFFile *)imageFile{
    
    printf("\n\n");
    NSLog(@"setImageForSpecialMerit");
    PFImageView *imageView = [[PFImageView alloc] init];
    
    imageView.image = [UIImage imageNamed:@"default.png"];
    
    if (imageFile != nil) {
        imageView.file = imageFile;
        [imageView loadInBackground:^(UIImage *image, NSError* error){
            
            if (!error) {
                specialImagesCounter++;
                NSLog(@"setImageForSpecialMerit - Asynchronous");
                [self checkIfAllSpecialImagesAreSet];
            }
            
        }];
    }
    
    [specialMeritImages setObject: imageView forKey:[NSString stringWithFormat:@"%i", [[merit objectForKey:@"Index"] intValue]]];
    
}

- (void)checkIfAllSpecialImagesAreSet{
    printf("\n\n");
    NSLog(@"checkIfAllSpecialImagesAreSet");
    if (specialImagesCounter == specialMeritObjects.count) {
        
        // Figure out the number of specialMerit Cells
        
        if (specialMeritImages.count % 3 == 0) {
            gNumberOfSpecialMeritCells = (int)(specialMeritObjects.count / 3);
        }
        else{
            gNumberOfSpecialMeritCells = (int)(specialMeritObjects.count / 3) + 1;
        }
        
        NSLog(@"Done Fetching Special Merit Images");
        [self fetchOtherMerits];
        
    }
    
}


@end
