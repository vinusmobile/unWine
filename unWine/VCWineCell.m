//
//  WineCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "VCWineCell.h"
#import "VineCastTVC.h"
#import "CastCheckinTVC.h"
#import "ParseSubclasses.h"
#import <ParseUI/ParseUI.h>
#import "CheckinInterface.h"

@interface UITextView (DetailView)

- (void)updateDetailView:(NewsFeed *)object;
- (CAGradientLayer *)makeGradient:(BOOL)downwards;

@end

@import MediaPlayer;
@implementation VCWineCell {
    CGRect aFrame;
    __block MPMoviePlayerController *player;
    BOOL isPlaying;
    BOOL awaitingReplay;
    UIButton *playButton;
    UIProgressView *load;
    BOOL isAnimating;
}
@synthesize imageFullVC, tinkView;
@synthesize click;

- (void)setup {
    [super setup];
    
    aFrame = self.wineImage.frame;
    //aFrame.size.width = [[UIScreen mainScreen] bounds].size.width;
    self.wineImage.alpha = 0;
    
    if(aFrame.origin.x < 0)
        aFrame.origin.x = 0;
    aFrame.size.width = SCREEN_WIDTH;
    
    self.realImage = [[PFImageView alloc] initWithFrame:aFrame];
    self.realImage.backgroundColor = UNWINE_RED;
    [self.realImage setImage:VINECAST_PLACEHOLDER];
    [self.realImage setContentMode: UIViewContentModeScaleAspectFit];
    
    //self.realImage.layer.cornerRadius = 2.5;
    self.realImage.layer.borderWidth = 0; //.5f;
    self.realImage.layer.borderColor = [[UIColor clearColor] CGColor]; //.5f;
    self.realImage.layer.masksToBounds = YES;
    self.realImage.layer.zPosition = 1005;
    
    self.realImage.backgroundColor = [UIColor clearColor];
    self.realImage.userInteractionEnabled = YES;
    self.realImage.clipsToBounds = YES;
    [self.contentView addSubview:self.realImage];
    
    load = [[UIProgressView alloc] initWithFrame:CGRectMake(IMAGE_NATURAL_X, IMAGE_NATURAL_Y + 4, IMAGE_NATURAL_WIDTH, 4)];
    load.progressViewStyle = UIProgressViewStyleDefault;
    load.tintColor = UNWINE_RED;
    
    self.vintage = @"N.V.";
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wineTapped:)];
    gesture1.numberOfTapsRequired = 1;
    [self.realImage addGestureRecognizer:gesture1];
    
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wineTapped:)];
    gesture2.numberOfTapsRequired = 2;
    [self.realImage addGestureRecognizer:gesture2];
    
    [gesture1 requireGestureRecognizerToFail:gesture2];
}

- (void)configureCell:(NewsFeed *)object {
    [super configureCell:object];
    
    if(object[@"photo"] == nil) {
        PFObject *wine = [VineCastCell getWineForObject:object];
        
        if(wine[@"image"] == nil) {
            [self configureWineImage:object];
        } else {
            [self configureFullImage:object withImageFile:wine[@"image"]];
        }
    } else {
        [self configureFullImage:object withImageFile:object[@"photo"]];
    }
    
    if(tinkView && [tinkView superview])
       [tinkView removeFromSuperview];
    isAnimating = NO;
    
    CGFloat height = [self.delegate tableView:self.delegate.tableView heightForRowAtIndexPath:self.indexPath];
    //NSInteger smallX = SCREENWIDTH -
    CGRect detailFrame = CGRectMake(0, MAX(height - 100, 0), SCREEN_WIDTH, 100);
    if(self.detailView == nil) {
        self.detailView = [self configureDetailView:self.object withFrame:detailFrame];
        [self.contentView addSubview:self.detailView];
    } else {
        [self.detailView updateDetailView:self.object];
        
        if([self.detailView superview])
           [self.detailView removeFromSuperview];
        
        [self.contentView addSubview:self.detailView];
    }
    [self.detailView setFrame:detailFrame];
    [self.detailView sizeToFit];
    //[self.detailView setFrame:(CGRect){0, 0, {SCREEN_WIDTH, HEIGHT(self.detailView)}}];
    [self.detailView setFrame:(CGRect){0, MAX(height - HEIGHT(self.detailView), 0), {SCREEN_WIDTH, HEIGHT(self.detailView)}}];
    
    [self adjustViews];
}

