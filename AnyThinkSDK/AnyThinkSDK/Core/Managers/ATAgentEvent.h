//
//  ATAgentEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 02/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATThreadSafeAccessor.h"
#import "ATAd.h"

extern NSString *const kGeneralAdAgentEventExtraInfoErrorKey;
extern NSString *const kGeneralAdAgentEventExtraInfoNetworkFirmIDKey;
extern NSString *const kGeneralAdAgentEventExtraInfoUnitGroupContentKey;
extern NSString *const kGeneralAdAgentEventExtraInfoPriorityKey;
extern NSString *const kGeneralAdAgentEventExtraInfoResultCodeKey;
extern NSString *const kGeneralAdAgentEventExtraInfoShortTimeoutFlagKey;
extern NSString *const kGeneralAdAgentEventExtraInfoAutoRequestFlagKey;
extern NSString *const kGeneralAdAgentEventExtraInfoSDKCallFlagKey;
extern NSString *const kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey;
extern NSString *const kGeneralAdAgentEventExtraInfoRewardedFlagKey;
extern NSString *const kGeneralAdAgentEventExtraInfoDefaultLoadFlagKey;

extern NSString *const kRVAgentEventExtraInfoDownloadResultKey;
extern NSString *const kRVAgentEventExtraInfoDownloadTimeKey;
extern NSString *const kRVAgentEventExtraInfoErrorTypeKey;
extern NSString *const kRVAgentEventExtraInfoErrorMsgKey;
extern NSString *const kRVAgentEventExtraInfoRewardedFlagKey;

extern NSString *const kAgentEventExtraInfoNotReadyReasonKey;
extern NSString *const kAgentEventExtraInfoReadyFlagKey;
extern NSString *const kAgentEventExtraInfoCallerInfoKey;

extern NSString *const kAgentEventExtraInfoPlacementIDKey;
extern NSString *const kAgentEventExtraInfoPSIDKey;
extern NSString *const kAgentEventExtraInfoSessionIDKey;
extern NSString *const kAgentEventExtraInfoRequestIDKey;
extern NSString *const kAgentEventExtraInfoGroupIDKey;
extern NSString *const kAgentEventExtraInfoLoadingEventTypeKey;
extern NSString *const kAgentEventExtraInfoSDKCallFlagKey;
extern NSString *const kAgentEventExtraInfoSDKNotCalledReasonKey;
extern NSString *const kAgentEventExtraInfoASIDKey;
extern NSString *const kAgentEventExtraInfoLoadingResultKey;
extern NSString *const kAgentEventExtraInfoLoadingFailureReasonKey;
extern NSString *const kAgentEventExtraInfoAdSourceIDKey;
extern NSString *const kAgentEventExtraInfoNetworkFirmIDKey;
extern NSString *const kAgentEventExtraInfoUnitGroupUnitIDKey;
extern NSString *const kAgentEventExtraInfoPriorityKey;
extern NSString *const kAgentEventExtraInfoRequestFailReasonKey;
extern NSString *const kAgentEventExtraInfoRequestFailErrorCodeKey;
extern NSString *const kAgentEventExtraInfoRequestFailErrorMsgKey;
extern NSString *const kAgentEventExtraInfoRequestFailTimeKey;
extern NSString *const kAgentEventExtraInfoRequestHeaderBiddingFlagKey;
extern NSString *const kAgentEventExtraInfoRequestPriceKey;
extern NSString *const kAgentEventExtraInfoNetworkSDKVersionKey;
extern NSString *const kAgentEventExtraInfoASResultKey;
extern NSString *const kAgentEventExtraInfoRewardFlagKey;
extern NSString *const kAgentEventExtraInfoTKHostKey;
extern NSString *const kAgentEventExtraInfoAPINameKey;
extern NSString *const kAgentEventExtraInfoNetworkErrorCodeKey;
extern NSString *const kAgentEventExtraInfoNetworkErrorMsgKey;
extern NSString *const kAgentEventExtraInfoRequestTimestampKey;
extern NSString *const kAgentEventExtraInfoResponseTimestampKey;
extern NSString *const kAgentEventExtraInfoNetworkTimeKey;
extern NSString *const kAgentEventExtraInfoLatestRequestIDKey;
extern NSString *const kAgentEventExtraInfoLatestRequestIDDifferFlagKey;
extern NSString *const kAgentEventExtraInfoAdFilledByReadyFlagKey;
extern NSString *const kAgentEventExtraInfoAutoloadOnCloseFlagKey;
extern NSString *const kAgentEventExtraInfoMyOfferDefaultFlagKey;
extern NSString *const kAgentEventExtraInfoMyOfferOfferIDKey;
extern NSString *const kAgentEventExtraInfoMyOfferResourceURLKey;
extern NSString *const kAgentEventExtraInfoMyOfferVideoDownloadResultKey;
extern NSString *const kAgentEventExtraInfoMyOfferVideoSizeKey;
extern NSString *const kAgentEventExtraInfoMyOfferVideoDownloadFailReasonKey;
extern NSString *const kAgentEventExtraInfoMyOfferVideoDownloadStartTimestampKey;
extern NSString *const kAgentEventExtraInfoMyOfferVideoDownloadFinishTimestampKey;
extern NSString *const kAgentEventExtraInfoMyOfferVideoDownloadTimeKey;
extern NSString *const kAgentEventExtraInfoOriginalRequestIDKey;
extern NSString *const kAgentEventExtraInfoMetadataLoadingTimeKey;
extern NSString *const kAgentEventExtraInfoAdDataLoadingTimeKey;
//5.4.0 tk failed count;
extern NSString *const kAgentEventExtraInfoTrackerFailedCountKey;
//extern NSString *const kAgentEventExtraInfoLoadingEventTypeLoad;
extern NSString *const kAgentEventExtraInfoLoadingEventTypeLoadResult;

