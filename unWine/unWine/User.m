//
//  User.m
//  unWine
//
//  Created by Fabio Gomez on 7/22/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#import "User.h"
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseTwitterUtils/PFTwitterUtils.h>
#import <ParseTwitterUtils/PF_Twitter.h>
#import <TwitterKit/TwitterKit.h>
#import <ParseUI/ParseUI.h>
//#import "ScrollCell.h"
#import <Bolts/Bolts.h>
#import "unWine.h"
#import "Friendship.h"
#import "MainLogInViewController.h"
#import "AppboyKit.h"
#import "unWineAlertLoginView.h"
#import "SlackHelper.h"
#import "UserCell.h"
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <TwitterKit/TwitterKit.h>
#import "LoginVC.h"
#import "MBProgressHUD.h"
#import <Intercom/Intercom.h>

#define EXIT_IF_NOT_PFUSER  if (![self.parseClassName isEqualToString:PFUserClassName]) {   \
NSLog(@"This is not a PFUser Object");                      \
return nil;                                                 \
}

@interface User () <SearchableSubclass>
@end

static NSInteger FILTERS_LOCKED_AFTER = 0;
static NSInteger SUPER_USER_CHECKIN_COUNT = 0;
static NSString *SHARE_MESSAGE = @"Befriend me on unWine! The fun and simple way to enjoy and discover wine with your friends. 😃 🍷";
static NSString *IOS_APP_STORE_URL = @"http://unwine.me/get_unwine/";
static NSArray *cachedLevels = nil;

@implementation User {
    BFTask *friendCache;
    UIViewController *viewc;
    
}

@dynamic acceptedTerms, imageFile, canonicalName, phoneNumber, checkIns, cellar, friends, uniqueWines, profile, earnedMerits, Likes, location, gender, facebookId, facebookPhotoURL, freeplays, highscores, birthday, level, emailVerified, version, emailUnsubscribed, isAdmin, currency, currencyTotal, friendCount, cellarCount, lastLogin, blockedUsers, creditedWines, hasPhotoFilters, notifications, isSuperUser, recentCheckins, recentSearches, userSettings, twitterHandle, seenTutorial, followedWineries, timezone, palateData, sharedApp, ratedApp, hasWineRecommendations, recommendationPromptType;
@synthesize theCellar = _theCellar, grapes = _grapes, friendsList = _friendsList, checkins = _checkins, contributions = _contributions, ratings = _ratings, locations = _locations, isUnwinegineer = _isUnwinegineer;

+ (void)load {
    [self registerSubclass];
}

/*
 * SIGN UP STUFF
 */

- (BFTask *)initializeAndThenSignUp {
    self.Likes          = [NSMutableArray arrayWithArray:@[]];
    self.cellar         = [NSMutableArray arrayWithArray:@[]];
    self.friends        = [NSMutableArray arrayWithArray:@[]];
    self.earnedMerits   = [NSMutableArray arrayWithArray:@[]];
    self.uniqueWines    = 0;
    self.checkIns       = 0;
    self.acceptedTerms  = YES;
    self.lastLogin      = [NSDate date];
    [self getNotifications];
    
    LOGGER(self.description);
    
    return [self signUpInBackground];
}

- (BFTask *)signUpUserWithHUD:(MBProgressHUD *)hud {
    BFTask *task = nil;
    LOGGER(@"Signing up User");
    
    if (self.imageFile.isDirty) {
        LOGGER(@"Signing up and loading photo");
        task = [self uploadPictureAndThenSignUpWithHUD:(MBProgressHUD *)hud];
    } else {
        LOGGER(@"Signing up with no photo");
        task = [self initializeAndThenSignUp];
    }
    
    return task;
}