- (void)adjustViews {
    self.realImage.layer.zPosition = 1005;
    self.detailView.layer.zPosition = 1006;
    
    /*if(self.object && self.detailView) {
        UIImage *image = self.delegate.cellImages[[self.object objectId]];
        if(image != nil) {
            CGFloat cellHeight = ([WineCell getImageFrame:self withImage:image]).size.height;
            CGFloat detailHeight = HEIGHT(self.detailView) + 20;
            [self.detailView setFrame:CGRectMake(0, cellHeight - detailHeight, SCREEN_WIDTH, detailHeight)];
        }
    }*/
}

+ (NSArray *)arrayFromSize:(CGSize)size {
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:size.width], [NSNumber numberWithInt:size.height], nil];
}

+ (CGRect)getImageFrame:(UIView *)view withImage:(UIImage *)image {
    return [VCWineCell getImageFrame:view withDims:[VCWineCell arrayFromSize:image.size]];
}

+ (CGRect)getImageFrame:(UIView *)view withDims:(NSArray *)dims {
    CGFloat width = [[dims objectAtIndex:0] floatValue];
    CGFloat height = [[dims objectAtIndex:1] floatValue];
    CGFloat ratio = width / height;
    
    NSInteger dimW = MIN(width, IMAGE_NATURAL_WIDTH);
    NSInteger dimH = MIN(dimW * (1.0f / ratio), IMAGE_NATURAL_MAX_HEIGHT);
    CGRect ret = CGRectMake((SCREEN_WIDTH - dimW) / 2.0f, IMAGE_NATURAL_Y, dimW, dimH);
    if(ret.origin.x < 0)
        ret.origin.x = 0;
    
    return ret;
}

