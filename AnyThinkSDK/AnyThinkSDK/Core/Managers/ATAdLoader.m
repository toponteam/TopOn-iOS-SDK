//
//  ATAdLoader.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdLoader.h"
#import "ATThreadSafeAccessor.h"
#import "ATAPI+Internal.h"
#import "ATPlacementModel.h"
#import "ATPlacementSettingManager.h"
#import "Utilities.h"
#import "ATTracker.h"
#import "ATAgentEvent.h"
#import "ATAdManager+Internal.h"
#import "ATAdLoadingDelegate.h"
#import "ATCapsManager.h"
#import "ATAdManagement.h"
#import "ATAdAdapter.h"
#import "ATAdManager+Internal.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATLoadingScheduler.h"
#import "ATAdStorageUtility.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
#import "ATAdManager.h"
#import "ATBidInfoManager.h"
#import "ATWaterfallManager.h"
#import "ATBidInfo.h"
#import "ATAdLoader+S2SHeaderBidding.h"
#import "ATHeaderBiddingManager.h"

NSString *const kADapterCustomInfoStatisticsInfoKey = @"statistics_info";
NSString *const kAdapterCustomInfoPlacementModelKey = @"tracking_info_placement_model";
NSString *const kAdapterCustomInfoUnitGroupModelKey = @"tracking_info_unit_group_model";
NSString *const kAdapterCustomInfoRequestIDKey = @"tracking_info_request_id";

NSString *const kAdLoadingExtraRefreshFlagKey = @"refresh";
NSString *const kAdapterCustomInfoExtraKey = @"extra";

static NSString *const kATMyOfferOfferManagerClassName = @"ATMyOfferOfferManager";
@interface ATAdLoader()
@property(nonatomic, readonly) ATThreadSafeAccessor *failedRequestRecordsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDate*> *failedRequestRecords;
@property(nonatomic, readonly) ATThreadSafeAccessor *failedBidRecordsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDate*> *failedBidRecords;
/**
 {
     placement_id: {
         date:2020-06-18 15:25:00
         da_sent_flag:@YES
     }
 }
 */
@property(nonatomic, readonly) ATSerialThreadSafeAccessor *loadFailureDateStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary*> *loadFailureDateStorage;
@end
static NSString *const kInactiveUnitGroupInfoUnitGroupKey = @"unit_group";
static NSString *const kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey = @"load_using_ad_source_status_flag";
@implementation ATAdLoader
+(instancetype)sharedLoader {
    static ATAdLoader *sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoader = [[ATAdLoader alloc] init];
    });
    return sharedLoader;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _failedRequestRecords = [NSMutableDictionary<NSString*, NSDate*> dictionary];
        _failedRequestRecordsAccessor = [ATThreadSafeAccessor new];
        
        _failedBidRecords = [NSMutableDictionary<NSString*, NSDate*> dictionary];
        _failedBidRecordsAccessor = [ATThreadSafeAccessor new];
        
        _loadFailureDateStorageAccessor = [ATSerialThreadSafeAccessor new];
        _loadFailureDateStorage = [NSMutableDictionary<NSString*, NSDictionary*> dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScheduledLoadNotification:) name:kATScheduledLoadFiredNotification object:nil];
    }
    return self;
}

static NSString *kLoadFailureDateStorageDateKey = @"date";
static NSString *kLoadFailureDateStorageAgentEventFlagKey = @"da_flag";

void LogATLoadderHeaderBiddingLog(NSString* log) { [ATLogger logMessage:[NSString stringWithFormat:@"HeaderBidding::%@", log] type:ATLogTypeInternal]; }

-(void) updateLoadFailureDateForPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    [_loadFailureDateStorageAccessor writeWithBlock:^{ weakSelf.loadFailureDateStorage[placementID] = @{kLoadFailureDateStorageDateKey:[NSDate date], kLoadFailureDateStorageAgentEventFlagKey:@NO}; }];
}

-(void) clearLoadFailureDateForPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    [_loadFailureDateStorageAccessor writeWithBlock:^{ [weakSelf.loadFailureDateStorage removeObjectForKey:placementID]; }];
}

-(BOOL) loadFailureDateExpiredForPlacementModel:(ATPlacementModel*)placementModel shouldSendDA:(BOOL*)shouldSendDA {
    __weak typeof(self) weakSelf = self;
    return [[_loadFailureDateStorageAccessor readWithBlock:^id{
        BOOL result = YES;
        NSDictionary *entry = weakSelf.loadFailureDateStorage[placementModel.placementID];
        if (entry != nil) {
            result = [[NSDate date] timeIntervalSinceDate:entry[kLoadFailureDateStorageDateKey]] > placementModel.loadFailureInterval;
            if (shouldSendDA != NULL) {
                *shouldSendDA = ![entry[kLoadFailureDateStorageAgentEventFlagKey] boolValue];
                weakSelf.loadFailureDateStorage[placementModel.placementID] = @{kLoadFailureDateStorageDateKey:entry[kLoadFailureDateStorageDateKey], kLoadFailureDateStorageAgentEventFlagKey:@YES};
            }
        }
        return @(result);
    }] boolValue];
}

-(void) updateRequestFailureForPlacemetModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    __weak typeof(self) weakSelf = self;
    [_failedRequestRecordsAccessor writeWithBlock:^{ weakSelf.failedRequestRecords[[NSString stringWithFormat:@"%@_%@", placementModel.placementID, unitGroupModel.unitID]] = [NSDate date]; }];
}

-(BOOL) shouldSendRequestAfterLastFailureForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    __weak typeof(self) weakSelf = self;
    NSDate *lastFailureDate = [_failedRequestRecordsAccessor readWithBlock:^id{ return weakSelf.failedRequestRecords[[NSString stringWithFormat:@"%@_%@", placementModel.placementID, unitGroupModel.unitID]]; }];
    return lastFailureDate == nil || [[NSDate date] timeIntervalSinceDate:lastFailureDate] > unitGroupModel.skipIntervalAfterLastLoadingFailure;
}

-(void) updateS2SBidRequestFailureForPlacemetModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    __weak typeof(self) weakSelf = self;
    [_failedBidRecordsAccessor writeWithBlock:^{ weakSelf.failedBidRecords[[NSString stringWithFormat:@"%@_%@", placementModel.placementID, unitGroupModel.unitID]] = [NSDate date]; }];
}

-(BOOL) shouldSendS2SBidRequestAfterLastFailureForPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    __weak typeof(self) weakSelf = self;
    NSDate *lastFailureDate = [_failedBidRecordsAccessor readWithBlock:^id{ return weakSelf.failedBidRecords[[NSString stringWithFormat:@"%@_%@", placementModel.placementID, unitGroupModel.unitID]]; }];
    return lastFailureDate == nil || [[NSDate date] timeIntervalSinceDate:lastFailureDate] > unitGroupModel.skipIntervalAfterLastBiddingFailure;
}

-(void) handleScheduledLoadNotification:(NSNotification*)notification {
    [ATLogger logMessage:@"ATAdLoader::handleScheduledLoadNotification:" type:ATLogTypeInternal];
    ATUnitGroupModel *unitGroupModel = notification.userInfo[kATScheduledLoadFiredNotificationUserInfoUnitGroupModel];
    if (!unitGroupModel.headerBidding) {
        NSString *requestID = notification.userInfo[kATScheduledLoadFiredNotificationUserInfoRequestID];
        ATPlacementModel *placementModel = notification.userInfo[kATScheduledLoadFiredNotificationUserInfoPlacementModel];
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithObject:@YES forKey:kAdLoadingExtraAutoloadFlagKey];
        if (notification.userInfo[kATScheduledLoadFiredNotificationUserInfoExtra] != nil) { [extra addEntriesFromDictionary:notification.userInfo[kATScheduledLoadFiredNotificationUserInfoExtra]]; }
        //Pass nil for finalWaterfall parameter to use the last one
        [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:unitGroupModel finalWaterfall:nil startDate:[NSDate date] extra:extra delegate:nil success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary *> *assets) {
            
        } failure:^(id<ATAdLoadingDelegate>delegate, NSError *error) {
            //
        }];
    }
}