- (BFTask *)uploadPictureAndThenSignUpWithHUD:(MBProgressHUD *)hud {
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self setUpHUD:hud];
    
    // Save PFFile
    
    [[[[self saveImageWithProgressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        if (hud) {
            hud.progress = (float)percentDone/100;
        }
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Signing Up User in Background");
        //self.imageFile = task.result;
        return [self initializeAndThenSignUp];
        
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Successfully Signed Up user");
        //[self sendTutorialEmail];
        [self saveInstallation];
        
        [theTask setResult:task.result];
        return nil;
        
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            LOGGER(@"Error signing up user");
            LOGGER(task.error.userInfo);
            [theTask setError:task.error];
        } else {
            //[theTask setResult:@"Something happened"];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

/*
 * END OF SIGN UP STUFF
 */


/*
 * USER INIT STUFF
 */

+ (void)unwitnessAllAlerts {
    [self unwitness:WITNESS_ALERT_WISH_LIST];
    [self unwitness:WITNESS_ALERT_VINECAST];
    [self unwitness:WITNESS_ALERT_DAILY_TOAST];
    [self unwitness:WITNESS_ALERT_MERIT];
    [self unwitness:WITNESS_ALERT_TOAST];
    [self unwitness:WITNESS_ALERT_CHECKIN];
    [self unwitness:WITNESS_ALERT_UNIQUE_WINES];
    [self unwitness:WITNESS_ALERT_GRAPES];
    [self unwitness:WITNESS_ALERT_GREAT_REACT];
}

// TODO: Makes this return a BFTask and execute with main thread on receiving end
+ (BFTask *)initStuffWithUser:(User *)user {
    if(!user) {
        LOGGER(@"Something called me wrong");
        return [BFTask taskWithError:[NSError errorWithDomain:@"Init Error"
                                                         code:500
                                                     userInfo:@{@"message" : @"No PFUser in session"}]];
    }
    
    LOGGER(user.objectId);
    [user updateInstallation];
    user.acceptedTerms = YES;
    
    return [user saveInBackground];
}

- (BFTask *)updateSocialMediaInfo {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    if ([self hasTwitter] && !ISVALID(self.twitterHandle)) {
        LOGGER(@"Updating Twitter Data");
        [[User twitterLogin] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if (t.error) {
                [theTask setError:t.error];
            } else {
                [theTask setResult:@(true)];
            }
            
            return nil;
        }];
        
    } else if ([self hasFacebook] && !ISVALID(self.facebookId)) {
        LOGGER(@"Updating Twitter Data");
        [[User facebookLogin] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if (t.error) {
                [theTask setError:t.error];
            } else {
                [theTask setResult:@(true)];
            }
            
            return nil;
        }];
    } else {
        LOGGER(@"Either have all info already or user is GUEST");
        [theTask setResult:@(true)];
    }
    
    return theTask.task;
}

/*
 * END OF USER INIT STUFF
 */

/*
 * ERROR STUFF
 */

+ (NSError *)createErrorWithDomain:(NSString *)domain
                       description:(NSString *)description
                            reason:(NSString *)reason
                     andSuggestion:(NSString *)suggestion {
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey:
                                   NSLocalizedString(ISVALID(description) ?
                                                     description :
                                                     @"Operation was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey:
                                   NSLocalizedString(ISVALID(reason) ?
                                                     reason :
                                                     @"The operation timed out.", nil),
                               NSLocalizedRecoverySuggestionErrorKey:
                                   NSLocalizedString(ISVALID(suggestion) ?
                                                     suggestion :
                                                     @"Have you tried turning it off and on again?", nil)
                               };
    NSError *error = [NSError errorWithDomain:ISVALID(domain) ? domain : @"User Error"
                                         code:-57
                                     userInfo:userInfo];
    
    return error;
}

/*
 * END OF ERROR STUFF
 */

/*
 * TWITER STUFF
 */

+ (BFTask *)twitterLogin {
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block User *user = [User currentUser];
    __block NSString *email = nil;
    __block NSError *loginError = nil;
    __block NSDictionary *twitterData = nil;
    
    // To know whether we need to delete user or not
    BFTask *deleteTask = user ? [User deleteAndLogoutGuest] : [BFTask taskWithResult:@"Success"];
    
    [[[[[[[deleteTask continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        LOGGER(@"Logged out and Deleted guest user");
        return [PFTwitterUtils logInInBackground];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        // Clearing out user to make sure we get newly signed in user
        user = nil;
        user = (User *)task.result;
        
        // Saving Parse Twitter Session to Twitter
        return [User saveParseTwitterSessionToTwitter];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        LOGGER(@"Saved Parse Session to Twitter");
        LOGGER(@"Getting Twitter Email\n\n");
        return [User getTwitterUserData];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        twitterData = (NSDictionary *)task.result;
        LOGGER(@"Got Twitter Email:");
        LOGGER(email);
        
        NSString *email = twitterData[@"email"];
        BFTask *t = nil;
        
        if (!ISVALID(email)) {
            LOGGER(@"Twitter Email is blank");
            t = [BFTask taskWithError:[User createErrorWithDomain:@"Twitter Login Error"
                                                      description:@"unWine needs an email address to give you the full experience. Without it, you are unable to contact us directly for feedback or feature requests, add friends, and much more!"
                                                           reason:nil
                                                    andSuggestion:nil]];
        } else {
            t = [User getUserWithEmail:email];
        }
        
        return t;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<User *> * _Nonnull task) {
        BFTask *t = nil;
        
        // Fail if we get a user back with same email address but different object id
        if (task.result && ![task.result.objectId isEqualToString:user.objectId]) {
            LOGGER(@"EMAIL TAKEN");
            t = [BFTask taskWithError:[User createErrorWithDomain:@"Login Error"
                                                      description:@"Email is taken. Please use a different email."
                                                           reason:@"Email is taken"
                                                    andSuggestion:@"Please use a different email."]];
        } else {
            LOGGER(@"Email not taken.");
            LOGGER(@"Initializing Twitter User");
            t = [User initWithTwitterUser:user andTwitterData:twitterData];
        }
        
        return t;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        BFTask *t = nil;
        if (!task.error) {
            LOGGER(@"Nothing to do here");
            t = [BFTask taskWithResult:@(true)];
        } else {
            LOGGER(@"Login error");
            loginError = task.error;
            
            LOGGER(@"Logging out user");
            t = [User logOutAndDismiss:nil];
        }
        return t;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (loginError) {
            LOGGER(@"Error logging in");
            [theTask setError:loginError];
            
        } else if (t.error) {
            LOGGER(@"Error while logging out");
            [theTask setError:t.error];
            
        } else {
            LOGGER(@"Success Login In");
            [theTask setResult:user];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

+ (BFTask *)saveParseTwitterSessionToTwitter {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    
    [store saveSessionWithAuthToken:[PFTwitterUtils twitter].authToken authTokenSecret:[PFTwitterUtils twitter].authTokenSecret completion:^(id<TWTRAuthSession>  _Nullable session, NSError * _Nullable error) {
        
        if (error) {
            LOGGER(@"Error saving Parse Twitter Auth Token to Twitter Session");
            [theTask setError:error];
            return;
        }
        
        LOGGER(@"Succesfully saved Parse Twitter Auth Token to Twitter Session");
        [theTask setResult:@"Success"];
    }];
    
    
    return theTask.task;
}

+ (BFTask *)getTwitterUserData {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
    NSURLRequest *request = [client URLRequestWithMethod:@"GET"
                                                     URL:@"https://api.twitter.com/1.1/account/verify_credentials.json"
                                              parameters:@{@"include_email": @"true",
                                                           @"skip_status": @"true"}
                                                   error:nil];
    
    [client sendTwitterRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            LOGGER(@"Error Getting Twitter Data");
            [theTask setError:error];
            return;
        }
        
        NSError *jerror = nil;
        NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jerror];
        
        if (jerror) {
            LOGGER(@"Error parsing out Twitter Data");
            [theTask setError:jerror];
            return;
        }
        
        [theTask setResult:jsonArray];
    }];
    
    return theTask.task;
}

+ (BFTask *)initWithTwitterUser:(User *)user andTwitterData:(NSDictionary *)data {
    BFTaskCompletionSource *complete = [BFTaskCompletionSource taskCompletionSource];
    BFTask *t = ISVALIDOBJECT(data) ? [BFTask taskWithResult:data] : [User getTwitterUserData];
    
    [[t continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSDictionary *result = (NSDictionary *)t.result;
        NSString *s = [NSString stringWithFormat:@"debug result - %@", result];
        LOGGER(s);
        
        NSString *imageRaw = [result objectForKey:@"profile_image_url_https"];
        NSURL *photoURL = [NSURL URLWithString:[imageRaw stringByReplacingOccurrencesOfString:@"_normal"
                                                                                   withString:@"_400x400"]];
        
        if(photoURL)
            user.imageFile = [PFFile fileWithData:[NSData dataWithContentsOfURL:photoURL]];
        
        user.canonicalName = result[@"name"];
        user.twitterHandle = result[@"screen_name"];
        user.email = result[@"email"];
        
        return [User initStuffWithUser:user];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            [complete setError:t.error];
        } else {
            [complete setResult:@(YES)];
        }
        
        return nil;
    }];
    
    return complete.task;
}

/*
 * END OF TWITER STUFF
 */


/*
 * FACEBOOK STUFF
 */

+ (BFTask *)facebookLogin {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block User *user = [User currentUser];
    __block NSError *loginError = nil;
    __block NSDictionary *facebookData = nil;
    
    // To know whether we need to delete user or not
    BFTask *deleteTask = user ? [User deleteAndLogoutGuest] : [BFTask taskWithResult:@"Success"];
    
    [[[[[[deleteTask continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        LOGGER(@"Logged out and Deleted guest user");
        return [PFFacebookUtils logInInBackgroundWithReadPermissions:FACEBOOK_PERMISSIONS];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        // Clearing out user to make sure we get newly signed in user
        user = nil;
        user = (User *)task.result;

        return [User getFacebookUserData];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        facebookData = (NSDictionary *)task.result;
        NSString *email = facebookData[@"email"];
        BFTask *t = nil;
        
        LOGGER(@"Got Facebook Email:");
        LOGGER(email);
        
        if (!ISVALID(email)) {
            LOGGER(@"Facebook Email is blank");
            t = [BFTask taskWithError:[User createErrorWithDomain:@"Facebook Login Error"
                                                      description:@"unWine needs an email address to give you the full experience. Without it, you are unable to contact us directly for feedback or feature requests, add friends, and much more!"
                                                           reason:nil
                                                    andSuggestion:nil]];
        } else {
            t = [User getUserWithEmail:email];
        }
        
        return t;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<User *> * _Nonnull task) {
        BFTask *t = nil;
        
        // Fail if we get a user back with same email address but different object id
        if (task.result && ![task.result.objectId isEqualToString:user.objectId]) {
            LOGGER(@"EMAIL TAKEN");
            t = [BFTask taskWithError:[User createErrorWithDomain:@"Login Error"
                                                      description:@"Email is taken. Please use a different email."
                                                           reason:@"Email is taken"
                                                    andSuggestion:@"Please use a different email."]];
        } else {
            LOGGER(@"Email not taken.");
            LOGGER(@"Initializing Facebook User");
            t = [User initWithFacebookUser:user andFacebookData:facebookData];
        }
        
        return t;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        BFTask *t = nil;
        if (!task.error) {
            LOGGER(@"Nothing to do here");
            t = [BFTask taskWithResult:@(true)];
        } else {
            LOGGER(@"Login error");
            loginError = task.error;
            
            LOGGER(@"Logging out user");
            t = [User logOutAndDismiss:nil];
        }
        return t;
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (loginError) {
            LOGGER(@"Error logging in");
            [theTask setError:loginError];
            
        } else if (t.error) {
            LOGGER(@"Error while logging out");
            [theTask setError:t.error];
            
        } else {
            LOGGER(@"Success Login In");
            [theTask setResult:user];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

+ (BFTask *)getFacebookUserData {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSDictionary *params = @{@"fields": @"id, name, email, location, gender, birthday"};
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if(!error) {
             NSDictionary *userData = (NSDictionary *)result;
             NSLog(@"userData - %@", userData);
             
             [theTask setResult:userData];
             
         } else {
             [theTask setError:error];
         }
     }];
    
    return theTask.task;
}

+ (BFTask <NSArray <NSDictionary*>*>*)getFacebookFriends {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    NSDictionary *params = @{@"fields": @"id, name, email, location, gender, birthday"};
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"me/friends"
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if(!error) {
            NSDictionary *userData = (NSDictionary *)result;
            NSString *s = [NSString stringWithFormat:@"friends - %@", userData];
            LOGGER(s);
            
            [theTask setResult:userData[@"data"]];
            
        } else {
            [theTask setError:error];
        }
    }];
    
    return theTask.task;
}

+ (BFTask <NSMutableArray <User *>*>*)getUsersFromFacebookFriends {
    LOGGER(@"Enter");
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    [[[User getFacebookFriends] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<NSDictionary *> *> * _Nonnull t) {
        BFTask *task = nil;
        
        if (t.result && t.result.count == 0) {
            LOGGER(@"Found no Facebook friends");
            task = [BFTask taskWithResult:@[]];

        } else if (t.result && t.result.count > 0) {
            NSMutableArray *tasks = [[NSMutableArray alloc] init];
            for (int i=0; i<t.result.count; i++) {
                NSDictionary *facebookUser = [t.result objectAtIndex:i];
                [tasks addObject:[User findUserMatchingFacebookUser:facebookUser]];
            }
            NSString *s = [NSString stringWithFormat:@"About to look for %li unWine Users from Facebook", t.result.count];
            LOGGER(s);
            task = [BFTask taskForCompletionOfAllTasksWithResults:tasks];
        }
        
        return task;

    }] continueWithBlock:^id _Nullable(BFTask <NSArray <User*>*>* _Nonnull t) {
        
        if (t.error) {
            LOGGER(@"Something happened when finding unWineUsers from Facebook");
            
            [theTask setError:t.error];
            return nil;
        }
        
        // Loop through results and
        NSString *s = [NSString stringWithFormat:@"Found %lu friends in unWine from Facebook with potential nulls", ((NSArray *)t.result).count];
        LOGGER(s);
        
        NSMutableArray *results = [[NSMutableArray alloc] initWithArray:t.result];
        [results removeObjectIdenticalTo:[NSNull null]];
        
        s = [NSString stringWithFormat:@"Found %lu friends in unWine from Facebook after removing potential nulls", results.count];
        LOGGER(s);
        
        [theTask setResult:results];
        
        return nil;
    }];
    
    return theTask.task;
}

+ (BFTask <User*>*)findUserMatchingFacebookUser:(NSDictionary *)facebookUser {
    if (facebookUser == nil) {
        LOGGER(@"No valid user provided. Exiting");
        return [BFTask taskWithResult:[NSNull null]];
    }
    
    NSString *idString = [facebookUser objectForKey:@"id"] ? facebookUser[@"id"] : @"";
    NSString *nameString = [facebookUser objectForKey:@"name"] ? ((NSString *)facebookUser[@"name"]).lowercaseString : @"";
    
    if (!ISVALID(idString)) {
        LOGGER(@"No id string in Facebook User. Exiting");
        return [BFTask taskWithResult:[NSNull null]];
    }
    
    if (!ISVALID(nameString)) {
        LOGGER(@"No name string in Facebook User. Exiting");
        return [BFTask taskWithResult:[NSNull null]];
    }
    
    LOGGER(@"Valid facebook user provided");
    
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    PFQuery *query1 = [User query];
    [query1 whereKey:@"facebookId" equalTo:idString];
    
    PFQuery *query2 = [User query];
    [query2 whereKey:@"canonicalName" equalTo:nameString];
    
    PFQuery *userQuery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    
    [[userQuery getFirstObjectInBackground] continueWithBlock:^id _Nullable(BFTask <User *>* _Nonnull t) {
        
        if (t.error) {
            LOGGER(@"Error getting user");
            LOGGER(t.error);
            
            if (t.error.code != kPFErrorObjectNotFound) {
                [Analytics trackError:t.error withName:@"Error getting Facebook User" withMessage:@"Something happened"];
            }
            
            [theTask setResult:[NSNull null]];

        } else if (t.result == nil) {
            LOGGER(@"No user was returned");
            [theTask setResult:[NSNull null]];

        } else {
            NSString *s = [NSString stringWithFormat:@"Found user with id \"%@\" and name \"%@\"", t.result.objectId, t.result.getName];
            LOGGER(s);
            // Doing this so we can get facebook image
            // But this cannot be saved unless actual user logs into the app
            if (!ISVALID(t.result.facebookId)) {
                t.result.facebookId = idString;
            }
            [theTask setResult:t.result];
        }
        
        return nil;
    }];
    
    
    return theTask.task;
}

+ (BFTask *)initWithFacebookUser:(User *)user andFacebookData:(NSDictionary *)data {
    BFTaskCompletionSource *complete = [BFTaskCompletionSource taskCompletionSource];
    BFTask *t = ISVALIDOBJECT(data) ? [BFTask taskWithResult:data] : [User getFacebookUserData];
    
    [[t continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSDictionary *result = (NSDictionary *)t.result;
        NSString *facebookID = result[@"id"];
        NSString *pictureURL = [User getFacebookFetchURL:facebookID];
        
        if(result[@"name"])
            user.canonicalName = result[@"name"];
        
        if(result[@"email"])
            user.email = result[@"email"];
        
        if(result[@"location"])
            user.location = result[@"location"][@"name"];
        
        if(result[@"gender"])
            user.gender = [result[@"gender"] capitalizedString];
        
        if (result[@"birthday"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [formatter dateFromString:result[@"birthday"]];
            user.birthday = date;
        }
        
        NSURL *fetchURL = [NSURL URLWithString:pictureURL];
        
        user.imageFile = [PFFile fileWithData:[NSData dataWithContentsOfURL:fetchURL]];
        user.facebookId = facebookID;
        
        return [User initStuffWithUser:user];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            [complete setError:t.error];
        } else {
            [complete setResult:@(YES)];
        }
        
        return nil;
    }];
    
    return complete.task;
}

+ (BFTask *)deauthorizeFacebook:(User *)user {
    BFTaskCompletionSource *complete = [BFTaskCompletionSource taskCompletionSource];
    if (![user hasFacebook] || ![FBSDKAccessToken currentAccessToken]) {
        LOGGER(@"User needs to have Facebook for this\n");
        [complete setError:[unWineError createGenericErrorWithMessage:@"Failed to detect Facebook session."]];
        return complete.task;
    }
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/permissions" parameters:nil HTTPMethod:@"DELETE"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            NSDictionary *userData = (NSDictionary *)result;
            NSLog(@"userData - %@", userData);
            [complete setResult:@(YES)];
        } else {
            LOGGER(error);
            [complete setError:error];
        }
    }];
    
    return complete.task;
}


/*
 * END OF FACEBOOK STUFF
 */

/*
 * GUEST STUFF
 */
+ (BFTask *)continueAsGuest {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block User *user = nil;
    
    [[[PFAnonymousUtils logInInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<User *> * _Nonnull t) {

        LOGGER(@"Logged in anonymous user");
        
        User *aUser = t.result;
        aUser.lastLogin = [NSDate date];
        aUser.canonicalName = @"Guest";
        user = aUser;
        
        return [User initStuffWithUser:aUser];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (t.error) {
            [theTask setError:t.error];
        } else {
            LOGGER(@"Done initializing guest");
            [theTask setResult:user];
        }
        
        return nil;
    }];

    return theTask.task;
}

/*
 * LOGOUT STUFF
 */
+ (BFTask *)logOutAndDismiss:(UIViewController *)view {
    LOGGER(@"Enter");
    User *user = [User currentUser];
    [User unwitness:WITNESS_GUEST_TOAST];
    [User unwitness:WITNESS_VINECAST_LAST];
    [User unwitness:WITNESS_PROFILE_VIEW_COUNT];
    
    NSString *userId = [[PFTwitterUtils twitter] userId];
    NSLog(@"userId - %@", userId);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(userId)
            [[[Twitter sharedInstance] sessionStore] logOutUserID:userId];
        [[PFFacebookUtils facebookLoginManager] logOut];
        [User deauthorizeFacebook:user];
    });
    
    [Intercom setLauncherVisible:NO];
    [Intercom reset];
    
    if(view)
        SHOW_HUD_FOR_VIEW(view.view);
    
    if ([user isAnonymous]) {
        return [[[user deleteInBackground] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                LOGGER(@"Error deleting guest user");
                LOGGER(task.error);
            } else {
                LOGGER(@"Guest user deleted successfully");
            }
            
            return [User logOutInBackground];
        }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (task.error) {
                LOGGER(@"Error logging out guest user");
                LOGGER(task.error);
            } else {
                LOGGER(@"Logged out guest user");
            }
            
            if(view) {
                HIDE_HUD_FOR_VIEW(view.view);
                
                [[MainVC sharedInstance] dismissPresented:YES];
            }
            
            return nil;
        }];
    } else {
        return [[User logOutInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            if(view) {
                HIDE_HUD_FOR_VIEW(view.view);
                
                return [[MainVC sharedInstance] dismissPresented:YES];
            }
            
            return nil;
        }];
    }
}

+ (BFTask *)deleteAndLogoutGuest {
    User *user = [User currentUser];
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    if(![user isAnonymous]) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed deleting and logging out guest user.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The user is not a guest", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Get your stuff right", nil)
                                   };
        NSError *error = [NSError errorWithDomain:@"User Class"
                                             code:-57
                                         userInfo:userInfo];
        
        LOGGER(@"The user is not a guest");
        [source setError:error];
        return source.task;
    }
    
    NSString *userId = [[PFTwitterUtils twitter] userId];
    NSLog(@"userId - %@", userId);
    
    [User socialMediaLogout];
    
    [[[user deleteInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        LOGGER(@"Just deleted user record. Now logging out user singleton");
        return [User logOutInBackground];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        NSString *s = [NSString stringWithFormat:@"Just deleted user. Error: %@", task.error];
        LOGGER(s);
        
        if (task.error && (task.error.code != kPFErrorInvalidSessionToken)) {
            LOGGER(task.error.localizedDescription);
            [source setError:task.error];
        
        } else {
            LOGGER(@"Logged out user");
            [source setResult:@"success"];
        }
        return nil;
    }];
    
    
    return source.task;
}

+ (void)socialMediaLogout {
    dispatch_async(dispatch_get_main_queue(), ^{
        TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
        NSString *userID = store.session.userID;
        NSLog(@"Logging out user: %@", userID);
        [store logOutUserID:userID];
        [[PFFacebookUtils facebookLoginManager] logOut];
        [Intercom setLauncherVisible:NO];
        [Intercom reset];
        
        /*NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
         NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
         for (NSHTTPCookie *cookie in cookies)
         {
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
         }*/
    });
}

+ (BFTask *)deleteAndLogoutUser {
    __block User *user = [User currentUser];
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [User socialMediaLogout];
    
    [[[PFCloud callFunctionInBackground:@"deleteAccount" withParameters:@{@"currentUser": user.objectId}] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        LOGGER(@"Just deleted account information and user record. Now logging out user singleton");
        return [User logOutInBackground];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        NSString *s = [NSString stringWithFormat:@"Just deleted user. Error: %@", task.error];
        LOGGER(s);
        
        if (task.error && (task.error.code != kPFErrorInvalidSessionToken)) {
            LOGGER(@"Error deleting or logging out user");
            LOGGER(task.error.localizedDescription);
            [source setError:task.error];
        
        } else {
            LOGGER(@"Logged out user");
            [source setResult:@"success"];
        }
        return nil;
    }];
    
    return source.task;
}

/*
 * END OF LOGOUT STUFF
 */

/*
 * INSTALLATION STUFF
 */
- (void)updateInstallation {
    if (![self isTheCurrentUser]) {
        LOGGER(@"Can only do this as the currentUser");
        return;
    }
    
    LOGGER(@"Updating installation");
    
    if (!self.version) {
        self.version = GET_UNWINE_VERSION;
    } else if ([self.version isEqualToString:GET_UNWINE_VERSION] == NO) {
        self.version = GET_UNWINE_VERSION;
    }
    
    if (self.isDirty) {
        LOGGER(@"Saving/Updating Version");
        [self saveInBackground];
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (!currentInstallation) {
        NSLog(@"%s - installation is nil, use something else", __PRETTY_FUNCTION__);
        return;
    }
    
    @try {
        
        if (!currentInstallation.createdAt) {
            NSLog(@"%s - createdAt is nil, meaning installation has not been saved for the first time yet!!!", __PRETTY_FUNCTION__);
            [currentInstallation setObject:self forKey:@"user"];
            [currentInstallation saveInBackground];
            return;
        }
        
        // do something that might throw an exception
        [currentInstallation fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
            
            if (!error) {
                
                PFInstallation *currentInstallation = (PFInstallation *) object;
                
                // Update Installation on Appboy
                if (currentInstallation.deviceToken) {
                    [[Appboy sharedInstance] registerPushToken:currentInstallation.deviceToken];
                    NSLog(@"%s - Registered device token on Appboy", __PRETTY_FUNCTION__);
                }
                
                if (currentInstallation[@"user"] == nil) {
                    currentInstallation[@"user"] = self;
                    NSLog(@"%s - user was nil. Adding currentUser", __PRETTY_FUNCTION__);
                }
                
                // Check if current user equals that of the installation
                if (![[currentInstallation[@"user"] objectId] isEqualToString:self.objectId]) {
                    currentInstallation[@"user"] = self;
                    NSLog(@"%s - Just changed user in installation since we are logging with a different user", __PRETTY_FUNCTION__);
                }
                
                // Save installation if dirty
                if (currentInstallation.isDirty) {
                    [currentInstallation saveInBackground];
                }
                
            }
            
        }];
        
    }
    @catch (NSException *exception) {
        // deal with the exception
        NSLog(@"Could not refresh current PFInstallation");
        [Analytics trackException:exception
                         withName:ERROR_COULD_NOT_REFRESH_INSTALLATION
                       andMessage:[NSString stringWithFormat:@"%s - Could not refresh current PFInstallation", __PRETTY_FUNCTION__]];
    }
    
}

- (void)saveInstallation{
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if ([User currentUser]) {
        [currentInstallation setObject:[User currentUser] forKey:@"user"];
    }
    
    LOGGER(@"Saving Installation");
    BOOL saveSuccessful = [currentInstallation save];
    LOGGER(saveSuccessful ? @"Saved installation successfully" : @"Failed to save installation");
    
}
/*
 * END OF INSTALLATION STUFF
 */

+ (PFQuery *)query {
    PFQuery *query = [super query];
    //[query includeKey:@"level"];
    return query;
}

+ (PFQuery *)find:(NSString *)searchString {
    NSMutableArray *parts = [NSMutableArray arrayWithArray:[searchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [parts removeObject:@""];
    
    PFQuery *query1 = [super query];
    [query1 whereKey:@"nameWords" containsAllObjectsInArray:[parts copy]];
    
    PFQuery *query2 = [super query];
    [query2 whereKey:@"canonicalName" hasPrefix:searchString];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query whereKey:@"objectId" notEqualTo:[User currentUser].objectId];
    [query includeKey:@"level"];
    [query orderByAscending:@"name"];
    [query setLimit:20];
    
    return query;
}

+ (BFTask *)findTask:(NSString *)searchString {
    return [[User find:searchString] findObjectsInBackground];
}

+ (BFTask *)getUserObjectTask:(NSString *)objectId {
    PFQuery *query = [User query];
    [query whereKey:@"objectId" equalTo:objectId];
    [query includeKey:@"level"];
    
    return [query getFirstObjectInBackground];
}


+ (BFTask *)getUserWithEmail:(NSString *)email {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    PFQuery *query = [User query];
    [query whereKey:@"email" equalTo:email];
    
    LOGGER(@"Querying user with email to make sure email is not taken:");
    LOGGER(email);
    
    [[query getFirstObjectInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error.code == kPFErrorObjectNotFound) {
            LOGGER(@"User not found, which is fine");
            [theTask setResult:nil];
            
        } else if (t.error) {
            LOGGER(@"Error when getting user with email");
            [theTask setError:t.error];
            
        } else {
            LOGGER(@"Got 1 user with matching email");
            [theTask setResult:t.result];
        }
        
        return nil;
    }];
    
    return theTask.task;
}


+ (NSInteger)getFiltersLockedAfter {
    return [User currentUser].hasPhotoFilters ? INT_MAX : FILTERS_LOCKED_AFTER;
}

+ (NSString *)getShareMessageAndURL {
    return [NSString stringWithFormat:@"%@\n\n%@", [User getShareMessage], [User getAppStoreURL]];
}

+ (NSString *)getShareMessage {
    return SHARE_MESSAGE;
}

+ (NSString *)getAppStoreURL {
    return IOS_APP_STORE_URL;
}

+ (void)setFiltersLockedAfter:(NSInteger)after {
    FILTERS_LOCKED_AFTER = after;
}

+ (void)setSuperUserCheckinCount:(NSInteger)count {
    SUPER_USER_CHECKIN_COUNT = count;
}

+ (void)setShareMessage:(NSString *)message {
    if(message != nil)
        SHARE_MESSAGE = message;
}

+ (void)setAppStoreURL:(NSString *)url {
    if(url != nil)
        IOS_APP_STORE_URL = url;
}


- (BOOL)hasFacebook {
    return [PFFacebookUtils isLinkedWithUser:self];
}

- (BOOL)hasTwitter {
    return [PFTwitterUtils isLinkedWithUser:self];
}

- (BOOL)isAnonymous {
    BOOL anon = !ISVALID(self.email) || ([PFAnonymousUtils isLinkedWithUser:self] && ![self hasFacebook] && ![self hasTwitter]);
    //NSLog(@"isAnonymous %@", anon ? @"YES" : @"NO");
    return anon;
}

- (BOOL)isUnwinegineer {
    return self.isAdmin | _isUnwinegineer;
}

- (BFTask *)saveInBackground {
    //LOGGER(self.objectId);
    if(![self isTheCurrentUser]) {
        NSLog(@"Tried to save someone that isn't me, %@", self.objectId);
        return nil;
    }
    
    [self getNotifications];
    
    return [super saveInBackground];
}

- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block {
    if(![self isTheCurrentUser])
        return;
    
    [super saveInBackgroundWithBlock:block];
}

- (NSString *)getKeyForSetting:(UserSetting)setting {
    switch(setting) {
        case UserSettingSmartCellar:
            return @"SmartCellar";
        default:
            return @"";
    }
}

- (id)getUserSetting:(UserSetting)setting {
    if(self.userSettings == nil)
        self.userSettings = [[NSMutableDictionary alloc] init];
    else
        self.userSettings = [NSMutableDictionary dictionaryWithDictionary:self.userSettings];
    
    return [self.userSettings objectForKey:[self getKeyForSetting:setting]];
}

- (void)setUserSetting:(UserSetting)setting value:(id)value {
    if(self.userSettings == nil)
        self.userSettings = [[NSMutableDictionary alloc] init];
    else
        self.userSettings = [NSMutableDictionary dictionaryWithDictionary:self.userSettings];
    
    [self.userSettings setValue:value forKey:[self getKeyForSetting:setting]];
}

- (BOOL)isUsingSmartCellar {
    id obj = [self getUserSetting:UserSettingSmartCellar];
    if(!obj || [obj isKindOfClass:[NSNull class]])
        [self setUserSetting:UserSettingSmartCellar value:@(YES)];
    
    return [[self getUserSetting:UserSettingSmartCellar] boolValue];
}

- (NSMutableDictionary *)getNotifications {
    return [self getNotifications:NO];
}

- (NSMutableDictionary *)getNotifications:(BOOL)recheck {
    if(self.notifications == nil && [self isTheCurrentUser]) {
        self.notifications = [[NSMutableDictionary alloc] init];
        
        for(PushNotificationObject *obj in [Push notifications]) {
            [self.notifications setObject:@([obj getDefaultSetting]) forKey:[obj getName]];
        }
    } else if(self.notifications == nil || [self.notifications isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        
        for(PushNotificationObject *obj in [Push notifications]) {
            [temp setObject:@([obj getDefaultSetting]) forKey:[obj getName]];
        }
        
        return temp;
    } else if([[Push notifications] count] != [self.notifications count] || recheck) {
        LOGGER(@"count disparity, push notifications mustve modified in the app!");
        LOGGER(self.notifications);
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.notifications];
        NSMutableArray *old = [NSMutableArray arrayWithArray:[temp allKeys]];
        
        for(PushNotificationObject *obj in [Push notifications]) {
            id grab = [temp objectForKey:[obj getName]];
            [old removeObject:[obj getName]]; // name still matters, its not old
            
            if(grab == nil) { // A new push notification was added
                [temp setObject:@([obj getDefaultSetting]) forKey:[obj getName]];
            } else {
                if(![obj.settingOptions containsObject:grab]) // The options were changed and the currently selected one is invalid
                    [temp setObject:@([obj getDefaultSetting]) forKey:[obj getName]];
            }
        }
        
        [temp removeObjectsForKeys:old]; //remove old shit
        
        if([self isTheCurrentUser])
            self.notifications = temp;
        else
            return temp;
    } else {
        self.notifications = [[NSMutableDictionary alloc] initWithDictionary:self.notifications];
    }
    
    return self.notifications;
}

- (NotificationsSetting)getNotificationStatus:(NotificationType)type {
    PushNotificationObject *obj = [Push notificationObject:type];
    
    return (NotificationsSetting)[[[self getNotifications] objectForKey:[obj getName]] integerValue];
}

- (void)setNotificationStatus:(NotificationType)type setting:(NotificationsSetting)setting {
    [[self getNotifications] setObject:@(setting) forKey:[Push notificationName:type]];
    
    if (type == NotificationTypeDailyToast) {
        NSLog(@"%i", setting);
        BOOL success = [[Appboy sharedInstance].user setEmailNotificationSubscriptionType:(setting == NotificationsSettingOn) ? ABKOptedIn : ABKUnsubscribed];
        success &= [[Appboy sharedInstance].user setPushNotificationSubscriptionType:(setting == NotificationsSettingOn) ? ABKOptedIn : ABKUnsubscribed];
        NSLog(@"%s - Setting APPBOY Push/Email subscription setting was %@", __PRETTY_FUNCTION__, success ? @"successful": @"unsuccessful");
    }
}

- (BFTask *)canReceiveNotification:(NotificationType)type { // completion:(id(^)(BOOL))completion {
    if([self isTheCurrentUser]) //prevents sending notifications to yourself
        return [BFTask taskWithResult:@(NO)];
    
    NSLog(@"canReceiveNotification of type %@", [Push notificationName:type]);
    
    //if(type == NotificationTypeMessage) //always send notifications related to messaging(whether they manifest once received is another story)
    //    return [BFTask taskWithResult:@(YES)];
    
    if([self hasUserBlocked:[User currentUser]]) {
        NSLog(@"no notifications from blocked users!");
        return [BFTask taskWithResult:@(NO)];
    }
    
    NotificationsSetting setting = [self getNotificationStatus:type];
    
    NSLog(@"aforementioned type has setting %@", [Push settingName:setting]);
    if(setting == NotificationsSettingFriends) {
        return [[self isFriendsWithUser:[User currentUser]] continueWithBlock:^id(BFTask *task) {
            if(task.error) {
                return [BFTask taskWithError:task.error];
            } else {
                BOOL areFriends = [task.result boolValue];
                NSLog(@"users %@(receiver) and %@(sender and currentUser) are friends? %@", [self objectId], [[User currentUser] objectId], areFriends ? @"YES" : @"NO");
                return [BFTask taskWithResult:@(areFriends)];
            }
        }];
    } else if(setting == NotificationsSettingEveryone || setting == NotificationsSettingOn) {
        return [BFTask taskWithResult:@(YES)];
    } else
        return [BFTask taskWithResult:@(NO)];
}

- (BFTask *)shouldReceiveNotificationFrom:(NSString *)userObjectId withType:(NotificationType)type {
    if(![self isTheCurrentUser]) //why are we even here if were not the current user, its their device receiving the notification, you shmuck
        return [BFTask taskWithResult:@(NO)];
    
    NSLog(@"canReceiveNotification of type %@", [Push notificationName:type]);
    
    NotificationsSetting setting = [self getNotificationStatus:type];
    
    NSLog(@"aforementioned type has setting %@", [Push settingName:setting]);
    if(setting == NotificationsSettingFriends) {
        if(!ISVALID(userObjectId)) {
            LOGGER(@"userObjectId is nil, must be a admin level push to a user only receiving notifications from friends");
            return [BFTask taskWithResult:@(NO)];
        }
        
        return [[self isFriendsWithUserId:userObjectId] continueWithBlock:^id(BFTask *task) {
            if(task.error) {
                return [BFTask taskWithError:task.error];
            } else {
                BOOL areFriends = [task.result boolValue];
                NSLog(@"users %@(sender) and %@(receiver and currentUser) are friends? %@", userObjectId, [[User currentUser] objectId], areFriends ? @"YES" : @"NO");
                return [BFTask taskWithResult:@(areFriends)];
            }
        }];
    } else if(setting == NotificationsSettingEveryone || setting == NotificationsSettingOn) {
        return [BFTask taskWithResult:@(YES)];
    } else
        return [BFTask taskWithResult:@(NO)];
}

- (NSString *)getName {
    
    NSString *userName = @"";
    
    if (self.canonicalName) {
        userName = self.canonicalName.capitalizedString;
    }
    
    if (!ISVALID(userName) && self.profile) {
        userName = [self.profile[@"name"] capitalizedString];
    }
    
    if (!ISVALID(userName)) {
        userName = @"Guest";
    }
    
    return [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)getMentionName:(BOOL)includeAt {
    if(includeAt)
        return [[NSString stringWithFormat:@"@%@", [self getName]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    else
        return [[self getName] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL)isMentionName:(NSString *)name {
    return [[self getMentionName:YES] isEqualToString:name] || [[self getMentionName:NO] isEqualToString:name];
}

- (NSString *)getFirstName {
    NSString *nameString = [self getName];
    NSString *firstName = nil;
    
    if ([self wordCountForString:nameString] > 1) {
        firstName = [[nameString componentsSeparatedByString:@" "] firstObject];
    } else {
        firstName = nameString;
    }
    
    return firstName;
}

- (NSString *)getLastName {
    NSString *nameString = [self getName];
    NSString *lastName = nil;
    
    if ([self wordCountForString:nameString] > 1) {
        lastName = [[nameString componentsSeparatedByString:@" "] lastObject];
    }
    
    return lastName;
}

- (NSString *)getShortName {
    NSString *firstName = [self getFirstName];
    NSString *lastName = [self getLastName];
    if(!ISVALID(lastName))
        return firstName;
    
    return [[[firstName stringByAppendingString:@" "] stringByAppendingString:[lastName substringWithRange:NSMakeRange(0, 1)]] stringByAppendingString:@"."];
}

- (BOOL)hasCellar{
    
    BOOL hasCellar = NO;
    
    if (self.cellar && self.cellar.count > 0) {
        hasCellar = YES;
    }
    
    return hasCellar;
    
}

- (BOOL)hasUserBlocked:(User *)user {
    if(self.blockedUsers == nil) {
        self.blockedUsers = [[NSMutableArray alloc] init];
        return NO;
    }
    
    return [self.blockedUsers containsObject:[user objectId]];
}

- (void)blockUser:(User *)user {
    if(![self isTheCurrentUser])
        return;
    
    if(self.blockedUsers == nil)
        self.blockedUsers = [[NSMutableArray alloc] init];
    
    if(![self hasUserBlocked:user])
        [self.blockedUsers addObject:[user objectId]];
}

- (void)unblockUser:(User *)user {
    if(![self isTheCurrentUser])
        return;
    
    if(self.blockedUsers == nil) {
        self.blockedUsers = [[NSMutableArray alloc] init];
    } else if([self hasUserBlocked:user]) {
        [self.blockedUsers removeObject:[user objectId]];
    }
}

//@synthesize theCellar = _theCellar, grapes = _grapes, friendsList = _friendsList, contributions = _contributions, ratings = _ratings, locations = _locations;

- (PFRelation *) checkins {
    if(_checkins == nil)
        _checkins = [self relationForKey:@"checkins"];
    
    return _checkins;
}

- (void) setCheckins:(PFRelation *)checkins {
    _checkins = checkins;
}

- (PFRelation *) theCellar {
    if(_theCellar == nil)
        _theCellar = [self relationForKey:@"theCellar"];
    
    return _theCellar;
}

- (void) setTheCellar:(PFRelation *)theCellar {
    _theCellar = theCellar;
}

- (PFRelation *)grapes {
    if(_grapes == nil)
        _grapes = [self relationForKey:@"grapes"];
    
    return _grapes;
}

- (void)setGrapes:(PFRelation *)grapes {
    _grapes = grapes;
}

- (PFRelation *)friendsList {
    if(_friendsList == nil)
        _friendsList = [self relationForKey:@"friendsList"];
    
    return _friendsList;
}

- (void)setFriendsList:(PFRelation *)friendsList {
    _friendsList = friendsList;
}

- (PFRelation *)ratings {
    if(_ratings == nil)
        _ratings = [self relationForKey:@"ratings"];
    
    return _ratings;
}

- (void)setRatings:(PFRelation *)ratings {
    _ratings = ratings;
}

- (PFRelation *)locations {
    if(_locations == nil)
        _locations = [self relationForKey:@"locations"];
    
    return _locations;
}

- (void)setLocations:(PFRelation *)locations {
    _locations = locations;
}

/*- (PFRelation *)conversations {
 if(_conversations == nil)
 _conversations = [self relationForKey:@"conversations"];
 
 return _conversations;
 }
 
 - (void)setConversations:(PFRelation *)conversations {
 _conversations = conversations;
 }*/

- (BFTask *)getCellar {
    PFQuery *query = [self.theCellar query];
    
    if([self isTheCurrentUser]) {
        [self updateCellarCount];
    }
    
    return [query findObjectsInBackground];
}

- (BFTask *)filterOutWinesInWishlist:(NSArray *)wines {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self.getCellar continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (t.error) {
            NSString *s = [NSString stringWithFormat:@"Something happened when getting cellar wines: %@", t.error];
            LOGGER(s);
            
            // Nothing to do here, just return same wines
            [theTask setResult:wines];
            return nil;
        }

        NSMutableArray *wishlistWines = (NSMutableArray * )t.result;
        
        if (wishlistWines.count == 0) {
            LOGGER(@"No wines in wishlist. Return...");
            [theTask setResult:wines];
            return nil;
        }
        
        NSMutableArray *filteredWines = [[NSMutableArray alloc] initWithArray:wines];
        NSString *s = [NSString stringWithFormat:@"Before filtering. Recommendation wines: %lu, Wishlist Wines: %lu", filteredWines.count, wishlistWines.count];
        LOGGER(s);
        
        for (unWine *w in wines) {
            for (unWine *ww in wishlistWines) {
                if ([w.objectId isEqualToString:ww.objectId]) {
                    NSString *s = [NSString stringWithFormat:@"Wine \"%@. %@\" is in Wishlist. Breaking", w.objectId, [w getWineName]];
                    LOGGER(s);
                    [filteredWines removeObject:w];
                    break;
                }
            }
        }
        s = [NSString stringWithFormat:@"After filtering. Recommendation wines: %lu, Wishlist Wines: %lu", filteredWines.count, wishlistWines.count];
        LOGGER(s);
        
        [theTask setResult:[filteredWines copy]];
    
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)updateCellarCount {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    PFQuery *query = [self.theCellar query];

    [[[query countObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        self.cellarCount = t.result.integerValue;
        return [self saveInBackground];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            [theTask setError:t.error];
        } else {
            [theTask setResult:t.result];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)hasWineInWishList:(unWine *)wine {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    PFQuery *query = [[self theCellar] query];
    [query whereKey:@"objectId" equalTo:wine.objectId];
    
    [[query countObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        if (t.error) {
            [theTask setError:t.error];
        } else {
            [theTask setResult:@(t.result.intValue > 0)];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)addWineToCellar:(unWine *)wine {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block BOOL save = false;
    LOGGER(@"Enter");

    [[[[self hasWineInWishList:wine] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        BOOL inWishList = t.result.boolValue;
        
        if (!inWishList) {
            LOGGER(@"Adding wine to wish list");
            [self.theCellar addObject:wine];
            save = true;
        } else {
            LOGGER(@"Wine is already in wish list");
        }
        
        LOGGER(@"Saving user");
        return save ? [self saveInBackground] : [BFTask taskWithResult:@(true)];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Successfully saved user, now updating wish list count");
        return save ? [self updateCellarCount] : [BFTask taskWithResult:@(true)];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something went wrong adding/removing wine from wish list");
            LOGGER(t.error);
            [theTask setError:t.error];
            
        } else {
            LOGGER(@"Successfully added/removed wine from wish list and updated wish list count");
            [theTask setResult:t.result];
        }
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)removeWineFromCellar:(unWine *)wine {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    __block BOOL save = false;
    LOGGER(@"Enter");
    
    [[[[self hasWineInWishList:wine] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        BOOL inWishList = t.result.boolValue;
        
        if (inWishList) {
            LOGGER(@"Removing wine from Wish List");
            [self.theCellar removeObject:wine];
            save = true;
            
        } else {
            LOGGER(@"Wine NOT in wish list. No need to do anything");
            save = false;
        }
        
        LOGGER(@"Saving user");
        return save ? [self saveInBackground] : [BFTask taskWithResult:@(true)];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        LOGGER(@"Successfully saved user, now updating wish list count");
        return save ? [self updateCellarCount] : [BFTask taskWithResult:@(true)];
        
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            LOGGER(@"Something went wrong adding/removing wine from wish list");
            LOGGER(t.error);
            [theTask setError:t.error];
            
        } else {
            LOGGER(@"Successfully removed wine from wish list and updated wish list count");
            [theTask setResult:t.result];
        }
        return nil;
    }];
    
    return theTask.task;
}

- (BOOL)didToastPost:(NewsFeed *)newsfeed {
    if(!self.Likes)
        self.Likes = [[NSMutableArray alloc] init];
    
    for(NSString *objectId in self.Likes) {
        if([objectId isEqualToString:newsfeed.objectId])
            return YES;
    }
    
    return NO;
}

- (void)toastPost:(NewsFeed *)newsfeed {
    if(!self.Likes)
        self.Likes = [[NSMutableArray alloc] init];
    else
        self.Likes = [[NSMutableArray alloc] initWithArray:self.Likes];
    
    [self.Likes addObject:newsfeed.objectId];
}

- (void)untoastPost:(NewsFeed *)newsfeed {
    if(!self.Likes) {
        self.Likes = [[NSMutableArray alloc] init];
        return;
    } else
        self.Likes = [[NSMutableArray alloc] initWithArray:self.Likes];
    
    [self.Likes removeObject:newsfeed.objectId];
}

- (NSInteger)getFriendCount {
    if(friendCache != nil) {
        return self.friendCount = [(NSArray *)friendCache.result count];
    } else {
        return self.friendCount;
    }
    
    return self.friendCount;
}

- (BOOL)hasFriends {
    
    BOOL hasFriends = NO;
    
    if (self.friends && self.friends.count > 0) {
        hasFriends = YES;
    }
    
    return hasFriends;
}

- (BFTask *)getFriends {
    //BFTaskCompletionSource *tcs = [[BFTaskCompletionSource alloc] init];
    
    PFQuery *friendsQuery1 = [Friendship query];
    [friendsQuery1 whereKey:@"toUser" equalTo:self];
    [friendsQuery1 whereKey:@"state" equalTo:@"Accepted"];
    
    PFQuery *friendsQuery2 = [Friendship query];
    [friendsQuery2 whereKey:@"fromUser" equalTo:self];
    [friendsQuery2 whereKey:@"state" equalTo:@"Accepted"];
    
    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:@[friendsQuery1, friendsQuery2]];
    [friendQuery whereKeyExists:@"toUser"];
    [friendQuery whereKeyExists:@"fromUser"];
    [friendQuery includeKey:@"toUser"];
    [friendQuery includeKey:@"toUser.level"];
    [friendQuery includeKey:@"fromUser"];
    [friendQuery includeKey:@"fromUser.level"];
    [friendQuery orderByDescending:@"canonicalName"];
    friendQuery.limit = 1000;
    
    friendQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    
    return [friendQuery findObjectsInBackground];
}

- (BFTask<NSArray<User *> *> *)getFriendUsers {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    [[self getFriends] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            [theTask setError:task.error];
            return nil;
        }
        
        NSMutableArray<User *> *users = [[NSMutableArray alloc] init];
        
        for (Friendship *friendship in task.result) {
            if (friendship) {
                User *other = [friendship getTheFriend:self];
                if (other && ![other isKindOfClass:[NSNull class]]) {
                    [users addObject:other];
                }
            }
        }

        [theTask setResult:users];
        
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)getFriendshipWithUser:(User *)user {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    PFQuery *friendsQuery1 = [Friendship query];
    [friendsQuery1 whereKey:@"toUser" equalTo:self];
    [friendsQuery1 whereKey:@"fromUser" equalTo:user];
    
    PFQuery *friendsQuery2 = [Friendship query];
    [friendsQuery2 whereKey:@"toUser" equalTo:user];
    [friendsQuery2 whereKey:@"fromUser" equalTo:self];
    
    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:@[friendsQuery1, friendsQuery2]];
    [friendQuery includeKey:@"toUser"];
    [friendQuery includeKey:@"fromUser"];
    friendQuery.limit = 1;
    
    [[friendQuery getFirstObjectInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (t.error) {
            [theTask setResult:nil];
        } else {
            [theTask setResult:t.result];
        }
        
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)isFriendsWithUser:(User *)user {
    PFQuery *friendsQuery1 = [Friendship query];
    [friendsQuery1 whereKey:@"toUser" equalTo:self];
    [friendsQuery1 whereKey:@"fromUser" equalTo:user];
    [friendsQuery1 whereKey:@"state" equalTo:@"Accepted"];
    
    PFQuery *friendsQuery2 = [Friendship query];
    [friendsQuery2 whereKey:@"toUser" equalTo:user];
    [friendsQuery2 whereKey:@"fromUser" equalTo:self];
    [friendsQuery2 whereKey:@"state" equalTo:@"Accepted"];
    
    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:@[friendsQuery1, friendsQuery2]];
    [friendQuery includeKey:@"toUser"];
    [friendQuery includeKey:@"toUser.level"];
    [friendQuery includeKey:@"fromUser"];
    [friendQuery includeKey:@"fromUser.level"];
    [friendQuery orderByDescending:@"canonicalName"];
    friendQuery.limit = 1;
    
    return [[friendQuery countObjectsInBackground] continueWithBlock:^id(BFTask<NSNumber *> *task) {
        if(task.error)
            return task;
        
        return [BFTask taskWithResult:@([task.result integerValue] == 1)];
    }];
}

- (BFTask *)isFriendsWithUserId:(NSString *)userObjectId {
    PFQuery *friendsQuery1 = [Friendship query];
    [friendsQuery1 whereKey:@"toUser" equalTo:self];
    [friendsQuery1 whereKey:@"fromUser" equalTo:[User objectWithoutDataWithObjectId:userObjectId]];
    [friendsQuery1 whereKey:@"state" equalTo:@"Accepted"];
    
    PFQuery *friendsQuery2 = [Friendship query];
    [friendsQuery2 whereKey:@"toUser" equalTo:[User objectWithoutDataWithObjectId:userObjectId]];
    [friendsQuery2 whereKey:@"fromUser" equalTo:self];
    [friendsQuery2 whereKey:@"state" equalTo:@"Accepted"];
    
    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:@[friendsQuery1, friendsQuery2]];
    [friendQuery includeKey:@"toUser"];
    [friendQuery includeKey:@"toUser.level"];
    [friendQuery includeKey:@"fromUser"];
    [friendQuery includeKey:@"fromUser.level"];
    [friendQuery orderByDescending:@"canonicalName"];
    friendQuery.limit = 1;
    
    return [[friendQuery countObjectsInBackground] continueWithBlock:^id(BFTask<NSNumber *> *task) {
        if(task.error)
            return task;
        
        return [BFTask taskWithResult:@([task.result integerValue] == 1)];
    }];
}

- (BOOL)hasMerits {
    return self.earnedMerits && self.earnedMerits.count > 0;
}

- (NSMutableArray *)getMerits{
    
    // If no merits return nil
    if ([self hasMerits]) {
        return self.earnedMerits;
    }
    
    return self.earnedMerits = [[NSMutableArray alloc] init];
    
}

- (NSInteger)getNumberOfMeritCellsForUser{
    
    NSInteger numberOfMeritCells = 1;
    NSInteger numberOfMerits = 0;
    
    if (self.earnedMerits) {
        numberOfMerits = self.earnedMerits.count;
    }
    
    if (numberOfMerits > 0) {
        if (numberOfMerits % 4 == 0) {
            numberOfMeritCells = (int)(numberOfMerits / 4);
        } else {
            numberOfMeritCells = (int)(numberOfMerits / 4) + 1;
        }
    }
    
    return numberOfMeritCells;
    
}

- (BOOL)hasFacebookPhotoURL {
    return [self getFacebookImageURL] ? YES : NO;
}

- (NSString *)getProfileImageURL{
    
    NSString *profileImageURL = nil;
    
    if ([self hasFacebookPhotoURL]) {
        //LOGGER(@"Using Facebook URL");
        profileImageURL = [self getFacebookImageURL];
    } else if (self.imageFile){
        //LOGGER(@"Using Image File");
        profileImageURL = self.imageFile.url;
    } else if (self.profile[@"picture"] && ISVALID(self.profile[@"picture"])) {
        //LOGGER(@"Using legacy image structure");
        profileImageURL = self.profile[@"picture"];
    }
    
    // Return nil if not a valid URL
    if (!ISVALID(profileImageURL)) {
        profileImageURL = nil;
    }
    
    return profileImageURL;
}

- (NSString *)getFacebookImageURL {
    NSString *facebookProfileURL = nil;
    
    if (ISVALID(self.facebookId)) {
        facebookProfileURL = [self getFacebookFetchURL];
    }
    
    if (!ISVALID(facebookProfileURL) && ISVALID(self.facebookPhotoURL)) {
        facebookProfileURL = self.facebookPhotoURL;
    }
    
    if (!ISVALID(facebookProfileURL) && ISVALIDOBJECT(self.profile) && ISVALIDOBJECT(self.profile[@"picture"])) {
        facebookProfileURL =  self.profile[@"picture"];
    }
    
    return facebookProfileURL;
}

- (NSString *)getFacebookFetchURL {
    return self.facebookId ? [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=600&height=600&return_ssl_resources=1", self.facebookId] : nil;
}

+ (NSString *)getFacebookFetchURL:(NSString *)identifier {
    return identifier ? [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=600&height=600&return_ssl_resources=1", identifier] : nil;
}


- (NSString *)getGender{
    
    NSString *gender = nil;
    
    NSString *string = [self.profile[@"gender"] lowercaseString];
    
    if ([string isEqualToString:@"male"]) {
        gender = @"male";
        
    } else if ([string isEqualToString:@"female"]){
        gender = @"female";
        
    }
    
    return gender;
}

- (NSDate *)getDateOfBirth{
    
    NSDate *dateOfBirth = nil;
    NSString *dateStr = self.profile[@"birthday"];
    
    if (ISVALID(dateStr)) {
        // Convert string to date object
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        dateOfBirth = [dateFormat dateFromString:dateStr];
    }
    
    return dateOfBirth;
}

- (int)getAge {
    int age = 0;
    NSDate *birthday = [self getDateOfBirth];
    
    if (birthday) {
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear
                                           fromDate:birthday
                                           toDate:now
                                           options:0];
        age = (int)[ageComponents year];
    }
    
    return age;
}

- (NSString *)getLocation {
    NSString *location = self.location;
    
    if (!ISVALID(location)) {
        location = self.profile[@"location"];
    }
    
    if (!ISVALID(location)) {
        location = @"";
    }
    
    return location;
}

- (void)setProfileImageWithImage:(UIImage *)image {
    NSData* data = UIImageJPEGRepresentation(image, 0.5f);
    self.imageFile = [PFFile fileWithName:@"Profile.jpg" data:data];
    /*NSData *imageData = UIImagePNGRepresentation(image);
     self.imageFile = [PFFile fileWithName:@"profile.png" data:imageData];*/
}


- (NSMutableArray *)getCreditedWines {
    if(!self.creditedWines)
        self.creditedWines = [[NSMutableArray alloc] init];
    
    return self.creditedWines;
}

- (void)addCreditedWines:(unWine *)wine {
    if(!self.creditedWines)
        self.creditedWines = [[NSMutableArray alloc] init];
    else
        self.creditedWines = [[NSMutableArray alloc] initWithArray:self.creditedWines];
    
    [self.creditedWines addObject:[wine objectId]];
}

- (NSMutableArray *)getRecentCheckinsObjects {
    if([self isTheCurrentUser]) {
        if(!self.recentCheckins)
            self.recentCheckins = [[NSMutableArray alloc] init];
        
        if([self.recentCheckins count] > 3)
            self.recentCheckins = [[self.recentCheckins subarrayWithRange:NSMakeRange(0, 3)] mutableCopy];
    }
    
    return self.recentCheckins;
}

- (void)addRecentCheckinsObject:(NSString *)objectId {
    if([self isTheCurrentUser]) {
        if(!self.recentCheckins)
            self.recentCheckins = [[NSMutableArray alloc] init];
        else
            self.recentCheckins = [[NSMutableArray alloc] initWithArray:self.recentCheckins];
        
        [self.recentCheckins insertObject:objectId atIndex:0];
        
        if (self.recentCheckins.count > 3)
            self.recentCheckins = [NSMutableArray arrayWithArray:[self.recentCheckins subarrayWithRange:NSMakeRange(0, 3)]];
    }
}

- (NSMutableArray *)getRecentSearchesObjects {
    if([self isTheCurrentUser]) {
        if(!self.recentSearches)
            self.recentSearches = [[NSMutableArray alloc] init];
        
        if([self.recentSearches count] > 20)
            self.recentSearches = [[self.recentSearches subarrayWithRange:NSMakeRange(0, 20)] mutableCopy];
    }
    
    return self.recentSearches;
}

- (void)addRecentSearchesObject:(NSString *)search {
    if([self isTheCurrentUser]) {
        if(!self.recentSearches)
            self.recentSearches = [[NSMutableArray alloc] init];
        else
            self.recentSearches = [[NSMutableArray alloc] initWithArray:self.recentSearches];
        
        [self.recentSearches insertObject:search atIndex:0];
        
        if (self.recentSearches.count > 20)
            self.recentSearches = [NSMutableArray arrayWithArray:[self.recentSearches subarrayWithRange:NSMakeRange(0, 20)]];
    }
}

- (void)removeRecentSearchesObject:(NSString *)search {
    if([self isTheCurrentUser]) {
        if(!self.recentSearches)
            self.recentSearches = [[NSMutableArray alloc] init];
        else
            self.recentSearches = [[NSMutableArray alloc] initWithArray:self.recentSearches];
        
        [self.recentSearches removeObject:search];
    }
}

- (NSMutableArray *)getFollowedWineries {
    if([self isTheCurrentUser]) {
        if(!self.followedWineries)
            self.followedWineries = [[NSMutableArray alloc] init];
    }
    
    return self.followedWineries;
}

- (BOOL)isFollowingWinery:(Winery *)winery {
    NSArray *following = [self getFollowedWineries];
    for(NSString *objectId in following) {
        if([winery.objectId isEqualToString:objectId])
            return YES;
    }
    
    return NO;
}

- (void)followWinery:(Winery *)winery {
    if([self isTheCurrentUser]) {
        if(!self.followedWineries)
            self.followedWineries = [[NSMutableArray alloc] init];
        else
            self.followedWineries = [[NSMutableArray alloc] initWithArray:self.followedWineries];
        
        [self.followedWineries addObject:winery.objectId];
    }
}

- (void)unfollowWinery:(Winery *)winery {
    if([self isTheCurrentUser]) {
        if(!self.followedWineries) {
            self.followedWineries = [[NSMutableArray alloc] init];
            return;
        } else
            self.followedWineries = [[NSMutableArray alloc] initWithArray:self.followedWineries];
        
        [self.followedWineries removeObject:winery.objectId];
    }
}

// Utility stuff
- (NSUInteger)wordCountForString:(NSString *)string {
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [string componentsSeparatedByCharactersInSet:separators];
    
    NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqualToString:@""];
    }];
    
    return [words count] - [separatorIndexes count];
}

- (void)setUserImageForImageView:(PFImageView *)imageView {
    if ([PFFacebookUtils isLinkedWithUser:self] && ISVALID(self.facebookPhotoURL)) {
        //LOGGER(@"Using Facebook URL");
        //[self setImageViewWithURL:imageView];
        [self setImageViewWithURL:imageView andURL:[self getProfileImageURL]];
    } else if (self.imageFile != nil) {
        //LOGGER(@"Using Image File");
        imageView.image = USER_PLACEHOLDER;
        imageView.file = self.imageFile;
        [imageView loadInBackground];
    } else {
        //LOGGER(@"Using legacy image structure");
        [self setImageViewWithURL:imageView andURL:[self getProfileImageURL]];
    }
}


- (void)setImageViewWithURL:(PFImageView *)imageView andURL:(NSString *)url {
    //LOGGER(@"Setting profile image in view");
    [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:USER_PLACEHOLDER];
}

// ****************************** Cellar stuff ******************************

// Cellar stuff
// Creates an array of BFTasks to download the Cellar Images
- (NSMutableArray *)composeWineImageDownloadTasksFromWineObjects:(NSMutableArray *)cellarObjects{
    NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
    
    for (unWine *wine in cellarObjects) {
        [tasksArray addObject:[wine taskForDownloadingWineImage]];
    }
    
    return tasksArray;
}

// Creates an array of BFTasks to download the Cellar Images
- (NSMutableArray *)composeUserImageDownloadTasksForUsers: (NSArray *)friends{
    NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
    
    for (User *user in friends) {
        [tasksArray addObject:[user taskForDownloadingUserImage]];
    }
    
    return tasksArray;
}


- (BFTask *)taskForDownloadingUserImage {
    
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    NSString *imageURL = nil;
    __block NSString *debug = nil;
    
    imageURL = [self getProfileImageURL];
    
    if (!ISVALID(imageURL)) {
        debug = [NSString stringWithFormat:@"No Image URL for %@\n\n", self.parseClassName];
        LOGGER(debug);
        [taskCompletionSource setResult:USER_PLACEHOLDER];
    } else if(self.imageFile != nil) {
        PFImageView *someView = [[PFImageView alloc] init];
        someView.file = self.imageFile;
        
        return [someView loadInBackground];
    } else {
        debug = [NSString stringWithFormat:@"URL for %@ - %@", self.parseClassName, imageURL];
        LOGGER(debug);
        
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]];
        requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
        
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            debug = [NSString stringWithFormat:@"Successfully downloaded image for %@\n\n", self.parseClassName];
            LOGGER(debug);
            [taskCompletionSource setResult:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            debug = [NSString stringWithFormat:@"Failed to download image for %@\n\n", self.parseClassName];
            LOGGER(debug);
            [taskCompletionSource setResult:USER_PLACEHOLDER];
        }];
        [requestOperation start];
    }
    
    return taskCompletionSource.task;
    
}


// Saving Stuff

- (BFTask *)updateProfileWithHUD:(MBProgressHUD *)hud {
    LOGGER(@"Updating Profile");
    self.acceptedTerms  = TRUE;
    return self.imageFile.isDirty ? [self uploadPictureAndThenSaveInBackgroundWithHUD:hud] : [self saveInBackground];
}

- (BFTask *)uploadPictureAndThenSaveInBackgroundWithHUD:(MBProgressHUD *)hud {
    
    BFTaskCompletionSource *theTask = [[BFTaskCompletionSource alloc] init];
    
    [self setUpHUD:hud];
    
    // Save PFFile
    
    [[[[self saveImageWithProgressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
        if (hud) {
            hud.progress = (float)percentDone/100;
        }
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Saving User in Background");
        //self.imageFile = task.result;
        return [self saveInBackground];
        
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        LOGGER(@"Successfully saved user");
        [theTask setResult:task.result];
        return nil;
        
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            LOGGER(@"Error signing up user");
            LOGGER(task.error.userInfo);
            [theTask setError:task.error];
        }
        
        return nil;
    }];
    
    return theTask.task;
    
}



- (BFTask *)saveImageWithProgressBlock:(PFProgressBlock)progressBlock {
    return [self.imageFile saveInBackgroundWithProgressBlock:progressBlock];
}



- (void)setUpHUD:(MBProgressHUD *)hud {
    if (!hud) {
        return;
    }
    
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"Uploading";
}




/*
 - (void)sendTutorialEmail{
 LOGGER([PFCloud callFunction:@"sendTutorialEmail" withParameters:@{}]);
 }*/

- (BOOL)isTheCurrentUser {
    return [self.objectId isEqualToString:[User currentUser].objectId];
}

- (BOOL)isEqual:(id)object {
    if([object isKindOfClass:[User class]]) {
        return [self.objectId isEqualToString:[(User *)object objectId]];
    } else
        return NO;
}

- (NSUInteger)hash {
    return [self.objectId hash]; //Must be a unique unsigned integer
}

- (BOOL)isEqualToUser:(User *)other {
    return [self.objectId isEqualToString:other.objectId];
}




- (void)promptGuest:(UIViewController *)controller {
    unWineAlertLoginView *alert = [unWineAlertLoginView sharedInstance];
    [alert setMessage:@"Some things are worth signing up for."];
    
    [alert showFromViewController:controller];
}



+ (void)witnessed:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:key];
    [defaults synchronize];
}

+ (void)unwitness:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}


+ (BOOL)hasSeen:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[[defaults dictionaryRepresentation] allKeys] containsObject:key];
}

+ (void)setWitnessState:(NSString *)key state:(NSString *)state {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:state forKey:key];
    [defaults synchronize];
}

+ (void)setWitnessValue:(id)value key:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

+ (NSString *)getWitnessState:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [User hasSeen:key] ? [defaults stringForKey:key] : @"";
}

+ (id)getWitnessValue:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [User hasSeen:key] ? [defaults objectForKey:key] : nil;
}

