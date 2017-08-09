//
//  ScannerVC.m
//  unWine
//
//  Created by Fabio Gomez on 4/24/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

//
//  TGInitialViewController.m
//  TGCameraViewController
//
//  Created by Bruno Furtado on 15/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//

#import "Scanner.h"
#import <TGCameraViewController/TGCameraViewController.h>
#import <CloudSight/CloudSight.h>
#import "WineContainerVC.h"
#import "VineCastTVC.h"
#import "SlackHelper.h"
#import "MBProgressHUD+Emojis.h"

@interface Scanner () <TGCameraDelegate, CloudSightQueryDelegate, unWineAlertViewDelegate>

@property (nonatomic, strong) TGCameraNavigationController *scanner;
@property (nonatomic, strong) CloudSightQuery *query;
@property (nonatomic, strong) UIImage *scannedImage;
@property (nonatomic, strong) NSString *scanningResultText;
@property (nonatomic, strong) UIView *photoSelectView;
@property (nonatomic, strong) NSDate *methodStart;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) NSInteger failCount;


@end



@implementation Scanner

- (id)init
{
    self = [super init];
    // set custom tint color
    [TGCameraColor setTintColor: UNWINE_RED];
    //[TGCameraColor setTintColor: UNWINE_RED_LIGHT];
    
    // save image to album
    //[TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:@YES];
    
    // use the original image aspect instead of square
    //[TGCamera setOption:kTGCameraOptionUseOriginalAspect value:@YES];
    
    // hide switch camera button
    [TGCamera setOption:kTGCameraOptionHiddenToggleButton value:@YES];
    
    // hide album button
    //[TGCamera setOption:kTGCameraOptionHiddenAlbumButton value:@YES;
    
    // hide filter button
    [TGCamera setOption:kTGCameraOptionHiddenFilterButton value:@YES];
    
    
    /*UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
     target:self
     action:@selector(clearTapped)];
     
     self.navigationItem.rightBarButtonItem = clearButton;
     */
    
    self.scanner = [TGCameraNavigationController newWithCameraDelegate:self];
    self.failCount = 0;
    
    return self;
}

- (void)showScanner {
    [self clearStuff];
    [self.delegate presentViewController:self.scanner animated:YES completion:^{
        // Check if user has seen scanner
        // UserDefaults.standard.set(true, forKey: kFirstLeftSwipe)
        //(UserDefaults.standard.object(forKey: kFirstTime) == nil)
        static NSString *kHasSeenScanner = @"HasSeenScanner";
        BOOL seen = [[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenScanner];
        
        if (!seen) {
            LOGGER(@"User has not seen scanner. Showing usage pop up");
            [unWineAlertView showAlertViewWithTitle:@"Welcome to the Wine Scanner!" message:@"Please take a photo of the wine bottle with the label facing front."];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasSeenScanner];
        } else {
            LOGGER(@"User HAS seen scanner before, do nothing");
        }
    }];
}

- (void)clearStuff {
    self.scannedImage = nil;
    self.scanningResultText = nil;
}

#pragma mark -
#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    LOGGER(@"Enter");
    [self clearStuff];
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_CANCELLED_SCANNING);
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    LOGGER(@"Enter");
    [self scanPhoto:image];
    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_TOOK_PHOTO);
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    LOGGER(@"Enter");
    [self scanPhoto:image];
    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_SELECTED_EXISTING_PHOTO);
}

- (void)scanPhoto:(UIImage *)image {
    
    // Scan
    // Search
    // Show WineContainer using 1st record
    LOGGER(@"Enter");
    self.scannedImage = image;
    self.photoSelectView = [self.scanner.viewControllers objectAtIndex:1].view;
    self.hud = SHOW_HUD_FOR_VIEW(self.photoSelectView);
    self.hud.label.text = @"Uploading photo...";
    //[self.hud addLoadMessage];
    
    // We recommend sending a JPG image no larger than 1024x1024 and with a 0.7-0.8 compression quality,
    // you can reduce this on a Cellular network to 800x800 at quality = 0.4
    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
    
    // Create the actual query object
    self.query = [[CloudSightQuery alloc] initWithImage:imageData
                                             atLocation:CGPointZero
                                           withDelegate:self
                                            atPlacemark:nil
                                           withDeviceId:nil];
    
    // Track time
    self.methodStart = [NSDate date];
    
    // Start the query process
    [self.query start];
    
}