extern NSString *const kAgentEventExtraInfoShowResultKey;
extern NSString *const kAgentEventExtraInfoShowFailureReasonKey;
extern NSString *const kAgentEventExtraInfoGeneratedIDTypeKey;
extern NSString *const kAgentEventExtraInfoIDGenerationRandomNumberKey;
extern NSString *const kAgentEventExtraInfoIDGenerationTimestampKey;
extern NSString *const kAgentEventExtraInfoGDPRThirdPartySDKLevelKey;
extern NSString *const kAgentEventExtraInfoGDPRDevConsentKey;
extern NSString *const kAgentEventExtraInfoServerGDPRIAValueKey;

extern NSString *const kAgentEventExtraInfoLifecycleEventTypeKey;
extern NSString *const kAgentEventExtraInfoActivateTimeKey;
extern NSString *const kAgentEventExtraInfoResignActiveTimeKey;
extern NSString *const kAgentEventExtraInfoLifecycleIntervalKey;

extern NSString *const kAgentEventExtraInfoFormatKey;
extern NSString *const kAgentEventExtraInfoShowTimestampKey;
extern NSString *const kAgentEventExtraInfoCloseTimestampKey;
extern NSString *const kAgentEventExtraInfoShowDurationKey;

extern NSString *const kATAgentEventKeyLoadFail;
extern NSString *const kATAgentEventKeyFailToPlay;
extern NSString *const kATAgentEventKeyRequestFail;
extern NSString *const kATAgentEventKeyReady;
extern NSString *const kATAgentEventKeyShowFail;
extern NSString *const kATAgentEventKeyClose;
extern NSString *const kATAgentEventKeyNetworkRequestFail;
extern NSString *const kATAgentEventKeyNetworkRequestSuccess;
extern NSString *const kATAgentEventKeyPSIDSessionIDGeneration;
extern NSString *const kATAgentEventKeyMyOfferVideoDownload;
extern NSString *const kATAgentEventKeyAdSourceStatusFillKey;
extern NSString *const kATAgentEventKeyMetadataAndAdDataLoadingTimeKey;
extern NSString *const kATAgentEventKeyGDPRLevelKey;
extern NSString *const kATAgentEventKeyAppLifecycleKey;
extern NSString *const kATAgentEventKeyAdShowDurationKey;

typedef NS_ENUM(NSInteger, ATAgentEventAdNotReason) {
    ATAgentEventAdNotReasonStatusFalse = 0,
    ATAgentEventAdNotReasonStatusExpired = 1,
    ATAgentEventAdNotReasonNoReadyAd = 2,
    ATAgentEventAdNotReasonAdAllExpired = 3
};
typedef NS_ENUM(NSInteger, ATGeneralAdAgentEventType) {
    ATGeneralAdAgentEventTypeRequest = 100001,
    ATGeneralAdAgentEventTypeRequestSuccess = 100002,
    ATGeneralAdAgentEventTypeRequestFailure = 100003,
    ATGeneralAdAgentEventTypeImpression = 100004,
    ATGeneralAdAgentEventTypeClick = 100005,
    ATGeneralAdAgentEventTypeClose = 100006,
    ATGeneralAdAgentEventTypeBannerVisible = 100007,
    ATGeneralAdAgentEventTypeBannerPresentScreen = 100008,
    ATGeneralAdAgentEventTypeBannerLeaveApp = 100009,
    ATGeneralAdAgentEventTypePlacementReady = 100010,
    ATGeneralAdAgentEventTypeAdSourceReady = 100011,
    ATGeneralAdAgentEventTypeLoad = 100012,
    ATGeneralAdAgentEventTypeShowSuccessfully = 100013,
    ATGeneralAdAgentEventTypeShowFailure = 100014
};

@interface ATAgentEvent : NSObject
+(instancetype)sharedAgent;
+(NSString*) eventRootPath;
/*
 * Save event & upload if one of the conditions of event upload becomes true:
 * 1) the number of the saved events has exceeded 8;
 * 2) the last upload has occured longer than 30 mins.
 */
+(void) saveRequestAPIName:(NSString*)apiName requestDate:(NSNumber*)requestDate responseDate:(NSNumber*)responseDate extra:(NSDictionary*)extra;
-(void) saveEventWithKey:(NSString*)key placementID:(nullable NSString*)placementID unitGroupModel:(nullable ATUnitGroupModel*)unitGroupModel extraInfo:(NSDictionary*)extraInfo;
/**
 * Upload all stored event and if succeeds, remove all the files from disk.
 */
-(void) uploadIfNeed;

+(NSDictionary*)generalAdAgentInfoWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID;
@end

@protocol ATAgentEventDataStructure<NSObject>
@end
