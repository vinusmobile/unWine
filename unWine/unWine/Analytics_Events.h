//
//  Analytics_Events.h
//  unWine
//
//  Created by Fabio Gomez on 1/24/15.
//  Copyright (c) 2015 LION Mobile. All rights reserved.
//

#ifndef unWine_Analytics_Events_h
#define unWine_Analytics_Events_h

#define EVENT_POST_TO_FACEBOOK                                    @"PostToFacebook"

#define EVENT_ACCOUNT_DELETION                                    @"AccountDeletion"
#define EVENT_NEW_FRIEND_INVITE                                   @"UserSentInternalFriendRequest"
#define EVENT_USER_UNFRIENDED_FRIEND                              @"UserUnfriendedFriend"
#define EVENT_OPENED_SOBRIETY_GAME                                @"OpenedSobrietyGame"
#define EVENT_SOBRIETY_GAME_OPEN                                  @"SobrietyGameOpen"
// OLD Scanner
#define EVENT_PRESSED_NO_BAR_CODE_BUTTON                          @"UserPressedNoBarCodeButton"
#define EVENT_USER_DENIED_ACCESS_TO_CAMERA_AND_CANNOT_SCAN        @"ScannerCannotScanBecauseUserDeniedCameraAccess"
#define EVENT_SCANNED_WINE_AND_NO_RESULTS                         @"ScannerScannedWineAndNoResults"

// NEW Scanner - High Level
#define EVENT_OPENED_SCANNER                                      @"ScannerOpenedScanner"
#define EVENT_SCANNER_TOOK_PHOTO                                  @"ScannerTookPhoto"
#define EVENT_SCANNER_SELECTED_EXISTING_PHOTO                     @"ScannerSelectedExistingPhoto"
#define EVENT_SCANNER_CANCELLED_SCANNING                          @"ScannerCancelledScanning"

#define EVENT_SCANNED_WINE                                        @"ScannerScannedWine"
#define EVENT_CREATED_NEW_WINE_FROM_SCANNER                       @"ScannerCreatedNewWineFromScanner"

#define EVENT_SCANNER_RETURNED_NO_RESULTS                         @"ScannerReturnedNoResults"
#define EVENT_SCANNER_RETURNED_SINGLE_RESULT                      @"ScannerReturnedSingleResult"
#define EVENT_SCANNER_RETURNED_MULTIPLE_RESULTS                   @"ScannerReturnedMultipleResults"

#define EVENT_SCANNER_PRESSED_SEARCH_BUTTON                       @"ScannerPressedSearchButton"
#define EVENT_SCANNER_PRESSED_RETRY_BUTTON                        @"ScannerPressedRetryButton"

// New Scanner - Low Level scanning
#define EVENT_CLOUDSIGHT_SUCCESSFULLY_SCANNED                     @"ScannerCloudsightReturnedResults"
#define EVENT_CLOUDSIGHT_RETURNED_NO_RESULTS                      @"ScannerCloudsightReturnedNoResults"


#define EVENT_SEARCHED_WINE                                       @"SearchedWine"
#define EVENT_SELECTED_WINE_FROM_SEARCH_RESULTS                   @"SelectedWineFromSearch"

#define EVENT_NEW_CHECKIN_CREATED                                 @"NewCheckInCreated"
#define EVENT_USER_EDITED_WINE                                    @"UserEditedWine"

#define EVENT_USER_MERGED_WINE                                    @"UserMergedWines"
#define EVENT_USER_LAST_LOGIN                                     @"UserLastLogin"

#define EVENT_USER_CHECKED_IN_WITH_NEW_WINE                       @"UserCheckedInWithNewWine"
#define EVENT_USER_CHECKED_IN_WITH_EXISTING_WINE                  @"UserCheckedInWithExistingWine"

#define EVENT_USER_CHECKED_IN_FROM                                @"UserCheckedInFrom"

// Sign Up
#define EVENT_USER_SIGNED_UP_WITH_EMAIL                           @"UserSignedUpWithEmail"
#define EVENT_USER_SIGNED_UP_WITH_FACEBOOK                        @"UserSignedUpWithFacebook"
#define EVENT_USER_SIGNED_UP_WITH_TWITTER                         @"UserSignedUpWithTwitter"

