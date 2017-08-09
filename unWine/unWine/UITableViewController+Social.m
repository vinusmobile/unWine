//
//  UITableViewController+Social.m
//  unWine
//
//  Created by Fabio Gomez on 3/16/17.
//  Copyright © 2017 LION Mobile. All rights reserved.
//

#import "UITableViewController+Social.h"
#import "MeritsTVC.h"
#import "FriendInviteTVC.h"
#import "ContactsInviteTVC.h"

static NSString *dialogInviteText = @"Invite by Text";
static NSString *dialogInviteEmail = @"Invite by Email";

@implementation UITableViewController (Social)
/*
 *
 * SHARING STUFF
 *
 */

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    @try {
        MeritAlertView *av = (MeritAlertView *)alertView;
        NSString *s = [NSString stringWithFormat:@"Clicked button %li", (long)buttonIndex];
        LOGGER(s);
        if (buttonIndex == 1) {
            NSArray *buttons = @[SHARE_FACEBOOK, SHARE_TEXT, SHARE_EMAIL];
            unWineActionSheet *sheet = [[unWineActionSheet alloc] initWithTitle:@"Share Merit"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                              otherButtonTitles:buttons];
            
            sheet.merit = av.merit;
            sheet.checkin = nil;
            [sheet showFromTabBar: self.navigationController.view];
        }
        
        [av close];
        
    } @catch (NSException *exception) {
        LOGGER(exception);
    }
}

- (void)actionSheet:(unWineActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    LOGGER(title);
    if (actionSheet.checkin == nil && actionSheet.merit == nil) {
        LOGGER(@"No checkin or merit to share!");
        return;
    }
    SHOW_HUD;
    UIImage *image = actionSheet.merit != nil ? [actionSheet.merit getShareImage] : [actionSheet.checkin getShareImage];
    NSString *caption = actionSheet.merit != nil ? [actionSheet.merit getShareCaption] : [actionSheet.checkin getShareCaption];
    HIDE_HUD;
    
    if (image == nil || caption == nil) {
        LOGGER(@"Got a nil situation with either body or image");
        if (image == nil) {
            LOGGER(@"Image is nil");
        }
        if (caption == nil) {
            LOGGER(@"caption is nil");
        }
        return;
    }
    
    NSString *s = [NSString stringWithFormat:@"Sharing %@ via ", actionSheet.merit != nil ? @"Merit" : @"Checkin"];
    BOOL hasCheckin = NO;
    if ( [actionSheet respondsToSelector:@selector(checkin)] ) {
        hasCheckin = (actionSheet.checkin != nil);
    }
    
    if([title isEqualToString:SHARE_FACEBOOK]) {
        [s stringByAppendingString:@"Facebook"];
        LOGGER(s);
        [self shareImageViaFacebook:image userGenerated:hasCheckin];
        
    } else if([title isEqualToString:SHARE_TEXT]) {
        [s stringByAppendingString:@"Text"];
        LOGGER(s);
        [self shareImageViaText:image withBody:caption hasCheckin:hasCheckin];
        
        
    } else if([title isEqualToString:SHARE_EMAIL]) {
        [s stringByAppendingString:@"Email"];
        LOGGER(s);
        [self shareImageViaEmail:image withBody:caption hasCheckin:hasCheckin];
        
    } else {
        LOGGER(@"Nada");
    }
}

- (void)shareImageViaFacebook:(UIImage *)image userGenerated:(BOOL)userGenerated {
    //LOGGER(@"Enter");
    if (FACEBOOK_IS_INSTALLED) {
        PFConfig *config = [PFConfig currentConfig];

        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = image;
        photo.userGenerated = userGenerated;

        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        content.hashtag = [FBSDKHashtag hashtagWithString:config[@"SHARE_HASHTAG"]];
        
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
    } else {
        [unWineAlertView showAlertViewWithTitle:SHARE_FACEBOOK message:@"Oops, you don't have facebook installed!" theme:unWineAlertThemeError];
    }
    
}

