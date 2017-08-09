//
//  Merits.m
//  unWine
//
//  Created by Bryce Boesen on 8/21/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "Merits.h"
#import "MeritsTVC.h"
#import <GPUImage/GPUImage.h>

@implementation Merits
@dynamic Index, description, identifier, image, message, name, type;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Merits";
}

- (void)setMeritImageForImageView:(PFImageView *)imageView {
    //imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = MERIT_PLACEHOLDER;
    if(!self.image || [self.image isKindOfClass:[NSNull class]])
        return;
    
    imageView.file = self.image;
    [imageView loadInBackground/*:^(UIImage * _Nullable image, NSError * _Nullable error) {
                                GPUImagePicture *source = [[GPUImagePicture alloc] initWithImage:image];
                                GPUImageMonochromeFilter *filter = [[GPUImageMonochromeFilter alloc] init];
                                [filter setColor:(GPUVector4){192.0f / 255, 192.0f / 255, 192.0f / 255, 1.f}];
                                [filter setIntensity:.7];
                                
                                [source addTarget:filter];
                                [filter useNextFrameForImageCapture];
                                [source processImage];
                                
                                UIImage *filtered = [filter imageFromCurrentFramebuffer];//imageByFilteringImage:[UIImage imageNamed:@"silvertexture.jpg"]];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                imageView.image = filtered;
                                imageView.layer.borderColor = [[UIColor colorWithWhite:192.f / 255 alpha:1] CGColor];
                                imageView.layer.borderWidth = 3;
                                });
                                }*/];
}

- (MeritAlertView *)createCustomAlertView:(NSInteger)meritMode andShowShareOption:(BOOL)show {
    return [self createCustomAlertView:meritMode andMerits:[User currentUser].earnedMerits andShowShareOption:show];
}

- (MeritAlertView *)createCustomAlertView:(NSInteger)meritMode andMerits:(NSArray *)earnedMerits andShowShareOption:(BOOL)show {
    NSArray *buttons = show ? @[@"OK", @"Share"] : @[@"OK"];
    MeritAlertView *alertView = [[MeritAlertView alloc] init];
    alertView.merit = self;
    [alertView setContainerView:[self createMeritAlertView:self meritMode:meritMode andMerits:earnedMerits]];
    [alertView setButtonTitles:buttons];
    [alertView setUseMotionEffects:true];
    [alertView show];
    
    for(UIView *view in [alertView subviews]) {
        if([view isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)view;
            [textView flashScrollIndicators];
        }
    }
    
    return alertView;
}

- (UIView *)createMeritAlertView:(Merits *)merit meritMode:(NSInteger)meritMode {
    return [self createMeritAlertView:merit meritMode:meritMode andMerits:[User currentUser].earnedMerits];
}

- (UIView *)createMeritAlertView:(Merits *)merit meritMode:(NSInteger)meritMode andMerits:(NSArray *)earnedMerits {
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 274)];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(35.0f, 20.0f, 180.0f, 22.0f)];
    title.text = @"Merit";
    title.backgroundColor = [UIColor clearColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"Avenir Next" size:20.0f];
    [demoView addSubview:title];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(75, 48, 100, 100)];
    if(meritMode == MeritModeDiscover || meritMode == MeritModeDiscoverMessage) {
        PFFile *imageFile = [merit objectForKey:@"image"];
        if(imageFile != nil && ![imageFile isKindOfClass:[NSNull class]]) {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    imageView.image = image;
                }
            }];
        } else
            imageView.image = MERIT_PLACEHOLDER;
    } else {
        if([earnedMerits containsObject:merit.objectId]) {
            PFFile *imageFile = [merit objectForKey:@"image"];
            if(imageFile != nil && ![imageFile isKindOfClass:[NSNull class]]) {
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        imageView.image = image;
                    }
                }];
            } else
                imageView.image = MERIT_PLACEHOLDER;
        } else {
            imageView.image = MERIT_PLACEHOLDER;
        }
    }
    [demoView addSubview:imageView];
    
    UILabel *meritName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 155.0f, 226.0f, 22.0f)];
    meritName.text = merit.name;
    meritName.backgroundColor = [UIColor clearColor];
    meritName.textAlignment = NSTextAlignmentCenter;
    meritName.font = [UIFont fontWithName:@"Avenir Next" size:20.0f];
    meritName.numberOfLines = 1;
    meritName.minimumScaleFactor = .50;
    meritName.adjustsFontSizeToFitWidth = YES;
    [demoView addSubview:meritName];
    
    //NSLog(@"%@", merit.description);
    
    UITextView *meritMessage = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 180.0f, 230.0f, 120.0f)];
    meritMessage.text = (meritMode == MeritModeDiscoverMessage || [earnedMerits containsObject:merit.objectId]) ? merit.message : merit[@"description"];
    meritMessage.backgroundColor = [UIColor clearColor];
    meritMessage.textColor = [UIColor colorWithRed:107/255.0f green:107/255.0f blue:107/255.0f alpha:1.0f];
    meritMessage.textAlignment = NSTextAlignmentCenter;
    meritMessage.font = [UIFont fontWithName:@"Avenir Next" size:13];
    meritMessage.editable = NO;
    [meritMessage sizeToFit];
    [meritMessage setFrame:CGRectMake(10.0f, 180.0f, 230.0f, HEIGHT(meritMessage))];
    [demoView addSubview:meritMessage];
    
    CGRect frame = demoView.frame;
    frame.size.height = Y2(meritMessage) + HEIGHT(meritMessage) + 6;
    [demoView setFrame:frame];
    return demoView;
}

- (NSString *)getShareURL {
    LOGGER(@"Getting the latest config for IOS_APP_STORE_URL...");
    PFConfig *config = [PFConfig currentConfig];
    return config[@"IOS_APP_STORE_URL"];
}

- (NSDictionary *)getShareContent {
    UIImage *img = [UIImage imageWithData:[self.image getData]];
    NSString *caption = [NSString stringWithFormat:
                         @"%@ just earned the \"%@\" merit on the unWine app!\n\n%@",
                         [[User currentUser] getFirstName],
                         self.name,
                         [self getShareURL]];
    
    return @{@"image": img, @"caption": caption};
}

- (UIImage *)getShareImage {
    return [self getShareContent][@"image"];
}

- (NSString *)getShareCaption {
    return [self getShareContent][@"caption"];
}

@end