// Guest
#define EVENT_USER_CONTINUED_AS_GUEST                             @"UserContinuedAsGuest"
#define EVENT_GUEST_LOGIN                                         @"GuestLoggedInWithExistingUnWineAccount"
#define EVENT_GUEST_SIGNED_UP                                     @"GuestCreatedNewAccount"
#define EVENT_GUEST_LOGIN_FACEBOOK                                @"GuestLoggedInWithExistingUnWineAccountWithFacebook"
#define EVENT_GUEST_SIGNED_UP_FACEBOOK                            @"GuestCreatedNewAccountWithFacebook"
#define EVENT_GUEST_LOGIN_TWITTER                                 @"GuestLoggedInWithExistingUnWineAccountWithTwitter"
#define EVENT_GUEST_SIGNED_UP_TWITTER                             @"GuestCreatedNewAccountWithTwitter"

#define EVENT_USER_CANCELLED_REGISTRATION                         @"UserCancelledRegistration"

#define EVENT_USER_SAW_VINECAST_BUBBLE                            @"UserSawVineCastBubble"
#define EVENT_USER_SAW_DAILY_TOAST_BUBBLE                         @"UserSawDailyToastBubble"

#define EVENT_USER_SAW_PROFILE_FRIENDS_BUBBLE                     @"UserSawProfileFriendsBubble"
#define EVENT_USER_SAW_PROFILE_UNIQUE_WINES_BUBBLE                @"UserSawProfileUniqueWinesBubble"
#define EVENT_USER_SAW_PROFILE_CELLAR_BUBBLE                      @"UserSawProfileCellarBubble"
#define EVENT_USER_SAW_PROFILE_MERITS_BUBBLE                      @"UserSawProfileMeritsBubble"

#define EVENT_USER_SAW_ADD_TO_CELLAR_BUBBLE                       @"UserSawAddToCellarBubble"
#define EVENT_USER_SAW_ADD_CUSTOM_CHECKIN_PHOTO_BUBBLE            @"UserSawAddCustomCheckinPhotoBubble"

// In App Purchases
#define EVENT_USER_RESTORED_IN_APP_PURCHASES                      @"UserRestoredInAppPurchases"                         // Say user purchased filters, deleted app and reinstalled

// Filters

#define EVENT_FILTERS_USER_OPENED_IN_APP_PURCHASE_VIEW_CONTROLLER @"UserOpenedInAppPurchaseViewController"
#define EVENT_FILTERS_USER_OPENED_IN_APP_PURCHASE_ALERT_VIEW      @"UserOpenedInAppPurchaseAlertView"
#define EVENT_FILTERS_USER_DISMISSED_IN_APP_PURCHASE_ALERT_VIEW   @"UserDismissedFiltersInAppPurchaseAlertView"         // Only if user was about to purchase filters
#define EVENT_FILTERS_USER_CANCELLED_IN_APP_PURCHASE_VIA_APPLE    @"UserCancelledFiltersInAppPurchaseFromApple"
#define EVENT_FILTERS_USER_DOES_NOT_HAVE_ENOUGH_GRAPES            @"UserTriedPurchasingFiltersButDidNotHaveEnoughGrapes"
#define EVENT_FILTERS_USER_PURCHASED_FILTER_VIA_APPLE             @"UserPurchasedFiltersViaApple"
#define EVENT_FILTERS_USER_PURCHASED_FILTER_VIA_GRAPES            @"UserPurchasedFiltersViaGrapes"

// Grapes
#define EVENT_USER_WAS_AWARDED_GRAPES                             @"UserWasAwardedGrapesFor"

#define EVENT_FILTERS_USER_TAPPED_ON_FILTER_X                     @"UserTappedOnFilterX"                                // Do more of these when we know the filter names

#define EVENT_FILTERS_USER_CHECKED_IN_USING_FILTER_X              @"UserCheckedInWithFilter"                            // Do more of these when we know the filter names
#define EVENT_FILTERS_USER_CHECKED_IN_WITH_NO_FILTER              @"UserCheckedInWithNoFilter"                          // Do more of these when we know the filter names

