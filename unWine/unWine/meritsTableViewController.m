//
//  meritsTableViewController.m
//  unWine
//
//  Created by Fabio Gomez on 12/21/13.
//  Copyright (c) 2013 LION Mobile. All rights reserved.
//

#import "meritsTableViewController.h"
#import "meritsTabCell.h"
#import "meritsBasicCell.h"
#import "meritDetailViewController.h"
#import "meritsTableViewController+fetching.h"
#import "meritsTableViewController+setupCells.h"
#import <Parse/Parse.h>
#import "UITableViewController+Helper.h"
#import <ParseUI/ParseUI.h>

@interface meritsTableViewController ()

@end

@implementation meritsTableViewController

@synthesize LevelMeritImages, LevelMeritObjects, specialMeritImages, specialMeritObjects, otherMeritObjects, otherMeritImages, exclusiveMeritImages, exclusiveMeritObjects, userEarnedMeritObjects;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addUnWineTitleView];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //self.tableView.separatorColor = [UIColor clearColor];
    
    LevelMeritObjects = [[NSMutableArray alloc] init];
    LevelMeritImages  = [[NSMutableDictionary alloc] init];
    specialMeritObjects = [[NSMutableArray alloc] init];
    specialMeritImages  = [[NSMutableDictionary alloc] init];
    otherMeritObjects   = [[NSMutableArray alloc] init];
    otherMeritImages    = [[NSMutableDictionary alloc] init];
    exclusiveMeritObjects   = [[NSMutableArray alloc] init];
    exclusiveMeritImages    = [[NSMutableDictionary alloc] init];
    gNumberOfLevelMeritCells = 1;
    gNumberOfOtherMeritCells = 1;
    gNumberOfSpecialMeritCells = 1;
    gNumberOfExclusiveMeritCells = 1;
    LevelImagesCounter = 0;
    specialImagesCounter = 0;
    otherImagesCounter = 0;
    exclusiveImagesCounter = 0;
    
    //[self fetchUserEarnedMerits];
    [self fetchMerits];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
            
            //case 0: return [self headerViewWithText:@"Photo Cell"];
        case MERIT_LEVEL_SECTION:       return [self headerViewWithText:@"Level"        andHeight:headerHeight];
        case MERIT_WINE_SECTION:        return [self headerViewWithText:@"Wine"         andHeight:headerHeight];
        case MERIT_SPECIAL_SECTION:     return [self headerViewWithText:@"Special"      andHeight:headerHeight];
        case MERIT_EXCLUSIVE_SECTION:   return [self headerViewWithText:@"Exclusive"    andHeight:headerHeight];
            
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return headerHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 1;
    
    if (section == MERIT_LEVEL_SECTION) {
        numberOfRows = gNumberOfLevelMeritCells;
    }
    else if (section == MERIT_WINE_SECTION) {
        numberOfRows = gNumberOfOtherMeritCells;
    }
    else if (section == MERIT_SPECIAL_SECTION){
        numberOfRows = gNumberOfSpecialMeritCells;
    }
    else if (section == MERIT_EXCLUSIVE_SECTION){
        numberOfRows = gNumberOfExclusiveMeritCells;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"MeritsTabCell";
        
        meritsTabCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[meritsTabCell alloc] initWithStyle:UITableViewCellStyleValue1
                                        reuseIdentifier:CellIdentifier];
        }
        return cell;
        
    } else {
        
        return [self setUpMeritsBasicCellWithIndexPath:indexPath];
    }
    
    // Should NOT reach this place
    return nil;
}

// Set the height for each the cells (i.e. the first cell should be smaller than the rest of the cells)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section!=0) {
        
        return 138.0;
        
    }
    
    else {
        
        return 50.0;
        
    }
    
}

