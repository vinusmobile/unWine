//
//  CastMergeTVC.m
//  unWine
//
//  Created by Bryce Boesen on 6/9/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastMergeTVC.h"
#import "CastScannerVC.h"
#import "ParseSubclasses.h"

@implementation CastMergeTVC {
    UIView *background;
    NSString *field;
    NSInteger choice;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(cancel)];
    [[self navigationItem] setBackBarButtonItem:back];
    self.navigationItem.leftBarButtonItem = back;
    
    if(self.fields == nil) {
        self.fields = [[NSMutableArray alloc] initWithObjects:@"region", @"vineyard", @"wineType", nil];
        self.wine = [self.wines firstObject];
        self.progress = [[NSMutableDictionary alloc] init];
        
        for(NSInteger i = [self.fields count] - 1; i >= 0; i--) {
            NSString *mergeField = [self.fields objectAtIndex:i];
            NSMutableOrderedSet *options = [[NSMutableOrderedSet alloc] init];
            
            for(unWine *mergable in self.wines) {
                id element = [mergable objectForKey:mergeField];
                if(element != nil) {
                    if([element isKindOfClass:[NSString class]]) {
                        [[(NSString *)element capitalizedString] stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];
                        if(!ISVALID((NSString *)element))
                            continue;
                    }
                    
                    [options addObject:element];
                }
            }
            
            if([options count] > 1) {
                //self.progress[mergeField] = options;
                [self.progress setValue:options forKey:mergeField];
            } else if([options count] == 1) {
                [self.fields removeObject:mergeField];
                [self.wine setValue:[options firstObject] forKey:mergeField];
            } else
                [self.fields removeObject:mergeField];
        }
    }
    
    field = [self.fields firstObject];
    choice = -1;
    if(field == nil)
        [self nextFinalize:0];
    
    //NSLog(@"fields %@", self.fields);
    //NSLog(@"progress %@", self.progress);
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin-bg4.jpeg"]];
    background.frame = self.navigationController.view.frame;
    background.layer.zPosition = -1;
    background.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = background;
    
    [self setupHeaderView];
    
    [self basicAppeareanceSetup];
}

- (void) cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setupHeaderView {
    CGRect wineNameFrame = CGRectMake(0, 0, WIDTH(self.tableView), 90);
    UIView *wineNameView = [[UIView alloc] initWithFrame:wineNameFrame];
    wineNameView.backgroundColor = [UIColor clearColor];
    
    UILabel *selectCorrect = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, WIDTH(self.tableView), 30)];
    
    [selectCorrect setText:[NSString stringWithFormat:@"Please select the correct %@ for", field]];
    selectCorrect.backgroundColor = [UIColor clearColor];
    selectCorrect.lineBreakMode = NSLineBreakByWordWrapping;
    selectCorrect.textAlignment = NSTextAlignmentCenter;
    [selectCorrect setTextColor:[UIColor whiteColor]];
    [selectCorrect setFont:[UIFont fontWithName:@"OpenSans" size:14]];
    
    [wineNameView addSubview:selectCorrect];
    
    UILabel *wineName = [[UILabel alloc] initWithFrame:CGRectMake(12, 42, WIDTH(self.tableView) - 24, 48)];
    
    [wineName setText:[self.wine[@"name"] capitalizedString]];
    wineName.clipsToBounds = YES;
    wineName.backgroundColor = [UIColor clearColor];
    wineName.lineBreakMode = NSLineBreakByCharWrapping;
    //wineName.numberOfLines = 0;
    [wineName setTextColor:[UIColor whiteColor]];
    [wineName setFont:[UIFont fontWithName:@"OpenSans" size:18]];
    
    [wineNameView addSubview:wineName];
    
    NSInteger storedHeight = HEIGHT(wineName);
    [wineName sizeToFit];
    [wineName setTextAlignment:NSTextAlignmentCenter];
    NSInteger diff = HEIGHT(wineName) - storedHeight;
    wineNameFrame.size.height += diff > 0 ? diff : 0;
    
    [wineNameView setFrame:wineNameFrame];
    
    self.tableView.tableHeaderView = wineNameView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (field != nil) ? [[self.progress objectForKey:field] count] + 1 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(field != nil && indexPath.section < [[self.progress objectForKey:field] count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MergeCell"];
        
        [cell.textLabel setText: [[self.progress objectForKey:field] objectAtIndex:indexPath.section]];
        
        [cell.textLabel setFrame:self.tableView.bounds];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [cell.textLabel sizeToFit];
        
        return MAX(8 * 2 + HEIGHT(cell.textLabel), DEFAULT_MERGE_CELL_HEIGHT);
    } else
        return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(field != nil && indexPath.section < [[self.progress objectForKey:field] count]) {
        MergeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MergeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.progress objectForKey:field] objectAtIndex:indexPath.section]];
        
        return cell;
    } else {
        MergeNextCell *cell = (MergeNextCell *)[tableView dequeueReusableCellWithIdentifier:@"NextCell"];
        cell.delegate = self;
        
        [cell setup:indexPath];
        [cell configure:self.wine];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(field == nil || indexPath.section == [[self.progress objectForKey:field] count])
        return;
    
    if ([cell respondsToSelector:@selector(tintColor)]) {
        CGFloat cornerRadius = 8.f;
        
        UIColor *fadecolor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.338];
        UIColor *color = (choice == indexPath.section)? UNWINE_RED : [UIColor colorWithRed:1 green:1 blue:1 alpha:.64];
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(field != nil && indexPath.section < [[self.progress objectForKey:field] count])
        choice = indexPath.section;
    else
        choice = -1;
    
    [self.tableView reloadData];
}

