//
//  meritsTableViewController+fetching_OtherMerits.m
//  unWine
//
//  Created by Fabio Gomez on 7/29/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritsTableViewController+fetching_OtherMerits.h"

#import "UIImageView+AFNetworking.h"
#import "meritsTableViewController+fetching_LevelMerits.h"
#import "meritsTableViewController+fetching_SpecialMerits.h"
#import "meritsTableViewController+fetching_ExclusiveMerits.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>

@implementation meritsTableViewController (fetching_OtherMerits)

- (void)fetchOtherMerits{
    printf("\n\n\n");
    NSLog(@"fetchOtherMerits");
    PFQuery *otherMeritsQuery = [PFQuery queryWithClassName:@"Merits"];
    
    [otherMeritsQuery whereKey:@"type" equalTo:@"wine"];
    [otherMeritsQuery orderByAscending:@"Index"];
    
    [otherMeritsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu otherMerits.", (unsigned long)objects.count);
            
            if (objects.count == 0) {
                [self fetchExclusiveMerits];
                return;
            }
            
            [otherMeritObjects removeAllObjects];
            [otherMeritObjects addObjectsFromArray:objects];
            
            // Start fetching the images, then fetch the other wines.
            [self fetchOtherMeritImages];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}


- (void)fetchOtherMeritImages{
    
    printf("\n\n");
    NSLog(@"Fetching Other Merit Images");
    
    [otherMeritImages removeAllObjects];
    
    // Go through each of the objects
    for (PFObject *otherMerit in otherMeritObjects) {
        
        PFFile *imageFile = otherMerit[@"image"];
        
        BOOL meritFoundOnEarnedMerits = NO;
        
        for (NSString *earnedMeritObjectId in self.userEarnedMeritObjects) {
            
            if ([earnedMeritObjectId isEqualToString:otherMerit.objectId] == TRUE) {
                NSLog(@"fetchOtherMeritImages - Merit Found in userEarnedMeritObjects");
                [self setImageForOtherMerit:otherMerit usingFile:imageFile];
                meritFoundOnEarnedMerits = YES;
                break;
                
            }
            
        }
        
        // Set the image to be default
        if (meritFoundOnEarnedMerits == NO) {
            NSLog(@"fetchOtherMeritImages - Merit NOT Found in userEarnedMeritObjects");
            [self setImageForOtherMerit:otherMerit usingFile:nil];
            otherImagesCounter++;
        }
        
        // Check If added all images already
        [self checkIfAllOtherImagesAreSet];
        
        
    }
    
}

// This function assumes that there is an image if Merit is valid
// Else, it will set the image to the the default image

- (void)setImageForOtherMerit:(PFObject *)merit usingFile:(PFFile *)imageFile{
    
    printf("\n\n");
    NSLog(@"setImageForOtherMerit");
    PFImageView *imageView = [[PFImageView alloc] init];
    
    imageView.image = [UIImage imageNamed:@"default.png"];
    
    if (imageFile != nil) {
        imageView.file = imageFile;
        [imageView loadInBackground:^(UIImage *image, NSError* error){
            
            if (!error) {
                otherImagesCounter++;
                NSLog(@"setImageForOtherMerit - Asynchronous");
                [self checkIfAllOtherImagesAreSet];
            }
            
        }];
        
    }
    
    [otherMeritImages setObject: imageView forKey:[NSString stringWithFormat:@"%i", [[merit objectForKey:@"Index"] intValue]]];
    
}

- (void)checkIfAllOtherImagesAreSet{
    printf("\n\n");
    NSLog(@"checkIfAllOtherImagesAreSet");
    if (otherImagesCounter == otherMeritObjects.count) {
        
        // Figure out the number of specialMerit Cells
        
        if (otherMeritImages.count % 3 == 0) {
            gNumberOfOtherMeritCells = (int)(otherMeritObjects.count / 3);
        }
        else{
            gNumberOfOtherMeritCells = (int)(otherMeritObjects.count / 3) + 1;
        }
        
        NSLog(@"Done Fetching Other Merit Images");
        // If we downloaded all the images, then reload all the data
        [self fetchExclusiveMerits];
        
    }
    
}


@end