- (BFTask *)updateSuperUserStatus {
    if([self isTheCurrentUser] && !self.isSuperUser) {
        NSString *s = [NSString stringWithFormat:@"Checkins required to become super user: %ld", (long)SUPER_USER_CHECKIN_COUNT];
        LOGGER(@"updating super user status");
        LOGGER(s);
        
        if(self.checkIns + 1 >= SUPER_USER_CHECKIN_COUNT) {
            LOGGER(@"We got a superuser");
            self.isSuperUser = YES;
            [SlackHelper notifyNewSuperUser:self];
        } else {
            LOGGER(@"No super user today");
        }
    }
    
    return self.isDirty ? [self saveInBackground] : [BFTask taskWithResult:@(true)];
}

- (BFTask *)updateUniqueWinesCount {
    BFTaskCompletionSource *theTask = [BFTaskCompletionSource taskCompletionSource];
    
    if(![self isTheCurrentUser])
        return [BFTask taskWithResult:@(TRUE)];
    
    BFTask *uniqWinesTask = [self getUniqWines];
    NSArray *tasks = @[uniqWinesTask];
    
    [[[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(BFTask *task) {
        NSArray *uniqWines = task.result;
        self.uniqueWines = [uniqWines count];
        return [self saveInBackground];
    
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            [theTask setError:t.error];
        } else {
            [theTask setResult:@(TRUE)];
        }
        return nil;
    }];
    
    return theTask.task;
}

- (BFTask *)getUniqWines {
    
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PFQuery *uniqueList = [NewsFeed query];
    [uniqueList whereKey:@"authorPointer" equalTo:self];
    [uniqueList whereKey:@"Type" equalTo:@"Wine"];
    [uniqueList includeKey:@"authorPointer"];
    [uniqueList includeKey:@"authorPointer.level"];
    [uniqueList includeKey:@"unWinePointer"];
    [uniqueList includeKey:@"unWinePointer.partner"];
    [uniqueList orderByAscending:@"name"];
    uniqueList.limit = 1000;
    
    [[uniqueList findObjectsInBackground] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            NSArray *uniqWines = [self filterNewsFeedIntoWines:task.result];
            [taskCompletionSource setResult:uniqWines];
        } else {
            [taskCompletionSource setError:task.error];
        }
        return nil;
    }];
    
    return taskCompletionSource.task;
}