- (void) reloadSectionDU:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation {
    NSRange range = NSMakeRange(section, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:rowAnimation];
}

- (void)clickNext {
    if(choice == -1) {
        [unWineAlertView showAlertViewWithTitle:@"Merging" message:@"Please select the field that best represents this wine."];
        return;
    }
    
    if([self.fields count] > 1) {
        //if not final then instantiate new viewcontroller, pass variables, progress logic
        
        CastMergeTVC *mergeNext = [self.storyboard instantiateViewControllerWithIdentifier:@"merge"];
        mergeNext.wines = self.wines;
        mergeNext.progress = self.progress;
        mergeNext.wine = self.wine;
        
        [self.wine setValue:[[self.progress objectForKey:field] objectAtIndex:choice] forKey:field];
        [self.fields removeObject:field];
        mergeNext.fields = self.fields;
        
        [self.navigationController pushViewController:mergeNext animated:YES];
    } else {
        [self nextFinalize:1];
        //else save Merge records, delete irrelevant wines, dismiss overlayed nav controller, research database on results page
    }
}

- (void) nextFinalize:(NSInteger)responseCode {
    [self.wine saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
        NSMutableArray *mergedWineIds = [[NSMutableArray alloc] init];
        for(NSUInteger i = 1; i < [self.wines count]; i++) {
            PFObject *mergedWine = [self.wines objectAtIndex:i];
            [mergedWineIds addObject:[mergedWine objectId]];
            
            PFQuery *rerouting = [PFQuery queryWithClassName:@"NewsFeed"];
            [rerouting whereKey:@"unWinePointer" equalTo:mergedWine];
            [rerouting findObjectsInBackgroundWithBlock:^(NSArray *checkins, NSError *error) {
                for(PFObject *checkin in checkins) {
                    checkin[@"unWinePointer"] = self.wine;
                    [checkin saveInBackground];
                }
                
                PFObject *mergeRecord = [PFObject objectWithClassName:@"Merges"];
                mergeRecord[@"merger"] = [User currentUser];
                mergeRecord[@"wine"] = self.wine;
                mergeRecord[@"oldWineObjectId"] = [mergedWine objectId];
                [mergeRecord saveInBackground];
                
                [mergedWine deleteInBackground];
            }];
            
            PFQuery *rerouting2 = [PFQuery queryWithClassName:@"Scan"];
            [rerouting2 whereKey:@"wine" equalTo:mergedWine];
            [rerouting2 findObjectsInBackgroundWithBlock:^(NSArray *scans, NSError *error) {
                for(PFObject *scan in scans) {
                    scan[@"wine"] = self.wine;
                    [scan saveInBackground];
                }
            }];
            
            PFQuery *rerouting3 = [PFQuery queryWithClassName:@"Records"];
            [rerouting3 whereKey:@"wine" equalTo:mergedWine];
            [rerouting3 findObjectsInBackgroundWithBlock:^(NSArray *records, NSError *error) {
                for(PFObject *record in records) {
                    record[@"wine"] = self.wine;
                    [record saveInBackground];
                }
            }];
        }
        
        if(self.delegate != nil) {
            CastScannerVC *scanner = [self.delegate getCastScannerVC];
            PFObject* scanned = scanner.scanned;
            
            if(scanned != nil) {
                PFQuery *query = [PFQuery queryWithClassName:@"Scan"];
                [query whereKey:@"type" equalTo:scanned[@"type"]];
                [query whereKey:@"code" equalTo:scanned[@"code"]];
                [query includeKey:@"wine"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *response, NSError *error) {
                    if(!error) {
                        NSMutableArray *collective = [[NSMutableArray alloc] init];
                        for(PFObject *scan in response) {
                            BOOL passing = YES;
                            for(NSString *objectId in mergedWineIds)
                                if(scan[@"wine"] == nil || [[scan[@"wine"] objectId] isEqualToString:objectId])
                                    passing = NO;
                            
                            if(passing)
                               [collective addObject:scan];
                        }
                        
                        [self doAnalytic];
                        [self.delegate updateScannerResults:[CastScannerVC filterDuplicateScans:collective]];
                        [self.delegate mergeComplete:responseCode];
                    }
                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }];
            } else {
                [self doAnalytic];
                [self.delegate mergeComplete:responseCode];
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        } else
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void) doAnalytic {
    /*
    PFObject *object = [PFObject objectWithClassName:@"Scanalytics"];
    object[@"user"] = [User currentUser];
    object[@"event"] = @"mergeComplete";
    object[@"attachedWine"] = self.wine;
    [object saveEventually];
    */
    [Analytics trackUserMergedWine:self.wine];
}

@end
