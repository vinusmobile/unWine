//
//  CIFilterVC.m
//  unWine
//
//  Created by Bryce Boesen on 10/12/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "CIFilterVC.h"
#import "UIImage+Blurring.h"
#import "UIImage+Filtering.h"
#import "UIImage+CameraFilters.h"
#import "UIImage+Resizing.h"
#import "UIImage+Tint.h"
#import "UIImage+FiltrrCompositions.h"
#import <GPUImage/GPUImage.h>
#import <StoreKit/StoreKit.h>
#import "unWineAlertView.h"
#import "SKProduct+priceAsString.h"
#import "SlackHelper.h"

#define scrollViewHeight 180
#define bufferViewWidth 120
#define thumbnailSize 280
#define IMAGEVIEW_TAG 101

@interface UIView (LockIcon)

- (void)addLockIcon:(CIFilterVC *)source;
- (void)removeLockIcon;

@end

@interface UIImage (CS_Extensions)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end;

@interface CIFilterVC () <unWineAlertViewDelegate> {
    NSMutableDictionary *_productMetadataDictionary;
    NSMutableDictionary *_productProgressDictionary;
    
    SKProductsRequest *_storeProductsRequest;
}

@property (nonatomic, strong) UIImage *original;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSMutableArray *history; //contains relevant representations(undoing and performing a new action will remove objects in the history beyond the undo point, as logically they are no longer apart of the history of the image)
@property (nonatomic,       ) NSUInteger index; //represents the cursor IN the history array

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *transformView;

@property (nonatomic, strong) NSMutableArray *filters;

@property (nonatomic        ) CIFilterState state;
@property (nonatomic        ) CIFilterEffect activeFilter;

@property (nonatomic, strong) PFProduct *product;

@end

CGFloat DegreesToRadians(CGFloat degrees) { return degrees * M_PI / 180; };
CGFloat RadiansToDegrees(CGFloat radians) { return radians * 180 / M_PI; };

@implementation CIFilterVC {
    UIBarButtonItem *done;
    UIBarButtonItem *apply;
    UIImage *displayed;
    
    NSMutableArray *effectViews;
}
@synthesize delegate = _delegate, original = _original, thumbnail = _thumbnail, image = _image, history = _history, index = _index, imageView = _imageView, transformView = _transformView, filters = _filters, state = _state;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self userHasFilter:_activeFilter])
        [_imageView removeLockIcon];
    
    if(_state == CIFilterStateApplyingEffect && effectViews && [effectViews count] > 0) {
        for(UIView *view in effectViews) {
            CIFilterEffect filter = (CIFilterEffect)view.tag;
            if([self userHasFilter:filter]) {
                for(UIView *subview in [view subviews])
                    if([subview tag] == IMAGEVIEW_TAG)
                        [subview removeLockIcon];
            }
        }
    }
}

- (void)setImage:(UIImage *)image {
    _original = [UIImage imageWithCGImage:image.CGImage];
    _history = [NSMutableArray arrayWithCapacity:1];
    _index = 0;
    _state = CIFilterStateApplyingEffect;
    _activeFilter = CIFilterEffectOriginal;
    
    CGFloat minDim = MIN(WIDTH2(image), HEIGHT2(image));
    NSInteger dim = minDim > 1024 ? 1024 : minDim;
    _image = [CIFilterVC squareImageFromImage:image scaledToSize:dim];
    [self makeThumbnail];
    //[self addCurrentImageToHistory];
}

+ (NSArray *)enhances {
    static NSMutableArray * _enhances = nil;
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        _enhances = [[NSMutableArray alloc] init];
        
        [_enhances insertObject:@"Original"      atIndex:CIFilterEnhanceOriginal];
        [_enhances insertObject:@"Brightness"    atIndex:CIFilterEnhanceBrightness];
        [_enhances insertObject:@"Constrast"     atIndex:CIFilterEnhanceContrast];
        [_enhances insertObject:@"Vibrance"      atIndex:CIFilterEnhanceVibrance];
        [_enhances insertObject:@"Gamma"         atIndex:CIFilterEnhanceGamma];
        [_enhances insertObject:@"Saturate"      atIndex:CIFilterEnhanceSaturate];
        [_enhances insertObject:@"Emboss"        atIndex:CIFilterEnhanceEmboss];
    });
    
    return _enhances;
}