- (void)showErrorAlert:(NSError *)error scanner:(BOOL)isScanner {
    LOGGER(error.localizedDescription);
    unWineAlertView *alertView = [[unWineAlertView sharedInstance]
                                  prepareWithMessage:@"We're not sure about this wine!"];
    alertView.theme = unWineAlertThemeError;
    alertView.title = @"😳";
    alertView.leftButtonTitle = @"Search 🔍";
    alertView.rightButtonTitle = @"Retake 📷";
    
    alertView.delegate = self;
    [alertView show];
    
    NSString *errorTitle = isScanner ? @"Error scanning wine" : @"Error finding scanned wine";
    [Analytics trackError:error withName:errorTitle withMessage:error.domain];
}

#pragma mark Slack
- (void)sendCloudSightDebuggingToSlack:(CloudSightQuery *)query withError:(NSError *)error {
    
    NSString *token = query.token;
    NSTimeInterval execTime = [self getExecutionTime];

    NSData *imgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation((self.scannedImage), 0.4)];
    NSUInteger imageSize = imgData.length;

    NSString *title = query.title;
    NSString *skipReason = query.skipReason;
    NSString *remoteURL = query.remoteUrl;
    
    NSString *message = [NSString stringWithFormat:@"Token = %@ \nExecution Time = %f seconds", token, execTime];
    NSString *color = SLACK_GOOD;
    
    if (imageSize) {
        message = [message stringByAppendingFormat:@"\nImage size = %lu bytes", (unsigned long)imageSize];
    }
    
    if (title) {
        message = [message stringByAppendingFormat:@"\nTitle = %@", title];
    }
    
    if (skipReason) {
        message = [message stringByAppendingFormat:@"\nSkip Reason = %@", skipReason];
        color = SLACK_WARNING;
    }
    
    if (remoteURL) {
        message = [message stringByAppendingFormat:@"\nRemote URL = %@", remoteURL];
    }
    
    if (error) {
        message = [message stringByAppendingFormat:@"\nError = %@", error.description];
        color = SLACK_DANGER;
    }
    
    [SlackHelper sendCloudSightMessage:message withColor:color];
}

#pragma mark CloudSightQueryDelegate

- (void)cloudSightQueryDidFail:(CloudSightQuery *)query withError:(NSError *)error {
    HIDE_HUD_FOR_VIEW(self.photoSelectView);
    NSLog(@"Error: %@", error);
    [self clearStuff];
    [self showErrorAlert:error scanner:YES];
    [self sendCloudSightDebuggingToSlack:query withError:error];
    ANALYTICS_TRACK_EVENT(EVENT_CLOUDSIGHT_ERROR);
}

- (NSTimeInterval )getExecutionTime {
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:self.methodStart];
    return executionTime;
}

