//
//  MediaHelper.m
//  unWine
//
//  Created by Bryce Boesen on 11/16/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "MediaHelper.h"

@interface MediaObject : NSObject

@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *preset;

+ (instancetype)fileName:(NSString *)fileName preset:(NSString *)preset;

@end

@import AVFoundation;
@import AssetsLibrary;
@implementation MediaHelper

+ (NSArray *)output {
    static NSMutableArray * _output = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _output = [[NSMutableArray alloc] init];
        /*[_output insertObject:[MediaObject fileName:@"output-4K.mp4" preset:AVAssetExportPreset3840x2160]
                      atIndex:CIVideoQuality4K];
        [_output insertObject:[MediaObject fileName:@"output-2K.mp4" preset:AVAssetExportPresetHighestQuality]
                      atIndex:CIVideoQuality2K];*/
        [_output insertObject:[MediaObject fileName:@"output-1080p.mp4" preset:AVAssetExportPreset1920x1080]
                      atIndex:CIVideoQuality1080p];
        [_output insertObject:[MediaObject fileName:@"output-720p.mp4" preset:AVAssetExportPreset1280x720]
                      atIndex:CIVideoQuality720p];
        [_output insertObject:[MediaObject fileName:@"output-540p.mp4" preset:AVAssetExportPreset960x540]
                      atIndex:CIVideoQuality540p];
        [_output insertObject:[MediaObject fileName:@"output-480p.mp4" preset:AVAssetExportPreset640x480]
                      atIndex:CIVideoQuality480p];
        [_output insertObject:[MediaObject fileName:@"output-320p.mp4" preset:AVAssetExportPresetLowQuality]
                      atIndex:CIVideoQuality320p];
        [_output insertObject:[MediaObject fileName:@"output.mp4" preset:AVAssetExportPresetPassthrough]
                      atIndex:CIVideoQualityNone];
    });
    
    return _output;
}

+ (NSString *)outputFileName:(CIVideoQuality)quality {
    return [[[self output] objectAtIndex:quality] fileName];
}

+ (NSString *)outputPreset:(CIVideoQuality)quality {
    return [[[self output] objectAtIndex:quality] preset];
}

+ (BFTask *)getContentForFacebookWithImage:(UIImage *)image {
    return [self getContentForFacebookWithThumbnail:image andMovieURL:nil andRefURL:nil];
}

+ (BFTask *)getContentForFacebookWithThumbnail:(UIImage *)image andMovieURL:(NSURL *)movieURL andRefURL:(NSURL *)refMovieURL {
    PFConfig *config = [PFConfig currentConfig];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = [UIImage imageWithCGImage:[image CGImage]];
    photo.userGenerated = YES;
    //photo.caption = @"#unwine";
    
    if(movieURL) {
        //NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_1007" ofType:@"mp4"]];
        
        BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
        if(refMovieURL) {
            FBSDKShareVideo *video = [FBSDKShareVideo videoWithVideoURL:refMovieURL];
            
            FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
            content.video = video;
            content.previewPhoto = photo;
            
            [task setResult:content];
        } else {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if([library videoAtPathIsCompatibleWithSavedPhotosAlbum:movieURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                    if(!error) {
                        FBSDKShareVideo *video = [FBSDKShareVideo videoWithVideoURL:assetURL];
                        
                        FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
                        content.video = video;
                        content.previewPhoto = photo;
                        content.hashtag = [FBSDKHashtag hashtagWithString:config[@"SHARE_HASHTAG"]];
                        
                        [task setResult:content];
                    } else {
                        [task setError:error];
                    }
                }];
            } else {
                [task setError:[unWineError createGenericErrorWithMessage:@"Incompatible media provided."]];
            }
        }
        
        return task.task;
    } else {
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        content.hashtag = [FBSDKHashtag hashtagWithString:config[@"SHARE_HASHTAG"]];
        
        return [BFTask taskWithResult:content];
    }
}

@end

@implementation MediaObject

+ (instancetype)fileName:(NSString *)fileName preset:(NSString *)preset {
    MediaObject *obj = [[MediaObject alloc] init];
    obj.fileName = fileName;
    obj.preset = preset;
    return obj;
}

@end