- (Level *)getLevel {
    if(self.level && [self.level isKindOfClass:[NSNull class]]) {
        for(Level *level in cachedLevels) {
            if([level isEqual:self.level])
                return level;
        }
    }
    
    return nil;
}

- (BFTask *)checkLevel {
    return [[User getLevels] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        NSArray *allLevels = task.result;
        if(!task.result && !cachedLevels) {
            return [BFTask taskWithResult:self.level];
        } else if(!task.result)
            allLevels = cachedLevels;
        
        for(Level *level in allLevels) {
            if(self.uniqueWines >= level.postCount)
                return [BFTask taskWithResult:(self.level = level)];
        }
        
        if(([self hasMerits] || self.uniqueWines > 0) && self.checkIns == 0) {
            return [[NewsFeed wineCheckinsForUser:self] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                NSArray *unique = [self filterNewsFeedIntoWines:task.result];
                self.checkIns = task.result ? [task.result count] : 0;
                self.uniqueWines = [unique count];
                for(Level *level in allLevels) {
                    if(self.uniqueWines >= level.postCount)
                        return [BFTask taskWithResult:(self.level = level)];
                }
                
                return nil;
            }];
        }
        
        NSLog(@"self.level = %@", self.level);
        return [BFTask taskWithResult:self.level];
    }];
}

