//
//  castCheckInVC.m
//  unWine
//
//  Created by Bryce Boesen on 2/1/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CastScannerVC.h"

#define NO_SCAN_WIDTH 130
#define NO_SCAN_HEIGHT 38
#define OUTLINE_WIDTH 256
#define OUTLINE_HEIGHT 256
#define RESULT_BUFFER 15

@interface CastScannerVC ()

@property (nonatomic) UIView *preview;
@property (nonatomic) NSMutableArray *uniqueCodes;
@property (nonatomic) UIButton *noScan;
@property (nonatomic) UIImageView *outline;
@property (nonatomic) UILabel *protipLabel;
//@property (nonatomic) UIImageView *background;

@end

@implementation CastScannerVC {
    BOOL firstLoad, cannotScan;
}
@synthesize scanner, preview, noScan, outline, results, scanned, protipLabel;

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(revert)];
    [[self navigationItem] setBackBarButtonItem:back];
    self.navigationItem.leftBarButtonItem = back;
    
    preview = [[UIView alloc] initWithFrame:self.view.frame];
    //CGRectMake(0, 20 + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREENHEIGHT - 20 - NAVIGATION_BAR_HEIGHT)
    //LOGGER(@"scanner frames");
    //NSLog(@"%@", NSStringFromCGRect(preview.frame));
    //NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    preview.backgroundColor = [UIColor blackColor];
    
    //[self setupOutline];
    //[self.view addSubview:outline];
    
    [self.view addSubview:preview];
    //[self.view bringSubviewToFront:noScan];
    //[self.view bringSubviewToFront:outline];
    
    [self startScan];
    
    [self setupAppearance];
    
    GET_TAB_BAR.userIsOnScanner = YES;
    //LOGGER(NSStringFromCGRect(preview.frame));
}

- (void)revert {
    GET_TAB_BAR.userIsOnScanner = NO;
    _backFromResults = NO;
    //[customTabBarController showTabBar:self.tabBarController];
    //[self.tabBarController.tabBar setHidden:NO];
    //[self.tabBarController setSelectedIndex:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNoScan];
    if(![noScan superview])
        [self.navigationController.view addSubview:noScan];
    
    if(self.backFromResults && cannotScan) {
        self.backFromResults = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    //[customTabBarController hideTabBar:self.tabBarController];
    //if(!self.backFromResults)
    //    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[customTabBarController hideTabBar:self.tabBarController];
    //[self.tabBarController.tabBar setHidden:YES];
    
    if(firstLoad) {
        if(preview != nil && [preview isDescendantOfView:self.view])
            [self startScan];
    }
    
    firstLoad = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    if([noScan superview])
        [noScan removeFromSuperview];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self.tabBarController.tabBar setHidden:NO];
    }
    
    [super viewWillDisappear:animated];
}