-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATAdLoadingDelegate>)delegate {
    NSString *requestID = [Utilities generateRequestID];
    [[ATPlacementSettingManager sharedManager] setLatestRequestID:requestID forPlacementID:placementID];
    if (![[ATPlacementSettingManager sharedManager] statusForPlacementID:placementID error:nil]) {
        BOOL shouldSendLoadFailureIntervalDA = NO;
        ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
        if (placementModel == nil || [self loadFailureDateExpiredForPlacementModel:placementModel shouldSendDA:&shouldSendLoadFailureIntervalDA]) {
            if ([[ATCapsManager sharedManager] validateLoadCapsForPlacementID:placementID cap:placementModel.loadCap duration:placementModel.loadCapDuration]) {
                if ([[ATWaterfallManager sharedManager] loadingAdForPlacementID:placementID]) {
                    [ATLogger logError:[NSString stringWithFormat:@"ATAdLoader::Ad for placementID:%@ is being loaded, please do not load again before the previous request's been finished", placementID] type:ATLogTypeExternal];
                    [self updateLoadFailureDateForPlacementID:placementID];
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodePreviousLoadNotFinished userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The previous load for the placementID %@ has not returned.", placementID]}];
                    [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0, kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraSDKNotCalledReasonKey:@3}];
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                    if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [delegate didFailToLoadADWithPlacementID:placementID error:error]; }
                } else {
                    void (^StartLoadWithPlacementModel)(ATPlacementModel *placementModel) = ^(ATPlacementModel *placementModel) {
                        [[ATAdManager sharedManager] setExtraInfo:extra forPlacementID:placementID requestID:requestID];
                        if (placementModel.adDeliverySwitch) {
                            [[ATAdLoader sharedLoader] startLoadingOffersWithRequestID:requestID placementModel:placementModel extra:extra delegate:delegate];
                        } else {
                            [self updateLoadFailureDateForPlacementID:placementID];
                            if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [delegate didFailToLoadADWithPlacementID:placementID error:[NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodePlacementAdDeliverySwitchOff userInfo:@{NSLocalizedDescriptionKey:@"Ad loading has failed.", NSLocalizedFailureReasonErrorKey:@"Ad delivery switch has be turned off in placement setting."}]]; }
                        }
                    };
                    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
                    NSDictionary *curCustomData = [[ATPlacementSettingManager sharedManager] calculateCustomDataForPlacementID:placementID];
                    if (placementModel != nil) {//Placement setting exists
                        if ([[NSDate date] timeIntervalSinceDate:placementModel.cacheDate] >= placementModel.cacheValidDuration || [ATPlacementSettingManager myOfferExhaustedInPlacementModel:placementModel] || ![placementModel.associatedCustomData isEqualToDictionary:curCustomData]) {//placement expired or my offers exhausted
                            __block BOOL placementReqSuc = NO;
                            __block BOOL placeemntReqTimeout = NO;
                            //request new placement model
                            [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData extra:extra completion:^(ATPlacementModel *newPlacementModel, NSError *error) {
                                if (error == nil) {
                                    [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:newPlacementModel];
                                    placementReqSuc = YES;
                                    if (!placeemntReqTimeout) { StartLoadWithPlacementModel(newPlacementModel); }
                                }
                            }];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.updateTolerateInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                placeemntReqTimeout = YES;
                                if (!placementReqSuc) { StartLoadWithPlacementModel(placementModel); }//placement request failed
                            });
                        } else {//placement valid, start load
                            StartLoadWithPlacementModel(placementModel);
                        }
                    } else {
                        //placementID has to be added
                        __weak typeof(delegate) weakDelegate = delegate;
                        [[ATAdManager sharedManager] addNewPlacementID:placementID];
                        [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData extra:extra completion:^(ATPlacementModel *placementModel, NSError *error) {
                            if (error == nil) {
                                [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:placementModel];
                                
                                //Kick off MyOffer loading...
                                if (placementModel.preloadMyOffer) { [ATAdLoader loadMyOfferOffersInPlacementModel:placementModel requestID:requestID offerIndex:0]; };
                                
                                StartLoadWithPlacementModel(placementModel);
                            } else {
                                [self updateLoadFailureDateForPlacementID:placementID];
                                if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [weakDelegate didFailToLoadADWithPlacementID:placementID error:error]; }
                            }
                        }];
                    }//End of outter else
                }
            } else {//load caps
                [self updateLoadFailureDateForPlacementID:placementID];
                NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeLoadCapsExceeded userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The placementID %@ load too many times within the specified time period", placementID]}];
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0, kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraSDKNotCalledReasonKey:@8}];
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [delegate didFailToLoadADWithPlacementID:placementID error:error]; }
            }
        } else {//load failure interval
            //ATADLoadingErrorCodeFailureTooFrequent
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeFailureTooFrequent userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The placementID %@ load too frequently within the specified times period after the previous load failure", placementID]}];
            if (shouldSendLoadFailureIntervalDA) {
                [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0, kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraSDKNotCalledReasonKey:@7}];
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
            }
            if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [delegate didFailToLoadADWithPlacementID:placementID error:error]; }
        }
    } else {//Status being true, notify successful load directory
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0, kATTrackerExtraSDKNotCalledReasonKey:@4, kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])}];
        
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoadResult extra:@{kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraLoadTimeKey:@.0f}];
            if ([delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [delegate didFinishLoadingADWithPlacementID:placementID]; }); }
        if ([[ATAdManager sharedManager] psIDExpired]) {
            [[ATAdManager sharedManager] clearPSID];
            NSDictionary *curCustomData = [[ATPlacementSettingManager sharedManager] calculateCustomDataForPlacementID:placementID];
            [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData extra:extra completion:^(ATPlacementModel *placementModel, NSError *error) { if (error == nil) [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:placementModel]; }];
        }
    }
}

//To seerially load my offers; switch to be added
+(void) loadMyOfferOffersInPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID offerIndex:(NSInteger)index {
    NSArray<ATMyOfferOfferModel*> *offerModels = placementModel.offers;
    if (index < [offerModels count]) { [[NSClassFromString(kATMyOfferOfferManagerClassName) sharedManager] loadOfferWithOfferModel:offerModels[index] setting:placementModel.myOfferSetting extra:nil completion:^(NSError *error) { [self loadMyOfferOffersInPlacementModel:placementModel requestID:requestID offerIndex:index + 1]; }]; }
}

-(void) updateStatusAndNotifySuccessToDelegate:(id<ATAdLoadingDelegate>)delegate placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID loadStartDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra {
    [self clearLoadFailureDateForPlacementID:placementModel.placementID];
    NSMutableDictionary *tkExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraLoadTimeKey:@(loadStartDate != nil ? [@([[NSDate date]timeIntervalSinceDate:loadStartDate] * 1000) integerValue] : 0)}];
    if ([extra[kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey] boolValue]) { tkExtra[kATTrackerExtraSDKNotCalledReasonKey] = @5; }
    [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeLoadResult extra:tkExtra];
    
    [[ATBidInfoManager sharedManager] saveRequestID:requestID forPlacementID:placementModel.placementID];
    ATPlacementModel *newPlacementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementModel.placementID];
    if ([placementModel.asid isEqualToString:newPlacementModel.asid]) { [[ATPlacementSettingManager sharedManager] setStatus:YES forPlacementID:placementModel.placementID]; }
    if (![[ATAdManager sharedManager] adBeingShownForPlacementID:placementModel.placementID] && [delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [delegate didFinishLoadingADWithPlacementID:placementModel.placementID]; }); }
}

-(void) notifyFailureWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID extra:(NSDictionary*)extra error:(NSError*)error delegate:(id<ATAdLoadingDelegate>)delegate {
    [self updateLoadFailureDateForPlacementID:placementModel.placementID];
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
    if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [delegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; }); }
}

-(void) configureDefaultAdSourceLoadIfNeededWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.extra.defaultAdSourceLoadingDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
            ATUnitGroupModel *loadingUG = [waterfall firstPendingNonHBUnitGroupWithNetworkFirmID:placementModel.extra.defaultNetworkFirmID];
            if (loadingUG != nil) {
                NSMutableDictionary *extraPara = extra != nil ? [NSMutableDictionary dictionaryWithDictionary:extra] : [NSMutableDictionary dictionary];
                extraPara[kAdLoadingExtraDefaultLoadKey] = @YES;
                [waterfall requestUnitGroup:loadingUG];
                [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:loadingUG finalWaterfall:finalWaterfall startDate:loadStartDate extra:extraPara delegate:delegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary *> *assets) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:extra];
                        userInfo[kATADLoadingNotificationUserInfoRequestIDKey] = requestID;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:userInfo];
                        [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                            if (!finished) {
                                [waterfall finishUnitGroup:loadingUG withType:ATUnitGroupFinishTypeFinished];
                                [waterfallWrapper finish];
                                [waterfallWrapper fill];
                                [self updateStatusAndNotifySuccessToDelegate:delegate placementModel:placementModel requestID:requestID loadStartDate:loadStartDate extra:nil];
                            }
                        }];
                       
                    });
                } failure:^(id<ATAdLoadingDelegate> delegate, NSError * error) {
                    //just do nothing
                    [waterfall finishUnitGroup:loadingUG withType:error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? ATUnitGroupFinishTypeTimeout : ATUnitGroupFinishTypeFailed];
                }];
            }
        }];
    });
}

-(void) configureOfferLoadingTimeoutWithPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.offerLoadingTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
            if (!finished) {
                NSError *error = [NSError errorWithDomain:ATSDKAdLoadingErrorMsg code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"No ad return after placement loading timeout"}];
                [waterfall enumerateTimeoutUnitGroupWithBlock:^(ATUnitGroupModel *unitGroup) {
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID], kAgentEventExtraInfoPriorityKey:@([finalWaterfall.unitGroups indexOfObject:unitGroup]), kAgentEventExtraInfoRequestFailReasonKey:@1, kAgentEventExtraInfoRequestFailErrorCodeKey:@(error.code), kAgentEventExtraInfoRequestFailErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@(unitGroup.headerBidding ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:[ATBidInfoManager priceForUnitGroup:unitGroup placementID:placementModel.placementID requestID:requestID], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                }];
                [headerBiddingWaterfall enumerateTimeoutUnitGroupWithBlock:^(ATUnitGroupModel *unitGroup) {
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID], kAgentEventExtraInfoPriorityKey:@([finalWaterfall.unitGroups indexOfObject:unitGroup]), kAgentEventExtraInfoRequestFailReasonKey:@1, kAgentEventExtraInfoRequestFailErrorCodeKey:@(error.code), kAgentEventExtraInfoRequestFailErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@(unitGroup.headerBidding ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:[ATBidInfoManager priceForUnitGroup:unitGroup placementID:placementModel.placementID requestID:requestID], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                }];
                
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey, nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
                LogATLoadderHeaderBiddingLog(@"Offer loading timeout handler trigured, will notify failure");
                [self notifyFailureWithPlacementModel:placementModel requestID:requestID extra:extra error:error delegate:delegate];
                [waterfallWrapper finish];
            }
        }];
    });
}

+(void) sendDAForBidResponseProcessingWithPlacementID:(NSString*)placementID unitGroup:(ATUnitGroupModel*)unitGroup requestID:(NSString*)requestID requestTime:(NSTimeInterval)requestTime loadingStatus:(NSInteger)loadingStatus bidPrice:(double)bidPrice markingPrice:(double)markingPrice processResult:(NSInteger)processResult {
    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyBidInfoProcessingKey placementID:placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID), kAgentEventExtraInfoAdSourceIDKey:unitGroup.unitID, kAgentEventExtraInfoBidInfoProcessingPriceKey:@(bidPrice), kAgentEventExtraInfoBidInfoBidRequestTimeKey:@((NSInteger)(requestTime * 1000.0f)), kAgentEventExtraInfoBidInfoLoadingStatusKey:@(loadingStatus), kAgentEventExtraInfoBidInfoMarkingPriceKey:@(markingPrice), kAgentEventExtraInfoBidInfoProcessResultKey:@(processResult)}];
}


//Thread safe is taken care of by the caller.
-(void) continueLoadingWaterfall:(ATWaterfall*)waterfall finalWaterfall:(ATWaterfall*)finalWaterfall placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID startDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    if (placementModel.maxConcurrentRequestCount == 1) {
        [self seriallyLoadOfferWithWaterfall:waterfall finalWaterfall:finalWaterfall requestID:requestID placementModel:placementModel startDate:loadStartDate extra:extra delegate:delegate];
    } else {
        [self concurrentlyLoadOfferWithWaterfall:waterfall finalWaterfall:finalWaterfall numberOfUnitGroups:1 requestID:requestID placementModel:placementModel startDate:loadStartDate extra:extra delegate:delegate];
    }
}

//Thread safe is taken care of by the caller.
-(void) continueLoadingHeaderBiddingWaterfall:(ATWaterfall*)headerBiddingWaterfall finalWaterfall:(ATWaterfall*)finalWaterfall placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID startDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    ATUnitGroupModel *loadingUG = [headerBiddingWaterfall unitGroupWithMaximumPrice];
    if (loadingUG != nil) {
        [headerBiddingWaterfall requestUnitGroup:loadingUG];
        LogATLoadderHeaderBiddingLog(@"HB load start");
        [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:loadingUG finalWaterfall:finalWaterfall startDate:loadStartDate extra:extra delegate:delegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary *> *assets) {
            [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                LogATLoadderHeaderBiddingLog(@"HB load success");
                waterfallWrapper.numberOfCachedOffers++;
                [[ATBidInfoManager sharedManager] saveRequestID:requestID forPlacementID:placementModel.placementID];
                if (!finished) {
                    LogATLoadderHeaderBiddingLog(@"Not finished, will notify success");
                    [self updateStatusAndNotifySuccessToDelegate:delegate placementModel:placementModel requestID:requestID loadStartDate:loadStartDate extra:extra];
                    [waterfallWrapper finish];
                    [waterfallWrapper fill];
                }
                [headerBiddingWaterfall finishUnitGroup:loadingUG withType:ATUnitGroupFinishTypeFinished];
                if ([headerBiddingWaterfall canContinueLoading:YES]) {
                    LogATLoadderHeaderBiddingLog(@"Can continue hb loading, will continue");
                    [self continueLoadingHeaderBiddingWaterfall:headerBiddingWaterfall finalWaterfall:finalWaterfall placementModel:placementModel requestID:requestID startDate:loadStartDate extra:extra delegate:delegate];
                }
            }];
        } failure:^(id<ATAdLoadingDelegate> delegate, NSError *error) {
            LogATLoadderHeaderBiddingLog([NSString stringWithFormat:@"HB load %@", error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? @"timeout" : @"failed"]);
            [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                [headerBiddingWaterfall finishUnitGroup:loadingUG withType:error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? ATUnitGroupFinishTypeTimeout : ATUnitGroupFinishTypeFailed];
                if ([headerBiddingWaterfall canContinueLoading:YES]) {
                    LogATLoadderHeaderBiddingLog(@"Can continue, will continue hb loading");
                    [self continueLoadingHeaderBiddingWaterfall:headerBiddingWaterfall finalWaterfall:finalWaterfall placementModel:placementModel requestID:requestID startDate:loadStartDate extra:extra delegate:delegate];
                } else {
                    LogATLoadderHeaderBiddingLog(@"Cannot continue, will check waterfall loading status");
                    if (!finished) {
                        if (!waterfall.isLoading && ![waterfall canContinueLoading:NO]) {
                            [self notifyFailureWithPlacementModel:placementModel requestID:requestID extra:extra error:error delegate:delegate];
                            [waterfallWrapper finish];
                        }
                    }
                }
            }];
        }];
    }
}

+(BOOL) shouldStartLoadForPlacementModel:(ATPlacementModel*)placementModel error:(NSError**)error {
    BOOL shouldLoad = NO;
    NSString *errorReasonDesc = @"";
    NSInteger errorCode = 0;
    if ([ATCapsManager validateCapsForPlacementModel:placementModel]) {
        if ([ATCapsManager validatePacingForPlacementModel:placementModel]) {
            shouldLoad = YES;
        } else {//Pacing within limit
            errorReasonDesc = @"Placement pacing within limit.";
            errorCode = 2;
        }
    } else {//Caps exceeded
        errorReasonDesc = @"Placement cap exeeds limit.";
        errorCode = 1;
    }
    if (!shouldLoad && error != nil) { *error = [NSError errorWithDomain:ATSDKAdLoadingErrorMsg code:errorCode userInfo:@{NSLocalizedDescriptionKey:@"Ad load for the placement should not be started", NSLocalizedFailureReasonErrorKey:errorReasonDesc}]; }
    return shouldLoad;
}