+ (BFTask *)getLevels {
    if(cachedLevels == nil) {
        PFQuery *levels = [Level query];
        [levels includeKey:@"merit"];
        [levels orderByDescending:@"postCount"];
        
        return [[levels findObjectsInBackground] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [BFTask taskWithResult:(cachedLevels = task.result)];
        }];
    } else {
        return [BFTask taskWithResult:cachedLevels];
    }
}

- (NSArray *)filterNewsFeedIntoWines:(NSArray *)objects {
    NSMutableSet *consistency = [[NSMutableSet alloc] init];
    NSMutableArray *filteredWines = [[NSMutableArray alloc] init];
    NSString *s = [NSString stringWithFormat:@"User checkins count = %lu", (unsigned long)objects.count];
    LOGGER(s);
    
    for(NewsFeed *newsfeed in objects) {
        unWine *wine = newsfeed[@"unWinePointer"];
        
        /*NSLog(@"wine.objectId = %@", wine.objectId);
         
         if (wine.objectId && wine.objectId != nil) {
         NSLog(@"wine.objectId = %@", wine.objectId);
         } else {
         NSLog(@"%@", newsfeed.description);
         }*/
        
        if(wine != nil && wine.objectId != nil && ![consistency containsObject:wine.objectId]) {
            [filteredWines addObject:wine];
            [consistency addObject:wine.objectId];
        }
    }
    
    //NSLog(@"filteredWines.count = %lu", (unsigned long)filteredWines.count);
    //NSLog(@"consistency.count = %lu", (unsigned long)consistency.count);
    
    return [filteredWines copy];
}