- (void)setupNoScan {
    if(noScan == nil) {
        noScan = [UIButton buttonWithType:UIButtonTypeCustom];
    
        [noScan setFrame:CGRectMake(SEMIWIDTH(self.view) - NO_SCAN_WIDTH / 2, 64 + 20, NO_SCAN_WIDTH, NO_SCAN_HEIGHT)];
        
        [noScan.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [noScan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [noScan setTitle:@"No Barcode?" forState:UIControlStateNormal];
        [noScan setBackgroundColor:[UIColor colorWithRed:.15 green:.15 blue:.15 alpha:.5]];
        
        noScan.layer.cornerRadius = 12;
        noScan.layer.borderColor = [[UIColor whiteColor] CGColor];
        noScan.layer.borderWidth = 1.0f;
        noScan.layer.zPosition = 1001;
        
        [noScan addTarget:self action:@selector(noBarCodeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    } else
        noScan.alpha = 1;
}

- (void)noBarCodeButtonPressed {
    ANALYTICS_TRACK_EVENT(EVENT_PRESSED_NO_BAR_CODE_BUTTON);
    [self processData];
}

- (void) setupOutline {
    if(outline == nil)
        outline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scanner-outline"]];
    else
        outline.alpha = 1;
    
    [outline setFrame:CGRectMake(SEMIWIDTH(self.view) - OUTLINE_WIDTH / 2,
                                 SEMIHEIGHT(self.view) - NAVIGATION_BAR_HEIGHT
                                 - OUTLINE_HEIGHT / 2 - STATUS_BAR_HEIGHT,
                                 OUTLINE_WIDTH, OUTLINE_HEIGHT)];
    outline.layer.zPosition = 1001;
    outline.layer.borderWidth = 300;
    outline.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:.2] CGColor];
}

- (BOOL)prefersStatusBarHidden {
    return NO; //(preview.alpha == 1);
}

- (void)stopScan {
    //self.preview.alpha = .99;
    [self.scanner stopScanning];
    [UIView animateWithDuration:.08 animations:^{
        noScan.alpha = 0;
        outline.alpha = 0;
        //background.alpha = 1;
    } completion:^(BOOL finished) {
        NSLog(@"Show Results");
    }];
}

- (void)startScan {
    preview.alpha = 1;
    noScan.alpha = 1;
    //background.alpha = 0;
    
    scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:preview];
    self.uniqueCodes = [[NSMutableArray alloc] init];
    scanned = nil;
    
    if([scanner isScanning])
        return;
    
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            outline.alpha = 1;
            //[scanner refreshVideoOrientation];
            NSLog(@"Camera Enabled.");
            
            [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Scanning... %@", codes);
                    for (AVMetadataMachineReadableCodeObject *code in codes) {
                        //NSLog(@"%@", code.corners);
                        if ([self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                            [self.uniqueCodes addObject:code.stringValue];
                            NSLog(@"Found unique code: %@, %@", code.type, code.stringValue);
                            
                            scanned = [PFObject objectWithClassName:@"Scan"];
                            scanned[@"type"] = code.type;
                            scanned[@"code"] = code.stringValue;
                            
                            PFQuery *query = [PFQuery queryWithClassName:@"Scan"];
                            [query whereKey:@"type" equalTo:code.type];
                            [query whereKey:@"code" equalTo:code.stringValue];
                            [query includeKey:@"wine"];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *response, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(!error) {
                                        NSLog(@"Found object %@", response);
                                        [self processData:response];
                                    } else {
                                        [self processData];
                                        //NSLog(@"Ress: %@", response);
                                    }
                                });
                            }];
                            //NSLog(@"%@", code.corners);
                        }
                    }
                //});
            }];
        } else { //Denied access to camera, default next page
            cannotScan = YES;
            ANALYTICS_TRACK_EVENT(EVENT_USER_DENIED_ACCESS_TO_CAMERA_AND_CANNOT_SCAN);
            outline.alpha = 0;
            [self processData:nil];
        }
        });
    }];
    
    [self performSelector:@selector(showProtip) withObject:nil afterDelay:4.2];
}

- (void)showProtip {
    if(protipLabel == nil)
        protipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHT(self.view) - 50, WIDTH(self.view), 40)];
    
    protipLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    protipLabel.textAlignment = NSTextAlignmentCenter;
    protipLabel.textColor = [UIColor whiteColor];
    protipLabel.numberOfLines = 0;
    [protipLabel setText:@"unWine Pro Tip: Try turning your phone!"];
    
    [self.view addSubview:protipLabel];
    [self.view bringSubviewToFront:protipLabel];
    
    [self performSelector:@selector(hideProtip) withObject:nil afterDelay:7.8];
}

- (void)hideProtip {
    [protipLabel removeFromSuperview];
}

//- (BOOL)hidesBottomBarWhenPushed {
//    return YES;
//}

- (void) processData {
    [self processData:[NSArray new]];
}

+ (NSMutableArray *)filterDuplicateScans:(NSArray *)response {
    NSMutableSet *uniqueIds = [[NSMutableSet alloc] init];
    NSMutableArray *scannedWines = [[NSMutableArray alloc] init];
    if(response != nil) {
        for(PFObject *scan in response) {
            if(scan[@"wine"] != nil) {
                NSLog(@"scanned %@", scan[@"wine"]);
                if(![uniqueIds containsObject:[scan[@"wine"] objectId]]) {
                    [uniqueIds addObject:[scan[@"wine"] objectId]];
                    [scannedWines addObject:scan[@"wine"]];
                }
            }
        }
    }
    
    return scannedWines;
}

- (void) processData:(NSArray *)response {
    [self.scanner stopScanning];
    
    if(scanned != nil)
        [Analytics trackUserScannedWine];
    
    results = [self.storyboard instantiateViewControllerWithIdentifier:@"results"];
    
    NSMutableArray *scannedWines = [CastScannerVC filterDuplicateScans:response];
    
    if (scannedWines.count) {
        ANALYTICS_TRACK_EVENT(EVENT_SCANNED_WINE_AND_NO_RESULTS);
    }
    
    results.scannerResults = (scannedWines.count > 0) ? scannedWines : nil;
    results.results = (scannedWines.count > 0) ? scannedWines : nil;
    //results.scanned = scanned;
    results.delegate = self;
    
    [self.navigationController pushViewController:results animated:YES];
}

- (void)setupAppearance {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Back";
    self.title = @"Back";
    
    self.tabBarController.tabBar.translucent = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"unwinewhitelogo22.png"]];
    self.navigationItem.titleView = imageView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
