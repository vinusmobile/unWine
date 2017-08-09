//
//  HeaderCell.m
//  unWine
//
//  Created by Bryce Boesen on 1/16/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "HeaderCell.h"
#import "VineCastTVC.h"
#import "NSDate+NVTimeAgo.h"
#import "ParseSubclasses.h"
#import "CameraStyleKitClass.h"

@interface ExpressBoltView : UIView

@property (nonatomic) HeaderCell *cell;

- (instancetype)initWithFrame:(CGRect)frame;

@end

@implementation HeaderCell {
    PFImageView *_occasionImage;
    ExpressBoltView *_expressImage;
    PFImageView *_levelImage;
    Merits *_levelMerit;
    PFImageView *_userImage;
    CascadingLabelView *_userInfoView;
    
    UILabel *_detailLabel;
    UILabel *_timerLabel;
}

static NSInteger buffer = 4;
static NSInteger iconDim = 24;
static NSInteger imageDim = 64;

- (void)setup {
    self.layer.masksToBounds = NO;
    
    CALayer *border = [CALayer layer];
    border.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border.frame = CGRectMake(2, 0, SCREEN_WIDTH - 4, .5);
    [self.layer addSublayer:border];
    
    CALayer *border2 = [CALayer layer];
    border2.backgroundColor = [[UIColor colorWithWhite:.65 alpha:1] CGColor];
    border2.frame = CGRectMake(2, VC_HEADER_CELL_HEIGHT - .5, SCREEN_WIDTH - 4, .5);
    [self.layer addSublayer:border2];
    
    _occasionImage = [[PFImageView alloc] initWithFrame:(CGRect){SCREEN_WIDTH - iconDim - buffer, buffer, {iconDim, iconDim}}];
    _occasionImage.userInteractionEnabled = YES;
    _occasionImage.contentMode = UIViewContentModeScaleAspectFill;
    _occasionImage.backgroundColor = [UIColor clearColor];
    //_occasionImage.layer.cornerRadius = _occasionImage.bounds.size.width / 2;
    [self.contentView addSubview:_occasionImage];
    
    _expressImage = [[ExpressBoltView alloc] initWithFrame:(CGRect){SCREEN_WIDTH - iconDim - buffer, buffer, {iconDim, iconDim}}];
    _expressImage.cell = self;
    _expressImage.backgroundColor = UNWINE_RED;
    _expressImage.layer.cornerRadius = _expressImage.bounds.size.width / 2;
    _expressImage.clipsToBounds = YES;
    [self.contentView addSubview:_expressImage];
    
    _levelImage = [[PFImageView alloc] initWithFrame:(CGRect){buffer, buffer, {iconDim, iconDim}}];
    _levelImage.userInteractionEnabled = self;
    _levelImage.backgroundColor = [UIColor clearColor];
    _levelImage.layer.cornerRadius = _levelImage.bounds.size.width / 2;
    _levelImage.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLevel)];
    [_levelImage addGestureRecognizer:tap];
    [self.contentView addSubview:_levelImage];
    
    _userImage = [[PFImageView alloc] initWithFrame:(CGRect){X2(_levelImage) + WIDTH(_levelImage) + buffer * 2, buffer, {imageDim, imageDim}}];
    _userImage.layer.cornerRadius = _userImage.bounds.size.width / 2;
    //_userImage.layer.masksToBounds = YES;
    _userImage.layer.borderWidth = .5f;
    _userImage.layer.borderColor = [[UIColor blackColor] CGColor];
    _userImage.clipsToBounds = YES;
    _userImage.userInteractionEnabled = YES;
    _userImage.contentMode = UIViewContentModeScaleAspectFill;
    _userImage.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *tapProfile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed:)];
    [_userImage addGestureRecognizer:tapProfile];
    [self.contentView addSubview:_userImage];
    
    NSInteger userInfoX = X2(_userImage) + WIDTH(_userImage) + buffer * 2;
    _userInfoView = [[CascadingLabelView alloc] initWithFrame:CGRectMake(userInfoX, buffer, SCREENWIDTH - userInfoX - buffer, VC_HEADER_CELL_HEIGHT - buffer * 2)];
    _userInfoView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_userInfoView];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.textColor = [UIColor blackColor];
    _detailLabel.textAlignment = NSTextAlignmentLeft;
    _detailLabel.adjustsFontSizeToFitWidth = YES;
    _detailLabel.minimumScaleFactor = .65;
    _detailLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePressed:)];
    [_detailLabel addGestureRecognizer:tapDetail];
    
    _timerLabel = [[UILabel alloc] init];
    _timerLabel.font = [UIFont fontWithName:VINECAST_FONT_BOLD size:10];
    _timerLabel.textColor = [UIColor darkGrayColor];
    
    self.backgroundColor = [UIColor lightTextColor];
    [self.contentView bringSubviewToFront:_occasionImage];
    [self.contentView bringSubviewToFront:_expressImage];
}

- (void)configureCell:(NewsFeed *)object withPath:(NSIndexPath *)indexPath {
    [super configureCell:object];
    
    [self configureSide:indexPath];
    [self configureUserImage:indexPath];
    [self configureUserInfo:indexPath];
}

- (void)configureUserImage:(NSIndexPath *)indexPath {
    User *user = self.object.authorPointer;
    if(user && [user isDataAvailable])
        [user setUserImageForImageView:_userImage];
    else
        _userImage.image = USER_PLACEHOLDER;
    _userImage.tag = indexPath.section;
}

- (void)configureSide:(NSIndexPath *)indexPath {
    [self configureOccasionImage:indexPath];
    [self configureLevelImage:indexPath];
    _expressImage.alpha = self.object.express ? 1 : 0;
}