/*
 * PASSWORD RESET STUFF
 */
+ (void)requestPasswordResetWithEmail:(NSString *)email forViewController:(UIViewController *)vc {
    LOGGER(@"Requesting Password Reset!");
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL success, NSError *error) {
        if (success) {
            NSString *title = NSLocalizedString(@"Password Reset",
                                                @"Password reset success alert title in PFLogInViewController.");
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"An email with reset instructions has been sent to '%@'.",
                                                                             @"Password reset message in PFLogInViewController"), email];
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
            
            [alert addAction:ok];
            
            [vc presentViewController:alert animated:YES completion:nil];
            
            
            
            //[UIAlertController showAlertViewWithTitle:title message:message cancelButtonTitle:NSLocalizedString(@"OK", @"OK")];
        } else {
            NSString *title = NSLocalizedString(@"Password Reset Failed",
                                                @"Password reset error alert title in PFLogInViewController.");
            
            
            [unWineAlertView showAlertViewWithTitle:title error:error];
        }
    }];
}


/*
 * END OF PASSWORD RESET STUFF
 */


- (NSString *)getSearchableName {
    return [self getName];
}





- (BFTask<NSArray<Venue *> *> *)getAssociatedVenues {
    PFQuery *query = [Venue query];
    [query whereKey:@"user" equalTo:self];
    return [query findObjectsInBackground];
}

