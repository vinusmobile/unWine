//
//  unWineError.h
//  unWine
//
//  Created by Fabio Gomez on 10/28/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

// Error Stuff
#define UNWINE_ERROR_DOMAIN                 @"unWineErrorDomain"
#define UNWINE_ERROR_DESCRIPTION_GENERIC    @"Something Happened"
#define UNWINE_ERROR_DESCRIPTION_PUSH       @"Failed to send Push Notification."
#define UNWINE_ERROR_CODE_PUSH_GENERIC      1234
#define UNWINE_ERROR_CODE_PUSH_NO_USER      4312
#define UNWINE_ERROR_CODE_PUSH_NO_MESSAGE   1324

@interface unWineError : NSError

+ (unWineError *)createGenericErrorWithMessage:(NSString *)message;
+ (unWineError *)createPushErrorWithMessage:(NSString *)message;

@end