- (void)cloudSightQueryDidFinishIdentifying:(CloudSightQuery *)query {
    LOGGER(@"Enter");
    NSString *s = [NSString stringWithFormat:@"executionTime = %f", [self getExecutionTime]];
    LOGGER(s);
    
    if (query.skipReason != nil) {
        NSLog(@"Skipped: %@", query.skipReason);
        self.failCount += 1;
        
        if (self.failCount < 3) {
            LOGGER(@"Trying scanning again");
            [self scanPhoto:self.scannedImage];
        } else {
            HIDE_HUD_FOR_VIEW(self.photoSelectView);
            NSError *error = [[NSError alloc] initWithDomain:@"Scanner Tried 3 times" code:1 userInfo:nil];
            [self showErrorAlert:error scanner:YES];
            [self sendCloudSightDebuggingToSlack:query withError:error];
            ANALYTICS_TRACK_EVENT(EVENT_CLOUDSIGHT_RETURNED_NO_RESULTS);
        }
        
        return;
    }
    
    [self sendCloudSightDebuggingToSlack:query withError:nil];
    
    self.scanningResultText = query.title;
    s = [NSString stringWithFormat:@"Identified: %@", query.title];
    LOGGER(s);
    
    ANALYTICS_TRACK_EVENT(EVENT_CLOUDSIGHT_SUCCESSFULLY_SCANNED);

    self.hud.label.text = @"Finding wine...";
    [[unWine findTask:query.title] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        HIDE_HUD_FOR_VIEW(self.photoSelectView);
        
        if (t.error) {
            [self showErrorAlert:t.error scanner:NO];
            return nil;
        }
        
        NSMutableArray *wines = (NSMutableArray *)t.result;
        NSString *s = [NSString stringWithFormat:@"Found %lu wines", (unsigned long)wines.count];
        LOGGER(s);
        
        [self.scanner dismissViewControllerAnimated:YES completion:^{
            if (wines.count <= 0) {
                LOGGER(@"Passed but no results");
                [self showAddWine];

            } else if (wines.count == 1) {
                LOGGER(@"Pushing Wine Container");
                [self pushWineContainerVC:wines];
                
            } else {
                LOGGER(@"Pushing SearchTVC");
                [self pushSearchTVC:wines];
            }
        }];
        
        return nil;
    }];
    
}

#pragma mark - User Actions

- (void)showAddWine {
    LOGGER(@"Enter");
    unWine *newWine = [unWine object];
    newWine.capitalizedName = self.scanningResultText.capitalizedString;
    newWine.image = [PFFile fileWithName:@"image.jpeg" data:UIImageJPEGRepresentation(self.scannedImage, 1)];
    
    NSDictionary *dict = @{
                           @"capitalizedName": newWine.capitalizedName,
                           @"image": newWine.image};
    
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = newWine;
    container.theWineImage = self.scannedImage;
    container.isNew = YES;
    container.registers = [[NSMutableDictionary alloc] initWithDictionary:dict];
    container.cameFrom = CastCheckinSourceScanner;
    
    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_RETURNED_NO_RESULTS);
    [self.delegate.navigationController pushViewController:container animated:YES];
}

- (void)pushWineContainerVC:(NSArray *)wines {
    LOGGER(@"Enter");
    unWine *wine = [wines objectAtIndex:0];
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = wine;
    container.isNew = NO;
    container.bidirectional = NO;
    container.cameFrom = CastCheckinSourceSomewhere;

    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_RETURNED_SINGLE_RESULT);
    [self.delegate.navigationController pushViewController:container animated:YES];
}

- (void)pushSearchTVC:(NSArray *)wines {
    LOGGER(@"Enter");
    SearchTVC *svc = [[SearchTVC alloc] init];
    svc.state = SearchTVCStateSearched;
    svc.mode = SearchTVCModeWines;
    svc._results = wines;
    
    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_RETURNED_MULTIPLE_RESULTS);
    [self.delegate.navigationController pushViewController:svc animated:YES];
}


#pragma mark -
#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark -
#pragma mark - unWineAlertViewDelegate
- (void)leftButtonPressed {
    LOGGER(@"Enter");
    [self.scanner dismissViewControllerAnimated:YES completion:^{
        SearchTVC *svc = [[SearchTVC alloc] init];
        svc.state = SearchTVCStateDefault;
        svc.mode = SearchTVCModeWines;
        
        ANALYTICS_TRACK_EVENT(EVENT_SCANNER_PRESSED_SEARCH_BUTTON);
        [self.delegate.navigationController pushViewController:svc animated:YES];
    }];
}

- (void)rightButtonPressed {
    LOGGER(@"Enter");
    [self clearStuff];
    ANALYTICS_TRACK_EVENT(EVENT_SCANNER_PRESSED_RETRY_BUTTON);
    [self.scanner popToRootViewControllerAnimated:YES];
}

@end