- (void)shareImageViaText:(UIImage *)image withBody:(NSString *)caption hasCheckin:(BOOL)hasCheckin {
    if([unWineSMSController canSendText]) {
        unWineSMSController *mc = [[unWineSMSController alloc] init]; // Create message VC
        if ([mc respondsToSelector:@selector(hasCheckin)] && mc.hasCheckin) {
            mc.hasCheckin = hasCheckin;
        }
        
        NSData *dataImg = UIImagePNGRepresentation(image);//Add the image as attachment
        
        [mc.navigationBar setTintColor:[UIColor whiteColor]];//cancel button will be of white color.
        [mc.navigationBar setBarTintColor:UNWINE_RED];//bar color will be black.
        
        mc.messageComposeDelegate = self; // Set delegate to current instance
        mc.body = caption;; // Set initial text to example message
        [mc addAttachmentData:dataImg typeIdentifier:@"public.data" filename:@"Image.png"];
        
        [self presentViewController:mc animated:YES completion:nil];
        
    } else {
        [unWineAlertView showAlertViewWithTitle:SHARE_TEXT message:@"This device cannot send text messages." theme:unWineAlertThemeError];
    }
}

- (void)shareImageViaEmail:(UIImage *)image withBody:(NSString *)caption hasCheckin:(BOOL)hasCheckin {
    if([unWineEmailController canSendMail]) {
        unWineEmailController * _mail = [[unWineEmailController alloc] init];
        if ( [_mail respondsToSelector:@selector(hasCheckin)] ) {
            _mail.hasCheckin = hasCheckin;
        }
        
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
        NSString *fileName = @"merit";
        
        _mail.mailComposeDelegate = self;
        _mail.navigationBar.tintColor = [UIColor whiteColor];
        [[_mail navigationBar] setBarTintColor:[UIColor whiteColor]];
        
        fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
        [_mail addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:fileName];
        
        [_mail setSubject:@"Check out unWine!"];
        [_mail setMessageBody:caption isHTML:NO];
        
        [self presentViewController:_mail animated:YES completion:nil];
        
    } else {
        [unWineAlertView showAlertViewWithTitle:SHARE_EMAIL message:@"This device has no email accounts registered!" theme:unWineAlertThemeError];
    }
}



// Delegates - Facebook Sharing

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    //LOGGER(@"Enter");
    // Determine if user generated (checkin) or not (merit)
    FBSDKSharePhoto *photo = FB_GET_PHOTO_CONTENT_FROM_SHARER(sharer);
    
    if (photo.userGenerated) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_CHECKIN_FACEBOOK);
    } else {
        if ([self isKindOfClass:[VineCastTVC class]]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_MERIT_FACEBOOK);
        } else if ([self isKindOfClass:[MeritsTVC class]]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_MERIT_FACEBOOK_MERIT_VIEW);
        } else {
            LOGGER(@"Nada");
        }
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    //LOGGER(@"Enter");
    // Determine if user generated (checkin) or not (merit)
    FBSDKSharePhoto *photo = FB_GET_PHOTO_CONTENT_FROM_SHARER(sharer);
    
    if (photo.userGenerated) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_CHECKIN_FACEBOOK);
    } else {
        if ([self isKindOfClass:[VineCastTVC class]]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_MERIT_FACEBOOK);
        } else if ([self isKindOfClass:[MeritsTVC class]]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_MERIT_FACEBOOK_MERIT_VIEW);
        } else {
            LOGGER(@"Nada");
        }
    }
    
    [CrashlyticsKit recordError:error];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    //LOGGER(@"Enter");
    // Determine if user generated (checkin) or not (merit)
    FBSDKSharePhoto *photo = FB_GET_PHOTO_CONTENT_FROM_SHARER(sharer);
    
    if (photo.userGenerated) {
        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_CHECKIN_FACEBOOK);
    } else {
        if ([self isKindOfClass:[VineCastTVC class]]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_MERIT_FACEBOOK);
        } else if ([self isKindOfClass:[MeritsTVC class]]) {
            ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_MERIT_FACEBOOK_MERIT_VIEW);
        } else {
            LOGGER(@"Nada");
        }
    }
}

