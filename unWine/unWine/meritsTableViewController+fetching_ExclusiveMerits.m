//
//  meritsTableViewController+fetching_ExclusiveMerits.m
//  unWine
//
//  Created by Fabio Gomez on 7/29/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritsTableViewController+fetching_ExclusiveMerits.h"

#import "UIImageView+AFNetworking.h"
#import "meritsTableViewController+fetching_LevelMerits.h"
#import "meritsTableViewController+fetching_SpecialMerits.h"
#import "meritsTableViewController+fetching_OtherMerits.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>

@implementation meritsTableViewController (fetching_ExclusiveMerits)

- (void)fetchExclusiveMerits{
    printf("\n\n\n");
    NSLog(@"fetchExclusiveMerits");
    PFQuery *exclusiveMeritsQuery = [PFQuery queryWithClassName:@"Merits"];
    [exclusiveMeritsQuery whereKey:@"type" equalTo:@"exclusive"];
    
    
    [exclusiveMeritsQuery orderByAscending:@"Index"];
    
    [exclusiveMeritsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu otherMerits.", (unsigned long)objects.count);
            
            if (objects.count == 0) {
                
                [exclusiveMeritObjects removeAllObjects];
                [exclusiveMeritImages  removeAllObjects];
                
                [self.tableView reloadData];
                return;
            }
            
            [exclusiveMeritObjects removeAllObjects];
            [exclusiveMeritObjects addObjectsFromArray:objects];
            
            // Start fetching the images, then fetch the other wines.
            [self fetchExclusiveMeritImages];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}


- (void)fetchExclusiveMeritImages{
    
    printf("\n\n");
    NSLog(@"Fetching Other Merit Images");
    
    [exclusiveMeritImages removeAllObjects];
    
    // Go through each of the objects
    for (PFObject *exclusiveMerit in exclusiveMeritObjects) {
        
        PFFile *imageFile = exclusiveMerit[@"image"];
        
        BOOL meritFoundOnEarnedMerits = NO;
        
        for (NSString *earnedMeritObjectId in self.userEarnedMeritObjects) {
            
            if ([earnedMeritObjectId isEqualToString:exclusiveMerit.objectId] == TRUE) {
                NSLog(@"fetchExclusiveMeritImages - Merit Found in userEarnedMeritObjects");
                [self setImageForExclusiveMerit:exclusiveMerit usingFile:imageFile];
                meritFoundOnEarnedMerits = YES;
                break;
                
            }
            
        }
        
        // Set the image to be default
        if (meritFoundOnEarnedMerits == NO) {
            NSLog(@"fetchExclusiveMeritImages - Merit NOT Found in userEarnedMeritObjects");
            [self setImageForExclusiveMerit:exclusiveMerit usingFile:nil];
            exclusiveImagesCounter++;
        }
        
        // Check If added all images already
        [self checkIfAllExclusiveImagesAreSet];
        
        
    }
    
}

// This function assumes that there is an image if Merit is valid
// Else, it will set the image to the the default image

- (void)setImageForExclusiveMerit:(PFObject *)merit usingFile:(PFFile *)imageFile{
    
    printf("\n\n");
    NSLog(@"setImageForExclusiveMerit");
    PFImageView *imageView = [[PFImageView alloc] init];
    
    imageView.image = [UIImage imageNamed:@"default.png"];
    
    if (imageFile != nil) {
        imageView.file = imageFile;
        [imageView loadInBackground:^(UIImage *image, NSError* error){
            
            if (!error) {
                exclusiveImagesCounter++;
                NSLog(@"setImageForExclusiveMerit - Asynchronous");
                [self checkIfAllExclusiveImagesAreSet];
            }
            
        }];
        
    }
    
    [exclusiveMeritImages setObject: imageView forKey:[NSString stringWithFormat:@"%i", [[merit objectForKey:@"Index"] intValue]]];
    
}

- (void)checkIfAllExclusiveImagesAreSet{
    printf("\n\n");
    NSLog(@"checkIfAllExclusiveImagesAreSet");
    if (exclusiveImagesCounter == exclusiveMeritObjects.count) {
        
        // Figure out the number of exclusiveMerit Cells
        
        if (exclusiveMeritImages.count % 3 == 0) {
            gNumberOfExclusiveMeritCells = (int)(exclusiveMeritObjects.count / 3);
        }
        else{
            gNumberOfExclusiveMeritCells = (int)(exclusiveMeritObjects.count / 3) + 1;
        }
        
        NSLog(@"checkIfAllExclusiveImagesAreSet - Done Fetching\n\n\n");
        // If we downloaded all the images, then reload all the data
        [self.tableView reloadData];
        
    }
    
}


@end
