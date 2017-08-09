//
//  CastEditTVC.m
//  unWine
//
//  Created by Bryce Boesen on 6/9/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastEditTVC.h"
#import "CastProfileVC.h"

@implementation CastEditTVC {
    UIView *background;
}
@synthesize wine;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin-bg3.jpeg"]];
    background.frame = self.navigationController.view.frame;
    background.layer.zPosition = -1;
    background.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = background;
    [self basicAppeareanceSetup];
    
    if(wine != nil) {
        PFRelation *history = [wine relationForKey:@"history"];
        PFQuery *query = [history query];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"editor"];
        [query includeKey:@"wine"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            if(!error) {
                //NSLog(@"result %@", results);
                self.results = results;
                [self.tableView reloadData];
            }
        }];
    }
    
    self.tableView.estimatedRowHeight = DEFAULT_EDIT_CELL_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.results == nil)? 0 : [self.results count];
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if(indexPath.section > 1) {
        AWEditCell *cell = [[AWEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EditCell"];
    
        PFObject *history = [self.results objectAtIndex:indexPath.row];
        
        [cell setup:indexPath];
        [cell configure:history];
    
        return MAX(14 * 2 + HEIGHT(cell.historyLabel), DEFAULT_EDIT_CELL_HEIGHT);
    //} else
    //    return DEFAULT_EDIT_CELL_HEIGHT;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AWEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.clipsToBounds = YES;
    
    PFObject *history = [self.results objectAtIndex:indexPath.row];
    
    [cell setup:indexPath];
    [cell configure:history];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *history = [self.results objectAtIndex:indexPath.row];
    
    User *user = history[@"editor"];
    
    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    
    [profile setProfileUser:user];
    
    [self.navigationController pushViewController:profile animated:YES];
    
    /*UIStoryboard *profile = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    newProfileTabViewController *friendProfile = [profile instantiateViewControllerWithIdentifier:@"profileTabViewController"];
    
    friendProfile.gUser = user;
    
    [self.navigationController pushViewController: friendProfile animated:YES];*/
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
        
        UIColor *fadecolor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.338];
        UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:.64];
        
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

@end
