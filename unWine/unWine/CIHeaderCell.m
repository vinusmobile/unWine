//
//  CIHeaderCell.m
//  unWine
//
//  Created by Bryce Boesen on 4/27/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "CIHeaderCell.h"
#import "ImageFullVC.h"
#import "CastCheckinTVC.h"
#import "MediaHelper.h"
#import <ParseUI/ParseUI.h>
#import "CastOccasionTVC.h"

typedef enum PickerType {
    PICK_VINTAGE,
    PICK_OCCASION
} PickerType;

@import Photos;
@import AVFoundation;
@import MediaPlayer;
@implementation CIHeaderCell {
    UILabel *addPhotoLabel;
    NSArray *pickables;
    NSMutableDictionary *selectedRow;
    UITextField *shadowField;
    PickerType type;
    ImageFullVC *imageFullVC;
}
@synthesize delegate, hasSetup, myPath, wine, showSettings;
@synthesize wineImageView, selectVintage, selectOccasion, addLocation, shareFacebook, pickerView, numberToolbar;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setup:(NSIndexPath *)indexPath {
    myPath = indexPath;
    
    if(!hasSetup) {
        hasSetup = YES;
        selectedRow = [[NSMutableDictionary alloc] init];
        
        CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
        
        shadowField = [[UITextField alloc] init];
        
        CGRect pickerViewFrame = CGRectMake(0, HEIGHT(parent.navigationController.view) - 256, WIDTH(parent.navigationController.view), 256);
        UIView *viewForPickerView = [[UIView alloc] initWithFrame:pickerViewFrame];
        
        pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, pickerViewFrame.size.width, 216)];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        pickerView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.75];
        
        numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, WIDTH(self), 44)];
        numberToolbar.barStyle = UIBarStyleDefault;
        numberToolbar.tintColor = UNWINE_RED;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickerView)],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(completePickerView)],
                               nil];
        [numberToolbar sizeToFit];
        
        [viewForPickerView addSubview:pickerView];
        [viewForPickerView addSubview:numberToolbar];
        
        shadowField.inputView = viewForPickerView;
        [self addSubview:shadowField];
        
        self.wineImageView.backgroundColor = UNWINE_RED;
        self.wineImageView.layer.borderWidth = 2;
        self.wineImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.wineImageView.layer.cornerRadius = 6;
        self.wineImageView.layer.masksToBounds = YES;
        self.wineImageView.clipsToBounds = YES;
        
        [self.wineImageView setImage:ADD_WINE_PLACEHOLDER];
        [self.wineImageView setContentMode:UIViewContentModeCenter];
        
        UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
        self.wineImageView.userInteractionEnabled = YES;
        [self.wineImageView addGestureRecognizer:gesture1];
        
        addPhotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(3,
                                                                  .70 * HEIGHT(self.wineImageView),
                                                                  WIDTH(self.wineImageView) - 6,
                                                                  30)];
        addPhotoLabel.backgroundColor = [UIColor clearColor];
        [addPhotoLabel setFont:[UIFont fontWithName:@"OpenSans" size:16]];
        [addPhotoLabel setTextColor:[UIColor whiteColor]];
        [addPhotoLabel setTextAlignment:NSTextAlignmentCenter];
        [addPhotoLabel setText:@"Custom Photo"];
        [self.wineImageView addSubview:addPhotoLabel];
        
        selectVintage.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        selectVintage.layer.cornerRadius = 6;
        selectVintage.layer.borderWidth = .5;
        selectVintage.backgroundColor = ALMOST_BLACK_2;
        selectVintage.tintColor = [UIColor whiteColor];
        selectVintage.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [selectVintage.titleLabel setTextColor:[UIColor whiteColor]];
        [selectVintage addTarget:self action:@selector(clickVintage:) forControlEvents:UIControlEventTouchUpInside];
        
        selectOccasion.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        selectOccasion.layer.cornerRadius = 6;
        selectOccasion.layer.borderWidth = .5;
        selectOccasion.backgroundColor = ALMOST_BLACK_2;
        selectOccasion.tintColor = [UIColor whiteColor];
        selectOccasion.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [selectOccasion.titleLabel setTextColor:[UIColor whiteColor]];
        [selectOccasion addTarget:self action:@selector(clickOccasion:) forControlEvents:UIControlEventTouchUpInside];
        
        addLocation.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        addLocation.layer.cornerRadius = 6;
        addLocation.layer.borderWidth = .5;
        addLocation.backgroundColor = ALMOST_BLACK_2;
        addLocation.tintColor = [UIColor whiteColor];
        addLocation.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [addLocation.titleLabel setTextColor:[UIColor whiteColor]];
        [addLocation addTarget:self action:@selector(clickLocation:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setupFacebookButton];
        shareFacebook.alpha = 0;
    }
}