+ (NSArray *)filters {
    static NSMutableArray * _names = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        _names = [[NSMutableArray alloc] init];
        [_names insertObject:@"Normal"          atIndex:CIFilterEffectOriginal];
        [_names insertObject:@"B&W"             atIndex:CIFilterEffectBlackWhite];
        [_names insertObject:@"Terrior"         atIndex:CIFilterEffectFilter2];
        [_names insertObject:@"Mute"            atIndex:CIFilterEffectFilter5];
        [_names insertObject:@"El Leon"         atIndex:CIFilterEffectFilterElLeon];
        [_names insertObject:@"Oak"             atIndex:CIFilterEffectFilter4];
        [_names insertObject:@"Bone Dry"        atIndex:CIFilterEffectFilterBoneDry];
        [_names insertObject:@"Vintage"         atIndex:CIFilterEffectFilter6];
        [_names insertObject:@"Clay"            atIndex:CIFilterEffectFilter7];
        [_names insertObject:@"Tannin"          atIndex:CIFilterEffectFilter8];
        [_names insertObject:@"Silt"            atIndex:CIFilterEffectFilter9];
        //[_names insertObject:@"Halloween"       atIndex:CIFilterEffectFilter10];
    });
    
    return _names;
}

+ (NSArray *)states {
    static NSMutableArray * _states = nil;
    static dispatch_once_t onceToken3;
    dispatch_once(&onceToken3, ^{
        _states = [[NSMutableArray alloc] init];
        [_states insertObject:@"Enhance"       atIndex:CIFilterStateEnhancing];
        [_states insertObject:@"Effects"       atIndex:CIFilterStateApplyingEffect];
        [_states insertObject:@"Crop"          atIndex:CIFilterStateCropping];
        [_states insertObject:@"Orientation"   atIndex:CIFilterStateOrienting];
    });
    
    return _states;
}

+ (NSString *)effectsName:(CIFilterEffect)effect {
    return [[self enhances] objectAtIndex:effect];
}

+ (NSString *)filterName:(CIFilterEffect)effect {
    return [[self filters] objectAtIndex:effect];
}

+ (NSString *)stateName:(CIFilterState)state {
    return [[self states] objectAtIndex:state];
}
- (void)applyEnhance:(CIFilterEnhance)enhance onImage:(UIImage *)img completion:(void(^)(UIImage *))callback {
    __block UIImage *image = img;
    //Enhances
    dispatch_queue_t myQueue = dispatch_queue_create("Enhance Queue", NULL);
    dispatch_async(myQueue, ^{
        if(enhance == CIFilterEnhanceContrast) {
            image = [image contrastAdjustmentWithValue:100];
        } else if(enhance == CIFilterEnhanceBrightness) {
            image = [image brightenWithValue:210];
        } else if(enhance == CIFilterEnhanceEmboss) {
            image = [image embossWithBias:.25];
        } else if(enhance == CIFilterEnhanceGamma) {
            image = [image gammaCorrectionWithValue:5];
        } else if(enhance == CIFilterEnhanceSaturate) {
            image = [image saturateImage:1.7 withContrast:1];
        }
        callback(image);
    });
}

- (UIImage *)divideBlendImage:(UIImage *)image withTexture:(UIImage *)texture {
    GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageDivideBlendFilter *filter = [[GPUImageDivideBlendFilter alloc] init];
    
    [source addTarget:filter];
    [filter useNextFrameForImageCapture];
    [source processImage];
    
    return [filter imageByFilteringImage:texture];
}

- (UIImage *)applyEffect:(CIFilterEffect)effect onImage:(UIImage *)img {
    UIImage *image = img;
    
    if(effect == CIFilterEffectBlackWhite) {
        image = [image saturateImage:0 withContrast:1.05];
        
    } else if(effect == CIFilterEffectFilterElLeon) {
        image = [image sepia];
        
    } else if(effect == CIFilterEffectFilter2) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"texture4.png"]];
        
    } else if(effect == CIFilterEffectFilterBoneDry) {
        GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
        GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
        [filter setEdgeStrength:1];
        
        [source addTarget:filter];
        [filter useNextFrameForImageCapture];
        [source processImage];
        
        image = [filter imageFromCurrentFramebuffer];
        
    } else if(effect == CIFilterEffectFilter4) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"VioletSpell.jpg"]];
        
    } else if(effect == CIFilterEffectFilter5) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"paper.jpg"]];
        
    } else if(effect == CIFilterEffectFilter6) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"texture1.jpg"]];
        
    } else if(effect == CIFilterEffectFilter7) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"texture2.jpg"]];
        
    } else if(effect == CIFilterEffectFilter8) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"texture3.jpg"]];
        
    } else if(effect == CIFilterEffectFilter9) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"texture5.jpg"]];
        
    } else if(effect == CIFilterEffectFilter10) {
        image = [self divideBlendImage:image withTexture:[UIImage imageNamed:@"halloween.jpg"]];
        
    }
    //NSLog(@"loaded - %@", [CIFilterVC filterName:effect]);
    
    //callback(image);
    return image;
}