#define EVENT_USER_CHECKED_IN_WITH_PHOTO                          @"UserCheckedInWithPhoto"
#define EVENT_USER_CHECKED_IN_WITH_NO_PHOTO                       @"UserCheckedInWithNoPhoto"

// Friend Recommendations
#define EVENT_USER_TAPPED_FRIENDS_TAB_ON_VINECAST                 @"UserTappedFriendsTabOnVineCast"
#define EVENT_USER_TAPPED_GLOBAL_TAB_ON_VINECAST                  @"UserTappedGlobalTabOnVineCast"

#define EVENT_USER_INVITED_FRIEND_VIA_TEXT                        @"UserInvitedFriendViaText"
#define EVENT_USER_FAILED_TO_INVITE_FRIEND_VIA_TEXT               @"UserFailedToInviteFriendViaText"
#define EVENT_USER_CANCELLED_TEXT_FRIEND_INVITE                   @"UserCancelledTextFriendInvite"

#define EVENT_USER_INVITED_FRIEND_VIA_EMAIL                       @"UserInvitedFriendViaEmail"
#define EVENT_USER_FAILED_TO_INVITE_FRIEND_VIA_EMAIL              @"UserFailedToInviteFriendViaEmail"
#define EVENT_USER_CANCELLED_EMAIL_FRIEND_INVITE                  @"UserCancelledEmailFriendInvite"

#define EVENT_USER_PRESSED_DONE_BUTTON_ON_FACEBOOK_INVITE         @"UserPressedDoneOnFacebookFriendInviteDialogue"
#define EVENT_USER_INVITED_FRIEND_VIA_FACEBOOK                    @"UserInvitedFriendViaFacebook"
#define EVENT_USER_FAILED_TO_INVITE_FRIEND_VIA_FACEBOOK           @"UserFailedToInviteFriendViaFacebook"
#define EVENT_USER_CANCELLED_FACEBOOK_FRIEND_INVITE               @"UserCancelledFacebookFriendInvite"

#define EVENT_USER_SHARED_WINE_INTERNALLY                         @"UserSharedWineInternally"
#define EVENT_USER_SHARED_OWN_CHECKIN_INTERNALLY                  @"UserSharedOwnCheckinInternally"
#define EVENT_USER_SHARED_SOMEONE_CHECKIN_INTERNALLY              @"UserSharedAnotherUserCheckinInternally"

#define EVENT_USER_OPENED_WINE_RECOMMENDATION                     @"UserOpenedWineRecommendation"
#define EVENT_USER_OPENED_CHECKIN_RECOMMENDATION                  @"UserOpenedCheckinRecommendation"

// Sharing Merits
#define EVENT_USER_SHARED_MERIT_FACEBOOK                          @"UserSharedMeritViaFacebook"
#define EVENT_USER_SHARED_MERIT_TWITTER                           @"UserSharedMeritViaTwitter"
#define EVENT_USER_SHARED_MERIT_TEXT                              @"UserSharedMeritViaText"
#define EVENT_USER_SHARED_MERIT_EMAIL                             @"UserSharedMeritViaEmail"

#define EVENT_USER_CANCELLED_SHARING_MERIT_FACEBOOK               @"UserCancelledSharingMeritViaFacebook"
#define EVENT_USER_CANCELLED_SHARING_MERIT_TWITTER                @"UserCancelledSharingMeritViaTwitter"
#define EVENT_USER_CANCELLED_SHARING_MERIT_TEXT                   @"UserCancelledSharingMeritViaText"
#define EVENT_USER_CANCELLED_SHARING_MERIT_EMAIL                  @"UserCancelledSharingMeritViaEmail"

#define EVENT_USER_SHARED_MERIT_FACEBOOK_MERIT_VIEW               @"UserSharedMeritViaFacebookFromMeritView"
#define EVENT_USER_SHARED_MERIT_TWITTER_MERIT_VIEW                @"UserSharedMeritViaTwitterFromMeritView"
#define EVENT_USER_SHARED_MERIT_TEXT_MERIT_VIEW                   @"UserSharedMeritViaTextFromMeritView"
#define EVENT_USER_SHARED_MERIT_EMAIL_MERIT_VIEW                  @"UserSharedMeritViaEmailFromMeritView"