- (void)setupFacebookButton {
    
    shareFacebook.layer.cornerRadius = 6;
    shareFacebook.clipsToBounds = YES;
    [shareFacebook setImage:FACEBOOK_ICON forState:UIControlStateNormal];
    [shareFacebook.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [shareFacebook.imageView setFrame:CGRectMake(0, 0, 24, 24)];
    
}

- (void)configure:(unWine *)wineObject {
    self.wine = wineObject;
    
    //[self performSelector:@selector(showPopover) withObject:nil afterDelay:.8];
    [self showPopover];
}

- (NSInteger)getYear {
    NSDateComponents *components = [[NSCalendar currentCalendar]
                                    components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                    fromDate:[NSDate date]];
    
    return components.year;
}

- (void)clickVintage:(id) sender {
    if(pickables != nil)
        return;
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    [objects addObject:@"Other Vintage"];
    for(int i = 1900; i <= [self getYear]; i++)
        [objects addObject:@(i)];
    [objects addObject:@"No Vintage"];
    
    type = PICK_VINTAGE;
    pickables = objects;
    
    [pickerView reloadComponent:0];
    
    NSInteger row = [[selectedRow objectForKey:[self stringOf:@(type)]] integerValue];
    if([selectedRow objectForKey:[self stringOf:@(type)]] != nil)
        [pickerView selectRow:row inComponent:0 animated:NO];
    else
        [pickerView selectRow:[objects count] - 1 inComponent:0 animated:NO];
    
    [pickerView reloadComponent:0];
    
    [shadowField becomeFirstResponder];
}

- (void)clickOccasion:(id) sender {
    if(pickables != nil)
        return;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Occasion"];
    [query whereKeyDoesNotExist:@"user"];
    [query orderByAscending:@"name"];
    type = PICK_OCCASION;
    
    PFQuery *query2 = [NewsFeed query];
    [query2 whereKeyExists:@"occasionPointer"];
    [query2 whereKey:@"authorPointer" equalTo:[User currentUser]];
    [query2 orderByDescending:@"createdAt"];
    [query2 includeKey:@"occasionPointer"];
    [query2 setLimit:3];
    
    NSArray *tasks = @[[query findObjectsInBackground], [query2 findObjectsInBackground]];
    
    [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        BFTask *occasionTask = [tasks objectAtIndex:0];
        BFTask *recentTask = [tasks objectAtIndex:1];
        if(!occasionTask.error) {
            CastOccasionTVC *occ = [[CastOccasionTVC alloc] init];
            occ.occasions = occasionTask.result;
            occ.delegate = self;
            
            if(!recentTask.error) {
                NSMutableArray *recent = [[NSMutableArray alloc] init];
                NSMutableArray *control = [[NSMutableArray alloc] init];
                for(NewsFeed *checkin in recentTask.result) {
                    if([recent count] < 5 && ![control containsObject:checkin.occasionPointer.objectId]) {
                        //NSString *s = [NSString stringWithFormat:@"Checking.id: %@, Ocassion: %@\nDescription: %@\n\n", checkin.objectId, occasion, occasion.description];
                        //LOGGER(s);
                        if (ISVALID(checkin.occasionPointer.name)) {
                            [recent addObject:checkin.occasionPointer];
                            [control addObject:checkin.occasionPointer.objectId];
                        }
                    }
                }
                occ.recentOccasions = recent;
            } else {
                occ.recentOccasions = @[];
                LOGGER(recentTask.error);
            }
            /*
             NSString *s = [NSString stringWithFormat:@"Recent: %@\n\nOccasions: %@", occ.recentOccasions, occ.occasions];
             LOGGER(s);*/
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
                [parent.navigationController pushViewController:occ animated:YES];
            });
            
            /*[pickerView reloadComponent:0];
             
             NSInteger row = [[selectedRow objectForKey:[self stringOf:@(type)]] integerValue];
             if([selectedRow objectForKey:[self stringOf:@(type)]] != nil)
             [pickerView selectRow:row inComponent:0 animated:NO];
             else
             [pickerView selectRow:[objects count] - 1 inComponent:0 animated:NO];
             
             [pickerView reloadComponent:0];
             
             [shadowField becomeFirstResponder];*/
        } else
            LOGGER(occasionTask.error);
        
        return nil;
    }];
}

