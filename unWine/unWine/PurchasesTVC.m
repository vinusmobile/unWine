//
//  PurchasesTVC.m
//  unWine
//
//  Created by Fabio Gomez on 10/15/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "PurchasesTVC.h"
#import <StoreKit/StoreKit.h>
#import "unWineAlertView.h"
#import "SKProduct+priceAsString.h"
#import "PopoverVC.h"
#import "SlackHelper.h"

@interface PurchasesTVC () <SKProductsRequestDelegate, SKRequestDelegate, SKPaymentTransactionObserver> {
    NSMutableDictionary *_productMetadataDictionary;
    NSMutableDictionary *_productProgressDictionary;
    
    SKReceiptRefreshRequest *_receiptRequest;
    SKProductsRequest *_storeProductsRequest;
    
    NSMutableArray *_productIdentifiers;
}

@end

@implementation PurchasesTVC {
    UIImageView *background;
    UIButton *info;
    UIButton *restore;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style className:[PFProduct parseClassName]]) {
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = NO;
        
        _productMetadataDictionary = [NSMutableDictionary dictionary];
        _productProgressDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(dismiss)];
    [[self navigationItem] setBackBarButtonItem:back];
    self.navigationItem.leftBarButtonItem = back;
    
    self.grapesButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(showPurchases)];
    
    self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:nil];
    self.grapesButton.customView.userInteractionEnabled = NO;
    [Grapes userUpdateCurrency:^(NSInteger grapes) {
        self.grapesButton.customView = [Grapes getCustomView:[User currentUser].currency delegate:nil];
        self.grapesButton.customView.userInteractionEnabled = NO;
        self.navigationItem.rightBarButtonItem = self.grapesButton;
    }];
    
    background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkin-bg2.jpg"]];
    background.frame = self.navigationController.view.frame;
    background.layer.zPosition = -1;
    background.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[PurchaseCell class] forCellReuseIdentifier:@"PurchaseCell"];
    self.tableView.backgroundView = background;
    self.tableView.tintColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.6];
    
    [self appeareanceSetup];
    [self showPopover];
    [self addInfo];
    
    ANALYTICS_TRACK_EVENT(EVENT_FILTERS_USER_OPENED_IN_APP_PURCHASE_VIEW_CONTROLLER);
}

- (void)appeareanceSetup{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationItem.backBarButtonItem.title = @"Back";
    self.tableView.tableFooterView = [self makeFooterView];
    self.navigationItem.title = @"Redeem";
    
    self.tabBarController.tabBar.translucent = NO;
    
    // White Status Bar for controllers inside Navigation Controller
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack; // Not sure why this works lol
}

- (UIView *)makeFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
    view.backgroundColor = [UIColor clearColor];
    
    restore = [UIButton buttonWithType:UIButtonTypeSystem];
    [restore setFrame:CGRectMake(SEMIWIDTH(view) - 80, 6, 160, 36)];
    restore.backgroundColor = [UIColor whiteColor];
    restore.layer.borderWidth = 2;
    restore.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    restore.layer.cornerRadius = 6;
    restore.layer.masksToBounds = YES;
    restore.clipsToBounds = YES;
    [restore addTarget:self action:@selector(restoreIAP) forControlEvents:UIControlEventTouchUpInside];
    [restore setTitle:@"Restore Purchases" forState:UIControlStateNormal];
    [restore setTitleColor:UNWINE_RED forState:UIControlStateNormal];
    [view addSubview:restore];
    
    return view;
}

