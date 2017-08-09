//
//  CastResultsTVC.m
//  unWine
//
//  Created by Bryce Boesen on 4/19/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastResultsTVC.h"
#import "CastMergeTVC.h"
#import "ParseSubclasses.h"

#define ADD_WINE_CELL_TAG 3321
#define ratHeight 88
#define ratWidth 128
#define ratFrame CGRectMake(SEMIWIDTH(self.view) - ratWidth / 2, HEIGHT(self.navigationController.view) - 1, ratWidth, ratHeight)
#define shiftFrame CGRectMake(SEMIWIDTH(self.view) - ratWidth / 2, HEIGHT(self.navigationController.view) - ratHeight, ratWidth, ratHeight)

@interface CastResultsTVC ()
@property (nonatomic) NSString *searchString;
@end

@implementation CastResultsTVC {
    UIView *mergeRat;
    UIImageView *background;
    BOOL hasSearched;
}
@synthesize scannerResults, dupes, results, detail, lockAllWines, searchString;

- (void)viewWillLayoutSubviews {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      WIDTH(self.tableView),
                                      HEIGHT(self.navigationController.view) - 50);
    
    [super viewWillLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

//- (BOOL)hidesBottomBarWhenPushed {
//    return YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        self.lockAllWines = [config[@"LOCK_ALL_WINES"] boolValue];
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-15, 0, 44, 0);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.separatorColor = [UIColor clearColor];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin-bg2.jpg"]];
    background.frame = self.navigationController.view.frame;
    background.layer.zPosition = -1;
    background.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = background;
    
    [self setupMergeRat];
    [self basicAppeareanceSetup];
    [self checkScannerResults];
    
    self.searchString = @"";
}

- (void)updateScannerResults:(NSArray *)scanResults {
    scannerResults = scanResults;
}

- (CastScannerVC *)getCastScannerVC {
    return self.delegate;
}