- (void)showPopover {
    if(![User hasSeen:WITNESS_ALERT_CHECKIN] && ![[PopoverVC sharedInstance] isDisplayed]) {
        CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
        CGRect placer = self.wineImageView.frame;
        NSLog(@"showPopover frame %@", NSStringFromCGRect(placer));
        //placer.size.width = placer.size.width / 2;
        
        [[PopoverVC sharedInstance] showFrom:parent.navigationController
                                  sourceView:self
                                  sourceRect:placer
                                   direction:UIPopoverArrowDirectionUp
                                        text:@"Capture the moment with a photo or a video. Doesn't matter if it's your wine or a selfie!"];
        
        [User witnessed:WITNESS_ALERT_CHECKIN];
        ANALYTICS_TRACK_EVENT(EVENT_USER_SAW_ADD_CUSTOM_CHECKIN_PHOTO_BUBBLE);
    }
}

- (void)clickLocation:(id) sender {
    UIStoryboard *pseudoLocationStoryboard = [UIStoryboard storyboardWithName:@"pseudoLocationCheckin" bundle:nil];
    pseudoLocationCheckinTableViewController *pseudoLocationController = [pseudoLocationStoryboard instantiateInitialViewController];
    
    pseudoLocationController.delegate = self;
    
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    [parent.navigationController pushViewController:pseudoLocationController animated:YES];
}

- (void)pseudoLocationCheckinTableViewController:(pseudoLocationCheckinTableViewController*)viewController
                                       sendVenue:(PFObject *)venue {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    [parent addLocation:venue];
    
    [addLocation setTitle:[venue[@"name"] capitalizedString] forState:UIControlStateNormal];
    [parent.navigationController popViewControllerAnimated:YES];
}

static NSString *dialogViewPhoto = @"Preview";
static NSString *dialogTakePhoto = @"Take a Photo";
static NSString *dialogUseLastPhoto = @"Use Last Photo Taken";
static NSString *dialogChoosePhoto = @"Choose From Library";
//static NSString *dialogImportPhoto = @"Import Image From...";

- (void)tapImage {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    
    NSArray *buttons = self.previewable == nil ? @[dialogTakePhoto, dialogChoosePhoto] : @[dialogViewPhoto, dialogTakePhoto, dialogChoosePhoto]; //@[dialogTakePhoto, dialogUseLastPhoto, dialogChoosePhoto];
    
    unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:buttons];
    
    //if(parent.pushedFromNotification)
    [sheet showFromTabBar:parent.navigationController.view];
    //else
    //    [sheet showFromTabBar:parent.tabBarController.view];
    
    //UIStoryboard *camera = [UIStoryboard storyboardWithName:@"castCamera" bundle:nil];
    
    /*UINavigationController *base = [camera instantiateInitialViewController];
     
     APLViewController *camView = (APLViewController *)[base.viewControllers objectAtIndex:0];
     camView.delegate = self;*/
    
    //[parent presentViewController:base animated:YES completion:nil];
    
    /*camView.view.alpha = 1;
     if(parent.wineImage != nil)
     [camView.imageView setImage:parent.wineImage];
     else
     [camView.imageView setImage:VINECAST_PLACEHOLDER];
     [camView.imageView setContentMode:UIViewContentModeScaleAspectFill];*/
}

- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogViewPhoto]) {
        [self preview];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogTakePhoto]) {
        [parent presentViewController:[CICameraVC cameraWithDelegate:self] animated:YES completion:nil];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogUseLastPhoto]) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        PHAsset *lastAsset = [fetchResult lastObject];
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:(CGSize){lastAsset.pixelWidth, lastAsset.pixelHeight}
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self presentPhotoForFiltering:result];
                                                    });
                                                }];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:dialogChoosePhoto]) {
        [parent showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)preview {
    if(self.previewable != nil) {
        CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
        if([self.previewable isKindOfClass:[UIImage class]]) {
            if(imageFullVC == nil)
                imageFullVC = [[UIStoryboard storyboardWithName:@"ImageFull" bundle:nil] instantiateInitialViewController];
            
            imageFullVC.view.alpha = 0;
            
            [imageFullVC setImage:(UIImage *)self.previewable];
            
            [parent.navigationController.view addSubview:imageFullVC.view];
            [UIView animateWithDuration:.3 animations:^{
                imageFullVC.view.alpha = 1;
            }];
        } else if([self.previewable isKindOfClass:[NSURL class]]) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            
            MPMoviePlayerViewController *playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:(NSURL *)self.previewable];
            [parent presentViewController:playerView animated:YES completion:nil];
        }
    }
}

- (void)cameraFinishedFiltering:(UIImage *)image withFilter:(NSString *)filter {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    parent.filterName = filter;
    
    parent.movieData = nil;
    parent.movieURL = nil;
    parent.movieFileName = nil;
    
    self.previewable = image;
    [self selectedPhoto:image];
}

- (void)cameraFinishedRecording:(NSData *)movieData url:(NSURL *)url thumbnail:(UIImage *)thumbnail {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    
    AVAsset *movie = [AVAsset assetWithURL:url];
    CGFloat time = CMTimeGetSeconds(movie.duration);
    
    NSLog(@"video duration: %f", time);
    if(time < 10) {
        MBProgressHUD *progressHUD = SHOW_HUD_FOR_VIEW(parent.navigationController.view);
        progressHUD.labelText = @"Processing Media";
        
        __block CIVideoQuality quality = CIVideoQuality720p;
        __block CGFloat fileSize = (float)movieData.length / 1024.0f / 1024.0f;
        NSLog(@"Original file size is: %.2f MB", fileSize);
        
        __block NSString *outputFileName = [MediaHelper outputFileName:quality];
        __block NSURL *outputURL = [self getOutputURL:outputFileName];
        
        [[self convertVideoQuailty:quality inputURL:url outputURL:outputURL] continueWithBlock:^id(BFTask *task) {
            AVAssetExportSession *session = task.result;
            
            NSData *newMovieData = [NSData dataWithContentsOfURL:session.outputURL];
            fileSize = (float)newMovieData.length / 1024.0f / 1024.0f;
            NSLog(@"Output %@ file size is: %.2f MB", outputFileName, fileSize);
            
            if(fileSize < 10 && fileSize > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressHUD hide:YES];
                });
                
                parent.movieData = newMovieData;
                parent.movieURL = session.outputURL;
                parent.movieFileName = outputFileName;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self selectedPhoto:thumbnail];
                });
                self.previewable = url;
                
                return nil;
            } else {
                NSLog(@"dropping quality...");
                quality = quality + 1;
                
                if(quality == CIVideoQualityNone) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressHUD hide:YES];
                    });
                    
                    [unWineAlertView showAlertViewWithTitle:@"unWine" message:@"This video was just too big a package for us to handle."];
                    
                    return nil;
                } else {
                    outputFileName = [MediaHelper outputFileName:quality];
                    outputURL = [self getOutputURL:outputFileName];
                    
                    return [self convertVideoQuailty:quality inputURL:url outputURL:outputURL];
                }
            }
        }];
    } else {
        [unWineAlertView showAlertViewWithTitle:@"unWine" message:@"Let's keep the videos under 10 seconds, we don't want people nodding off after all."];
    }
}

