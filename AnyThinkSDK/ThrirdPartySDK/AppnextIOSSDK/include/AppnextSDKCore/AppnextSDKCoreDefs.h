//
//  AppnextSDKCoreDefs.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 11/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#ifndef AppnextSDKCoreDefs_h
#define AppnextSDKCoreDefs_h

#pragma mark - System helper macroses and defines

//
// Helper macroses

#define __ON__ (1)
#define __OFF__ (0)

#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#if __has_feature(objc_instancetype)

#undef	AS_SINGLETON
#define AS_SINGLETON

#undef	AS_SINGLETON
#define AS_SINGLETON( ... ) \
- (instancetype)sharedInstance; \
+ (instancetype)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}

#undef	DEF_SINGLETON
#define DEF_SINGLETON( ... ) \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}

#else	// #if __has_feature(objc_instancetype)

#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
- (__class *)sharedInstance; \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
- (__class *)sharedInstance \
{ \
return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
return __singleton__; \
}

#endif	// #if __has_feature(objc_instancetype)

#define RAND_FROM_TO(min, max) [AppnextUtils getRandomBetween:min and:max]

#define GET_BIT_AT_POS(__value,__pos) (__value&(1<<__pos))

#define SIZE_OF_KILOBYTE 1024
#define SIZE_OF_MEGABYTE (1024*1024)

#define SECONDS_IN_MINUTE 60
#define SECONDS_IN_HOUR 3600

#define IS_OS_BELOW_7 ([UIDevice iOSVersion] < 7.0)
#define IS_OS_7_8 (([UIDevice iOSVersion] >= 7.0) && ([UIDevice iOSVersion] < 9.0))
#define IS_OS_8_OR_LATER ([UIDevice iOSVersion] >= 8.0)
#define IS_OS_7_OR_LATER ([UIDevice iOSVersion] >= 7.0)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[UIDevice getDeviceOSVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[UIDevice getDeviceOSVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[UIDevice getDeviceOSVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[UIDevice getDeviceOSVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[UIDevice getDeviceOSVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//
// Array
#define __ArrayObjectAtIndex(__arr,__i) ((__i<[__arr count])?[__arr objectAtIndex:__i]:nil)
#define __ArrayInsertObjectAtIndex(__arr,__obj,__i) { if(__i>=0 && __i<=[__arr count])[__arr insertObject:__obj atIndex:__i]; }
#define __ArrayRemoveObject(__arr,__obj) { if(__obj) [__arr removeObject:__obj]; }
#define __ArrayAddObject(__arr,__obj) { if(__obj) [__arr addObject:__obj]; }
#define __ArrayAddObjectsFromArray(__arr,__arr2) { if(__arr2) [__arr addObjectsFromArray:__arr2]; }
#define __ArrayRemoveAllObjects(__arr) [__arr removeAllObjects]
#define __ArrayContainsObject(__arr,__obj) ((__obj!=nil)?[__arr containsObject:__obj]:NO)
#define __ArrayRemoveObjectsInRange(__arr,__range) ([__arr removeObjectsInRange:__range])

//
// Dictionary
#define __DictionaryObjectForKey(__dic,__key) ((__key!=nil)?[__dic objectForKey:__key]:nil)
#define __DictionaryValueForKey(__dic,__key) ((__key!=nil)?[__dic valueForKey:__key]:nil)
#define __DictionarySetValueForKey(__dic,__key,__val) {if(__key!=nil)[__dic setValue:__val forKey:__key];}
#define __DictionarySetObjectForKey(__dic,__key,__val) {if(__key!=nil)[__dic setObject:__val forKey:__key];}
#define __DictionaryAddEntries(__dic,__dic2) { if(__dic2) [__dic addEntriesFromDictionary:__dic2]; }
#define __DictionaryRemoveObjectForKey(__dic,__key) {if(__key!=nil)[__dic removeObjectForKey:__key];}

//
// Set
#define __SetAddObject(__set,__obj) { if(__obj) [__set addObject:__obj]; }
#define __SetAddObjectsFromArray(__set,__array) { if(__array) [__set addObjectsFromArray:__array]; }
#define __SetRemoveObject(__set,__obj) { if(__obj) [__set removeObject:__obj]; }
#define __SetGetMember(__set,__obj) ((__obj!=nil)?[__set member:__obj]:nil)
#define __SetRemoveAllObjects(__set) [__set removeAllObjects]

//
// NSOrderedSet
#define __SetContainsObject(__set,__obj) ((__obj!=nil)?[__set containsObject:__obj]:NO)