- (void)checkScannerResults {
    dupes = [[NSMutableArray alloc] init];
    if(scannerResults != nil && [scannerResults count] > 0) {
        NSMutableDictionary *unique = [NSMutableDictionary new];
        
        for(unWine *object in scannerResults) {
            if(![object isEditable])
                continue;
            
            NSString *wineName = [object getWineName];
            if(![[unique allKeys] containsObject:wineName]) {
                [unique setValue:[NSMutableArray arrayWithObjects:object, nil] forKey:wineName];
            } else {
                NSMutableArray *wines = [unique valueForKey:wineName];
                [wines addObject:object];
            }
        }
        
        for(NSString *wineName in unique) {
            NSArray *objects = [unique valueForKey:wineName];
            if([objects count] > 1)
                [dupes addObject:objects];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(mergeRat != nil)
        [mergeRat removeFromSuperview];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        SearchCell *cell = (SearchCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if(cell != nil)
            [cell.searchBar resignFirstResponder];
        
        if(scannerResults == nil) {
            _delegate.backFromResults = YES;
            //[_delegate revert];
            //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
        //[self.tabBarController.tabBar setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return 1;
            break;
        case 1:
            return !hasSearched ? 0 : 1;
            break;
        case 2:
            return (results == nil) ? 0 : [results count];
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section > 1) {
        PFObject *wine = [results objectAtIndex:indexPath.row];
        /*if([(unWine *)wine isPossiblyVerified]) {
         ResultVerifCell *cell = (ResultVerifCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResultVerifCell"];
         
         [cell.wineLabel setFrame:self.tableView.bounds];
         [cell.wineLabel setText:[wine[@"name"] capitalizedString]];
         
         cell.wineLabel.backgroundColor = [UIColor clearColor];
         cell.wineLabel.numberOfLines = 0;
         cell.wineLabel.lineBreakMode = NSLineBreakByWordWrapping;
         [cell.wineLabel setTextColor:[UIColor whiteColor]];
         [cell.wineLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
         [cell.wineLabel sizeToFit];
         
         return MAX(8 * 2 + HEIGHT(cell.wineLabel), DEFAULT_CELL_HEIGHT);
         } else {*/
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResultCell"];
        
        //[cell.textLabel setFrame:self.tableView.bounds];
        [cell.textLabel setText:[wine[@"name"] capitalizedString]];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [cell.textLabel sizeToFit];
        
        return MAX(14 * 2 + HEIGHT(cell.textLabel), DEFAULT_CELL_HEIGHT);
        //}
    } else
        return DEFAULT_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section > 0) {
        unWine *wine = (results == nil || [results count] == 0)? nil : [results objectAtIndex:indexPath.row];
        UITableViewCell *cell;
        
        if(indexPath.section != 1 && wine != nil && ![wine isEditable]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ResultVerifCell"];
            
            if (cell == nil) {
                cell = [[ResultVerifCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResultVerifCell"];
            }
            
            ResultVerifCell *verified = (ResultVerifCell *)cell;
            
            verified.wineLabel.backgroundColor = [UIColor clearColor];
            verified.wineLabel.numberOfLines = 0;
            verified.wineLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [verified.wineLabel setTextColor:[UIColor whiteColor]];
            [verified.wineLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
            [verified.wineLabel sizeToFit];
            
            [verified.wineLabel setText:[wine getWineName]];
        } else {
            NSString *cellId = (indexPath.section == 1) ? @"UnknownCell" : @"ResultCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.textLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
            [cell.textLabel sizeToFit];
            
            if(indexPath.section > 1)
                [cell.textLabel setText:[wine getWineName]];
            else {
                [cell.textLabel setText:@"Don't see your wine? Help us!"];
                cell.tag = ADD_WINE_CELL_TAG;
            }
        }
        
        if(indexPath.section > 1) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(0, 0, 30, 30)];
            
            UITableViewCell *disclosure = [[UITableViewCell alloc] init];
            [button addSubview:disclosure];
            disclosure.frame = button.bounds;
            disclosure.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            disclosure.userInteractionEnabled = NO;
            
            [cell setAccessoryView:button];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.clipsToBounds = YES;
        
        return cell;
    } else {
        SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        [cell setup];
        
        //if(dupes != nil && [dupes count] > 0 && ![[User currentUser] isAnonymous])
        //    [self showMergeRat];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.clipsToBounds = YES;
        
        cell.searchBar.frame = CGRectMake(12,
                                          cell.searchBar.frame.origin.y,
                                          cell.frame.size.width - 24,
                                          cell.frame.size.height);
        cell.searchBar.backgroundColor = [UIColor clearColor];
        cell.searchBar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Wine" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [cell.searchBar setTextColor:[UIColor whiteColor]];
        cell.searchBar.returnKeyType = UIReturnKeySearch;
        cell.searchBar.delegate = self;
        
        cell.searchBar.rightViewMode = UITextFieldViewModeAlways;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIcon"]];
        imageView.frame = CGRectMake(10, 0, 22, 22);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        cell.searchBar.rightView = imageView;
        
        cell.searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
        for(UIGestureRecognizer *gesture in [cell.searchBar gestureRecognizers]) {
            if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]])
                gesture.enabled = NO;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 8.f;
        
        UIColor *fadecolor = (indexPath.section != 1) ? [UIColor colorWithRed:0 green:0 blue:0 alpha:.338] : [UIColor colorWithRed:1 green:.5 blue:0 alpha:.25];
        UIColor *color = (indexPath.section != 1) ? [UIColor colorWithRed:1 green:1 blue:1 alpha:.64] : [UIColor colorWithRed:1 green:.5 blue:0 alpha:.64];
        
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
        CGRect prebounds = CGRectMake(12,
                                      cell.bounds.origin.y,
                                      cell.bounds.size.width - 24,
                                      (rowsAmount - 1 == indexPath.row) ? cell.bounds.size.height - 1 : cell.bounds.size.height);
        CGRect bounds = CGRectInset(prebounds, 5, 0);
        layer.strokeColor = [color CGColor];
        
        BOOL addLine = NO;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            addLine = YES;
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
            addLine = YES;
        }
        
        layer.path = pathRef;
        layer.fillColor = [fadecolor CGColor];
        CFRelease(pathRef);
        
        if (addLine == YES) {
            CALayer *lineLayer = [[CALayer alloc] init];
            CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+5, bounds.size.height-lineHeight, bounds.size.width-5, lineHeight);
            lineLayer.backgroundColor = tableView.separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isFirstResponder]) {
        NSString *text = textField.text;
        hasSearched = YES;
        
        [textField resignFirstResponder];
        if([text isEqualToString:@""]) {
            results = scannerResults;
            [self checkScannerResults];
            [self.tableView reloadData];
        } else
            [self searchWines:textField.text];
    }
    
    return [self textFieldShouldEndEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    unWine *wine = (indexPath.section > 1 && results != nil && [results count] > 0) ? [results objectAtIndex:indexPath.row] : nil;
    
    if (cell.tag != ADD_WINE_CELL_TAG) {
        [Analytics trackUserSelectedWineFromResults:wine andSearchString:self.searchString];
    }
    
    detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];

    detail.wine = wine;
    detail.lockAllWines = lockAllWines;
    detail.isNew = (wine == nil);
    
    [self.navigationController pushViewController:detail animated:YES];
    
}