- (void)configureFullImage:(PFObject *)object withImageFile:(PFFile *)imageFile {
    if([self.delegate.cellImages objectForKey:[object objectId]]) {
        [load removeFromSuperview];
        if([[self.realImage subviews] count] > 0)
            [[self.realImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.realImage.alpha = 1;
        self.realImage.clipsToBounds = NO;
        
        UIImage *image = (UIImage *)self.delegate.cellImages[[object objectId]];
        
        //NSLog(@"retroactiveImage %@: %@", [object objectId], NSStringFromCGSize(image.size));
        CGRect loadFrame = [VCWineCell getImageFrame:self withImage:image];
        if([self.object hasMovie])
            loadFrame.size.height = MIN(loadFrame.size.height, VIDEO_NATURAL_MAX_HEIGHT);
        
        [self.realImage setFrame:loadFrame];
        [self.realImage setImage:image];
        [self.realImage setContentMode: UIViewContentModeScaleAspectFit];
        [self showPlayButtonIfApplicable];
        [self adjustViews];
        //NSLog(@"realImage %@", NSStringFromCGRect(self.realImage.frame));
    } else {
        PFFile *theImage = imageFile;
        if([[self.realImage subviews] count] > 0)
            [[self.realImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [self.realImage setImage:nil];
        self.realImage.alpha = 0;
        [self addSubview:load];
        
        if(theImage == nil || [theImage isKindOfClass:[NSNull class]]) {
            self.realImage.image = VINECAST_PLACEHOLDER;
            return;
        }
        
        self.realImage.file = theImage;
        
        [self.realImage loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
            
            self.realImage.image = image;
            self.delegate.cellImages[[object objectId]] = image;
            
            CGRect loadFrame = [VCWineCell getImageFrame:self withImage:image];
            
            [self.realImage setFrame:loadFrame];
            //[self.realImage setImage:image];
            [self.realImage setContentMode: UIViewContentModeScaleAspectFit];
            
        } progressBlock:^(int percentDone) {
            if(percentDone < 100) {
                load.progress = percentDone / 100.0f;
            } else {
                [load removeFromSuperview];
                self.realImage.clipsToBounds = NO;
                [UIView animateWithDuration:.1 animations:^{
                    self.realImage.alpha = 1;
                }];
            }
        }];
        
        /*[[self.realImage loadInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull task) {
            
            UIImage *image = task.result;
            self.delegate.cellImages[[object objectId]] = image;
            
            CGRect loadFrame = [VCWineCell getImageFrame:self withImage:image];
            if([self.object hasMovie])
                loadFrame.size.height = MIN(loadFrame.size.height, VIDEO_NATURAL_MAX_HEIGHT);
            
            [self.realImage setFrame:loadFrame];
            [self.realImage setImage:image];
            [self.realImage setContentMode: UIViewContentModeScaleAspectFit];
            //[self showPlayButtonIfApplicable];
            
            //[self.delegate.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //[self adjustViews];
            return nil;
        }];*/
    
        
        
        /*[theImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            UIImage *image = (imageData)? [UIImage imageWithData:imageData] : VINECAST_PLACEHOLDER;
            
            //NSLog(@"loadedImage %@: %@", [object objectId], NSStringFromCGSize(image.size));
            
            self.delegate.cellImages[[object objectId]] = image;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect loadFrame = [VCWineCell getImageFrame:self withImage:image];
                if([self.object hasMovie])
                    loadFrame.size.height = MIN(loadFrame.size.height, VIDEO_NATURAL_MAX_HEIGHT);
                
                [self.realImage setFrame:loadFrame];
                [self.realImage setImage:image];
                [self.realImage setContentMode: UIViewContentModeScaleAspectFit];
                [self showPlayButtonIfApplicable];
                
                [self.delegate.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                [self adjustViews];
            });
        } progressBlock:^(int percentDone) {
            if(percentDone < 100) {
                load.progress = percentDone / 100.0f;
            } else {
                [load removeFromSuperview];
                self.realImage.clipsToBounds = NO;
                [UIView animateWithDuration:.1 animations:^{
                    self.realImage.alpha = 1;
                }];
            }
        }];*/
    }
}

- (void)showPlayButtonIfApplicable {
    if([self.object hasMovie]) {
        [self.realImage setBackgroundColor:[UIColor blackColor]];
        [self.realImage setContentMode:UIViewContentModeScaleAspectFit];
        
        //dispatch_queue_t myQueue = dispatch_queue_create("Video Queue", NULL);
        //dispatch_async(myQueue, ^{
            NSURL *url = [NSURL URLWithString:ISVALID(self.object.videoURL) ? self.object.videoURL : self.object.video.url];
            
            player = [[MPMoviePlayerController alloc] initWithContentURL:url];
            //if(player.loadState == MPMovieLoadStatePlayable)
            if(![player isPreparedToPlay])
                [player prepareToPlay];
            //});
                
            player.view.backgroundColor = [UIColor clearColor];
            player.controlStyle = MPMovieControlStyleNone;
            player.scalingMode = MPMovieScalingModeAspectFit;
            player.view.userInteractionEnabled = NO;
        
        
            //dispatch_async(dispatch_get_main_queue(), ^{
                player.view.frame = CGRectMake(0, 0, WIDTH(self.realImage), HEIGHT(self.realImage));
                //player.view.layer.zPosition = 1006;
                [self.realImage addSubview:player.view];
        
            //});
        //});
        
        /*if(playButton == nil) {
            playButton = [self.object getPlayButton];
            [playButton addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchUpInside];
            
            //playButton.layer.zPosition = 1007;
            playButton.center = self.realImage.center;
            
            [self.realImage addSubview:playButton];
            [self.realImage bringSubviewToFront:playButton];
        } else if(![playButton superview]) {
            //playButton.layer.zPosition = 1007;
            playButton.center = self.realImage.center;
            
            [self.realImage addSubview:playButton];
            [self.realImage bringSubviewToFront:playButton];
        }*/
    } else {
        [self.realImage setBackgroundColor:[UIColor clearColor]];
        
        player = nil;
        playButton = nil;
    }
}

- (void)notifyCompletelyVisible {
    [self playMovie];
}

- (void)notifyNotCompletelyVisible {
    [self stopMovie];
}

- (void)movieFinished:(MPMoviePlayerController *)moviePlayer {
    //[self.realImage addSubview:playButton];
    //[self.realImage bringSubviewToFront:playButton];
    //[playButton setHidden:NO];
    //[player.view removeFromSuperview];
    isPlaying = NO;
    awaitingReplay = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
}

- (void)playMovie {
    if([self.object hasMovie] && !isPlaying && !awaitingReplay) {
        //dispatch_queue_t myQueue = dispatch_queue_create("Playback Queue", NULL);
        //dispatch_async(myQueue, ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            //[playButton setHidden:YES];
        //[playButton removeFromSuperview];
        //[self.realImage addSubview:player.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:player];
        
        [player play];
        isPlaying = YES;
        awaitingReplay = NO;
        //});
        //[self.object playMovieFromView:self.realImage];
        //[self.object playMovieFromNVC:((VineCastTVC *)self.delegate).navigationController];
    }
}

- (void)stopMovie {
    if([self.object hasMovie] && isPlaying) {
        [player stop];
        isPlaying = NO;
        awaitingReplay = YES;
    }
}

- (void)configureWineImage:(PFObject *)object {
    PFObject *wine = [VineCastCell getWineForObject:(NewsFeed *)object];
    
    wine[@"image"] = [PFFile fileWithName:@"Image.png" data:UIImagePNGRepresentation(VINECAST_PLACEHOLDER)];
    [wine saveInBackground];
    
    [self.realImage setFrame:[VCWineCell getImageFrame:self withImage:VINECAST_PLACEHOLDER]];
    self.realImage.image = VINECAST_PLACEHOLDER;
    self.delegate.cellImages[[object objectId]] = VINECAST_PLACEHOLDER;
}

- (void)wineTapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && sender.numberOfTapsRequired == 2) {
        [self.delegate sudoToast:self.indexPath];
    } else if (sender.state == UIGestureRecognizerStateEnded && sender.numberOfTapsRequired == 1) {
        /*if(imageFullVC == nil)
            imageFullVC = [[UIStoryboard storyboardWithName:@"ImageFull" bundle:nil] instantiateInitialViewController];
        
        //NSString *wineName = [self getWineName:self.object];
        imageFullVC.view.alpha = 0;
        
        [imageFullVC.detailView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [imageFullVC.detailView addSubview:[self configureDetailView:self.object withFrame:CGRectMake(0, 0, SCREEN_WIDTH + 20, HEIGHT(imageFullVC.detailView))]];
        
        [imageFullVC setImage:self.realImage.image];
        
        if([self.delegate.tabBarController.view isHidden] || ![[self.delegate.tabBarController tabBar] window])
            [self.delegate.navigationController.view addSubview:imageFullVC.view];
        else
            [self.delegate.tabBarController.view addSubview:imageFullVC.view];
        [UIView animateWithDuration:.3 animations:^{
            imageFullVC.view.alpha = 1;
        }];*/
        [self inspectWine:sender];
    }
}

- (UITextView *)configureDetailView:(NewsFeed *)object withFrame:(CGRect)frame {
    UITextView *detailView = [[UITextView alloc] initWithFrame:frame];
    
    detailView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.6];
    [detailView setEditable:NO];
    [detailView setScrollEnabled:NO];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inspectWine:)];
    [detailView addGestureRecognizer:tapGesture];
    
    NSString *wineName = [self getWineName:object];
    UIFont *boldFont = [UIFont fontWithName:VINECAST_FONT_BOLD size:14.0f];
    
    if(object.occasionPointer != nil && (wineName == nil || [wineName isEqualToString:@""])) {
        NSString *occasionString = object.occasionPointer.name;
        
        detailView.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:14.0f];
        detailView.text = occasionString;
        detailView.textAlignment = NSTextAlignmentCenter;
        detailView.textColor = [UIColor whiteColor];
    } else if(object.occasionPointer != nil) {
        NSString *occasionString = object.occasionPointer.name;
        wineName = [NSString stringWithFormat:@" with %@", wineName];

        NSMutableString *stuffString = [[NSMutableString alloc] initWithString:occasionString];
        [stuffString appendString:wineName];
        
        NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:stuffString];
        [formatted addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [occasionString length])];
        if([wineName length] > 0)
            [formatted addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange([occasionString length] + 6, [wineName length] - 6)];
        
        detailView.font = [UIFont fontWithName:VINECAST_FONT size:14.0f];
        detailView.attributedText = formatted;
        detailView.textAlignment = NSTextAlignmentCenter;
        detailView.textColor = [UIColor whiteColor];
    } else {
        NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:wineName];
        [formatted addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, [wineName length])];
        detailView.font = [UIFont fontWithName:VINECAST_FONT size:14.0f];
        detailView.attributedText = formatted;
        detailView.textAlignment = NSTextAlignmentCenter;
        detailView.textColor = [UIColor whiteColor];
    }
    
    return detailView;
}