- (NSURL *)getOutputURL:(NSString *)outputFileName {
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:outputFileName];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    if ([manager fileExistsAtPath:outputPath]) {
        [manager removeItemAtPath:outputPath error:nil];
    }
    
    return [[NSURL alloc] initFileURLWithPath:outputPath];
}

- (BFTask *)convertVideoQuailty:(CIVideoQuality)quality inputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:[MediaHelper outputPreset:quality]];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        [task setResult:exportSession];
    }];
    
    return task.task;
}

- (void)presentPhotoForFiltering:(UIImage *)image {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    //SHOW_HUD_FOR_VIEW(parent.navigationController.view);
    CIFilterVC *filter = [[CIFilterVC alloc] init];
    [filter setImage:image];
    filter.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:filter];
    [parent presentViewController:nav animated:YES completion:nil];
}

- (void)finishedFiltering:(UIImage *)image withFilter:(NSString *)filter {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    parent.filterName = filter;
    [parent.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    parent.movieData = nil;
    parent.movieFileName = nil;
    parent.movieURL = nil;
    
    self.previewable = image;
    [self selectedPhoto:image];
}

- (void)willEndEditting {
    //CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    //HIDE_HUD_FOR_VIEW(parent.navigationController.view);
}

- (void)selectedPhoto:(UIImage *)photo {
    UIImage *image = photo != nil ? [UIImage imageWithCGImage:[photo CGImage]] : nil;
    
    LOGGER(@"Setting newsfeed image");
    
    if (image == nil || ![image isEqual:VINECAST_PLACEHOLDER]) {
        LOGGER(@"Selected Custom Image");
        
        CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
        
        [self.wineImageView setImage:image];
        [self.wineImageView setContentMode:UIViewContentModeScaleAspectFill];
        addPhotoLabel.alpha = 0;
        parent.newsFeedImage = image;
        
    } else {
        LOGGER(@"No Custom Image Selected");
    }
    
    //[parent addPhoto:image];
}

- (void)cancelPickerView {
    pickables = nil;
    [shadowField resignFirstResponder];
}

- (void)completePickerView {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    
    NSInteger row = [[selectedRow objectForKey:[self stringOf:@(type)]] integerValue];
    if(pickables == nil || row >= [pickables count]) {
        [self cancelPickerView];
        return;
    }
    
    id selected = [pickables objectAtIndex:row];
    if(type == PICK_OCCASION) {
        PFObject *object = (PFObject *)selected;
        [parent addOccasion:object];
        
        [selectOccasion setTitle:object[@"name"] forState:UIControlStateNormal];
        [self cancelPickerView];
    } else if(type == PICK_VINTAGE) {
        NSString *object = [NSString stringWithFormat:@"%@", selected];
        [parent addVintage:object];
        
        [selectVintage setTitle:object forState:UIControlStateNormal];
        [self cancelPickerView];
    }
}

- (void)updateOccasion:(Occasion *)occasion {
    CastCheckinTVC *parent = (CastCheckinTVC *)delegate;
    [parent addOccasion:occasion];
    
    [selectOccasion setTitle:occasion.name forState:UIControlStateNormal];
    [self cancelPickerView];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [selectedRow setValue:@(row) forKey:[self stringOf:@(type)]];
}

- (NSString *)stringOf:(id)something {
    return [NSString stringWithFormat:@"%@", something];
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(row < [pickables count]) {
        if(type == PICK_OCCASION) {
            return [NSString stringWithFormat:@"%@", [pickables objectAtIndex:row][@"name"]];
        } else
            return [NSString stringWithFormat:@"%@", [pickables objectAtIndex:row]];
    } else
        return @"";
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickables == nil ? 0 : [pickables count];
}

- (UIViewController *)actionSheetPresentationViewController {
    return self.delegate;
}

@end
