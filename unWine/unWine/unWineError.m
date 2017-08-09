//
//  unWineError.m
//  unWine
//
//  Created by Fabio Gomez on 10/28/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#import "unWineError.h"

@implementation unWineError

+ (unWineError *)createGenericErrorWithMessage:(NSString *)message {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(UNWINE_ERROR_DESCRIPTION_GENERIC, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                               };
    
    return [unWineError errorWithDomain:UNWINE_ERROR_DOMAIN code:UNWINE_ERROR_CODE_PUSH_GENERIC userInfo:userInfo];
}

+ (unWineError *)createPushErrorWithMessage:(NSString *)message {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(UNWINE_ERROR_DESCRIPTION_PUSH, nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                               };
    
    return [unWineError errorWithDomain:UNWINE_ERROR_DOMAIN code:UNWINE_ERROR_CODE_PUSH_GENERIC userInfo:userInfo];
}

@end