#define __Deg2Rad(__deg) (__deg * M_PI/180.0)

//
// Device directories macroses
#define __AppnextBaseSubdirName         @"Appnext"
#define __AppnextVideosSubdirName       @"Videos"
#define __AppnextImagesSubdirName       @"Images"
#define __DocumentDirectory             __ArrayObjectAtIndex(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES), 0)
#define __TempDirectory                 [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define __AppnextVideosSubdirPath       [NSString stringWithFormat:@"%@/%@/", __AppnextBaseSubdirName, __AppnextVideosSubdirName]
#define __AppnextVideosDirectoryPath    [NSString stringWithFormat:@"%@/%@", __DocumentDirectory, __AppnextVideosSubdirPath]
#define __AppnextImagesSubdirPath       [NSString stringWithFormat:@"%@/%@/", __AppnextBaseSubdirName, __AppnextImagesSubdirName]
#define __AppnextImagesDirectoryPath    [NSString stringWithFormat:@"%@/%@", __DocumentDirectory, __AppnextImagesSubdirPath]

#define kMaxNumOfFilesToLeaveInDir 15

#define NetworkRequestManager [AppnextNetworkRequestManager sharedInstance]

#define kInfiniteValidityTime -1
#define kDefaultAdResponseValidityTimeMinutes 1

#define kOfferWallAdsRequestCount 50

#define kPostViewResolveDefaultTimeout 20.0f
#define kClickResolveDefaultTimeout 15.0f
#define kClickResolveMinTimeout 8.0f

static NSString * const kBannerExpirationDefaultTimeString = @"12";
static NSString * const kClickResolveDefaultTimeoutString = @"15.0";
static NSString * const kCapRangeDefaultString = @"6";
static NSString * const kPostponeImpressionSecDefaultString = @"0";
static NSString * const kPostponeVTASecDefaultString = @"0";
static NSString * const kAdsCachingTimeMinutesDefaultString = @"1";

static NSString * const kInternetConnectionUnknownString = @"Unknown";
static NSString * const kInternetConnectionNotReachableString = @"-";
static NSString * const kInternetConnectionWiFiString = @"wifi";
static NSString * const kInternetConnection2GString = @"2G";
static NSString * const kInternetConnection3GString = @"3G";
static NSString * const kInternetConnection4GString = @"4G";

extern dispatch_queue_t appnextApiWorkQueue;

static NSString * const kOSID = @"200";
static NSString * const kTID = @"300";
static NSString * const kPIMP = @"1";
static NSString * const kGROUP = @"sdk";
static NSString * const kM = @"1";

static NSString * const kAppStoreHTTPPrefix = @"http://itunes.apple.com/";
static NSString * const kAppStoreHTTPSPrefix = @"https://itunes.apple.com/";
static NSString * const kAppStoreDirectSPrefix1 = @"itms-apps://itunes.apple.com/";
static NSString * const kAppStoreDirectSPrefix2 = @"itms://itunes.apple.com/";
static NSString * const kAppStoreDirectSPrefix3 = @"itms-appss://itunes.apple.com/";

typedef void (^appnext_prepare_load_block_t)(BOOL loaded);

static NSString * const kPositionTypeValueStringBottomRight = @"bottomright";
static NSString * const kPositionTypeValueStringBottomLeft = @"bottomleft";
static NSString * const kPositionTypeValueStringBottom = @"bottom";
static NSString * const kPositionTypeValueStringTopRight = @"topright";
static NSString * const kPositionTypeValueStringTopLeft = @"topleft";
static NSString * const kPositionTypeValueStringTop = @"top";
static NSString * const kPositionTypeValueStringRight = @"right";
static NSString * const kPositionTypeValueStringLeft = @"left";
static NSString * const kPositionTypeValueStringCenter = @"center";

typedef NS_ENUM(NSUInteger, ANPositionInViewType)
{
    ANPositionInViewTypeNone        = 0,
    ANPositionInViewTypeBottomRight = 1,
    ANPositionInViewTypeBottomLeft  = 2,
    ANPositionInViewTypeBottom      = 3,
    ANPositionInViewTypeTopRight    = 4,
    ANPositionInViewTypeTopLeft     = 5,
    ANPositionInViewTypeTop         = 6,
    ANPositionInViewTypeRight       = 7,
    ANPositionInViewTypeLeft        = 8,
    ANPositionInViewTypeCenter      = 9,
};