/**
 * Used for when there are images in the stack after performing "undoes" and another action is made
 */
- (void)_clearHangingRedoes {
    [self _clearAfter:_index];
}

- (void)_clearAfter:(NSInteger)index {
    for(NSUInteger i = [_history count] - 1; i > index; i++)
        [_history removeObjectAtIndex:i];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(attemptClose)];
    [[self navigationItem] setBackBarButtonItem:back];
    self.navigationItem.leftBarButtonItem = back;
    
    done = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(attemptDone)];
    self.navigationItem.rightBarButtonItem = done;
    
    self.view.backgroundColor = UNWINE_GRAY_DARK;
    [self basicAppeareanceSetup];
    
    NSInteger emptyPadding = 0;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-emptyPadding, HEIGHT(self.view) - scrollViewHeight, SCREEN_WIDTH + emptyPadding * 2, scrollViewHeight)];
    _scrollView.backgroundColor = UNWINE_RED_70;
    _scrollView.clipsToBounds = YES;
    [_scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [_scrollView setLayoutMargins:UIEdgeInsetsMake(0, 10 + emptyPadding, 0, 10 + emptyPadding)];
    [_scrollView setBounces:YES];
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [[UIColor blackColor] CGColor];
    border.frame = CGRectMake(0, 0, WIDTH(_scrollView), .1);
    [_scrollView.layer addSublayer:border];
    
    [self.view addSubview:_scrollView];
    
    
    NSInteger dim = WIDTH(self.view);
    NSInteger interHeight = MIN(HEIGHT(self.view) - scrollViewHeight - dim, 80);
    NSInteger interY = Y2(_scrollView) - interHeight;
    NSInteger imageSpace = HEIGHT(self.view) - scrollViewHeight - interHeight;
    NSInteger imageY = (imageSpace - dim) / 2;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, MAX(imageY, 0), dim, dim)];
    [self setActiveImage:_image];
    _imageView.userInteractionEnabled = YES;
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressed:)];
    press.minimumPressDuration = .25;
    [_imageView addGestureRecognizer:press];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewSwiped:)];
    [_imageView addGestureRecognizer:swipe];
    [self.view addSubview:_imageView];
    
    _transformView = [[UIScrollView alloc] initWithFrame:(CGRect){0, interY, {WIDTH(self.view), interHeight}}];
    _transformView.backgroundColor = UNWINE_GRAY;
    _transformView.clipsToBounds = YES;
    [_transformView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    //[_transformView setLayoutMargins:UIEdgeInsetsMake(0, 10 + emptyPadding, 0, 10 + emptyPadding)];
    [_transformView setBounces:YES];

    UIButton *rotateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rotateButton setFrame:(CGRect){0, 0, {interHeight, interHeight}}];
    [rotateButton setImage:[UIImage imageNamed:@"rotateIcon"] forState:UIControlStateNormal];
    [rotateButton addTarget:self action:@selector(rotateImage) forControlEvents:UIControlEventTouchUpInside];
    rotateButton.backgroundColor = [UIColor clearColor];
    rotateButton.tintColor = [UIColor whiteColor];
    [_transformView addSubview:rotateButton];
    
    [self.view addSubview:_transformView];
    
    [self setState:_state];
}

- (void)setState:(CIFilterState)state {
    _state = state;
    if(state == CIFilterStateDefault) {
        [self showDefaults];
        done.title = @"Done";
    } else if(state == CIFilterStateApplyingEffect) {
        [self showEffects:YES];
        UIView *first = (UIView *)[effectViews objectAtIndex:0];
        first.backgroundColor = UNWINE_RED;
        
        done.title = @"Apply";
    }
}

- (void)centerButtonPressed {
    if([[unWineAlertView sharedInstance] tag] == CIAlertTagCancel) {
        [self close];
    }
}