- (Class<PFObjectCell>)getAssociatedCell {
    return [UserCell class];
}

- (void)sharedTheApp {
    LOGGER(@"User Shared the app");
    if (self.sharedApp == NO) {
        self.sharedApp = YES;
        LOGGER(@"Doing the saving thing");
        [self saveInBackground];
    }
}

- (void)ratedTheApp {
    if (ISVALIDOBJECT(self[@"ratedApp"]) == false ||
        (ISVALIDOBJECT(self[@"ratedApp"]) && self.ratedApp == false)) {
        LOGGER(@"First time rating app");
        self.ratedApp = true;
        [self saveInBackground];
    }
}

- (BFTask *)sendFeedbackEmail:(NSString *)feedback {
    NSMutableDictionary *feedbackDictionary = [[NSMutableDictionary alloc] init];
    
    [feedbackDictionary setObject:self.objectId forKey:@"currentUser"];
    [feedbackDictionary setObject:feedback forKey:@"feedback"];
    [feedbackDictionary setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"appversion"];
    
    return [PFCloud callFunctionInBackground:@"sendUserFeedback" withParameters:feedbackDictionary];
}

- (BFTask *)awardRecommendations {
    LOGGER(@"Awarding Wine Recommendations");
    self.hasWineRecommendations = YES;
    return [self saveInBackground];
}