static NSString *const kATHeaderBiddingResponseListFailedListKey = @"header_bidding_failed_request";
-(void) startLoadingOffersWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    __weak typeof(delegate) weakDelegate = delegate;
    
    NSError *placementValidateError = nil;
    BOOL capsAndPacingValid = [ATAdLoader shouldStartLoadForPlacementModel:placementModel error:&placementValidateError];
    NSMutableDictionary *trackingExtraInfo = [NSMutableDictionary dictionaryWithObject:@(capsAndPacingValid ? 1 : 0) forKey:kATTrackerExtraSDKCalledFlagKey];
    if (!capsAndPacingValid) { trackingExtraInfo[kATTrackerExtraSDKNotCalledReasonKey] = @(placementValidateError.code); }
    
    if ([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]) { trackingExtraInfo[kATTrackerExtraAutoloadOnCloseFlagKey] = @YES; }
    [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:trackingExtraInfo];
    
    if (capsAndPacingValid) {
        //check unitgroup number
        if (([placementModel.unitGroups count] + [placementModel.S2SHeaderBiddingUnitGroups count] + [placementModel.adxUnitGroups count] + [placementModel.headerBiddingUnitGroups count])> 0) {
            NSMutableDictionary *startLoadNotiUserInfo = [NSMutableDictionary dictionaryWithObject:placementModel forKey:kATADLoadingNotificationUserInfoPlacementKey];
            if (extra != nil) { startLoadNotiUserInfo[kATADLoadingNotificationUserInfoExtraKey] = extra; }
            [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingStartLoadNotification object:nil userInfo:startLoadNotiUserInfo];
            
            void(^SendAgentEvent)(NSArray*infos) = ^(NSArray *infos) {
                if ([infos count] > 0) {
                    NSArray *inActiveInfos = [NSArray arrayWithArray:infos];
                    [inActiveInfos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:obj[kATTrackerExtraNetworkFirmIDKey] != nil ? obj[kATTrackerExtraNetworkFirmIDKey] : @(0), kAgentEventExtraInfoUnitGroupUnitIDKey:obj[kATTrackerExtraUnitIDKey] != nil ? obj[kATTrackerExtraUnitIDKey] : @"", kAgentEventExtraInfoPriorityKey:obj[kAgentEventExtraInfoPriorityKey] != nil ? obj[kAgentEventExtraInfoPriorityKey] : @0, kAgentEventExtraInfoRequestFailReasonKey:@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue]), kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@([obj[kAgentEventExtraInfoRequestHeaderBiddingFlagKey] boolValue] ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:@([obj[kAgentEventExtraInfoRequestPriceKey] doubleValue]), kAgentEventExtraInfoRequestFailReasonKey:@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue]), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}]; }];
                }
            };
            
            NSArray *inActiveInfos = nil;
            NSMutableArray<ATUnitGroupModel*>* activeUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.unitGroups inactiveUnitGroupInfos:&inActiveInfos requestID:requestID];
            
            //hb
            NSArray *hbInactiveInfos = nil;
            NSMutableArray<ATUnitGroupModel*>* activeHBUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.headerBiddingUnitGroups inactiveUnitGroupInfos:&hbInactiveInfos requestID:requestID];
            
            //c2s hb
            NSArray *s2sHBInactiveInfos = nil;
            NSMutableArray<ATUnitGroupModel*>* activeS2SHBUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.S2SHeaderBiddingUnitGroups inactiveUnitGroupInfos:&s2sHBInactiveInfos requestID:requestID];
            
            //Handle agent event
            NSMutableArray *mergeHBInactiveInfos = [NSMutableArray arrayWithArray:hbInactiveInfos];
            if ([s2sHBInactiveInfos count] > 0) { [mergeHBInactiveInfos addObjectsFromArray:s2sHBInactiveInfos]; }
            
            NSArray<ATUnitGroupModel*>* offerCachedHBUnitGroups = [ATAdLoader offerCachedActiveUnitGroupsInPlacementModel:placementModel hbUnitGroups:activeHBUnitGroups s2sHBUnitGroups:activeS2SHBUnitGroups];
            [activeHBUnitGroups removeObjectsInArray:offerCachedHBUnitGroups];//remove hblist
            [activeS2SHBUnitGroups removeObjectsInArray:offerCachedHBUnitGroups];//remove s2shblist
            [activeUnitGroups addObjectsFromArray:offerCachedHBUnitGroups];//add normal
            [[ATBidInfoManager sharedManager] renewBidInfoForPlacementID:placementModel.placementID fromRequestID:[[ATBidInfoManager sharedManager] requestForPlacementID:placementModel.placementID] toRequestID:requestID unitGroups:offerCachedHBUnitGroups];
            
            NSArray<ATUnitGroupModel*>* hbUGsWithHistoryBidInfo = [[ATBidInfoManager sharedManager] unitGroupWithHistoryBidInfoAvailableForPlacementID:placementModel.placementID unitGroups:activeHBUnitGroups s2sUnitGroups:activeS2SHBUnitGroups newRequestID:requestID];
            [activeHBUnitGroups removeObjectsInArray:hbUGsWithHistoryBidInfo];
            [activeS2SHBUnitGroups removeObjectsInArray:hbUGsWithHistoryBidInfo];
            [activeUnitGroups addObjectsFromArray:hbUGsWithHistoryBidInfo];
            
            //Handle agent event
            NSMutableArray *mutableInactiveInfos = [NSMutableArray arrayWithArray:inActiveInfos];
            if ([hbInactiveInfos count] > 0) { [mutableInactiveInfos addObjectsFromArray:hbInactiveInfos]; }
            if ([s2sHBInactiveInfos count] > 0) { [mutableInactiveInfos addObjectsFromArray:s2sHBInactiveInfos]; }
            SendAgentEvent(mutableInactiveInfos);
            
            if (([activeUnitGroups count] + [activeHBUnitGroups count] + [activeS2SHBUnitGroups count]) > 0) {
                [[ATCapsManager sharedManager] increaseCapWithPlacementID:placementModel.placementID duration:placementModel.loadCapDuration];
                
                NSArray<ATUnitGroupModel*>* rankedAndShuffledUnitGroups = [ATAdLoader rankAndShuffleUnitGroups:activeUnitGroups placementModel:placementModel requestID:requestID];
                
                //tk15
                if ([rankedAndShuffledUnitGroups count] > 0) {
                    [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeRankAndShuffle extra:@{kATTrackerExtraHeaderBiddingInfoKey:[ATAdLoader rankAndShuffleTKExtraWithPlacementID:placementModel.placementID rankAndShullfedUnitGroups:rankedAndShuffledUnitGroups offerCachedUnitGroups:offerCachedHBUnitGroups unitGroupsWithHistoryBidInfo:hbUGsWithHistoryBidInfo bidRequestDate:[NSDate date] requestID:requestID], kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])}];
                }
                
                ATWaterfall *waterfall = [[ATWaterfall alloc] initWithUnitGroups:rankedAndShuffledUnitGroups placementID:placementModel.placementID requestID:requestID];
                [[ATWaterfallManager sharedManager] attachWaterfall:waterfall completion:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                    waterfallWrapper.headerBiddingFired = [activeHBUnitGroups count] > 0;
                    //Configure default adsource load
                    if ([waterfall canContinueLoading:YES]) {
                        LogATLoadderHeaderBiddingLog(@"Configure default load & start loading");
                        [self configureDefaultAdSourceLoadIfNeededWithPlacementModel:placementModel requestID:requestID extra:extra delegate:delegate];
                        
                        if (placementModel.maxConcurrentRequestCount == 1) {
                            [self seriallyLoadOfferWithWaterfall:waterfall finalWaterfall:finalWaterfall requestID:requestID placementModel:placementModel startDate:loadStartDate extra:extra delegate:delegate];
                        } else {
                            [self concurrentlyLoadOfferWithWaterfall:waterfall finalWaterfall:finalWaterfall numberOfUnitGroups:MIN(placementModel.maxConcurrentRequestCount, [waterfall.unitGroups count]) requestID:requestID placementModel:placementModel startDate:loadStartDate extra:extra delegate:delegate];
                        }
                    }
                    
                    LogATLoadderHeaderBiddingLog(@"Configure offer loading timeout");
                    //Configure placement timeout
                    [self configureOfferLoadingTimeoutWithPlacementModel:placementModel requestID:requestID extra:extra delegate:delegate];
                }];
                