typedef NS_ENUM(NSUInteger, ANPreferredOrientationType)
{
    ANPreferredOrientationTypeAutomatic        = 0,
    ANPreferredOrientationTypeLandscape        = 1,
    ANPreferredOrientationTypePortrait         = 2,
    ANPreferredOrientationTypeNotSet           = 3,
};

typedef NS_ENUM(NSUInteger, ANPostViewLocation)
{
    ANPostViewLocationNone        = 0,
    ANPostViewLocationPlayVideo   = 1,
    ANPostViewLocationImpression  = 2,
};

typedef NS_ENUM(NSUInteger, ANLoadingState)
{
    ANLoadingStateNotLoaded = 0,
    ANLoadingStateLoading   = 1,
    ANLoadingStateLoaded    = 2,
};

typedef NS_ENUM(NSUInteger, ANLoadResult)
{
    ANLoadResultNotLoaded = 0,
    ANLoadResultFailed    = 1,
    ANLoadResultSuccess   = 2
};

static NSString * const kPostViewLocationStringPlayVideoPV = @"play_video_pv";
static NSString * const kPostViewLocationStringImpressionPV = @"impression_pv";
static NSString * const kConfigurationKeyForensiqControl = @"fq_control";

static NSString * const kWhiteColor = @"ffffff";

static NSString * const kWhiteColorNameString = @"white";
static NSString * const kBlackColorNameString = @"black";

// Configuration Keys

static NSString * const kConfigurationKeyResolveTimeout = @"resolve_timeout";

static NSString * const kConfigurationKeyButtonColor = @"b_color";
static NSString * const kConfigurationKeyButtonTitle = @"b_title";
static NSString * const kConfigurationKeyButtonWidth = @"b_width";
static NSString * const kConfigurationKeyButtonHeight = @"b_height";
static NSString * const kConfigurationKeyButtonPosition = @"b_position";

static NSString * const kConfigurationKeyShowInstall = @"show_install";
static NSString * const kConfigurationKeyShowIcon = @"show_icon";
static NSString * const kConfigurationKeyShowNameApp = @"show_nameApp";
static NSString * const kConfigurationKeyShowRating = @"show_rating";
static NSString * const kConfigurationKeyShowDesc = @"show_desc";

static NSString * const kConfigurationKeyProgressType = @"progress_type";
static NSString * const kConfigurationKeyProgressColor = @"progress_color";
static NSString * const kConfigurationKeyProgressDelay = @"progress_delay";

static NSString * const kConfigurationKeyCloseDelay = @"close_delay";
static NSString * const kConfigurationKeyShowClose = @"show_close";
static NSString * const kConfigurationKeyCloseButtonPosition = @"close_button_position";

static NSString * const kConfigurationKeyVideoLength = @"video_length";
static NSString * const kConfigurationKeyMute = @"mute";
static NSString * const kConfigurationKeyUrlAppProtection = @"urlApp_protection";
static NSString * const kConfigurationKeyClickInApp = @"clickInApp";
static NSString * const kConfigurationKeyBackgroundColor = @"background_color";
static NSString * const kConfigurationKeyPView = @"pview";
static NSString * const kConfigurationKeyCreative = @"creative";
static NSString * const kConfigurationKeySkipTitle = @"skip_title";
static NSString * const kConfigurationKeyAutoPlay = @"auto_play";
static NSString * const kConfigurationKeyRemovePosterOnAutoPlay = @"remove_poster_on_auto_play";
static NSString * const kConfigurationKeyBannerExpirationTime = @"banner_expiration_time";
static NSString * const kConfigurationKeyPostponeImpressionSec = @"postpone_impression_sec";
static NSString * const kConfigurationKeyPostponeVTASec = @"postpone_vta_sec";
static NSString * const kConfigurationKeyAdsCachingTimeMinutes = @"ads_caching_time_minutes";

static NSString * const kConfigurationKeyPostViewLocation = @"postview_location";
static NSString * const kConfigurationKeyCapRange = @"capRange";

// Resolve Manager Errors
static NSString * const kResolveManagerErrorEmptyResolveURL = @"Empty Resolve URL";
static NSString * const kResolveManagerErrorCanceled = @"Resolve Canceled";
static NSString * const kResolveManagerErrorTimedout = @"Resolve Timedout";

// Open Url Errors
static NSString * const kOpenUrlErrorEmptyURL = @"Empty Open URL";
static NSString * const kOpenUrlErrorFailed = @"Open URL Failed";
static NSString * const kOpenUrlErrorTimedout = @"Open URL Timedout";

#endif /* AppnextSDKCoreDefs_h */
