//
//  meritsTableViewController+fetching_LevelMerits.m
//  unWine
//
//  Created by Fabio Gomez on 7/29/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritsTableViewController+fetching_LevelMerits.h"

#import "UIImageView+AFNetworking.h"
#import "meritsTableViewController+fetching_SpecialMerits.h"
#import "meritsTableViewController+fetching_OtherMerits.h"
#import "meritsTableViewController+fetching_ExclusiveMerits.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>

@implementation meritsTableViewController (fetching_LevelMerits)

- (void)fetchLevelMerits{
    printf("\n\n");
    NSLog(@"fetchLevelMerits");
    PFQuery *LevelMeritsQuery = [PFQuery queryWithClassName:@"Merits"];
    
    [LevelMeritsQuery whereKey:@"type" equalTo:@"level"];
    [LevelMeritsQuery orderByAscending:@"Index"];
    
    [LevelMeritsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu LevelMerits.", (unsigned long)objects.count);
            
            if (objects.count == 0) {
                [self fetchSpecialMerits];
                return;
            }
            
            [LevelMeritObjects removeAllObjects];
            [LevelMeritObjects addObjectsFromArray:objects];
            
            // Start fetching the images, then fetch the other wines.
            [self fetchLevelMeritImages];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)fetchLevelMeritImages{
    
    printf("\n\n");
    NSLog(@"Fetching Level Merit Images");
    
    [LevelMeritImages removeAllObjects];
    
    // Go through each of the objects
    for (PFObject *LevelMerit in LevelMeritObjects) {
        
        PFFile *imageFile = LevelMerit[@"image"];
        
        BOOL meritFoundOnEarnedMerits = NO;
        
        for (NSString *earnedMeritObjectId in self.userEarnedMeritObjects) {
            
            if ([earnedMeritObjectId isEqualToString:LevelMerit.objectId] == TRUE) {
                NSLog(@"fetchLevelMeritImages - Merit Found in userEarnedMeritObjects");
                [self setImageForLevelMerit:LevelMerit usingFile:imageFile];
                meritFoundOnEarnedMerits = YES;
                break;
                
            }
            
        }
        
        // Set the image to be default
        if (meritFoundOnEarnedMerits == NO) {
            NSLog(@"fetchLevelMeritImages - Merit NOT Found in userEarnedMeritObjects");
            [self setImageForLevelMerit:LevelMerit usingFile:nil];
            LevelImagesCounter++;
        }
        
        // Check If added all images already
        [self checkIfAllLevelImagesAreSet];
        
        
    }
    
}

// This function assumes that there is an image if Merit is valid
// Else, it will set the image to the the default image

- (void)setImageForLevelMerit:(PFObject *)merit usingFile:(PFFile *)imageFile{
    
    printf("\n\n");
    NSLog(@"setImageForLevelMerit");
    PFImageView *imageView = [[PFImageView alloc] init];
    
    imageView.image = [UIImage imageNamed:@"default.png"];
    
    if (imageFile != nil) {
        imageView.file = imageFile;
        [imageView loadInBackground:^(UIImage *image, NSError* error){
            
            if (!error) {
                LevelImagesCounter++;
                NSLog(@"setImageForLevelMerit - Asynchronous");
                [self checkIfAllLevelImagesAreSet];
            }
            
        }];
    }
    
    [LevelMeritImages setObject: imageView forKey:[NSString stringWithFormat:@"%i", [[merit objectForKey:@"Index"] intValue]]];
    
}

- (void)checkIfAllLevelImagesAreSet{
    printf("\n\n");
    NSLog(@"checkIfAllLevelImagesAreSet");
    if (LevelImagesCounter == LevelMeritObjects.count) {
        
        // Figure out the number of LevelMerit Cells
        
        if (LevelMeritImages.count % 3 == 0) {
            gNumberOfLevelMeritCells = (int)(LevelMeritObjects.count / 3);
        }
        else{
            gNumberOfLevelMeritCells = (int)(LevelMeritObjects.count / 3) + 1;
        }
        
        NSLog(@"Done Fetching Level Merit Images");
        [self fetchSpecialMerits];
        
    }
    
}


@end
