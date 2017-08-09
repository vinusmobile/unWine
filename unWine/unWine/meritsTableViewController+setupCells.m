//
//  meritsTableViewController+setupCells.m
//  unWine
//
//  Created by Fabio Gomez on 2/26/14.
//  Copyright (c) 2014 LION Mobile. All rights reserved.
//

#import "meritsTableViewController+setupCells.h"
#import "meritsBasicCell.h"
#import <ParseUI/ParseUI.h>

@implementation meritsTableViewController (setupCells)

- (UITableViewCell *)setUpMeritsBasicCellWithIndexPath: (NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    if (indexPath.section == MERIT_LEVEL_SECTION){
        cell = [self setUpLevelMeritCellWithIndexPath:indexPath];
    }
    else if (indexPath.section == MERIT_WINE_SECTION){
        cell = [self setUpOtherMeritCellWithIndexPath:indexPath];
    }
    else if (indexPath.section == MERIT_SPECIAL_SECTION) {
        cell = [self setUpSpecialMeritCellWithIndexPath:indexPath];
    }
    else if (indexPath.section == MERIT_EXCLUSIVE_SECTION) {
        cell = [self setUpExclusiveMeritCellWithIndexPath:indexPath];
    }
        
    return cell;
}

- (UITableViewCell *)setUpLevelMeritCellWithIndexPath: (NSIndexPath *)indexPath{
    printf("\n");
    NSLog(@"setUpLevelMeritCellWithIndexPath - %li", (long)indexPath.row);
    meritsBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:iMeritsBasicCellIdentifier forIndexPath:indexPath];
    
    // This basically is the index to start getting images from the merit images array
    int meritImagesIndex = (int)(indexPath.row*3);
    int numberOfImagesToBeShown;
    
    NSLog(@"LevelMeritImages.count - meritImagesIndex");
    NSLog(@"%lu - %i = %u", (unsigned long)LevelMeritImages.count,  meritImagesIndex, LevelMeritImages.count - meritImagesIndex);
    // Figure out whether there are not enough images in the merit images array for this cell
    if (LevelMeritImages.count - meritImagesIndex >= 3) {
        numberOfImagesToBeShown = 3;
    }
    else{
        numberOfImagesToBeShown = (int)LevelMeritImages.count - meritImagesIndex;
    }
    
    NSLog(@"numberOfImagesToBeShown = %i", numberOfImagesToBeShown);
    // Now set up the cell images one by one based on the numberOfImagesToBeShown
    // We are definitely setting this one up, else we would not be here
    NSLog(@"showing left button");
    PFImageView *imageView = (PFImageView *)[LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
    
    //[self finishSettingUpMeritCell:cell withImageView:imageView numberOfImagesToBeShown:numberOfImagesToBeShown andMeritImagesIndex:meritImagesIndex];
    
    [cell.leftButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
    
    if (imageView.file != nil) {
        cell.leftButton.userInteractionEnabled = YES;
    }
    else{
        cell.leftButton.userInteractionEnabled = NO;
    }
    
    // We have to do this since we are using dequeueReusableCellWithIdentifier
    // Basically it keeps the UI from the previous cell (i.e the buttons and their interactivity)
    [cell.middleButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.middleButton.userInteractionEnabled = NO;
    [cell.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.rightButton.userInteractionEnabled = NO;
    
    // We set the images and the interactivity here only if we need to
    // Else, the app will crash when tapping on a button/image
    if (numberOfImagesToBeShown > 1) {
        NSLog(@"showing middle button");
        imageView = (PFImageView *)[LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
        [cell.middleButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.middleButton.userInteractionEnabled = YES;
        }
        else{
            cell.middleButton.userInteractionEnabled = NO;
        }
    }
    
    if (numberOfImagesToBeShown > 2) {
        NSLog(@"showing right button");
        imageView = (PFImageView *)[LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
        [cell.rightButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.rightButton.userInteractionEnabled = YES;
        }
        else{
            cell.rightButton.userInteractionEnabled = NO;
        }
    }
    
    return cell;
    
}


- (UITableViewCell *)setUpSpecialMeritCellWithIndexPath: (NSIndexPath *)indexPath{
    printf("\n");
    NSLog(@"setUpSpecialMeritCellWithIndexPath - %li", (long)indexPath.row);
    meritsBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:iMeritsBasicCellIdentifier forIndexPath:indexPath];
    
    // This basically is the index to start getting images from the merit images array
    int meritImagesIndex = (int)(indexPath.row*3);
    int numberOfImagesToBeShown;
    
    NSLog(@"specialMeritImages.count - meritImagesIndex");
    NSLog(@"%lu - %i = %u", (unsigned long)specialMeritImages.count,  meritImagesIndex, specialMeritImages.count - meritImagesIndex);
    // Figure out whether there are not enough images in the merit images array for this cell
    if (specialMeritImages.count - meritImagesIndex >= 3) {
        numberOfImagesToBeShown = 3;
    }
    else{
        numberOfImagesToBeShown = (int)specialMeritImages.count - meritImagesIndex;
    }
    
    NSLog(@"numberOfImagesToBeShown = %i", numberOfImagesToBeShown);
    // Now set up the cell images one by one based on the numberOfImagesToBeShown
    // We are definitely setting this one up, else we would not be here
    NSLog(@"showing left button");
    PFImageView *imageView = (PFImageView *)[specialMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
    
    //[self finishSettingUpMeritCell:cell withImageView:imageView numberOfImagesToBeShown:numberOfImagesToBeShown andMeritImagesIndex:meritImagesIndex];
    
    [cell.leftButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
    
    if (imageView.file != nil) {
        cell.leftButton.userInteractionEnabled = YES;
    }
    else{
        cell.leftButton.userInteractionEnabled = NO;
    }
    
    // We have to do this since we are using dequeueReusableCellWithIdentifier
    // Basically it keeps the UI from the previous cell (i.e the buttons and their interactivity)
    [cell.middleButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.middleButton.userInteractionEnabled = NO;
    [cell.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.rightButton.userInteractionEnabled = NO;
    
    // We set the images and the interactivity here only if we need to
    // Else, the app will crash when tapping on a button/image
    if (numberOfImagesToBeShown > 1) {
        NSLog(@"showing middle button");
        imageView = (PFImageView *)[specialMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
        [cell.middleButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.middleButton.userInteractionEnabled = YES;
        }
        else{
            cell.middleButton.userInteractionEnabled = NO;
        }
    }
    
    if (numberOfImagesToBeShown > 2) {
        NSLog(@"showing right button");
        imageView = (PFImageView *)[specialMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
        [cell.rightButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.rightButton.userInteractionEnabled = YES;
        }
        else{
            cell.rightButton.userInteractionEnabled = NO;
        }
    }
    
    return cell;
    
}

- (UITableViewCell *)setUpOtherMeritCellWithIndexPath: (NSIndexPath *)indexPath{
    printf("\n");
    NSLog(@"setUpOtherMeritCellWithIndexPath - %li", (long)indexPath.row);
    meritsBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:iMeritsBasicCellIdentifier forIndexPath:indexPath];
    
    // This basically is the index to start getting images from the merit images array
    int meritImagesIndex = (int)(indexPath.row*3);
    int numberOfImagesToBeShown;
    
    NSLog(@"otherMeritImages.count - meritImagesIndex");
    NSLog(@"%lu - %i = %u", (unsigned long)otherMeritImages.count,  meritImagesIndex, otherMeritImages.count - meritImagesIndex);
    // Figure out whether there are not enough images in the merit images array for this cell
    if (otherMeritImages.count - meritImagesIndex >= 3) {
        numberOfImagesToBeShown = 3;
    }
    else{
        numberOfImagesToBeShown = (int)otherMeritImages.count - meritImagesIndex;
    }
    
    NSLog(@"numberOfImagesToBeShown = %i", numberOfImagesToBeShown);
    // Now set up the cell images one by one based on the numberOfImagesToBeShown
    // We are definitely setting this one up, else we would not be here
    NSLog(@"showing left button");
    PFImageView *imageView = (PFImageView *)[otherMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
    
    //[self finishSettingUpMeritCell:cell withImageView:imageView numberOfImagesToBeShown:numberOfImagesToBeShown andMeritImagesIndex:meritImagesIndex];
    
    [cell.leftButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
    
    if (imageView.file != nil) {
        cell.leftButton.userInteractionEnabled = YES;
    }
    else{
        cell.leftButton.userInteractionEnabled = NO;
    }
    
    // We have to do this since we are using dequeueReusableCellWithIdentifier
    // Basically it keeps the UI from the previous cell (i.e the buttons and their interactivity)
    [cell.middleButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.middleButton.userInteractionEnabled = NO;
    [cell.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.rightButton.userInteractionEnabled = NO;
    
    // We set the images and the interactivity here only if we need to
    // Else, the app will crash when tapping on a button/image
    if (numberOfImagesToBeShown > 1) {
        NSLog(@"showing middle button");
        imageView = (PFImageView *)[otherMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
        [cell.middleButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.middleButton.userInteractionEnabled = YES;
        }
        else{
            cell.middleButton.userInteractionEnabled = NO;
        }
    }
    
    if (numberOfImagesToBeShown > 2) {
        NSLog(@"showing right button");
        imageView = (PFImageView *)[otherMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
        [cell.rightButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.rightButton.userInteractionEnabled = YES;
        }
        else{
            cell.rightButton.userInteractionEnabled = NO;
        }
    }
    
    return cell;
    
}

- (UITableViewCell *)setUpExclusiveMeritCellWithIndexPath: (NSIndexPath *)indexPath{
    printf("\n");
    NSLog(@"setUpExclusiveMeritCellWithIndexPath - %li", (long)indexPath.row);
    meritsBasicCell *cell = [self.tableView dequeueReusableCellWithIdentifier:iMeritsBasicCellIdentifier forIndexPath:indexPath];
    
    [UIImage imageNamed:@"default.png"];
    
    [cell.leftButton setBackgroundImage: [UIImage imageNamed:@"default.png"] forState:UIControlStateNormal];
    [cell.middleButton setBackgroundImage: [UIImage imageNamed:@"default.png"] forState:UIControlStateNormal];
    [cell.rightButton setBackgroundImage: [UIImage imageNamed:@"default.png"] forState:UIControlStateNormal];
    
    cell.leftButton.userInteractionEnabled = NO;
    cell.middleButton.userInteractionEnabled = NO;
    cell.rightButton.userInteractionEnabled = NO;
    
    
    // This basically is the index to start getting images from the merit images array
    int meritImagesIndex = (int)(indexPath.row*3);
    int numberOfImagesToBeShown;
    
    NSLog(@"exclusiveMeritImages.count - meritImagesIndex");
    NSLog(@"%lu - %i = %u", (unsigned long)exclusiveMeritImages.count,  meritImagesIndex, exclusiveMeritImages.count - meritImagesIndex);
    // Figure out whether there are not enough images in the merit images array for this cell
    if (exclusiveMeritImages.count - meritImagesIndex >= 3) {
        numberOfImagesToBeShown = 3;
    }
    else{
        numberOfImagesToBeShown = (int)exclusiveMeritImages.count - meritImagesIndex;
    }
    
    NSLog(@"numberOfImagesToBeShown = %i", numberOfImagesToBeShown);
    // Now set up the cell images one by one based on the numberOfImagesToBeShown
    // We are definitely setting this one up, else we would not be here
    NSLog(@"showing left button");
    PFImageView *imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
    
    //[self finishSettingUpMeritCell:cell withImageView:imageView numberOfImagesToBeShown:numberOfImagesToBeShown andMeritImagesIndex:meritImagesIndex];
    [cell.leftButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
    
    if (imageView.file != nil) {
        cell.leftButton.userInteractionEnabled = YES;
    }
    else{
        cell.leftButton.userInteractionEnabled = NO;
    }
    
    // We have to do this since we are using dequeueReusableCellWithIdentifier
    // Basically it keeps the UI from the previous cell (i.e the buttons and their interactivity)
    [cell.middleButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.middleButton.userInteractionEnabled = NO;
    [cell.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.rightButton.userInteractionEnabled = NO;
    
    // We set the images and the interactivity here only if we need to
    // Else, the app will crash when tapping on a button/image
    if (numberOfImagesToBeShown > 1) {
        NSLog(@"showing middle button");
        imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
        [cell.middleButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.middleButton.userInteractionEnabled = YES;
        }
        else{
            cell.middleButton.userInteractionEnabled = NO;
        }
    }
    
    if (numberOfImagesToBeShown > 2) {
        NSLog(@"showing right button");
        imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
        [cell.rightButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.rightButton.userInteractionEnabled = YES;
        }
        else{
            cell.rightButton.userInteractionEnabled = NO;
        }
    }
    
    return cell;
    
}

/*
- (void)finishSettingUpMeritCell:(meritsBasicCell *)cell withImageView:(PFImageView *) imageView numberOfImagesToBeShown:(int) numberOfImagesToBeShown andMeritImagesIndex:(int) meritImagesIndex{
    
    [cell.leftButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
    
    if (imageView.file != nil) {
        cell.leftButton.userInteractionEnabled = YES;
    }
    else{
        cell.leftButton.userInteractionEnabled = NO;
    }
    
    // We have to do this since we are using dequeueReusableCellWithIdentifier
    // Basically it keeps the UI from the previous cell (i.e the buttons and their interactivity)
    [cell.middleButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.middleButton.userInteractionEnabled = NO;
    [cell.rightButton setBackgroundImage:nil forState:UIControlStateNormal];
    cell.rightButton.userInteractionEnabled = NO;
    
    // We set the images and the interactivity here only if we need to
    // Else, the app will crash when tapping on a button/image
    if (numberOfImagesToBeShown > 1) {
        NSLog(@"showing middle button");
        imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
        [cell.middleButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.middleButton.userInteractionEnabled = YES;
        }
        else{
            cell.middleButton.userInteractionEnabled = NO;
        }
    }
    
    if (numberOfImagesToBeShown > 2) {
        NSLog(@"showing right button");
        imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
        [cell.rightButton setBackgroundImage: imageView.image forState:UIControlStateNormal];
        
        if (imageView.file != nil) {
            cell.rightButton.userInteractionEnabled = YES;
        }
        else{
            cell.rightButton.userInteractionEnabled = NO;
        }
    }

}*/

@end