#define EVENT_USER_CANCELLED_SHARING_MERIT_FACEBOOK_MERIT_VIEW    @"UserCancelledSharingMeritViaFacebookFromMeritView"
#define EVENT_USER_CANCELLED_SHARING_MERIT_TWITTER_MERIT_VIEW     @"UserCancelledSharingMeritViaTwitterFromMeritView"
#define EVENT_USER_CANCELLED_SHARING_MERIT_TEXT_MERIT_VIEW        @"UserCancelledSharingMeritViaTextFromMeritView"
#define EVENT_USER_CANCELLED_SHARING_MERIT_EMAIL_MERIT_VIEW       @"UserCancelledSharingMeritViaEmailFromMeritView"

// Sharing App

// FriendInviteTVC
#define EVENT_USER_SAW_FRIEND_INVITE_VIEW_FROM_SIGN_UP            @"UserSawFriendInviteViewFromSignUp"
#define EVENT_USER_OPENED_FRIEND_INVITE_VIEW_FROM_PROFILE         @"UserOpenedFriendInviteViewFromProfileSettings"
#define EVENT_USER_OPENED_FRIEND_INVITE_VIEW_FROM_FRIENDS_VIEW    @"UserOpenedFriendInviteViewFromFriendsView"
#define EVENT_USER_OPENED_FRIEND_INVITE_VIEW_FROM_VINECAST        @"UserOpenedFriendInviteViewFromVineCast"

// FriendInviteTVC
#define EVENT_USER_PRESSED_FACEBOOK_BUTTON_FRIEND_INVITE          @"UserPressedFacebookButtonFromFriendInviteTVC"
#define EVENT_USER_PRESSED_CONTACTS_BUTTON_FRIEND_INVITE          @"UserPressedContactsButtonFromFriendInviteTVC"
#define EVENT_USER_PRESSED_SMS_BUTTON_FRIEND_INVITE               @"UserPressedSMSButtonFromFriendInviteTVC"
#define EVENT_USER_PRESSED_EMAIL_BUTTON_FRIEND_INVITE             @"UserPressedEmailButtonFromFriendInviteTVC"

// FacebookInviteTVC
#define EVENT_USER_PRESSED_ADD_ALL_BUTTON_FACEBOOK_INVITE_TVC     @"UserPressedAddAllButtonFromFacebookInviteTVC"

// ContactsInviteTVC
#define EVENT_USER_PRESSED_ADD_ALL_BUTTON                         @"UserPressedAddAllButtonFromContactsInviteTVC"
#define EVENT_USER_PRESSED_SELECT_ALL_BUTTON                      @"UserPressedSelectAllButtonFromContactsInviteTVC"

#define EVENT_USER_CANCELLED_SHARING_APP_EMAIL_FRIEND_TVC         @"UserCancelledSharingAppViaEmailFromFriendInviteTVC"
#define EVENT_USER_CANCELLED_SHARING_APP_EMAIL_CONTACT_TVC        @"UserCancelledSharingAppViaEmailFromContactInviteTVC"
#define EVENT_USER_CANCELLED_SHARING_APP_EMAIL_PROFILE_TVC        @"UserCancelledSharingAppViaEmailFromProfileTVC"
#define EVENT_USER_CANCELLED_SHARING_APP_SMS_FRIEND_TVC           @"UserCancelledSharingAppViaSMSFromFriendInviteTVC"
#define EVENT_USER_CANCELLED_SHARING_APP_SMS_CONTACT_TVC          @"UserCancelledSharingAppViaSMSFromContactInviteTVC"
#define EVENT_USER_CANCELLED_SHARING_APP_SMS_PROFILE_TVC          @"UserCancelledSharingAppViaSMSFromProfileTVC"