//                if ([activeS2SHBUnitGroups count] > 0) { [self startLoadingS2SHeaderBiddingWithRequestID:requestID headerBiddingUnitGroups:activeS2SHBUnitGroups offerCachedHBUnitGroups:offerCachedHBUnitGroups unitGroupsWithHistoryBidInfo:hbUGsWithHistoryBidInfo inactiveUGInfo:inActiveInfos inactiveHBUGInfo:mergeHBInactiveInfos placementModel:placementModel extra:extra delegate:delegate]; }
                
                if (([activeHBUnitGroups count] + [activeS2SHBUnitGroups count]) > 0) { [[[ATHeaderBiddingManager alloc] init] startLoadingHeaderBiddingWithRequestID:requestID headerBiddingUnitGroups:activeHBUnitGroups s2sHBUnitGroups:activeS2SHBUnitGroups offerCachedHBUnitGroups:offerCachedHBUnitGroups unitGroupsWithHistoryBidInfo:hbUGsWithHistoryBidInfo inactiveUGInfo:inActiveInfos inactiveHBUGInfo:mergeHBInactiveInfos placementModel:placementModel extra:extra delegate:delegate]; }
            } else {//No active unit groups
                if (([hbInactiveInfos count] + [s2sHBInactiveInfos count]) > 0) {
                    NSMutableArray *inactiveInfos = [NSMutableArray arrayWithArray:inActiveInfos];
                    [inactiveInfos addObjectsFromArray:hbInactiveInfos];
                    [inactiveInfos addObjectsFromArray:s2sHBInactiveInfos];
                    SendAgentEvent(inactiveInfos);
                } else {
                    SendAgentEvent(inActiveInfos);
                }
                
                [self updateLoadFailureDateForPlacementID:placementModel.placementID];
                
                NSError *error = [NSError errorWithDomain:@"com.anythink.ATAdLoading" code:ATADLoadingErrorCodeUnitGroupsFilteredOut userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Ad sources are filtered, no ad source is currently available."}];
                [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0, kATTrackerExtraSDKNotCalledReasonKey:@6}];
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code)}];
                if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; }); }
            }
        } else {//No adsource(ug_list or hb_list) configured in the placement
            [self updateLoadFailureDateForPlacementID:placementModel.placementID];
            
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeNoUnitGroupsFoundInPlacement userInfo:@{NSLocalizedDescriptionKey:@"AD offer loading has failed.",NSLocalizedFailureReasonErrorKey:@"The placement strategy does not contain any ad sources, please check the mediation configuration in TopOn."}];
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey,  nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
            if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; }); }
        }
    } else {//Placement cap&pacing validation vailed
        [self updateLoadFailureDateForPlacementID:placementModel.placementID];
        
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AD offer loading has failed.",NSLocalizedFailureReasonErrorKey:placementValidateError.userInfo[NSLocalizedFailureReasonErrorKey] != nil ? placementValidateError.userInfo[NSLocalizedFailureReasonErrorKey] : @"Placement cap/pacing validation failed"}];
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kGeneralAdAgentEventExtraInfoLoadErrorCodeKey:@(error.code), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey,  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
        
        if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; }); }
    }
}

//Thread safe is taken care of by the caller.
-(void) seriallyLoadOfferWithWaterfall:(ATWaterfall*)loadingWaterfall finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel startDate:loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    ATUnitGroupModel *loadingUG = [loadingWaterfall unitGroupWithMaximumPrice];
    if (loadingUG != nil) {
        [loadingWaterfall requestUnitGroup:loadingUG];
        __weak typeof(delegate) weakDelegate = delegate;
        id<ATAdManagement> adManager = [placementModel.adManagerClass sharedManager];
        NSArray<NSDictionary*>* adSourceStatusInpectionExtraInfo = nil;
        if ([adManager respondsToSelector:@selector(inspectAdSourceStatusWithPlacementModel:unitGroup:finalWaterfall:requestID:extraInfo:)] && [adManager inspectAdSourceStatusWithPlacementModel:placementModel unitGroup:loadingUG finalWaterfall:finalWaterfall requestID:requestID extraInfo:&adSourceStatusInpectionExtraInfo]) {
            //Send da
            [adSourceStatusInpectionExtraInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAdSourceStatusFillKey placementID:placementModel.placementID unitGroupModel:nil extraInfo:obj]; }];
            
            [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:extra]; });
                waterfallWrapper.numberOfCachedOffers += [adSourceStatusInpectionExtraInfo count];
                if (!finished) {
                    [waterfallWrapper finish];
                    [waterfallWrapper fill];
                    [self updateStatusAndNotifySuccessToDelegate:delegate placementModel:placementModel requestID:requestID loadStartDate:loadStartDate extra:@{kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey:@YES}];
                }
                [loadingWaterfall finishUnitGroup:loadingUG withType:ATUnitGroupFinishTypeFinished];
            }];
        } else {
            [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:loadingUG finalWaterfall:finalWaterfall startDate:loadStartDate extra:extra delegate:weakDelegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary*> *assets) {
                LogATLoadderHeaderBiddingLog(@"Serially load success");
                [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:extra]; });
                    
                    [loadingWaterfall finishUnitGroup:loadingUG withType:ATUnitGroupFinishTypeFinished];
                    if (!finished) {
                        LogATLoadderHeaderBiddingLog(@"Not finished, will finish&notify success");
                        [waterfallWrapper finish];
                        [waterfallWrapper fill];
                        [self updateStatusAndNotifySuccessToDelegate:delegate placementModel:placementModel requestID:requestID loadStartDate:loadStartDate extra:nil];
                    }
                }];
            } failure:^(id<ATAdLoadingDelegate> delegate, NSError *error) {
                LogATLoadderHeaderBiddingLog([NSString stringWithFormat:@"Serially load %@", error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? @"timeout" : @"failed"]);
                [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                    [loadingWaterfall finishUnitGroup:loadingUG withType:error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? ATUnitGroupFinishTypeTimeout : ATUnitGroupFinishTypeFailed];
                    if (!finished) {
                        LogATLoadderHeaderBiddingLog(@"Not finished, will check can continue");
                        if ([waterfall canContinueLoading:NO]) {
                            LogATLoadderHeaderBiddingLog(@"Will continue");
                            [self seriallyLoadOfferWithWaterfall:waterfall finalWaterfall:finalWaterfall requestID:requestID placementModel:placementModel startDate:loadStartDate extra:extra delegate:delegate];
                        } else {
                            LogATLoadderHeaderBiddingLog(@"Can't continue");
                            if (!finished) {
                                LogATLoadderHeaderBiddingLog(@"Not finish, will checkout start date");
                                if (!waterfallWrapper.headerBiddingFired || waterfallWrapper.headerBiddingFailed || [[NSDate date] timeIntervalSinceDate:loadStartDate] > placementModel.headerBiddingRequestTimeout) {
                                    LogATLoadderHeaderBiddingLog(@"Takes more than headerBiddingRequestTimeout, will check number of timeout requests");
                                    if (waterfall.numberOfTimeoutRequests == 0) {
                                        LogATLoadderHeaderBiddingLog(@"No timeouts, will check headerBiddingWaterfall status");
                                        if (headerBiddingWaterfall)
                                        [waterfallWrapper finish];
                                        [self notifyFailureWithPlacementModel:placementModel requestID:requestID extra:extra error:error delegate:delegate];
                                    }
                                }//headerBiddingRequestTimeout
                            }
                        }//End of [waterfall canContinueLoading]
                    }
                }];
            }];
        }//end of else of no
    }
}