- (void)finish {
    [self close];
    if([_delegate respondsToSelector:@selector(finishedFiltering:withFilter:)])
        [_delegate finishedFiltering:_image withFilter:[self getFilterName]];
}

- (NSString *)getFilterName {
    return (_activeFilter != CIFilterEffectOriginal) ? [CIFilterVC filterName:_activeFilter] : nil;
}

- (void)attemptClose {
    if([_history count] <= 1) {
        [self close];
        return;
    }
    
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"(Tip: You can always swipe across the photo to undo or redo.)"];
    alert.delegate = self;
    alert.title = @"Your edits have not been saved.";
    alert.leftButtonTitle = @"Leave editor";
    alert.rightButtonTitle = @"Keep editing";
    alert.tag = CIAlertTagCancel;
    [alert show];
}

- (void)close {
    if([_delegate respondsToSelector:@selector(willEndEditting)])
        [_delegate willEndEditting];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if([_delegate respondsToSelector:@selector(didEndEditting)])
            [_delegate didEndEditting];
    }];
}

- (BOOL)userHasFilter:(CIFilterEffect)filter {
    return (int)filter <= [User getFiltersLockedAfter];
}

- (void)attemptDone {
    if(_state == CIFilterStateApplyingEffect) {
        if([self userHasFilter:_activeFilter]) {
            //[self addCurrentImageToHistory];
            _image = _imageView.image;
            [self makeThumbnail];
            
            [self finish];
        } else {
            [self showLockedFilterDialog];
        }
    }
}

- (void)showLockedFilterDialog {
    unWineAlertView *alert = [[unWineAlertView sharedInstance] prepareWithMessage:@"You don't have access to all the filters, unlock them instantly below!"];
    alert.delegate = self;
    alert.title = @"Photo Filters";
    alert.theme = unWineAlertThemeRed;
    alert.emptySpaceDismisses = YES;
    alert.leftButtonTitle = [NSString stringWithFormat:@"Cancel"];
    alert.rightButtonTitle = [NSString stringWithFormat:@"Unlock"];
    [alert shouldShowOrLabel:NO];
    [alert show];
}

- (void)rightButtonPressed {
    [Grapes showPurchases:self.navigationController];
}

- (void)imageViewPressed:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        displayed = _imageView.image;
        _imageView.image = _image;
    } else if(gesture.state == UIGestureRecognizerStateEnded && displayed != nil) {
        _imageView.image = displayed;
        displayed = nil;
    }
}

- (void)imageViewSwiped:(UISwipeGestureRecognizer *)gesture {
    if(_state != CIFilterStateEnhancing)
        return;
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
    } else if(gesture.state == UIGestureRecognizerStateEnded) {
        
    }
    if(gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        
    } else if(gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        
    }
}

- (void)effectTapped:(UIGestureRecognizer *)sender {
    [self applyEffectWithSender:sender andFailCount:0];
}

- (void)applyEffectWithSender:(UIGestureRecognizer *)sender andFailCount:(int)count {
    LOGGER(@"Enter");
    
    for(UIView *view in [_scrollView subviews]) {
        view.backgroundColor = [UIColor clearColor];//view.tag % 2 == 0 ? UNWINE_RED_70 : UNWINE_RED_80;
    }
    
    UIView *tapped = [sender view];
    tapped.backgroundColor = UNWINE_RED;
    
    CIFilterEffect filter = (CIFilterEffect)tapped.tag;
    
    @try {
        
        SHOW_HUD_FOR_VIEW(self.navigationController.view);
        UIImage *image = [self applyEffect:filter onImage:_image];
        HIDE_HUD_FOR_VIEW(self.navigationController.view);

        dispatch_async(dispatch_get_main_queue(), ^{
            _activeFilter = filter;
            [_imageView setImage:image];
            if(![self userHasFilter:filter]) {
                [_imageView addLockIcon:self];
            } else
                [_imageView removeLockIcon];
        });
        
    } @catch (NSException *exception) {
        NSString *s = [NSString stringWithFormat:@"Error while applying selected filter:\n%@", exception];
        LOGGER(s);
        
        if (count < 3) {
            // Try again
            count++;
            NSString *s = [NSString stringWithFormat:@"Trying again: %i", count];
            LOGGER(s);
            [self applyEffectWithSender:sender andFailCount:count];
            
        } else {
            LOGGER(@"Something is wrong with filters");
            [SlackHelper sendSlackNotificationToDebugChannel:s];
        }
        
    } @finally {
        HIDE_HUD_FOR_VIEW(self.navigationController.view);
    }
}

