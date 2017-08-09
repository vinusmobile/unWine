//
//  WineTVC.m
//  unWine
//
//  Created by Bryce Boesen on 3/3/16.
//  Copyright © 2016 LION Mobile. All rights reserved.
//

#import "WineTVC.h"
#import "CheckinInterface.h"
#import "WineNameCell.h"
#import "WineDetailCell.h"
#import "PHFComposeBarView.h"

#define WINE_NAME_TAG 1001

@interface WineTVC () <WineNameCellDelegate, WineDetailCellDelegate, PHFComposeBarViewDelegate>

@property (nonatomic, strong) PHFComposeBarView *composeBarView;

@end

@implementation WineTVC {
    UIButton *lastEdit;
    UITextView *shadowField;
    User *edittor;
    NSMutableArray *_cells;
    BOOL active;
    NSInteger activeField;
}
@synthesize singleTheme;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    singleTheme = unWineThemeDark;
    
    self.tableView.backgroundColor = [ThemeHandler getDeepBackgroundColor:singleTheme];
    self.tableView.separatorColor = [ThemeHandler getSeperatorColor:singleTheme];//[UIColor clearColor];
    self.tableView.tintColor = [ThemeHandler getForegroundColor:singleTheme];
    self.tableView.clipsToBounds = NO;
    //self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    //self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    [self.tableView registerClass:[WineNameCell class] forCellReuseIdentifier:@"WineNameCell"];
    [self.tableView registerClass:[WineDetailCell class] forCellReuseIdentifier:@"WineDetailCell"];
    
    self.tableView.tableHeaderView = [self getLastEdittedView];
    
    shadowField = [[UITextView alloc] initWithFrame:CGRectZero];
    shadowField.delegate = self;
    shadowField.inputAccessoryView = self.composeBarView = [self makeComposeBarView];
    [self.view addSubview:shadowField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    active = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    active = NO;
    [self.composeBarView resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //if(self.parentViewController)
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (NSArray *)getCellList:(BOOL)refresh {
    if(!_cells || refresh) {
        if(!_cells)
            _cells = [[NSMutableArray alloc] init];
        else
            [_cells removeAllObjects];
        
        [_cells addObject:[NSArray arrayWithObjects:@(WineCellsBasicName), nil]];
        [_cells addObject:[NSArray arrayWithObjects:@(WineCellsBasicDetail), @(WineCellsBasicDetail), @(WineCellsBasicDetail),  @(WineCellsBasicDetail), nil]];
    }
    
    return _cells;
}

#pragma Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self getCellList:YES] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 8)];
    footer.backgroundColor = [UIColor clearColor];
    
    if(section < [self numberOfSectionsInTableView:tableView] - 1) {
        CALayer *border = [CALayer layer];
        border.backgroundColor = [[ThemeHandler getSeperatorColor:singleTheme] CGColor];
        border.frame = CGRectMake(2, 8 - .5, SCREEN_WIDTH - 4, .5);
        [footer.layer addSublayer:border];
    }
    
    return footer;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self getCellList:NO] objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellList = [self getCellList:NO];
    NSArray *sectionCells = [cellList objectAtIndex:indexPath.section];
    WineCells cell = (WineCells)[[sectionCells objectAtIndex:indexPath.row] integerValue];
    
    if(cell == WineCellsBasicName) {
        return [[self getNameCell:indexPath] getAppropriateHeight];
    } else if(cell == WineCellsBasicDetail) {
        return [[self getDetailCell:indexPath] getAppropriateHeight];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellList = [self getCellList:NO];
    NSArray *sectionCells = [cellList objectAtIndex:indexPath.section];
    WineCells cell = (WineCells)[[sectionCells objectAtIndex:indexPath.row] integerValue];
    if(cell == WineCellsBasicName) {
        return [self getNameCell:indexPath];
    } else if(cell == WineCellsBasicDetail) {
        return [self getDetailCell:indexPath];
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if(self.isEditingWine) {
        //TODO present shadowField keyboard
        if([cell isKindOfClass:[WineNameCell class]]) {
            WineNameCell *name = (WineNameCell *)cell;
            self.composeBarView.text = [name getLabelText];
            activeField = WINE_NAME_TAG;
            [shadowField becomeFirstResponder];
        } else if([cell isKindOfClass:[WineDetailCell class]]) {
            WineDetailCell *detail = (WineDetailCell *)cell;
            self.composeBarView.text = [detail getLabelText];
            activeField = detail.detail;
            [shadowField becomeFirstResponder];
        }
    } else {
        if([cell isKindOfClass:[WineDetailCell class]]) {
            WineDetailCell *detail = (WineDetailCell *)cell;
            if(detail.detail == WineDetailVineyard) {
                SHOW_HUD_FOR_VIEW(self.parent.view);
                [[Winery findFirstCreateIfNecessary:[self.wine.vineyard lowercaseString]] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
                    HIDE_HUD_FOR_VIEW(self.parent.view);
                    if(task.result) {
                        WineryContainerVC *winery = [[WineryContainerVC alloc] init];
                        winery.winery = task.result;
                        [self.parent.navigationController pushViewController:winery animated:YES];
                    }
                    
                    if(task.error)
                        LOGGER(task.error);
                     
                    return nil;
                }];
            } else if(detail.detail == WineDetailRegion) {
                NSString *region = [self.wine.region capitalizedString];
                
                SearchTVC *search = [[SearchTVC alloc] init];
                search.mode = SearchTVCModeRegion;
                search.presearch = region;
                [self.navigationController pushViewController:search animated:YES];
            }
        }
    }
}

#pragma TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(activeField == WineDetailPrice) {
        self.composeBarView.textView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    } else
        self.composeBarView.textView.keyboardType = UIKeyboardTypeDefault;
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIScrollView *scrollView = self.parent.parallaxView.scrollView;
    CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height);
    [scrollView setContentOffset:bottomOffset animated:YES];
    
    [self.composeBarView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(textView != shadowField) {
        NSString *text = [[textView.text lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(activeField != WINE_NAME_TAG)
            [self.parent setWineDetail:(WineDetail)activeField toText:text];
        else
            [self.parent setWineName:text];
    }
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    [composeBarView resignFirstResponder];
}

#pragma Views and Cells

- (PHFComposeBarView *)makeComposeBarView {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, PHFComposeBarViewInitialHeight);
    PHFComposeBarView *composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
    
    [composeBarView setMaxCharCount:200];
    [composeBarView setMaxLinesCount:5];
    [composeBarView setPlaceholder:@"Type something..."];
    [composeBarView setDelegate:self];
    composeBarView.buttonTitle = @"Done";
    composeBarView.buttonTintColor = UNWINE_RED;
    composeBarView.tintColor = UNWINE_RED;
    
    composeBarView.textView.returnKeyType = UIReturnKeyDone;
    
    return composeBarView;
}

- (UIView *)getLastEdittedView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, -32)];
    view.clipsToBounds = NO;
    [view setTintColor:[ThemeHandler getForegroundColor:unWineThemeDark]];
    
    if(!lastEdit) {
        lastEdit = [UIButton buttonWithType:UIButtonTypeSystem];
        lastEdit.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:-.35];
        [lastEdit setFrame:CGRectMake(0, -32, WIDTH(view), 32)];
        [lastEdit setImage:SMALL_COG_ICON forState:UIControlStateNormal];
        [lastEdit setTintColor:[ThemeHandler getForegroundColor:unWineThemeDark]];
        [lastEdit.imageView setTintColor:[ThemeHandler getForegroundColor:unWineThemeDark]];
        [lastEdit.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [lastEdit.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [lastEdit.titleLabel setTintColor:[ThemeHandler getForegroundColor:unWineThemeDark]];
        [lastEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lastEdit setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [lastEdit setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [lastEdit addTarget:self action:@selector(viewEdits:) forControlEvents:UIControlEventTouchUpInside];
        [self setLastEditText:@"N/A"];
        [self configureLastEdit];
        [view addSubview:lastEdit];
    }
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (WineNameCell *)getNameCell:(NSIndexPath *)indexPath {
    WineNameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WineNameCell"];
    cell.delegate = self;
    cell.isEditing = self.isEditingWine;
    
    [cell setup:indexPath];
    [cell configure:self.wine];
    
    return cell;
}

- (WineDetailCell *)getDetailCell:(NSIndexPath *)indexPath {
    WineDetailCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WineDetailCell"];
    cell.delegate = self;
    cell.isEditing = self.isEditingWine;
    
    [cell setup:indexPath];
    [cell configure:self.wine detail:(WineDetail)indexPath.row];
    
    return cell;
}

#pragma Last Editted


- (BFTask *)getLastEdit {
    return [[self getRecords] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [BFTask taskWithResult:task.result && [task.result count] > 0 ? [task.result objectAtIndex:0] : nil];
    }];
}

- (BFTask *)getRecords {
    if(!self.parent.isNew) {
        PFRelation *history = self.wine.history;
        
        PFQuery *historyQuery = [history query];
        [historyQuery orderByDescending:@"updatedAt"];
        [historyQuery includeKey:@"editor"];
        return [historyQuery findObjectsInBackground];
    } else
        return [BFTask taskWithResult:nil];
}

- (void)configureLastEdit {
    [[self getLastEdit] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        PFObject *last = task.result;
        if(last == nil) {
            if(self.parent.registers != nil && [self.parent.registers count] > 0)
                [self setLastEditText:@"You"];
            else
                [self setLastEditText:@"N/A"];
        } else {
            edittor = last[@"editor"];
            [self setLastEditText:[edittor getShortName]];
        }
        return nil;
    }];
}

- (void)setLastEditText:(NSString *)name {
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:13];
    UIFont *boldFont = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:@""];
    [formatted appendAttributedString:[self makeAttributed:@"Wine last edited by " font:font]];
    [formatted appendAttributedString:[self makeAttributed:ISVALID(name) ? name : @"N/A" font:boldFont]];
    
    [lastEdit setAttributedTitle:formatted forState:UIControlStateNormal];
    lastEdit.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (NSAttributedString *)makeAttributed:(NSString *)string font:(UIFont *)font {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    return [[NSAttributedString alloc] initWithString:string attributes:dict];
}

- (void)viewEdits:(UIButton *)sender {
    LOGGER(@"edits");
    //show old Edits VC or user's profile
    
    if(edittor) {
        CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
        [profile setProfileUser:edittor];
        [self.parent.navigationController pushViewController:profile animated:YES];
    }
}

#pragma Edit Stuff

/*- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    
}*/

#pragma Delegate Stuff

- (void)updateTheme {
}

@end