- (void)searchWines:(NSString *)searchText {
    
    if([searchText isEqualToString:@""]) {
        results = scannerResults;
        [self checkScannerResults];
        [self.tableView reloadData];
        return;
    }
    
    self.searchString = searchText;
    
    [Analytics trackUserSearchedWine:self.searchString];
    [Search createSearchHistoryWithString:self.searchString];
    
    dupes = [[NSMutableArray alloc] init];
    
    SHOW_HUD;
    
    [[unWine findTask:searchText.lowercaseString] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        
        NSArray *preprocess = (NSArray *)task.result;
        NSError *error = task.error;
        
        if (!error) {
            NSMutableDictionary *unique = [NSMutableDictionary new];
            
            for(unWine *object in preprocess) {
                if(![object isEditable])
                    continue;
                
                NSString *wineName = [object getWineName];
                if(![[unique allKeys] containsObject:wineName]) {
                    [unique setValue:[NSMutableArray arrayWithObjects:object, nil] forKey:wineName];
                } else {
                    NSMutableArray *wines = [unique valueForKey:wineName];
                    [wines addObject:object];
                }
            }
            
            NSInteger verifiedCount = 0;
            NSMutableArray *verifiedFirst = [[NSMutableArray alloc] init];
            for(NSInteger i = [preprocess count] - 1; i >= 0; i--) {
                unWine *object = [preprocess objectAtIndex:i];
                
                if(![object isEditable]) {
                    [verifiedFirst insertObject:object atIndex:0];
                    verifiedCount++;
                } else {
                    [verifiedFirst insertObject:object atIndex:verifiedCount];
                }
            }
            
            results = verifiedFirst;
            
            for(NSString *wineName in unique) {
                NSArray *objects = [unique valueForKey:wineName];
                if([objects count] > 1)
                    [dupes addObject:objects];
            }
            
            [self.tableView reloadData];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        HIDE_HUD;
        
        return nil;
    }];
}

- (void)setupMergeRat {
    mergeRat = [[UIView alloc] initWithFrame:ratFrame];
    mergeRat.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
    mergeRat.clipsToBounds = YES;
    mergeRat.layer.borderWidth = .5f;
    mergeRat.layer.borderColor = [[UIColor blackColor] CGColor];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMergeRat)];
    [mergeRat addGestureRecognizer:gesture];
    
    CGFloat buffer = 0;
    CGRect ratImageFrame = CGRectMake(buffer, buffer, ratWidth - buffer * 2, ratHeight - buffer * 2);
    UIImageView *rat = [[UIImageView alloc] initWithFrame:ratImageFrame];
    [rat setImage:[UIImage imageNamed:@"unwineRat"]];
    [rat setContentMode:UIViewContentModeScaleAspectFit];
    [mergeRat addSubview:rat];
    
    mergeRat.alpha = 0;
    [self.navigationController.view addSubview:mergeRat];
}

- (void) showMergeRat {
    NSLog(@"Should Show Merge Rat.");
    mergeRat.alpha = 1;
    [mergeRat setFrame:ratFrame];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [mergeRat setFrame:shiftFrame];
                     } completion:^(BOOL finished) {
                         [self performSelector:@selector(hideMergeRat) withObject:nil afterDelay:5.0];
                     }];
}

- (void)hideMergeRat {
    [self hideMergeRat:^{ }];
}

- (void)hideMergeRat:(void(^)(void))callback {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [mergeRat setFrame:ratFrame];
                     } completion:^(BOOL finished) {
                         mergeRat.alpha = 0;
                         callback();
                     }];
}

- (void) tapMergeRat {
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Sometimes the same wine gets added multiple times, and we need your help to decide which information is the most accurate."];
    alert.delegate = self;
    alert.leftButtonTitle = @"Nah";
    alert.rightButtonTitle = @"Help unWine";
    alert.tag = 3;
    [alert show];
}

- (void)rightButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == 3) {
        [self hideMergeRat:^{
            UINavigationController *mergeNav = [self.storyboard instantiateViewControllerWithIdentifier:@"mergeNav"];
            
            CastMergeTVC *merge = [mergeNav.viewControllers objectAtIndex:0];
            merge.delegate = self;
            merge.wines = [dupes firstObject];
            
            [self.navigationController presentViewController:mergeNav animated:YES completion:nil];
        }];
    } else if([[unWineAlertView sharedInstance] tag] == 1) {
        SearchCell *cell = (SearchCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self searchWines:cell.searchBar.text];
    }
}

- (void)mergeComplete:(NSInteger)responseCode {
    NSLog(@"Merge Complete!");
    
    if(responseCode == 0) {
        unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Sometimes wine merging is as easy as clicking a button! Thanks for helping out!"];
        alert.title = @"Wish List Rat";
        alert.centerButtonTitle = @"Awesome!";
        [alert show];
    } else if(responseCode == 1) {
        unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"Thanks for helping out! It's people like you that make unWine a better place."];
        alert.title = @"Wish List Rat";
        alert.centerButtonTitle = @"Keep unWineing";
        [alert show];
    }
}

@end
