//
//  UITableViewController+Social.h
//  unWine
//
//  Created by Fabio Gomez on 3/16/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "unWineSMSController.h"
#import "unWineEmailController.h"
#import <Crashlytics/Crashlytics.h>
#import "unWineActionSheet.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "Appboy.h"
#import "AppboyKit.h"

@interface UIViewController (Social) <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBSDKSharingDelegate, FBSDKAppInviteDialogDelegate, CustomIOSAlertViewDelegate, unWineActionSheetDelegate>

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

- (void)shareImageViaFacebook:(UIImage *)image userGenerated:(BOOL)userGenerated;

- (void)shareImageViaText:(UIImage *)image withBody:(NSString *)caption hasCheckin:(BOOL)hasCheckin;

- (void)shareImageViaEmail:(UIImage *)image withBody:(NSString *)caption hasCheckin:(BOOL)hasCheckin;

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results;

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error;

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer;

// SMS Stuff
- (void)inviteText:(NSString *)recipient;
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result;

// Email Stuff
- (void)inviteEmail:(NSString *)email;
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;

// Facebook Stuff
- (void)inviteFacebook;
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results;
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error;

// unWine User Stuff
- (BFTask *)addAllUnWineUsers:(NSArray <User *>*)users;

// UI Stuff
- (void)showAlertWithHeader:(NSString *)header message:(NSString *)message andButtonText:(NSString *)buttonText error:(BOOL)error;
- (void)showSocialVC:(BOOL)signUpMode;
@end