- (void)restoreIAP {
    //_receiptRequest = [[SKReceiptRefreshRequest alloc] init];
    //_receiptRequest.delegate = self;
    //[_receiptRequest start];
    SHOW_HUD;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    LOGGER(transactions);
    HIDE_HUD;
    for(SKPaymentTransaction *transaction in transactions) {
        PurchaseCell *cell = [self getCellWithIdentifier:transaction.transactionIdentifier];
        
        /*
        if(cell == nil) {
            [unWineAlertView showAlertViewWithBasicSuccess:@"Spilled some Wine!"];
            break;
        }*/
        
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                case SKPaymentTransactionStatePurchased: {
                    // user has purchased
                    //[self saveTransactionReceipt:transaction];
                    //[self unlockFullVersion];
                    // download content here if necessary
                    [SlackHelper notifyPhotoFiltersPurchased:[User currentUser] withMoney:YES];
                    [cell applyPurchaseAndReload:[User currentUser]];
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    break;
                }
                    
                case SKPaymentTransactionStateFailed: {
                    // transaction didn't work
                    //[self displayAlertViewWithMessage:@"There was a problem with your purchase. Please try again later."];
                    [unWineAlertView showAlertViewWithTitle:@"Spilled some wine" error:transaction.error];
                    break;
                }
                    
                case SKPaymentTransactionStateRestored: {
                    // purchase has been restored
                    [cell applyPurchaseAndReload:[User currentUser]];
                    //[unWineAlertView showAlertViewWithTitle:nil message:@"Purchases restored!"];
                    [unWineAlertView showAlertViewWithTitle:nil message:@"Purchases restored" theme:unWineAlertThemeSuccess];
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    break;
                }
                    
                    
                case SKPaymentTransactionStatePurchasing: {
                    // currently purchasing
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
}

- (PurchaseCell *)getCellWithIdentifier:(NSString *)identifier {
    for(NSInteger i = 0; i < [self.tableView numberOfSections]; i++) {
        for(NSInteger j = 0; j < [self.tableView numberOfRowsInSection:i]; j++) {
            PurchaseCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            if([[cell getProductIdentifier] isEqualToString:identifier])
                return cell;
        }
    }
    return nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    HIDE_HUD;
    NSString *title = NSLocalizedString(@"Download Error",
                                        @"Download Error");
    NSLog(@"%@ - %@", title, error);
    [unWineAlertView showAlertViewWithTitle:title error:error];
}

- (void)showPopover {
    if(![User hasSeen:WITNESS_ALERT_GRAPES] && ![[PopoverVC sharedInstance] isDisplayed]) {
        CGRect placer = CGRectMake(SCREEN_WIDTH - 60, 0, 60, 64);
        
        [[PopoverVC sharedInstance] showFrom:self.navigationController
                                  sourceView:self.navigationController.view
                                  sourceRect:placer
                                        text:@"Help unWine grow by harvesting your own grapes! Every time you add a wine to the database, you earn grapes! You can redeem your grapes to unlock more features!"];
        
        [User witnessed:WITNESS_ALERT_GRAPES];
    }
}

- (void)showPurchases {
    [Grapes showPurchases:self.navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)dismiss {
    [self removeInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissAsGuest {
    [self removeInfo];
    [self dismissViewControllerAnimated:YES completion:^{
        [[User currentUser] promptGuest:self];
    }];
}

- (void)addInfo {
    if(info == nil) {
        CGFloat dim = 64;
        info = [UIButton buttonWithType:UIButtonTypeInfoLight];
        info.tintColor = [UIColor whiteColor];
        [info setFrame:CGRectMake((SCREEN_WIDTH - dim) / 2, SCREENHEIGHT - dim - 16, dim, dim)];
        [info addTarget:self action:@selector(pressedInfo) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.view addSubview:info];
    }
}

- (void)removeInfo {
    [info removeFromSuperview];
}

- (void)pressedInfo {
    if(![[PopoverVC sharedInstance] isDisplayed]) {
        CGRect placer = info.frame;
        
        [[PopoverVC sharedInstance] showFrom:self.navigationController
                                  sourceView:self.navigationController.view
                                  sourceRect:placer
                                        text:@"Help unWine grow by harvesting your own grapes! Every time you add a wine to the database, you earn grapes! You can redeem your grapes to unlock more features!"];
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    if (error) {
        return;
    }
    
    //NSLog(@"purchases - %@", self.objects);
    
    _productIdentifiers = [[NSMutableArray alloc] init];
    
    [self.objects enumerateObjectsUsingBlock:^(PFProduct *product, NSUInteger idx, BOOL *stop) {
        // No download for this product - just continue
        [_productIdentifiers addObject:product.productIdentifier];
        if (!product.downloadName) {
            return;
        }
        
        [PFPurchase addObserverForProduct:product.productIdentifier block:^(SKPaymentTransaction *transaction) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            PurchaseCell *cell = (PurchaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            cell.state = PFPurchaseTableViewCellStateDownloading;
            [PFPurchase downloadAssetForTransaction:transaction
                                         completion:^(NSString *filePath, NSError *downloadError) {
                                             if (!downloadError) {
                                                 cell.state = PFPurchaseTableViewCellStateDownloaded;
                                                 
                                                 User *user = [User currentUser];
                                                 user.hasPhotoFilters = YES;
                                                 [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                     if(!error) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [cell reconfigure];
                                                         });
                                                     }
                                                 }];
                                             } else {
                                                 cell.state = PFPurchaseTableViewCellStateNormal;
                                                 
                                                 NSString *title = NSLocalizedString(@"Download Error",
                                                                                     @"Download Error");
                                                 NSLog(@"%@ - %@", title, downloadError);
                                                 [unWineAlertView showAlertViewWithTitle:title error:downloadError];
                                             }
                                         }
                                           progress:^(int percentDone) {
                                               _productProgressDictionary[product.productIdentifier] = @(percentDone);
                                               //[cell.progressView setProgress:percentDone/100.0f animated:YES];
                                           }];
        }];
    }];
    
    [self _queryStoreForProductsWithIdentifiers:[NSSet setWithArray:[_productIdentifiers copy]]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH(self.tableView), 40)];
    headerView.backgroundColor = UNWINE_GRAY_DARK;
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SEMIWIDTH(self.tableView), 40)];
    [headerTitle setText:@"Photos"];
    [headerTitle setTextColor:[UIColor whiteColor]];
    [headerTitle setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16]];
    
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PurchaseCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PurchaseCell"];
    
    PFProduct *object = [self.objects objectAtIndex:indexPath.row];
    cell.delegate = self;
    
    [cell setup:indexPath];
    [cell configure:object];
    
    return cell;
}