#define EVENT_USER_SHARED_APP_EMAIL_FRIEND_TVC                    @"UserSharedAppViaEmailFromFriendInviteTVC"
#define EVENT_USER_SHARED_APP_EMAIL_CONTACT_TVC                   @"UserSharedAppViaEmailFromContactInviteTVC"
#define EVENT_USER_SHARED_APP_EMAIL_PROFILE_TVC                   @"UserSharedAppViaEmailFromProfileTVC"
#define EVENT_USER_SHARED_APP_SMS_FRIEND_TVC                      @"UserSharedAppViaSMSFromFriendInviteTVC"
#define EVENT_USER_SHARED_APP_SMS_CONTACT_TVC                     @"UserSharedAppViaSMSFromContactInviteTVC"
#define EVENT_USER_SHARED_APP_SMS_PROFILE_TVC                     @"UserSharedAppViaSMSFromProfileTVC"

// Sharing Checkins
#define EVENT_USER_SHARED_CHECKIN_FACEBOOK                        @"UserSharedCheckinViaFacebook"
#define EVENT_USER_SHARED_CHECKIN_TWITTER                         @"UserSharedCheckinViaTwitter"
#define EVENT_USER_SHARED_CHECKIN_TEXT                            @"UserSharedCheckinViaText"
#define EVENT_USER_SHARED_CHECKIN_EMAIL                           @"UserSharedCheckinViaEmail"

#define EVENT_USER_CANCELLED_SHARING_CHECKIN_FACEBOOK             @"UserCancelledSharingCheckinViaFacebook"
#define EVENT_USER_CANCELLED_SHARING_CHECKIN_TWITTER              @"UserCancelledSharingCheckinViaTwitter"
#define EVENT_USER_CANCELLED_SHARING_CHECKIN_TEXT                 @"UserCancelledSharingCheckinViaText"
#define EVENT_USER_CANCELLED_SHARING_CHECKIN_EMAIL                @"UserCancelledSharingCheckinViaEmail"

// Reactions
#define EVENT_USER_CHECKED_IN_WITH_REACTION                       @"UserCheckedInWithReaction"
#define EVENT_USER_CHECKED_IN_WITHOUT_REACTION                    @"UserCheckedInWithOutReaction"
#define EVENT_USER_TAPPED_REACTION_BUTTON_ON_VINECAST             @"UserTappedReactionButtonOnVineCast"

/*
    - User checked in with Xpress Checkin
    - User tapped on recent checkins
    - User added wine to cellar from Checkin Ellipsis
    - User tapped on wine cell on checkin
    - User tapped on recent search
    - User tapped on friend from search friend view
    - User searched friend using searcher
    - User tapped on friend after searching
    - User sent friend invite after searching user
 
    - User opened app from 3d touch
    - User checked in after opening 3d touch
    
 Optional:
    user pasted a link on checkin comments
    user opened link from comments
 */
// New Search
#define EVENT_USER_CHECKED_IN_WITH_XPRESS_CHECKIN_ON_CHECKIN_TAB  @"UserCheckedInWithXpressCheckinOnCheckinTab" // Done
#define EVENT_USER_TAPPED_ON_RECENT_SEARCH                        @"UserTappedOnRecentSearch" // Done
#define EVENT_USER_TAPPED_ON_RECENT_CHECKIN_ON_CHECKIN_TAB        @"UserTappedOnRecentCheckinOnCheckinTab"  // Done
#define EVENT_USER_TAPPED_ON_TOP_RESULT_AFTER_SEARCHING_WINE      @"UserTappedOnTopResultAfterSearchingWine"   // Done
#define EVENT_USER_TAPPED_ON_WINE_AFTER_SEARCHING_SEARCHING       @"UserTappedOnWineAfterSearching" // Done


// VineCast
#define EVENT_USER_ADDED_WINE_TO_CELLAR_FROM_VINECAST_ELLIPSIS    @"UserAddedWineToCellarFromVineCastEllipsis"

// Checkin
#define EVENT_USER_TAPPED_ON_WINE_CELL_ON_CHECKIN_VIEW            @"UserTappedOnWineCellOnCheckinView" // Done