-(void) concurrentlyLoadOfferWithWaterfall:(ATWaterfall*)loadingWaterfall finalWaterfall:(ATWaterfall*)finalWaterfall numberOfUnitGroups:(NSInteger)numberOfUnitGroups requestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel startDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    id<ATAdManagement> adManager = [placementModel.adManagerClass sharedManager];
    NSArray<NSDictionary*>* adSourceStatusInpectionExtraInfo = nil;//to do
    NSMutableArray<NSString*>* unitIDRecords = [NSMutableArray<NSString*> array];
    for (NSInteger i = 0; i < numberOfUnitGroups; i++) {
        ATUnitGroupModel *loadingUG = [loadingWaterfall unitGroupWithMaximumPrice];
        if (loadingUG != nil) {
            LogATLoadderHeaderBiddingLog([NSString stringWithFormat:@"Concurrently load adsource %ld", i]);
            if ([unitIDRecords count] == 0 && [adManager respondsToSelector:@selector(inspectAdSourceStatusWithPlacementModel:unitGroup:finalWaterfall:requestID:extraInfo:)] && [adManager inspectAdSourceStatusWithPlacementModel:placementModel unitGroup:loadingUG finalWaterfall:finalWaterfall requestID:requestID extraInfo:&adSourceStatusInpectionExtraInfo]) {
                //Send da
                [adSourceStatusInpectionExtraInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAdSourceStatusFillKey placementID:placementModel.placementID unitGroupModel:nil extraInfo:obj];
                    if (obj[kAgentEventExtraInfoAdSourceIDKey] != nil) {
                        [unitIDRecords addObject:obj[kAgentEventExtraInfoAdSourceIDKey]];
                        [loadingWaterfall requestUnitGroup:[loadingWaterfall unitGroupWithUnitID:obj[kAgentEventExtraInfoAdSourceIDKey]]];
                    }
                }];
                
                [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:extra]; });
                    waterfallWrapper.numberOfCachedOffers += [adSourceStatusInpectionExtraInfo count];
                    if (!finished) {
                        [waterfallWrapper finish];
                        [waterfallWrapper fill];
                        [self updateStatusAndNotifySuccessToDelegate:delegate placementModel:placementModel requestID:requestID loadStartDate:loadStartDate extra:@{kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey:@YES}];
                    }
                    [adSourceStatusInpectionExtraInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [loadingWaterfall finishUnitGroup:[loadingWaterfall unitGroupWithUnitID:obj[kAgentEventExtraInfoAdSourceIDKey]] withType:ATUnitGroupFinishTypeFinished]; }];
                }];
            } else {
                if (![unitIDRecords containsObject:loadingUG.unitID]) {
                    [loadingWaterfall requestUnitGroup:loadingUG];
                    [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:loadingUG finalWaterfall:finalWaterfall startDate:loadStartDate extra:extra delegate:delegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary*> *assets) {
                        [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:extra]; });
                            LogATLoadderHeaderBiddingLog([NSString stringWithFormat:@"Concurrently load adsource %ld successfully", i]);
                            waterfallWrapper.numberOfCachedOffers++;
                            if (!finished) {
                                LogATLoadderHeaderBiddingLog(@"Not finished yet, will finish & notify success");
                                [waterfallWrapper finish];
                                [waterfallWrapper fill];
                                [self updateStatusAndNotifySuccessToDelegate:delegate placementModel:placementModel requestID:requestID loadStartDate:loadStartDate extra:nil];
                            }
                            [loadingWaterfall finishUnitGroup:loadingUG withType:ATUnitGroupFinishTypeFinished];
                        }];
                    } failure:^(id<ATAdLoadingDelegate> delegate, NSError *error) {
                        [[ATWaterfallManager sharedManager] accessWaterfallForPlacementID:placementModel.placementID requestID:requestID withBlock:^(ATWaterfallWrapper *waterfallWrapper, ATWaterfall *waterfall, ATWaterfall *headerBiddingWaterfall, ATWaterfall *finalWaterfall, BOOL finished, NSDate *loadStartDate) {
                            [loadingWaterfall finishUnitGroup:loadingUG withType:error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? ATUnitGroupFinishTypeTimeout : ATUnitGroupFinishTypeFailed];
                            LogATLoadderHeaderBiddingLog([NSString stringWithFormat:@"Concurrently load %ld %@", i, error.code == ATADLoadingErrorCodeADOfferLoadingTimeout ? @"timeout" : @"failed"]);
                            LogATLoadderHeaderBiddingLog([NSString stringWithFormat:@"Cached offers:%ld, expected number:%ld", waterfallWrapper.numberOfCachedOffers, placementModel.expectedNumberOfOffers]);
                            if (waterfallWrapper.numberOfCachedOffers < placementModel.expectedNumberOfOffers) {
                                LogATLoadderHeaderBiddingLog(@"Not finished, check can continue");
                                if ([waterfall canContinueLoading:NO]) {
                                    LogATLoadderHeaderBiddingLog(@"Can load next");
                                    NSMutableDictionary *loadingExtra = [NSMutableDictionary dictionary];
                                    if (extra != nil) { [loadingExtra addEntriesFromDictionary:extra]; }
                                    if (waterfallWrapper.filled) { loadingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
                                    [self concurrentlyLoadOfferWithWaterfall:waterfall finalWaterfall:finalWaterfall numberOfUnitGroups:1 requestID:requestID placementModel:placementModel startDate:loadStartDate extra:loadingExtra delegate:delegate];
                                } else {
                                    LogATLoadderHeaderBiddingLog(@"Can't load next");
                                    if (!finished) {
                                        LogATLoadderHeaderBiddingLog(@"Not finished");
                                        if (!waterfallWrapper.headerBiddingFired || waterfallWrapper.headerBiddingFailed || [[NSDate date] timeIntervalSinceDate:loadStartDate] > placementModel.headerBiddingRequestTimeout) {
                                            LogATLoadderHeaderBiddingLog(@"HB timeout");
                                            if (waterfall.numberOfTimeoutRequests == 0) {
                                                LogATLoadderHeaderBiddingLog(@"No timeout adsouce");
                                                [waterfallWrapper finish];
                                                [self notifyFailureWithPlacementModel:placementModel requestID:requestID extra:extra error:error delegate:delegate];
                                            }
                                        }//headerBiddingRequestTimeout
                                    }
                                }//End of [waterfall canContinueLoading]
                            }
                        }];
                    }];
                }
            }
        }//End of loadingUG nil comp
    }
}

static NSString *const kAutoloadExtraInfoKey = @"extra_info";
-(void) loadOfferWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroup finalWaterfall:(ATWaterfall*)finalWaterfall startDate:(NSDate*)loadStartDate extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate success:(void(^)(id<ATAdLoadingDelegate>delegate, NSArray<NSDictionary*> *assets))successHandler failure:(void(^)(id<ATAdLoadingDelegate>, NSError*))failureHandler {
    __weak typeof(delegate) weakDelegate = delegate;
    if (unitGroup.adapterClass != nil) {
        NSMutableDictionary *adapterInfo = [NSMutableDictionary dictionaryWithDictionary:unitGroup.content];
        adapterInfo[kADapterCustomInfoStatisticsInfoKey] = [ATAdLoader statisticsInfoWithPlacementModel:placementModel unitGroupModel:unitGroup finalWaterfall:finalWaterfall requestID:requestID bidRequest:NO];
        adapterInfo[@"request_num"] = @(unitGroup.networkRequestNum);
        adapterInfo[kAdapterCustomInfoRequestIDKey] = requestID;
        adapterInfo[kAdapterCustomInfoPlacementModelKey] = placementModel;
        adapterInfo[kAdapterCustomInfoUnitGroupModelKey] = unitGroup;
//        if ([extra isKindOfClass:[NSDictionary class]]) { adapterInfo[kAdapterCustomInfoExtraKey] = extra; }
        //init network sdk with custom info& local info
        __block id<ATNativeAdapter> adapter = [[unitGroup.adapterClass alloc] initWithNetworkCustomInfo:adapterInfo localInfo:extra];
        ((NSObject*)adapter).delegateToBePassed = weakDelegate;
        dispatch_queue_t loading_completion_queue = dispatch_queue_create("completionQueue.com.anythink", DISPATCH_QUEUE_SERIAL);
        __block BOOL requestFinished = NO;//Failed or Succeeded, the request is regarded as having finished.
        __block BOOL requestTimeout = NO;
        
        id<ATAd> phAd = [ATPlacementholderAd placeholderAdWithPlacementModel:placementModel requestID:requestID unitGroup:unitGroup finalWaterfall:finalWaterfall];
        [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:ATGeneralAdAgentEventTypeRequest extra:extra error:nil]] type:ATLogTypeTemporary];
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraHeaderBiddingInfoKey:[ATTracker headerBiddingTrackingExtraWithAd:phAd requestID:requestID], kATTrackerExtraUnitIDKey:unitGroup.unitID, kATTrackerExtraNetworkFirmIDKey:@(unitGroup.networkFirmID), kATTrackerExtraRefreshFlagKey:@([extra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey:@([extra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey:@([extra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraRequestExpectedOfferNumberFlagKey:@([extra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] boolValue])}];
        [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeADRequest extra:trackingExtra];
        NSDate *requestStartDate = [NSDate date];
        __block NSTimeInterval dataDidLoadedTime;
        __block BOOL ismetaDataDidLoaded = NO;
        @try {
            if (unitGroup.networkDataTimeout != -1 && [adapter respondsToSelector:@selector(setMetaDataDidLoadedBlock:)]) {
                adapter.metaDataDidLoadedBlock = ^(){
                    ismetaDataDidLoaded = YES;
                    dataDidLoadedTime = [[NSDate date] timeIntervalSinceDate:requestStartDate];
                };
            }
        } @catch (NSException *exception) {} @finally {}
        //Kick off the request
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [adapter loadADWithInfo:adapterInfo localInfo:extra completion:^(NSArray<NSDictionary*> *assets, NSError *error) {
                [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:error != nil ? ATGeneralAdAgentEventTypeRequestFailure : ATGeneralAdAgentEventTypeRequestSuccess extra:extra error:error]] type:ATLogTypeTemporary];
                if ([assets count] > 0 && error == nil) {
                    if (unitGroup.networkDataTimeout != -1 && ismetaDataDidLoaded) {
                        NSArray<ATUnitGroupModel*>* activeUnitGroups = finalWaterfall.unitGroups;
                        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyMetadataAndAdDataLoadingTimeKey placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{
                                                               kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID),
                                                               kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID],
                                                               kAgentEventExtraInfoPriorityKey:@([activeUnitGroups indexOfObject:unitGroup]),
                                                               kAgentEventExtraInfoMetadataLoadingTimeKey:@([@(dataDidLoadedTime * 1000) integerValue]),
                                                               kAgentEventExtraInfoAdDataLoadingTimeKey:@([@([[NSDate date] timeIntervalSinceDate:requestStartDate] * 1000.0f) integerValue])
                                                           }];
                    }
                }
                dispatch_async(loading_completion_queue, ^{
                    requestFinished = YES;
                    
                    trackingExtra[kATTrackerExtraFilledWithinNetworkTimeoutFlagKey] = @(requestTimeout ? 1 : 0);
                    NSArray<ATUnitGroupModel*>* activeUnitGroups = finalWaterfall.unitGroups;
                    activeUnitGroups = [activeUnitGroups count] > 0 ? activeUnitGroups : placementModel.unitGroups;
                    NSInteger unitGroupPri = [activeUnitGroups indexOfObject:unitGroup];
                    if (error == nil) {
                        NSInteger shownPri = [[[placementModel adManagerClass] sharedManager] highestPriorityOfShownAdInPlacementID:placementModel.placementID requestID:requestID];
                        trackingExtra[kATTrackerExtraFillTimeKey] = @([@([[NSDate date] timeIntervalSinceDate:requestStartDate] * 1000.0f) integerValue]);
                        trackingExtra[kATTrackerExtraFillRequestFlagKey] = @(shownPri == NSNotFound ? 0 : shownPri < unitGroupPri ? 1 : 2);
                        
                        if (assets[0][kAdAssetsCustomObjectKey] != nil) { trackingExtra[kATTrackerExtraCustomObjectKey] = assets[0][kAdAssetsCustomObjectKey]; }
                        [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeADRecalledSuccessfully extra:trackingExtra];
                        [weakSelf handleAssets:assets placementModel:placementModel unitGroupModel:unitGroup finalWaterfall:finalWaterfall requestID:requestID extra:extra];
                        if (successHandler != nil) successHandler(weakDelegate, assets);
                        adapter = nil;
                    } else {
                        [self updateRequestFailureForPlacemetModel:placementModel unitGroupModel:unitGroup];
                        
                        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID], kAgentEventExtraInfoPriorityKey:@(unitGroupPri), kAgentEventExtraInfoRequestFailReasonKey:@0, kAgentEventExtraInfoRequestFailErrorCodeKey:@(error.code), kAgentEventExtraInfoRequestFailErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@(unitGroup.headerBidding ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:[ATBidInfoManager priceForUnitGroup:unitGroup placementID:placementModel.placementID requestID:requestID],kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0), kAgentEventExtraInfoRequestFailTimeKey:@([@([[NSDate date] timeIntervalSinceDate:requestStartDate] * 1000.0f) integerValue]) }];
                        
                        if (failureHandler != nil) failureHandler(weakDelegate, error);
                        adapter = nil;
                    }
                });//End dispatch_async
            }];
        });

        @try {
            //dataload timeout handler
            if (unitGroup.networkDataTimeout != -1 && [adapter respondsToSelector:@selector(setMetaDataDidLoadedBlock:)]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(unitGroup.networkDataTimeout / 1000.0f * NSEC_PER_SEC)), loading_completion_queue, ^{
                    if (!ismetaDataDidLoaded) {
                        requestTimeout = YES;
                        if (placementModel.format != 4) {
                            if (!requestFinished) {
                                NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT SDK has failed to load ad.", NSLocalizedFailureReasonErrorKey:@"Third party SDK load data timeouts."}];
                                [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:ATGeneralAdAgentEventTypeRequestFailure extra:extra error:error]] type:ATLogTypeTemporary];
                            }
                            if (!requestFinished && failureHandler != nil) {
                                failureHandler(weakDelegate, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingTimeout userInfo:@{NSLocalizedDescriptionKey:@"The offer data loading timeouts.",NSLocalizedFailureReasonErrorKey:@"Certain error might have occured during the offer loading process."}]);
                            }
                        }
                    }
                });
            }
        } @catch (NSException *exception) {} @finally {}
        //Configure timeout handler
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(unitGroup.networkTimeout * NSEC_PER_SEC)), loading_completion_queue, ^{
            requestTimeout = YES;
            if (placementModel.format != 4) {
                if (!requestFinished) {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:ATSDKAdLoadFailedErrorMsg, NSLocalizedFailureReasonErrorKey:@"Third party SDK load timeouts."}];
                    [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:ATGeneralAdAgentEventTypeRequestFailure extra:extra error:error]] type:ATLogTypeTemporary];
                }
                if (!requestFinished && failureHandler != nil) {
                    failureHandler(weakDelegate, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingTimeout userInfo:@{NSLocalizedDescriptionKey:@"The offer loading timeouts.",NSLocalizedFailureReasonErrorKey:@"Certain error might have occured during the offer loading process."}]);
                }
            }
        });
    } else {
        failureHandler(weakDelegate, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeAdapterClassNotFound userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Adapter(%@) initialization failed", unitGroup.adapterClassString],NSLocalizedFailureReasonErrorKey:@"The adapter not found"}]);
    }
}