#pragma mark -
#pragma mark Data

- (NSString *)priceForProduct:(PFProduct *)product {
    LOGGER(_productMetadataDictionary);
    return _productMetadataDictionary[product.productIdentifier][PFProductMetadataPriceFormattedKey];
}

- (int)downloadProgressForProduct:(PFProduct *)product {
    return [_productProgressDictionary[product.productIdentifier] intValue];
}

#pragma mark -
#pragma mark PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [super queryForTable];
    [query orderByAscending:@"order"];
    return query;
}

#pragma mark -
#pragma mark Querying Store

- (void)_queryStoreForProductsWithIdentifiers:(NSSet *)identifiers {
    _storeProductsRequest.delegate = nil;
    _storeProductsRequest = nil;
    
    _storeProductsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    _storeProductsRequest.delegate = self;
    [_storeProductsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (request != _storeProductsRequest) {
        return;
    }
    
    NSArray *validProducts = response.products;
    if ([validProducts count] == 0) {
        return;
    }
    
    [validProducts enumerateObjectsUsingBlock:^(SKProduct *product,  NSUInteger idx, BOOL *stop) {
        NSDictionary *metadata = @{ PFProductMetadataPriceKey : product.price,
                                    PFProductMetadataPriceLocaleKey : product.priceLocale,
                                    PFProductMetadataPriceFormattedKey : [product priceAsString]};
        _productMetadataDictionary[product.productIdentifier] = metadata;
    }];
    NSLog(@"products - %@", _productMetadataDictionary);
    [self.tableView reloadData];
    
    _storeProductsRequest.delegate = nil;
}

- (void)requestDidFinish:(SKRequest *)request {
    _storeProductsRequest.delegate = nil;
    _storeProductsRequest = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    _storeProductsRequest.delegate = nil;
    _storeProductsRequest = nil;
}

@end