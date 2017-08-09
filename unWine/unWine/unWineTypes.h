//
//  unWineTypes.h
//  unWine
//
//  Created by Fabio Gomez on 12/1/15.
//  Copyright © 2015 LION Mobile. All rights reserved.
//

#ifndef unWineTypes_h
#define unWineTypes_h

typedef enum CastCheckinSource {
    CastCheckinSourceSomewhere,
    CastCheckinSourceVinecast,
    CastCheckinSourceWishList,
    CastCheckinSourceUnique,
    CastCheckinSourceInbox,
    CastCheckinSourcePushNotification,
    CastCheckinSourceExpress,
    CastCheckinSourceWineProfileFavorite,
    CastCheckinSourceScanner
} CastCheckinSource;

typedef enum CastInboxDefault {
    CastInboxDefaultNotification,
    CastInboxDefaultConversation,
    CastInboxDefaultDailyToast
} CastInboxDefault;

#endif /* unWineTypes_h */