// UserSearch
#define EVENT_USER_TAPPED_ON_EXISTING_FRIEND_ON_FRIEND_VIEW       @"UserTappedOnExistingFriendOnFriendView" // Done
#define EVENT_USER_SEARCHED_USER_ON_FRIEND_VIEW                   @"UserSearchedUserOnFriendView" // Done
#define EVENT_USER_TAPPED_ON_TOP_USER_AFTER_SEARCHING             @"UserTappedOnTopUserAfterSearchingOnFriendView" // Done
#define EVENT_USER_TAPPED_ON_USER_AFTER_SEARCHING                 @"UserTappedOnUserAfterSearchingOnFriendView" // Done
#define EVENT_USER_SENT_FRIEND_INVITE_AFTER_SEARCHING_USER        @"UserSentFriendInviteAfterSearchingOnFriendView" // Done

// 3D touch
#define EVENT_USER_OPENED_APP_USING_3D_TOUCH                      @"UserOpenedAppUsing3DTouch"
#define EVENT_USER_CHECKED_IN_AFTER_OPENING_APP_WITH_3D_TOUCH     @"UserCheckedInAfterOpeningAppWith3DTouch"

// Comments
#define EVENT_USER_PASTED_A_LINK_ON_CHECKIN_COMMENT               @"UserPastedALinkOnCheckinComment"
#define EVENT_USER_OPENED_LINK_FROM_CHECKIN_COMMENT               @"UserOpenedLinkFromCheckinComment"

// Shake
#define EVENT_USER_SHOOK_PHONE_AND_SAW_FEEDBACK_POP_UP            @"UserShookPhoneAndSawFeedbackPopUp"
#define EVENT_USER_TAPPED_FEEDBACK_POP_UP_AND_SAW_FEEDBACK_VIEW   @"UserTappedFeedbackPopUpAndSawFeedbackView"

// Discover View
#define EVENT_USER_TAPPED_FEATURED_WINE_FROM_DISCOVER_VIEW        @"UserTappedOnFeaturedWineFromDiscoverView"
#define EVENT_USER_TAPPED_SEARCH_FOR_WINERIES_FROM_DISCOVER_VIEW  @"UserTappedSearchForWineriesFromDiscoverView"
#define EVENT_USER_TAPPED_SEARCH_BY_REGION_FROM_DISCOVER_VIEW     @"UserTappedSearchByRegionFromDiscoverView"
#define EVENT_USER_TAPPED_POPULAR_WINES_FROM_DISCOVER_VIEW        @"UserTappedTappedPopularWinesFromDiscoverView"
#define EVENT_USER_TAPPED_GREAT_WINES_FROM_DISCOVER_VIEW          @"UserTappedTappedGreatWinesFromDiscoverView"
#define EVENT_USER_TAPPED_WINE_WORLD_FROM_DISCOVER_VIEW           @"UserTappedTappedWineWorldFromDiscoverView"

// Profile
#define EVENT_USER_TAPPED_WINE_WORLD_FROM_PROFILE_VIEW           @"UserTappedTappedWineWorldFromProfileView"
#define EVENT_USER_TAPPED_WINE_FROM_PROFILE_REACTION_VIEW        @"UserTappedWineFromProfileReactionView"

#define EVENT_USER_TAPPED_REACTIONS_SECTION                      @"UserTappedReactionSection"
#define EVENT_USER_TAPPED_LIST_SECTION                           @"UserTappedListSection"
#define EVENT_USER_TAPPED_CELLAR_SECTION                         @"UserTappedCellarSection"
#define EVENT_USER_TAPPED_MERITS_SECTION                         @"UserTappedMeritsSection"

#define EVENT_USER_TAPPED_REACTIONS_SECTION_ON_ANOTHER_USER      @"UserTappedReactionSectionOnAnotherUser"
#define EVENT_USER_TAPPED_LIST_SECTION_ON_ANOTHER_USER           @"UserTappedListSectionOnAnotherUser"
#define EVENT_USER_TAPPED_CELLAR_SECTION_ON_ANOTHER_USER         @"UserTappedCellarSectionOnAnotherUser"
#define EVENT_USER_TAPPED_MERITS_SECTION_ON_ANOTHER_USER         @"UserTappedMeritsSectionOnAnotherUser"