// Delegates - Text
- (void)inviteText:(NSString *)recipient {
    
    if ([MFMessageComposeViewController canSendText] == NO) {
        [unWineAlertView showAlertViewWithTitle:dialogInviteText message:@"This device cannot send text messages." theme:unWineAlertThemeError];
        return;
    }
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:UNWINE_RED];
    MFMessageComposeViewController * _message = [[MFMessageComposeViewController alloc] init];
    
    _message.messageComposeDelegate = self;
    _message.navigationBar.backgroundColor = UNWINE_RED;
    [[_message navigationBar] setBarTintColor:UNWINE_RED];
    
    _message.body = [User getShareMessageAndURL];
    
    if (ISVALID(recipient)) {
        _message.recipients = @[recipient];
        
    } else {
        _message.recipients = @[];
    }
    
    SHOW_HUD;
    [self presentViewController:_message animated:YES completion:^{
        HIDE_HUD;
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:[UIColor whiteColor]];
    unWineSMSController *cont = (unWineSMSController *)controller;
    
    [cont dismissViewControllerAnimated:YES completion:^{
        switch(result) {
            case MessageComposeResultCancelled:
                if ( [cont respondsToSelector:@selector(hasCheckin)] && cont.hasCheckin) {
                    ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_CHECKIN_TEXT);
                } else {
                    if ([self isKindOfClass:[VineCastTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_MERIT_TEXT);

                    } else if ([self isKindOfClass:[MeritsTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_MERIT_TEXT_MERIT_VIEW);

                    } else if ([self isKindOfClass:[FriendInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_APP_SMS_FRIEND_TVC);
                        
                    } else if ([self isKindOfClass:[ContactsInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_APP_SMS_CONTACT_TVC);
                        
                    } else {
                        LOGGER(@"Nada");
                    }
                }
                break;
            case MessageComposeResultSent:
                if ( [cont respondsToSelector:@selector(hasCheckin)] && cont.hasCheckin) {
                    ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_CHECKIN_TEXT);
                } else {
                    if ([self isKindOfClass:[VineCastTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_MERIT_TEXT);

                    } else if ([self isKindOfClass:[MeritsTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_MERIT_TEXT_MERIT_VIEW);
                        
                    } else if ([self isKindOfClass:[FriendInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_APP_SMS_FRIEND_TVC);
                        [[User currentUser] sharedTheApp];
                        
                    } else if ([self isKindOfClass:[ContactsInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_APP_SMS_CONTACT_TVC);
                        [[User currentUser] sharedTheApp];
                        
                    } else {
                        LOGGER(@"Nada");
                    }
                }
                [self showAlertWithHeader:@"Text Invite Sent"
                                  message:@"The cat is out of the bag now."
                            andButtonText:@"OK"
                                    error:NO];
                break;
            case MessageComposeResultFailed:
                if ( [cont respondsToSelector:@selector(hasCheckin)] && cont.hasCheckin) {
                    ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_CHECKIN_TEXT);
                } else {
                    if ([self isKindOfClass:[VineCastTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_MERIT_TEXT);

                    } else if ([self isKindOfClass:[MeritsTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_MERIT_TEXT_MERIT_VIEW);

                    } else if ([self isKindOfClass:[FriendInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_APP_SMS_FRIEND_TVC);
                        
                    } else if ([self isKindOfClass:[ContactsInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_APP_SMS_CONTACT_TVC);
                        
                    } else {
                        LOGGER(@"Nada");
                    }
                }
                [self showAlertWithHeader:@"Spilled some wine"
                                  message:@"Text Invite failed to send."
                            andButtonText:@"OK"
                                    error:YES];
                break;
            default:
                break;
        }
    }];
}

// Email Stuff

- (void)inviteEmail:(NSString *)email {
    if([MFMailComposeViewController canSendMail] == NO) {
        [unWineAlertView showAlertViewWithTitle:dialogInviteEmail message:@"This device has no email accounts registered!" theme:unWineAlertThemeError];
        return;
    }
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:[UIColor whiteColor]];
    MFMailComposeViewController *_mail = [[MFMailComposeViewController alloc] init];
    _mail.mailComposeDelegate = self;
    
    if (ISVALID(email)) {
        [_mail setToRecipients:@[email]];
    } else {
        [_mail setToRecipients:@[]];
    }
    
    [_mail setSubject:@"Check out unWine!"];
    [_mail setMessageBody:[User getShareMessageAndURL] isHTML:NO];
    
    SHOW_HUD;
    [self presentViewController:_mail animated:YES completion:^{
        HIDE_HUD;
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    unWineEmailController *cont = (unWineEmailController *)controller;
    
    [cont dismissViewControllerAnimated:YES completion:^{
        if(error) {
            [unWineAlertView showAlertViewWithTitle:dialogInviteEmail error:error];
            return;
        }
        switch(result) {
            case MFMailComposeResultCancelled:
                if ( [cont respondsToSelector:@selector(hasCheckin)] && cont.hasCheckin) {
                    ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_CHECKIN_EMAIL);
                } else {
                    if ([self isKindOfClass:[VineCastTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_MERIT_EMAIL);

                    } else if ([self isKindOfClass:[MeritsTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_MERIT_EMAIL_MERIT_VIEW);

                    } else if ([self isKindOfClass:[FriendInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_APP_EMAIL_FRIEND_TVC);
                        
                    } else if ([self isKindOfClass:[ContactsInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_CANCELLED_SHARING_APP_EMAIL_CONTACT_TVC);
                        
                    } else {
                        LOGGER(@"Nada");
                    }
                }
                break;
            case MFMailComposeResultSent:
                if ( [cont respondsToSelector:@selector(hasCheckin)] && cont.hasCheckin) {
                    ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_CHECKIN_EMAIL);
                } else {
                    if ([self isKindOfClass:[VineCastTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_MERIT_EMAIL);

                    } else if ([self isKindOfClass:[MeritsTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_MERIT_EMAIL_MERIT_VIEW);

                    } else if ([self isKindOfClass:[FriendInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_APP_EMAIL_FRIEND_TVC);
                        [[User currentUser] sharedTheApp];
                        
                    } else if ([self isKindOfClass:[ContactsInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_SHARED_APP_EMAIL_CONTACT_TVC);
                        [[User currentUser] sharedTheApp];
                        
                    } else {
                        LOGGER(@"Nada");
                    }
                }
                
                [self showAlertWithHeader:@"Email Invite Sent"
                                  message:@"The cat is out of the bag now."
                            andButtonText:@"OK"
                                    error:NO];
                break;
            case MFMailComposeResultFailed:
                if ( [cont respondsToSelector:@selector(hasCheckin)] && cont.hasCheckin) {
                    ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_CHECKIN_EMAIL);
                } else {
                    if ([self isKindOfClass:[VineCastTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_MERIT_EMAIL);

                    } else if ([self isKindOfClass:[MeritsTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_MERIT_EMAIL_MERIT_VIEW);

                    } else if ([self isKindOfClass:[FriendInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_APP_EMAIL_FRIEND_TVC);
                        
                    } else if ([self isKindOfClass:[ContactsInviteTVC class]]) {
                        ANALYTICS_TRACK_EVENT(EVENT_USER_FAILED_TO_SHARE_APP_EMAIL_CONTACT_TVC);
                        
                    } else {
                        LOGGER(@"Nada");
                    }
                    
                    [Analytics trackError:error withName:@"Email Error" withMessage:@"Something happened"];
                }
                [self showAlertWithHeader:@"Spilled some wine"
                                  message:@"Email Invite failed to send."
                            andButtonText:@"OK"
                                    error:YES];
                break;
            default:
                break;
        }
    }];
}

- (void)showAlertWithHeader:(NSString *)header message:(NSString *)message andButtonText:(NSString *)buttonText error:(BOOL)error {
    NSString *s = [NSString stringWithFormat:@"Sending alert with:\nheader: %@\nmessage: %@\nbuttonText: %@\nerror: %@",
                   header, message, buttonText, (error ? @"YES" : @"NO")];
    LOGGER(s);
    dispatch_async(dispatch_get_main_queue(), ^{
        ABKInAppMessageButton *button = [[ABKInAppMessageButton alloc] init];
        button.buttonText = buttonText;
        button.buttonTextColor = UNWINE_WHITE;
        button.buttonBackgroundColor = error ? UNWINE_RED_NEW : UNWINE_GREEN_NEW;
        [button setButtonClickAction:ABKInAppMessageNoneClickAction withURI:nil];
        
        ABKInAppMessageModal *alert = [[ABKInAppMessageModal alloc] init];
        alert.header = header;
        alert.message = message;
        alert.closeButtonColor = UNWINE_BLACK;
        alert.backgroundColor = UNWINE_WHITE;
        [alert setInAppMessageButtons:@[button]];
        
        [[Appboy sharedInstance].inAppMessageController addInAppMessage:alert];
    });
}
@end