- (void)rotateImage {
    SHOW_HUD_FOR_VIEW(self.navigationController.view);
    UIImage *image = [_imageView.image imageRotatedByDegrees:90];
    [_imageView setImage:image];
    HIDE_HUD_FOR_VIEW(self.navigationController.view);
    //[_image imageRotatedByDegrees:90];
}

- (void)showDefaults {
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger x = 0;
    for(NSInteger i = 0; i < [[CIFilterVC states] count]; i++) {
        CIFilterState state = (CIFilterState)i;
        
        UIView *filterView = [self stateView:state];
        
        filterView.tag = i;
        filterView.backgroundColor = [UIColor clearColor];//i % 2 == 0 ? UNWINE_RED_70 : UNWINE_RED_80;
        
        CGRect adjust = filterView.frame;
        adjust.origin.x = x;
        [filterView setFrame:adjust];
        
        [_scrollView addSubview:filterView];
        x += adjust.size.width;
    }
    [_scrollView setContentSize:(CGSize){x, HEIGHT(_scrollView)}];
}

// Create filter thumbnails
- (void)showEffects:(BOOL)cached {
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if(effectViews == nil)
        effectViews = [[NSMutableArray alloc] init];
    
    NSInteger x = 0;
    for(NSInteger i = 0; i < [[CIFilterVC filters] count]; i++) {
        CIFilterEffect filter = (CIFilterEffect)i;
        
        UIView *filterView;
        if([effectViews count] > i && cached) {
            filterView = [effectViews objectAtIndex:i];
        } else {
            filterView = [self effectView:filter andFailCount:0];
            [effectViews addObject:filterView];
        }
        filterView.tag = i;
        filterView.backgroundColor = [UIColor clearColor];//i % 2 == 0 ? UNWINE_RED_70 : UNWINE_RED_80;
        
        
        if(![self userHasFilter:filter]) {
            for(UIView *subview in [filterView subviews])
                if([subview tag] == IMAGEVIEW_TAG)
                    [subview addLockIcon:self];
        }
        
        CGRect adjust = filterView.frame;
        adjust.origin.x = x;
        [filterView setFrame:adjust];
        
        [_scrollView addSubview:filterView];
        x += adjust.size.width;
    }
    [_scrollView setContentSize:(CGSize){x, HEIGHT(_scrollView)}];
}

- (UIView *)bufferView {
    UIView *bufferView = [UIView new];
    
    if(bufferView) {
        NSInteger dim = scrollViewHeight;
        [bufferView setFrame:CGRectMake(0, 0, bufferViewWidth, dim - 64)];
        bufferView.backgroundColor = UNWINE_RED;
    }
    
    return bufferView;
}

- (UIView *)stateView:(CIFilterState)state {
    return [self filterView:[UIImage imageNamed:@"paper.jpg"] name:[CIFilterVC stateName:state]];
}

// Individual filter thumbnails
- (UIView *)effectView:(CIFilterEffect)effect andFailCount:(int)count {
    UIView *filterView = [self filterView:nil name:[CIFilterVC filterName:effect]];
    @try {
        LOGGER(@"Attempting to apply a filter");
        UIImage *filteredImage = [self applyEffect:effect onImage:_thumbnail];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [[filterView subviews] objectAtIndex:0];
            [imageView setImage:filteredImage];
        });
        
    } @catch (NSException *exception) {
        NSString *s = [NSString stringWithFormat:@"Error while creating filter thumbnails:\n%@", exception];
        LOGGER(s);
        
        if (count < 3) {
            // Try again
            count++;
            NSString *s = [NSString stringWithFormat:@"Trying again: %i", count];
            LOGGER(s);
            filterView = [self effectView:effect andFailCount:count];
            
        } else {
            LOGGER(@"Something is wrong with filters");
            [SlackHelper sendSlackNotificationToDebugChannel:s];
        }
    }
    
    return filterView;
}