-(void) handleAssets:(NSArray<NSDictionary*>*)assets placementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID extra:(NSDictionary*)extra {
    [[ATLoadingScheduler sharedScheduler] scheduleLoadingWithPlacementModel:placementModel unitGroup:unitGroupModel requestID:requestID extra:extra];
    [assets enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithDictionary:obj];
        if ([extra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] boolValue]) { asset[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        [[placementModel.adManagerClass sharedManager] addAdWithADAssets:asset withPlacementSetting:placementModel unitGroup:unitGroupModel finalWaterfall:finalWaterfall requestID:requestID];
    }];
}

+(NSDictionary*)statisticsInfoWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel finalWaterfall:(ATWaterfall*)finalWaterfall requestID:(NSString*)requestID bidRequest:(BOOL)bidRequest {
    return @{@"ads":@([[ATCapsManager sharedManager] capByDayWithAdFormat:placementModel.format]),
             @"ahs":@([[ATCapsManager sharedManager] capByHourWithAdFormat:placementModel.format]),
             @"pds":@([[ATCapsManager sharedManager] capByDayWithPlacementID:placementModel.placementID]),
             @"phs":@([[ATCapsManager sharedManager] capByHourWithPlacementID:placementModel.placementID]),
             @"tpl":placementModel.placementID != nil ? placementModel.placementID : @"",
             @"ap":@(bidRequest ? 0 : [finalWaterfall.unitGroups indexOfObject:unitGroupModel] + 1),
             @"rid":requestID != nil ? requestID : @"",
             @"sr":@"tp"
    };
}

static NSString *kHeaderBiddingResponseListSortPriorityKey = @"sortpriority";
static NSString *kHeaderBiddingResponseListSortTypeKey = @"sorttype";
static NSString *kHeaderBiddingResponseListAdSourceIDKey = @"unit_id";
static NSString *kHeaderBiddingResponseListBidResultKey = @"bidresult";
static NSString *kHeaderBiddingResponseListBidPriceKey = @"bidprice";
static NSString *kHeaderBiddingResponseListErrorCodeKey = @"errorcode";
static NSString *kHeaderBiddingResponseListErrorMessageKey = @"errormsg";
+(NSDictionary*) bidSortTKExtraWithPlacementID:(NSString*)placementID requestID:(NSString*)requestID bidStartDate:(NSDate*)bidStartDate inactiveHBUnitGroupInfo:(NSArray<NSDictionary*>*)inactiveHBUGInfo inactiveUGInfo:(NSArray<NSDictionary*>*)inactiveUGInfo failedHBUGInfo:(NSDictionary<NSString*, NSError*>*)failedHBUGInfo sortedUGs:(NSArray<ATUnitGroupModel*>*)sortedUGs offerCachedUnitGroups:(NSArray<ATUnitGroupModel*>*)offerCachedUGs unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsWithHistoryBidInfo {
    NSMutableArray<NSDictionary*>* list = [NSMutableArray<NSDictionary*> array];
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@((NSInteger)([bidStartDate timeIntervalSince1970] * 1000.0f)), @"bidrequesttime", @((NSInteger)([[NSDate date] timeIntervalSince1970] * 1000.0f)), @"bidresponsetime", list, @"bidresponselist", nil];
    //inactive ugs
    [inactiveUGInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                          kHeaderBiddingResponseListSortTypeKey:@-1,
                          kHeaderBiddingResponseListAdSourceIDKey:obj[kATTrackerExtraUnitIDKey] != nil ? obj[kATTrackerExtraUnitIDKey] : @"",
                          kHeaderBiddingResponseListBidResultKey:@0,
                          kHeaderBiddingResponseListBidPriceKey:@0,
                          kHeaderBiddingResponseListErrorCodeKey:obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] != nil ? obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] : @0,
                          kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@ within limit", @{@0:@"Cap/pacing", @2:@"Cap", @3:@"Pacing"}[@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue])]]
        }];
    }];
    
    //inactive hb_ugs
    [inactiveHBUGInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                          kHeaderBiddingResponseListSortTypeKey:@-1,
                          kHeaderBiddingResponseListAdSourceIDKey:obj[kATTrackerExtraUnitIDKey] != nil ? obj[kATTrackerExtraUnitIDKey] : @"",
                          kHeaderBiddingResponseListBidResultKey:@0,
                          kHeaderBiddingResponseListBidPriceKey:obj[kAgentEventExtraInfoRequestPriceKey] != nil ? obj[kAgentEventExtraInfoRequestPriceKey] : @0,
                          kHeaderBiddingResponseListErrorCodeKey:obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] != nil ? obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] : @0,
                          kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@", @{@0:@"Cap/pacing within limit", @2:@"Cap within limit", @3:@"Pacing within limit", @4:@"Bid time interval within limit", @6:@"HB not supported for this network"}[@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue])]]
        }];
    }];
    
    //failed hb request
    [failedHBUGInfo enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSError * _Nonnull obj, BOOL * _Nonnull stop) {
        [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                          kHeaderBiddingResponseListSortTypeKey:@-1,
                          kHeaderBiddingResponseListAdSourceIDKey:key,
                          kHeaderBiddingResponseListBidResultKey:@0,
                          kHeaderBiddingResponseListBidPriceKey:@0,
                          kHeaderBiddingResponseListErrorCodeKey:@(obj.code),
                          kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@", obj]
        }];
    }];
    
    //sorted ugs
    [sortedUGs enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@(idx),
                          kHeaderBiddingResponseListSortTypeKey:@(obj.headerBidding ? ([offerCachedUGs containsObject:obj] ? 3 : ([unitGroupsWithHistoryBidInfo containsObject:obj] ? 2 : 0)) : 1),
                          kHeaderBiddingResponseListAdSourceIDKey:obj.unitID != nil ? obj.unitID : @"",
                          kHeaderBiddingResponseListBidResultKey:@(obj.headerBidding ? 1 : 0),
                          kHeaderBiddingResponseListBidPriceKey:[ATBidInfoManager priceForUnitGroup:obj placementID:placementID requestID:requestID]
        }];
    }];
    
    return extraInfo;
}