- (BFTask *)randomlySetPromptType {
    if (self.recommendationPromptType == RecommendationPromptTypeNone) {
        int random = arc4random_uniform(3) + 1;
        switch (random) {
            case 1:
                LOGGER(@"Setting RecommendationPromptTypeFriendInvite");
                self.recommendationPromptType = RecommendationPromptTypeFriendInvite;
                [SlackHelper sendRecommendationMessage:@"Got a user who will see the Friend Invite Option Only"];
                break;
            case 2:
                LOGGER(@"Setting RecommendationPromptTypePurchase");
                self.recommendationPromptType = RecommendationPromptTypePurchase;
                [SlackHelper sendRecommendationMessage:@"Got a user who will see the Purchase Option Only"];
                break;
            case 3:
                LOGGER(@"Setting RecommendationPromptTypeBoth");
                self.recommendationPromptType = RecommendationPromptTypeBoth;
                [SlackHelper sendRecommendationMessage:@"Got a user who will see both Friend Invite and Purchase Options"];
                break;
        }
    } else {
        NSString *s = [NSString stringWithFormat:@"User already has recommendation prompt type of %li", (long)self.recommendationPromptType];
        LOGGER(s);
    }
    
    return self.isDirty ? [self saveInBackground] : [BFTask taskWithResult:@(TRUE)];
}

@end