- (void)inspectWine:(UIGestureRecognizer *)recognizer {
    if(imageFullVC)
        [imageFullVC.view removeFromSuperview];
    
    if(!self.object[@"unWinePointer"] || [self.object.unWinePointer isKindOfClass:[NSNull class]]) {
        [unWineAlertView showAlertViewWithTitle:@"Sorry!" message:@"This wine is no longer available, one of the unWinegineers must have drank it all. Again..."];
        return;
    }
    unWine *wine = self.object[@"unWinePointer"];
    
    WineContainerVC *container = [[WineContainerVC alloc] init];
    container.wine = wine;
    container.isNew = NO;
    container.cameFrom = CastCheckinSourceVinecast;
    [self.delegate.navigationController pushViewController:container animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

- (NSString *)getWineName:(PFObject *)object {
    self.vintage = ([VCWineCell isNumeric:object[@"vintage"]])? object[@"vintage"] : @"";
    
    PFObject *wine = [VineCastCell getWineForObject:(NewsFeed *)object];
    NSString *wineName = [wine.parseClassName isEqualToString:[unWine parseClassName]] ? [((unWine *)wine) getWineName] : ((unwinePending *)wine).name.capitalizedString;
    
    return ISVALID(self.vintage) ? [NSString stringWithFormat:@"%@ (%@)", wineName, self.vintage] : (wineName == nil ? @"" : wineName);
}

+ (NSString *)getWineName:(PFObject *)object {
    NSString *vintage = ([VCWineCell isNumeric:object[@"vintage"]])? object[@"vintage"] : @"";
    
    PFObject *wine = [VineCastCell getWineForObject:(NewsFeed *)object];
    NSString *wineName = [wine.parseClassName isEqualToString:[unWine parseClassName]] ? [((unWine *)wine) getWineName] : ((unwinePending *)wine).name.capitalizedString;
    
    return ISVALID(vintage) ? [NSString stringWithFormat:@"%@ (%@)", wineName, vintage] : (wineName == nil ? @"" : wineName);
}

- (void)interuptTinkView {
    if(tinkView != nil) {
        [tinkView removeFromSuperview];
        
        if(click != nil && [click isPlaying])
            [click stop];
    }
}

- (CGRect)getFrameFromRealImage {
    CGRect rect = CGRectMake(SEMIWIDTH(self.realImage) - SCREEN_WIDTH / 2, 0, SCREEN_WIDTH, HEIGHT(self));
    return rect;
}

- (void)showToastAnimation:(UIButton *)tappedButton {
    if(isAnimating)
        return;
    
    isAnimating = YES;
    if(!tinkView) {
        tinkView = [[UIView alloc] initWithFrame:[self getFrameFromRealImage]];
    } else {
        [tinkView setFrame:[self getFrameFromRealImage]];
        [[tinkView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    tinkView.alpha = .9f;
    tinkView.userInteractionEnabled = YES;
    [self.realImage addSubview:tinkView];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interuptTinkView)];
    [tinkView addGestureRecognizer:gesture];
    
    NSInteger isDoge = (int) (arc4random() % 20) + 1;
    UIImage *image = (isDoge == 20)? [UIImage imageNamed:@"doge"] : [UIImage imageNamed:@"wineRight"];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image];
    [imageView1 setFrame:CGRectMake(-image.size.width, .25f * HEIGHT(tinkView), WIDTH(imageView1), HEIGHT(imageView1))];
    [tinkView addSubview:imageView1];
    
    image = (isDoge == 20)? [UIImage imageNamed:@"doge2"] : [UIImage imageNamed:@"wineLeft"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image];
    [imageView2 setFrame:CGRectMake(WIDTH(tinkView) + image.size.width, .25f * HEIGHT(tinkView), WIDTH(imageView2), HEIGHT(imageView2))];
    [tinkView addSubview:imageView2];
    
    [UIView animateWithDuration:1.4 animations:^{
        [imageView1 setFrame:CGRectMake(.50 * WIDTH(tinkView) - image.size.width, Y2(imageView1), WIDTH(imageView1), HEIGHT(imageView1))];
        [imageView2 setFrame:CGRectMake(.50 * WIDTH(tinkView)                   , Y2(imageView1), WIDTH(imageView1), HEIGHT(imageView1))];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            tinkView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            isAnimating = NO;
            [tinkView removeFromSuperview];
            if(click != nil && [click isPlaying])
                [click stop];
        }];
    }];
    
    @try {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [UIView animateWithDuration:.95 animations:^{
            //Needed to fill with something to get the timer
            imageView1.alpha = .9;
            imageView2.alpha = .9;
        } completion:^(BOOL finished) {
            isAnimating = NO;
            NSString *toUse = (isDoge == 20)? @"dogeBark" : @"wineSound";
            NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:toUse ofType:@"mp3"]];
            click = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
            if(click != nil) {
                [click setVolume:1.0];
                [click play];
            }
        }];
    } @catch(NSException *e) {
        NSLog(@"Audio Bug, Breakpoint Exception?");
    }
}

