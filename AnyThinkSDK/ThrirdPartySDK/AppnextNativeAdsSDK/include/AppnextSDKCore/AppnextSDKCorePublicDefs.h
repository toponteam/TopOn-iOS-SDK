//
//  AppnextSDKCorePublicDefs.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 14/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#ifndef AppnextSDKCorePublicDefs_h
#define AppnextSDKCorePublicDefs_h

// Possible errors returned to client in AppnextAdDelegate method adError:error:

static NSString * const kAdErrorNoInternetConnection = @"No internet connection";
static NSString * const kAdErrorNoPlacementID = @"Placement ID cannot be empty";
static NSString * const kAdErrorDownloadingResources = @"Error Downloading Resources";
static NSString * const kAdErrorAdNotReady = @"Ad not ready";
static NSString * const kAdErrorPreparingViews = @"Error Preparing Views";
static NSString * const kAdErrorLoadingAd = @"Error Loading Ad";
static NSString * const kAdErrorBadParameters = @"Bad parameters";
static NSString * const kAdErrorEmptyResponse = @"Empty response";
static NSString * const kAdErrorNoAds = @"No ads";
static NSString * const kAdErrorFailedLoadingAds = @"Failed loading ads";
static NSString * const kAdErrorNoSuitableAd = @"No suitable ad";
static NSString * const kAdErrorVideoFileNameNotValid = @"Video file name not valid";

static NSString * const kNativeAdsErrorRequestNotValid = @"Request cannot be null";
static NSString * const kNativeAdsErrorAdDataNotValid = @"Ad Data cannot be null";
static NSString * const kNativeAdsErrorCantOpenStore = @"Cant open store on the device";

static NSString * const kPreferredOrientationTypeStringAutomatic = @"automatic";
static NSString * const kPreferredOrientationTypeStringLandscape = @"landscape";
static NSString * const kPreferredOrientationTypeStringPortrait  = @"portrait";
static NSString * const kPreferredOrientationTypeStringNotSet    = @"not_set";

static NSString * const kCreativeTypeStringManaged = @"managed";
static NSString * const kCreativeTypeStringVideo = @"video";
static NSString * const kCreativeTypeStringStatic = @"static";

typedef NS_ENUM(NSInteger, ANCreativeType)
{
    ANCreativeTypeNotSet = -1,
    ANCreativeTypeManaged = 0,
    ANCreativeTypeVideo   = 1,
    ANCreativeTypeStatic  = 2,
};

static NSString * const kProgressTypeStringDefault = @"default";
static NSString * const kProgressTypeStringClock = @"clock";
static NSString * const kProgressTypeStringBar = @"bar";
static NSString * const kProgressTypeStringNone = @"none";

typedef NS_ENUM(NSUInteger, ANProgressType)
{
    ANProgressTypeDefault = 0, // Takes from Settings
    ANProgressTypeClock   = 1,
    ANProgressTypeBar     = 2,
    ANProgressTypeNone    = 3,
};

static NSString * const kVideoLengthLongString = @"30";
static NSString * const kVideoLengthShortString = @"15";

typedef NS_ENUM(NSInteger, ANVideoLength)
{
    ANVideoLengthManaged = -1, // Takes from Settings
    ANVideoLengthShort   = 15,
    ANVideoLengthLong    = 30,
};

#endif /* AppnextSDKCorePublicDefs_h */