+(NSDictionary*) rankAndShuffleTKExtraWithPlacementID:(NSString*)placementID rankAndShullfedUnitGroups:(NSArray<ATUnitGroupModel*>*)rankAndShullfedUnitGroups offerCachedUnitGroups:(NSArray<ATUnitGroupModel*>*)offerCachedUnitGroups unitGroupsWithHistoryBidInfo:(NSArray<ATUnitGroupModel*>*) unitGroupsWithHistoryBidInfo bidRequestDate:(NSDate*)bidRequestDate requestID:(NSString*)requestID {
    NSMutableArray<NSDictionary*>* list = [NSMutableArray<NSDictionary*> array];
    NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([bidRequestDate timeIntervalSince1970] * 1000.0f), @"bidrequesttime", @([[NSDate date] timeIntervalSince1970] * 1000.0f), @"bidresponsetime", list, @"bidresponselist", nil];
    
    //rankAndShullfedUnitGroups
    [rankAndShullfedUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@(idx),
                          kHeaderBiddingResponseListSortTypeKey:@(obj.headerBidding ? ([offerCachedUnitGroups containsObject:obj] ? 3 : ([unitGroupsWithHistoryBidInfo containsObject:obj] ? 2 : 0)) : 1),
                          kHeaderBiddingResponseListAdSourceIDKey:obj.unitID != nil ? obj.unitID : @"",
                          kHeaderBiddingResponseListBidResultKey:@(obj.headerBidding ? 1 : 0),
                          kHeaderBiddingResponseListBidPriceKey:[ATBidInfoManager priceForUnitGroup:obj placementID:placementID requestID:requestID]
        }];
    }];

    return extraInfo;
}

+(NSMutableArray<ATUnitGroupModel*>*) offerCachedActiveUnitGroupsInPlacementModel:(ATPlacementModel*)placementModel hbUnitGroups:(NSArray<ATUnitGroupModel*>*)hbUnitGroups s2sHBUnitGroups:(NSArray<ATUnitGroupModel*>*)s2sHBUnitGroups{
    NSMutableArray<ATUnitGroupModel*>* unitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    [hbUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if ([[placementModel.adManagerClass sharedManager] adSourceStatusInPlacementModel:placementModel unitGroup:obj]) { [unitGroups addObject:obj]; } }];
    [s2sHBUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { if ([[placementModel.adManagerClass sharedManager] adSourceStatusInPlacementModel:placementModel unitGroup:obj]) { [unitGroups addObject:obj]; } }];
    return unitGroups;
}

/**
   filter unitgroup with invalide cap&pacing and failed in skipIntervalAfterLastBiddingFailure time
 */
+(NSMutableArray<ATUnitGroupModel*>*)activeUnitGroupsInPlacementModel:(ATPlacementModel*)placementModel unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups inactiveUnitGroupInfos:(NSArray<NSDictionary*>* __autoreleasing*)inactiveActiveUnitGroupInfos requestID:(NSString*)requestID {
    NSMutableArray<ATUnitGroupModel*> *activeUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    NSMutableArray<NSDictionary*>* reasons = [NSMutableArray<NSDictionary*> array];
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *reason = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:placementModel unitGroupModel:obj requestID:requestID]];
        reason[kAgentEventExtraInfoRequestHeaderBiddingFlagKey] = @(obj.headerBidding ? 1 : 0);
        reason[kAgentEventExtraInfoRequestPriceKey] = [ATBidInfoManager priceForUnitGroup:obj placementID:placementModel.placementID requestID:requestID];
        reason[kAgentEventExtraInfoPriorityKey] = @(idx);
        reason[kInactiveUnitGroupInfoUnitGroupKey] = obj;
        reason[kATTrackerExtraUnitIDKey] = obj.unitID != nil ? obj.unitID : @"";
        reason[kATTrackerExtraNetworkFirmIDKey] = @(obj.networkFirmID);
        if ([ATAdStorageUtility validateCapsForUnitGroup:obj placementID:placementModel.placementID]) {
            if ([ATAdStorageUtility validatePacingForUnitGroup:obj placementID:placementModel.placementID]) {
                if (obj.headerBidding ? [[ATAdLoader sharedLoader] shouldSendS2SBidRequestAfterLastFailureForPlacementModel:placementModel unitGroupModel:obj] : [[ATAdLoader sharedLoader] shouldSendRequestAfterLastFailureForPlacementModel:placementModel unitGroupModel:obj]) {
                    [activeUnitGroups addObject:obj];
                } else {
                    reason[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] = @4;//loading/bidding failure interval
                }
            } else {
                reason[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] = @3;//pacing
            }
        } else {
            reason[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] = @2;//cap
        }
        if (reason[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] != nil) { [reasons addObject:reason]; }
    }];
    if (inactiveActiveUnitGroupInfos != nil) { *inactiveActiveUnitGroupInfos = reasons; }
    return activeUnitGroups;
}

+(NSArray<ATUnitGroupModel*>*)rankAndShuffleUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID {
    NSMutableArray<ATUnitGroupModel*> *rankedAndShuffledUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    if ([unitGroups count] > 0) {
        NSMutableArray<ATUnitGroupModel*>* sortedUnitGroups = [NSMutableArray<ATUnitGroupModel*> arrayWithArray:unitGroups];
        [sortedUnitGroups sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            NSString *obj2_price = [ATBidInfoManager priceForUnitGroup:obj2 placementID:placementModel.placementID requestID:requestID];
            NSString *obj1_price = [ATBidInfoManager priceForUnitGroup:obj1 placementID:placementModel.placementID requestID:requestID];
            
            return [obj2_price compare:obj1_price options:NSNumericSearch];
            
        }];
        
        NSMutableArray<ATUnitGroupModel*> *curRank = [NSMutableArray<ATUnitGroupModel*> arrayWithObject:sortedUnitGroups[0]];
        [sortedUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < [sortedUnitGroups  count] - 1) {
                ATUnitGroupModel *nextObj = sortedUnitGroups[idx + 1];
                if ([[ATBidInfoManager priceForUnitGroup:obj placementID:placementModel.placementID requestID:requestID] isEqualToString: [ATBidInfoManager priceForUnitGroup:nextObj placementID:placementModel.placementID requestID:requestID]]) {
                    [curRank addObject:nextObj];
                } else {
                    [rankedAndShuffledUnitGroups addObjectsFromArray:[curRank shuffledArray_anythink]];
                    [curRank removeAllObjects];
                    [curRank addObject:nextObj];
                }
            } else {
                [rankedAndShuffledUnitGroups addObjectsFromArray:[curRank shuffledArray_anythink]];
            }
        }];
    }
    
    
    
    return rankedAndShuffledUnitGroups;
}
@end