/*
- (void)winePressed:(UITapGestureRecognizer *)recognizer {
    PFObject *wine = (self.object[@"unWinePointer"] != nil)? self.object[@"unWinePointer"] : self.object[@"unWinePendingPointer"];
    
    NSString *wineObjectId = [self.object objectForKey:@"wineID"];
    NSString *verified = [self.object objectForKey:@"verified"];
    
    if (!wineObjectId)
        wineObjectId = [wine objectId];
    
    UIStoryboard *checkIn = [UIStoryboard storyboardWithName:@"checkIn" bundle:nil];
    wineDetailViewController *checkInInitialController = [checkIn instantiateViewControllerWithIdentifier:@"wineDetail"];
    checkInInitialController.title = @"Check In";
    checkInInitialController.tabBarItem.image = [UIImage imageNamed:@"checkin.png"];
    checkInInitialController.wineObjectIdFromNewsFeed = wineObjectId;
    checkInInitialController.newsFeedObject = self.object;
    checkInInitialController.verified = verified;
        
    [self.delegate.navigationController pushViewController:checkInInitialController animated:YES];
}
 */

+ (BOOL)isNumeric:(NSString *)val {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if (val != nil && [val rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        if(![val isEqualToString:@""])
            return YES;
    }
    return NO;
}

@end

@implementation UITextView (DetailView)

- (void)updateDetailView:(NewsFeed *)object {
    UITextView *view = [[VCWineCell new] configureDetailView:object withFrame:CGRectZero];
    
    self.text = view.text;
    self.attributedText = view.attributedText;
}

- (CAGradientLayer *)makeGradient:(BOOL)upwards {
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)[[UIColor colorWithWhite:0 alpha:0] CGColor], (__bridge id)[[UIColor colorWithWhite:0 alpha:1] CGColor], nil];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:[self bounds]];
    [gradientLayer setColors:colors];
    if(upwards) {
        [gradientLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
        [gradientLayer setEndPoint:CGPointMake(0.0f, 1.0f)];
    } else {
        [gradientLayer setStartPoint:CGPointMake(0.0f, 1.0f)];
        [gradientLayer setEndPoint:CGPointMake(0.0f, 0.0f)];
    }
    gradientLayer.zPosition = -1;
    
    return gradientLayer;
}

@end