// Prepare to segue to the meritDetailViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    printf("\n\n");
    NSLog(@"prepareForSegue");
    // We do the following assuming the sender is one of the buttons in one of the meritBasicCells
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"indexPath.section = %lu, row = %lu", indexPath.section, indexPath.row);
    
    NSLog(@"otherMeritImages.count = %lu, specialMeritImages.count = %lu", (unsigned long)otherMeritImages.count, (unsigned long)specialMeritImages.count);
    
    if ([[segue identifier] isEqualToString:@"leftButtonSegue"]) {
        
        NSLog(@"leftButtonSegue");
        meritDetailViewController *detailViewController = [segue destinationViewController];
        int meritImagesIndex = (int)(indexPath.row*3);
        PFImageView *imageView;
        NSMutableString *meritLabelDetail = [[NSMutableString alloc] init];
        NSMutableString *meritDescriptionDetail = [[NSMutableString alloc] init];

        if (indexPath.section == MERIT_LEVEL_SECTION){
            NSLog(@"LevelMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", meritImagesIndex);
            imageView = (PFImageView *)[LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
            PFObject *meritObject = [LevelMeritObjects objectAtIndex:meritImagesIndex];
            
            NSLog(@"%@!!!!!!!!!!!", [LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]]);
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
            
        }
        else if (indexPath.section == MERIT_WINE_SECTION){
            NSLog(@"otherMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", meritImagesIndex);
            imageView = (PFImageView *)[otherMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
            PFObject *meritObject = [otherMeritObjects objectAtIndex:meritImagesIndex];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
            
        }
        else if (indexPath.section == MERIT_SPECIAL_SECTION) {
            NSLog(@"specialMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", meritImagesIndex);
            imageView = (PFImageView *)[specialMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
            PFObject *meritObject = [specialMeritObjects objectAtIndex:meritImagesIndex];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
        else if (indexPath.section == MERIT_EXCLUSIVE_SECTION) {
            NSLog(@"exclusiveMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", meritImagesIndex);
            imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", meritImagesIndex]];
            PFObject *meritObject = [exclusiveMeritObjects objectAtIndex:meritImagesIndex];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
        
        //detailViewController.meritDetailModel = @[specialMeritImages[0]];
        
    }
    
    if ([[segue identifier] isEqualToString:@"middleButtonSegue"]) {
        
        NSLog(@"middleButtonSegue");
        meritDetailViewController *detailViewController = [segue destinationViewController];
        int meritImagesIndex = (int)(indexPath.row*3);
        PFImageView *imageView;
        NSMutableString *meritLabelDetail = [[NSMutableString alloc] init];
        NSMutableString *meritDescriptionDetail = [[NSMutableString alloc] init];

        
        if (indexPath.section == MERIT_LEVEL_SECTION){
            NSLog(@"LevelMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", (meritImagesIndex+1));
            imageView = (PFImageView *)[LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
            PFObject *meritObject = [LevelMeritObjects objectAtIndex:(meritImagesIndex+1)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
            
        }
        else if (indexPath.section == MERIT_WINE_SECTION){
            NSLog(@"otherMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", (meritImagesIndex+1));
            imageView = (PFImageView *)[otherMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
            PFObject *meritObject = [otherMeritObjects objectAtIndex:(meritImagesIndex+1)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
            
        }
        else if (indexPath.section == MERIT_SPECIAL_SECTION) {
            NSLog(@"otherMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", (meritImagesIndex+1));
            imageView = (PFImageView *)[specialMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
            PFObject *meritObject = [specialMeritObjects objectAtIndex:(meritImagesIndex+1)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
        else if (indexPath.section == MERIT_EXCLUSIVE_SECTION) {
            NSLog(@"exclusiveMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", meritImagesIndex);
            imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+1)]];
            PFObject *meritObject = [exclusiveMeritObjects objectAtIndex:(meritImagesIndex+1)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
    }
    
    if ([[segue identifier] isEqualToString:@"rightButtonSegue"]) {
        
        NSLog(@"rightButtonSegue");
        meritDetailViewController *detailViewController = [segue destinationViewController];
        int meritImagesIndex = (int)(indexPath.row*3);
        PFImageView *imageView;
        NSMutableString *meritLabelDetail = [[NSMutableString alloc] init];
        NSMutableString *meritDescriptionDetail = [[NSMutableString alloc] init];

        
        if (indexPath.section == MERIT_LEVEL_SECTION){
            NSLog(@"LevelMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", (meritImagesIndex+2));
            imageView = (PFImageView *)[LevelMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
            PFObject *meritObject = [LevelMeritObjects objectAtIndex:(meritImagesIndex+2)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
            
        }
        else if (indexPath.section == MERIT_WINE_SECTION){
            NSLog(@"otherMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", (meritImagesIndex+2));
            imageView = (PFImageView *)[otherMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
            PFObject *meritObject = [otherMeritObjects objectAtIndex:(meritImagesIndex+2)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
        else if (indexPath.section == MERIT_SPECIAL_SECTION) {
            NSLog(@"otherMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", (meritImagesIndex+2));
            imageView = (PFImageView *)[specialMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
            PFObject *meritObject = [specialMeritObjects objectAtIndex:(meritImagesIndex+2)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
        else if (indexPath.section == MERIT_EXCLUSIVE_SECTION) {
            NSLog(@"exclusiveMerits Section - Cell Index: %li", (long)indexPath.row);
            NSLog(@"meritImagesIndex = %i", meritImagesIndex);
            imageView = (PFImageView *)[exclusiveMeritImages objectForKey:[NSString stringWithFormat:@"%i", (meritImagesIndex+2)]];
            PFObject *meritObject = [exclusiveMeritObjects objectAtIndex:(meritImagesIndex+2)];
            
            [meritLabelDetail setString: (NSMutableString *)[meritObject objectForKey:@"name"]];
            [meritDescriptionDetail setString: (NSMutableString *)[meritObject objectForKey:@"message"]];
            detailViewController.meritDetailModel = @[imageView.image, meritLabelDetail, meritDescriptionDetail];
        }
    }
}

@end