- (void)configureOccasionImage:(NSIndexPath *)indexPath {
    if([self hasOccassionImage]) {
        _occasionImage.image = nil;
        _occasionImage.file = self.object.occasionPointer.image;
        [_occasionImage loadInBackground];
    } else
        _occasionImage.image = nil;
}

- (BOOL)hasOccassionImage {
    return self.object.occasionPointer && self.object.occasionPointer.image && ![self.object.occasionPointer.image isKindOfClass:[NSNull class]];
}


- (void)configureLevelImage:(NSIndexPath *)indexPath {
    User *user = self.object.authorPointer;
    if(user && [user isDataAvailable]) {
        //NSString *preLevel = user.level.objectId;
        [[user checkLevel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            if(task.error) {
                LOGGER(task.error);
            }
            Level *level = task.result;
            if(level && ![level isKindOfClass:[NSNull class]] && [level isDataAvailable]) {
                _levelImage.image = nil;
                
                if(level.merit && ![level.merit isKindOfClass:[NSNull class]] && [level.merit isDataAvailable]) {
                    _levelImage.file = level.merit.image;
                    _levelMerit = level.merit;
                    return [_levelImage loadInBackground];
                } else {
                    _levelMerit = nil;
                    _levelImage.image = nil;
                    return nil;
                }
            } else {
                _levelMerit = nil;
                _levelImage.image = nil;
                return nil;
            }
        }];
    } else {
        _levelMerit = nil;
        _levelImage.image = nil;
    }
}

- (void)showLevel {
    if(_levelMerit && ![_levelMerit isKindOfClass:[NSNull class]])
        [_levelMerit createCustomAlertView:MeritModeDiscoverMessage andShowShareOption:YES];
}

- (NSAttributedString *)createOccasionTimerText:(NSString *)timerText {
    NSDictionary *normDict = @{NSFontAttributeName: [UIFont fontWithName:VINECAST_FONT size:10],
                               NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    NSDictionary *boldDict = @{NSFontAttributeName: [UIFont fontWithName:VINECAST_FONT_BOLD size:10],
                               NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    if(self.object.occasionPointer && ![self.object.occasionPointer isKindOfClass:[NSNull class]]) {
        NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:self.object.occasionPointer.name attributes:boldDict];
        
        [attributed appendAttributedString:[[NSAttributedString alloc] initWithString:@" -- " attributes:normDict]];
        
        [attributed appendAttributedString:[[NSAttributedString alloc] initWithString:timerText attributes:boldDict]];
        
        return attributed;
    } else
       return [[NSAttributedString alloc] initWithString:timerText attributes:boldDict];
}

- (void)configureUserInfo:(NSIndexPath *)indexPath {
    [self configureDetailLabel];
    _timerLabel.attributedText = [self createOccasionTimerText:[self.object.createdAt formattedAsTimeAgo]];//object.createdAt.timeAgo;
    
    if(![_detailLabel isDescendantOfView:_userInfoView])
        [_userInfoView addSubview:_detailLabel];
    if(![_timerLabel isDescendantOfView:_userInfoView])
        [_userInfoView addSubview:_timerLabel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_userInfoView update];
    });
}
 
- (void)configureDetailLabel {
    NSString *nameString = self.object.authorPointer ? [self.object.authorPointer getName] : @"Deleted User";

    NSString *locationString = @"";
    if(self.object.venue && ![self.object.venue isKindOfClass:[NSNull class]])
        locationString = [self.object.venue.name capitalizedString];
    else if(ISVALID(self.object.location) && ![self.object.location isEqualToString:LOCATION_DEFAULT_MESSAGE])
        locationString = [self.object.location capitalizedString];
    
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:13];
    UIFont *boldFont = [UIFont fontWithName:@"OpenSans-Bold" size:14];

    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:@""];
    [formatted appendAttributedString:[self makeAttributed:nameString font:boldFont]];
    if(ISVALID(locationString)) {
        [formatted appendAttributedString:[self makeAttributed:@" at " font:font]];
        [formatted appendAttributedString:[self makeAttributed:locationString font:boldFont]];
    }
    
    _detailLabel.attributedText = formatted;
    _detailLabel.textAlignment = NSTextAlignmentLeft;
}

- (NSAttributedString *)makeAttributed:(NSString *)string font:(UIFont *)font {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    return [[NSAttributedString alloc] initWithString:string attributes:dict];
}

- (void)profilePressed:(UITapGestureRecognizer *)recognizer {
    User *user = self.object.authorPointer;
    if(!user || ![user isDataAvailable])
        return;

    CastProfileVC *profile = [[UIStoryboard storyboardWithName:@"CastProfile" bundle:nil] instantiateViewControllerWithIdentifier:@"profile"];
    
    profile.isProfileTab = NO;
    [profile setProfileUser:user];
    if(self.delegate.singleUser == nil) {
        [self.delegate.navigationController pushViewController:profile animated:YES];
    } /*else {
        [profile.profileTable profilePressed:recognizer];
    }*/
}

@end

@implementation ExpressBoltView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.exclusiveTouch = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDialog)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showDialog {
    CGRect placer = self.frame;
    placer.origin.x = 0;
    placer.origin.y -= 3;
    [[PopoverVC sharedInstance] showFrom:self.cell.delegate.navigationController
                              sourceView:self
                              sourceRect:placer
                               direction:UIPopoverArrowDirectionRight
                                    text:@"Short on Time? You can record your wine experience even faster with express check-in! Use the express check-in by searching a wine, and then pressing and holding down on the wine."];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [CameraStyleKitClass drawCameraFlashWithFrame:self.bounds];
}

@end