#define EVENT_USER_TAPPED_REACTION_SELECTION_BUTTON              @"UserTappedReactionSelectionButton"
#define EVENT_USER_CANCELLED_REACTION_FILTER_SELECTION           @"UserCancelledReactionFilterSelection"

#define EVENT_USER_TAPPED_REACTION_SELECTION_BUTTON_OAU          @"UserTappedReactionSelectionButtonOnAnotherUser"
#define EVENT_USER_CANCELLED_REACTION_FILTER_SELECTION_OAU       @"UserCancelledReactionFilterSelectionOnAnotherUser"

#define EVENT_USER_TAPPED_GREAT_WINES_REACTION_FILTER            @"UserTappedGreatWinesReactionFilter"
#define EVENT_USER_TAPPED_GOOD_WINES_REACTION_FILTER             @"UserTappedGoodWinesReactionFilter"
#define EVENT_USER_TAPPED_OK_WINES_REACTION_FILTER               @"UserTappedOKWinesReactionFilter"
#define EVENT_USER_TAPPED_BAD_WINES_REACTION_FILTER              @"UserTappedBadWinesReactionFilter"
#define EVENT_USER_TAPPED_AWFUL_WINES_REACTION_FILTER            @"UserTappedAwfulWinesReactionFilter"
#define EVENT_USER_TAPPED_NO_REACTION_FILTER                     @"UserTappedNoReactionFilter"

#define EVENT_USER_TAPPED_GREAT_WINES_REACTION_FILTER_OAU        @"UserTappedGreatWinesReactionFilterOnAnotherUser"
#define EVENT_USER_TAPPED_GOOD_WINES_REACTION_FILTER_OAU         @"UserTappedGoodWinesReactionFilterOnAnotherUser"
#define EVENT_USER_TAPPED_OK_WINES_REACTION_FILTER_OAU           @"UserTappedOKWinesReactionFilterOnAnotherUser"
#define EVENT_USER_TAPPED_BAD_WINES_REACTION_FILTER_OAU          @"UserTappedBadWinesReactionFilterOnAnotherUser"
#define EVENT_USER_TAPPED_AWFUL_WINES_REACTION_FILTER_OAU        @"UserTappedAwfulWinesReactionFilterOnAnotherUser"
#define EVENT_USER_TAPPED_NO_REACTION_FILTER_OAU                 @"UserTappedNoReactionFilterOnAnotherUser"


// Wine World
#define EVENT_USER_OPENED_WINERY_FROM_WINE_WORLD                 @"UserTappedOpenedWineryFromWineWorld"
#define EVENT_USER_OPENED_MAPS_FOR_WINERY_FROM_WINE_WORLD        @"UserTappedOpenedMapsForWineryFromWineWorld"
#define EVENT_USER_OPENED_MAPS_FOR_WINE_VENUE_FROM_WINE_WORLD    @"UserTappedOpenedMapsForWineVenueFromWineWorld"
#define EVENT_USER_OPENED_MAPS_FOR_CHECKIN_VENUE_FROM_WINE_WORLD @"UserTappedOpenedMapsForCheckinVenueFromWineWorld"

// Winery Search
#define EVENT_USER_TAPPED_ON_WINERY_NEARBY_ON_WINERY_SEARCH_VIEW @"UserTappedOnWineryNearbyOnWinerySearchView"
#define EVENT_USER_SEARCHED_WINERY_ON_WINERY_SEARCH_VIEW         @"UserSearchedWineryFromWinerySearchView"
#define EVENT_USER_RECOMMENDED_WINERY_FROM_WINERY_SEARCH_VIEW    @"UserRecommendedWineryFromWinerySearchView"
#define EVENT_USER_OPENED_WINERY_MAP_FROM_WINERY_SEARCH_VIEW     @"UserOpenedWineryMapFromWinerySearchView"

// Winery View
#define EVENT_USER_RECOMMENDED_WINERY_FROM_WINERY_VIEW           @"UserRecommendedWineryFromWineryView"
#define EVENT_USER_TAPPED_ON_WINE_FROM_WINERY_VIEW               @"UserTappedOnWineFromWineryView"
#define EVENT_USER_ADDED_WINE_TO_CELLAR_FROM_WINERY_VIEW         @"UserAddedWineToCellarFromWineryView"