- (UIView *)filterView:(UIImage *)image name:(NSString *)name {
    UIView *filterView = [UIView new];
    
    if(filterView) {
        NSInteger dim = scrollViewHeight - 64;
        [filterView setFrame:CGRectMake(0, 0, dim, dim)];
    
        filterView.userInteractionEnabled = YES;
        
        CGFloat imageBuffer = 18;
        
        CGPoint origin = (CGPoint){imageBuffer, imageBuffer / 2};
        CGSize size = (CGSize){WIDTH(filterView) - imageBuffer * 2, HEIGHT(filterView) - imageBuffer * 2};
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(origin.x, origin.y, size.width, size.height)];
        if(image)
            [imageView setImage:image];
        imageView.clipsToBounds = YES;
        imageView.tag = IMAGEVIEW_TAG;
        imageView.layer.cornerRadius = 8;
        imageView.backgroundColor = [UIColor blackColor];
        [filterView addSubview:imageView];
        //NSLog(@"imageView frame %@", NSStringFromCGRect(imageView.frame));
        
        CGPoint lOrigin = (CGPoint){0, size.height + origin.y};
        CGSize lSize = (CGSize){WIDTH(filterView), HEIGHT(filterView) - (size.height + origin.y)};
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(lOrigin.x, lOrigin.y, lSize.width, lSize.height)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:name];
        [label setFont:[UIFont fontWithName:@"OpenSans" size:12]];
        [filterView addSubview:label];
        //NSLog(@"label frame %@", NSStringFromCGRect(label.frame));
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(effectTapped:)];
        [filterView addGestureRecognizer:tap];
    }
    
    return filterView;
}

- (void)setActiveImageFromHistory:(NSUInteger)index {
    if(index >= [_history count]) {
        [NSException raise:@"wtf" format:@"out of bounds scrub"];
    }
    [self addCurrentImageToHistory:index];
    _index = index;
}

- (void)setActiveImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
    [self makeThumbnail];
}

- (void)addCurrentImageToHistory {
    [_history addObject:[UIImage imageWithCGImage:_image.CGImage]];
}

- (void)addCurrentImageToHistory:(NSUInteger)index {
    [_history insertObject:[UIImage imageWithCGImage:_image.CGImage] atIndex:index];
}

- (void)makeThumbnail {
    _thumbnail = [CIFilterVC squareImageFromImage:_image scaledToSize:thumbnailSize];//[_image scaleToSize:(CGSize){thumbnailSize, thumbnailSize}];
}

+ (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UILabel *)displayLabel:(NSString *)text {
    UILabel *label = [UILabel new];
    
    if(label) {
        CGSize size = (CGSize){100, 20};
        [label setFrame:CGRectMake((WIDTH(_imageView) - size.width) / 2,
                                   (HEIGHT(_imageView) - size.height) / 2,
                                   size.width, size.height)];
        
        label.layer.cornerRadius = 8;
        label.backgroundColor = UNWINE_RED;
        
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:text];
        [label setFont:[UIFont fontWithName:@"OpenSans" size:12]];
    }
    
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)basicAppeareanceSetup {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Photo Filter";
}

@end

#define lockViewTag 6234987

@implementation UIView (LockIcon)

- (void)addLockIcon:(CIFilterVC *)source {
    [self removeLockIcon];
    
    //dispatch_queue_t myQueue = dispatch_queue_create("Lock Queue", NULL);
    //dispatch_async(myQueue, ^{
    BOOL invert = false;
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    UIImageView *lockView = [[UIImageView alloc] initWithImage: invert ? [UIImage imageNamed:@"blackLockIcon"] : [UIImage imageNamed:@"whiteLockIcon"]];
    lockView.layer.shadowOffset = CGSizeMake(1, 1);
    lockView.layer.shadowColor = [[UIColor blackColor] CGColor];
    lockView.layer.shadowRadius = 1;
    lockView.layer.shadowOpacity = 1;
    lockView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:source action:@selector(showLockedFilterDialog)];
    [lockView addGestureRecognizer:gesture];
    
    NSInteger dim = WIDTH(self) / 5;
    NSInteger buffer = 5;
    [lockView setFrame:CGRectMake(WIDTH(self) - dim - buffer, buffer, dim, dim)];
    [lockView setContentMode:UIViewContentModeScaleAspectFill];
    lockView.tag = lockViewTag;

    [self addSubview:lockView];
    //});
    //});
}

- (void)removeLockIcon {
    if([self.subviews count] > 0) {
        for(UIView *view in self.subviews) {
            if(view.tag == lockViewTag) {
                [view removeFromSuperview];
                return;
            }
        }
    }
}

@end

@implementation UIImage (CS_Extensions)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end;