// Wine Profile Stats View
#define EVENT_USER_VIEWED_WINE_STATS                             @"UserViewedWineStats"
#define EVENT_USER_VIEWED_WINE_STATS_AND_BLOCKED                 @"UserViewedWineStatsAndGotBlocked"
#define EVENT_USER_STARTED_TO_SEND_WINE_PROFILE_FEEDBACK         @"UserStartedToSendWineProfileFeedback"
#define EVENT_USER_VIEWED_FAVORITE_WINE                          @"UserViewedFavoriteWine"

// App Rating
#define EVENT_USER_SAW_APP_RATING                                @"UserSawAppRating"
#define EVENT_USER_RATED_APP                                     @"UserRatedApp"
#define EVENT_USER_DECLINED_RATING_APP                           @"UserDeclinedRatingApp"
#define EVENT_USER_DEFERRED_RATING_APP                           @"UserDeferredRatingApp"

// Recommendation
#define EVENT_RECOMMENDATION_USER_SAW_INVITE_ALERT_BOTH          @"RecommendationUserSawInviteAlertWithBothFriendAndPurchaseOptions"
#define EVENT_RECOMMENDATION_USER_SAW_INVITE_ALERT_FRIEND        @"RecommendationUserSawInviteAlertWithFriendInviteOptionOnly"
#define EVENT_RECOMMENDATION_USER_SAW_INVITE_ALERT_PURCHASE      @"RecommendationUserSawInviteAlertWithPurchaseOptionOnly"

#define EVENT_RECOMMENDATION_USER_TAPPED_RECOMMENDATION_TAB      @"RecommendationUserTappedRecommendationTab"
#define EVENT_RECOMMENDATION_USER_SWIPED_RIGHT                   @"RecommendationUserSwipedRight"
#define EVENT_RECOMMENDATION_USER_SWIPED_LEFT                    @"RecommendationUserSwipedLeft"
#define EVENT_RECOMMENDATION_USER_TAPPED_RIGHT_BUTTON            @"RecommendationUserTappedRightButton"
#define EVENT_RECOMMENDATION_USER_TAPPED_LEFT_BUTTON             @"RecommendationUserTappedLeftButton"
#define EVENT_RECOMMENDATION_USER_TAPPED_REWIND_BUTTON           @"RecommendationUserTappedRewindButton"

#define EVENT_RECOMMENDATION_USER_SHARED_APP_FACEBOOK            @"RecommendationUserSharedAppFacebook"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_TWITTER             @"RecommendationUserSharedAppTwitter"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_WHATSAPP            @"RecommendationUserSharedAppWhatsApp"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_MESSENGER           @"RecommendationUserSharedAppMessenger"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_EMAIL               @"RecommendationUserSharedAppEMail"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_TEXT_MESSAGE        @"RecommendationUserSharedAppTextMessage"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_SLACK               @"RecommendationUserSharedAppSlack"
#define EVENT_RECOMMENDATION_USER_SHARED_APP_LINKEDIN            @"RecommendationUserSharedAppLinkedIn"

#define EVENT_RECOMMENDATION_USER_AWARDED_THROUGH_INVITES_BOTH   @"RecommendationUserObtainedRecommendationsThroughAppInvitesAfterBeingShownBothFriendAndPurchaseOptions"
#define EVENT_RECOMMENDATION_USER_AWARDED_THROUGH_INVITES_FRIEND   @"RecommendationUserObtainedRecommendationsThroughAppInvitesAfterBeingShownFriendOptionOnly"

#define EVENT_RECOMMENDATION_USER_PURCHASED_RECOMMENDATIONS_BOTH @"RecommendationUserPurchasedRecommendationsAfterBeingShownBothFriendAndPurchaseOptions"
#define EVENT_RECOMMENDATION_USER_PURCHASED_RECOMMENDATIONS_PURCHASE  @"RecommendationUserPurchasedRecommendationsAfterBeingShownPurchaseOptionOnly"
#define EVENT_RECOMMENDATION_USER_RESTORED_RECOMMENDATIONS       @"RecommendationUserRestoredRecommendations"

#endif
