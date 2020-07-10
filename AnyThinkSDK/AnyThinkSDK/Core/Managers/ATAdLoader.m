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
#import "ATAdLoader+HeaderBidding.h"
#import "ATAdCustomEvent.h"
#import "ATAppSettingManager.h"
#import "ATAdManager.h"
NSString *const kADapterCustomInfoStatisticsInfoKey = @"statistics_info";
NSString *const kAdapterCustomInfoPlacementModelKey = @"tracking_info_placement_model";
NSString *const kAdapterCustomInfoUnitGroupModelKey = @"tracking_info_unit_group_model";
NSString *const kAdapterCustomInfoRequestIDKey = @"tracking_info_request_id";

NSString *const kAdLoadingExtraRefreshFlagKey = @"refresh";
NSString *const kAdapterCustomInfoExtraKey = @"extra";

static NSString *const kATMyOfferOfferManagerClassName = @"ATMyOfferOfferManager";
@interface ATPlacementModel(OfferLoading)

/**
 * Calculate the active unit groups.
 */
@property(nonatomic, readonly) NSArray<ATUnitGroupModel*>* activeUnitGroups;
@end
@implementation ATPlacementModel(OfferLoading)
-(NSArray<ATUnitGroupModel*>*)activeUnitGroups {
    NSMutableArray<ATUnitGroupModel*>* activeUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    [self.unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj unitGroupValid:self.placementID]) { [activeUnitGroups addObject:obj]; }
    }];
    return activeUnitGroups;
}
@end

@interface ATAdLoader()
/**
 * To keep the adapters around until offers are successfully loaded.
 */
@property(nonatomic, readonly) ATThreadSafeAccessor *adaptersAccessors;
@property(nonatomic, readonly) NSMutableDictionary *adapters;

@property(nonatomic, readonly) ATThreadSafeAccessor *requestIDStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSString*>* requestIDStorage;

@property(nonatomic, readonly) ATThreadSafeAccessor *delegateCallFlagsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSString*>* delegateCallFlags;

@property(nonatomic, readonly) ATThreadSafeAccessor *loadDateStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDate*>* loadDateStorage;
/*
 *Used to ensure that load success tracking has been sent once&only once for every requestID
 */
@property(nonatomic, readonly) ATThreadSafeAccessor *agentEventFlagsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSNumber*>* agentEventFlags;

@property(nonatomic, readonly) ATThreadSafeAccessor *currentUnitGroupIndexAccessors;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*>* currentUnitGroupIndexStorage;

@property(nonatomic, readonly) ATThreadSafeAccessor *failedRequestRecordsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSDate*> *failedRequestRecords;
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
        _adaptersAccessors = [ATThreadSafeAccessor new];
        _adapters = [NSMutableDictionary dictionary];
        
        _requestIDStorageAccessor = [ATThreadSafeAccessor new];
        _requestIDStorage = [NSMutableDictionary<NSString*, NSString*> new];
        
        _delegateCallFlags = [NSMutableDictionary<NSString*, NSString*> dictionary];
        _delegateCallFlagsAccessor = [ATThreadSafeAccessor new];
        
        _agentEventFlags = [NSMutableDictionary<NSString*, NSNumber*> dictionary];
        _agentEventFlagsAccessor = [ATThreadSafeAccessor new];
        
        _currentUnitGroupIndexStorage = [NSMutableDictionary<NSString*, NSDictionary<NSString*, NSNumber*>*> new];
        _currentUnitGroupIndexAccessors = [ATThreadSafeAccessor new];
        
        _loadDateStorage = [NSMutableDictionary<NSString *, NSDate*> new];
        _loadDateStorageAccessor = [ATThreadSafeAccessor new];
        
        _failedRequestRecords = [NSMutableDictionary<NSString*, NSDate*> dictionary];
        _failedRequestRecordsAccessor = [ATThreadSafeAccessor new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScheduledLoadNotification:) name:kATScheduledLoadFiredNotification object:nil];
    }
    return self;
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

-(void) setDelegateCallFlagForPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    [_delegateCallFlagsAccessor writeWithBlock:^{ _delegateCallFlags[placementID] = requestID; }];
}

-(void) clearDelegateCallFlagForPlacementID:(NSString*)placementID {
    [_delegateCallFlagsAccessor writeWithBlock:^{ [_delegateCallFlags removeObjectForKey:placementID]; }];
}

/*
 {
     placement_id:{
         request_id:request_id,
         current_ad_source:current_ad_source
     }
 }
 */
-(void) setCurrentUnitGroupIndex:(NSInteger)index forPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdLoader::setting index:%ld placementID:%@ requestID:%@", index, placementID, requestID] type:ATLogTypeInternal];
    if (placementID != nil && requestID != nil) { [_currentUnitGroupIndexAccessors writeWithBlock:^{ _currentUnitGroupIndexStorage[placementID] = @{requestID:@(index)}; }]; }
}

-(NSInteger)currentUnitGroupIndexForPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    return [[_currentUnitGroupIndexAccessors readWithBlock:^id{ return _currentUnitGroupIndexStorage[placementID][requestID]; }] integerValue];
}

-(void) handleScheduledLoadNotification:(NSNotification*)notification {
    [ATLogger logMessage:@"ATAdLoader::handleScheduledLoadNotification:" type:ATLogTypeInternal];
    NSString *requestID = notification.userInfo[kATScheduledLoadFiredNotificationUserInfoRequestID];
    ATPlacementModel *placementModel = notification.userInfo[kATScheduledLoadFiredNotificationUserInfoPlacementModel];
    ATUnitGroupModel *unitGroupModel = notification.userInfo[kATScheduledLoadFiredNotificationUserInfoUnitGroupModel];
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithObject:@YES forKey:kAdLoadingExtraAutoloadFlagKey];
    if (notification.userInfo[kATScheduledLoadFiredNotificationUserInfoExtra] != nil) { [extra addEntriesFromDictionary:notification.userInfo[kATScheduledLoadFiredNotificationUserInfoExtra]]; }
    
    if (unitGroupModel.headerBidding) {
        [self sendHeaderBiddingRequestWithPlacementModel:placementModel nonHeaderBiddingUnitGroups:nil headerBiddingUnitGroups:@[unitGroupModel] completion:^(NSArray<ATUnitGroupModel *> *sortedUnitGroups, NSDictionary *extraInfo) {
            if ([sortedUnitGroups count] > 0) {
                [unitGroupModel updateBidInfoForRequestID:requestID];
                [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:unitGroupModel extra:extra delegate:nil success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary *> *assets) {
                    
                } failure:^(id<ATAdLoadingDelegate>delegate, NSError *error) {
                    //
                }];
            }//do not load when bidding request failed.
        }];
    } else {
        [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:unitGroupModel extra:extra delegate:nil success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary *> *assets) {
            
        } failure:^(id<ATAdLoadingDelegate>delegate, NSError *error) {
            //
        }];
    }
}

-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATAdLoadingDelegate>)delegate {
    NSString *requestID = [Utilities generateRequestID];
    [[ATPlacementSettingManager sharedManager] setLatestRequestID:requestID forPlacementID:placementID];
    if (![[ATPlacementSettingManager sharedManager] statusForPlacementID:placementID error:nil]) {
        if ([self loadingAdForPlacementID:placementID]) {
            [ATLogger logError:[NSString stringWithFormat:@"ATAdLoader::Ad for placementID:%@ is being loaded, please do not load again before the previous request's been finished", placementID] type:ATLogTypeExternal];
            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodePreviousLoadNotFinished userInfo:@{NSLocalizedDescriptionKey:@"ATSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The previous load for the placementID %@ has not returned.", placementID]}];
            [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0,
                                                                                                                   kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]),                       kATTrackerExtraSDKNotCalledReasonKey:@3
                                                                                                                                          }];
            [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { [delegate didFailToLoadADWithPlacementID:placementID error:error]; }
        } else {
            [self setRequestID:requestID forPlacementID:placementID];
            void (^StartLoadWithPlacementModel)(ATPlacementModel *placementModel) = ^(ATPlacementModel *placementModel) {
                [[ATAdManager sharedManager] setExtraInfo:extra forPlacementID:placementID requestID:requestID];
                if (placementModel.adDeliverySwitch) {
                    [[ATAdLoader sharedLoader] startLoadingOffersWithRequestID:requestID placementModel:placementModel extra:extra delegate:delegate];
                } else {
                    [self clearRequestIDForPlacementID:placementID];
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
                    [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData completion:^(ATPlacementModel *newPlacementModel, NSError *error) {
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
                [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData completion:^(ATPlacementModel *placementModel, NSError *error) {
                    if (error == nil) {
                        [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:placementModel];
                        
                        //Kick off MyOffer loading...
                        if (placementModel.preloadMyOffer) { [ATAdLoader loadMyOfferOffersInPlacementModel:placementModel requestID:requestID offerIndex:0]; };
                        
                        StartLoadWithPlacementModel(placementModel);
                    } else {
                        [self clearRequestIDForPlacementID:placementID];
                        if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                            [weakDelegate didFailToLoadADWithPlacementID:placementID error:error];
                        }
                    }
                }];
            }//End of outter else
        }
    } else {//Status being true, notify successful load directory
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0,
                                                                                                                                      kATTrackerExtraSDKNotCalledReasonKey:@4,
                                                                                                                                      kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])
                                                                                                                                      }];
        
        [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoadResult extra:@{kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraLoadTimeKey:@.0f}];
            if ([delegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate didFinishLoadingADWithPlacementID:placementID];
                });
            }
        if ([[ATAdManager sharedManager] psIDExpired]) {
            [[ATAdManager sharedManager] clearPSID];
            NSDictionary *curCustomData = [[ATPlacementSettingManager sharedManager] calculateCustomDataForPlacementID:placementID];
            [[ATPlacementSettingManager sharedManager] requestPlacementSettingWithPlacementID:placementID customData:curCustomData completion:^(ATPlacementModel *placementModel, NSError *error) {
                if (error == nil) [[ATPlacementSettingManager sharedManager] addNewPlacementSetting:placementModel];
            }];
        }
    }
}

//To seerially load my offers; switch to be added
+(void) loadMyOfferOffersInPlacementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID offerIndex:(NSInteger)index {
    NSArray<ATMyOfferOfferModel*> *offerModels = placementModel.offers;
    if (index < [offerModels count]) {
        [[NSClassFromString(kATMyOfferOfferManagerClassName) sharedManager] loadOfferWithOfferModel:offerModels[index] setting:placementModel.myOfferSetting extra:nil completion:^(NSError *error) {
            [self loadMyOfferOffersInPlacementModel:placementModel requestID:requestID offerIndex:index + 1];
        }];
    }
}

static NSString *const kRequestIDKey = @"request_id";
/**
 * The structure of the delegate flags dict is as follows:
 * {
 *      placement_1:request_id,
 *      placement_2:request_id
 * }
 */
-(void) updateStatusAndNotifySuccessIfNeededToDelegate:(id<ATAdLoadingDelegate>)delegate placementID:(NSString*)placementID requestID:(NSString*)requestID extra:(NSDictionary*)extra {
    __weak typeof(delegate) weakDelegate = delegate;
    __weak typeof(self) weakSelf = self;
    [weakSelf.agentEventFlagsAccessor writeWithBlock:^{
        if (![weakSelf.agentEventFlags[requestID] boolValue]) {
            weakSelf.agentEventFlags[requestID] = @YES;
            NSDate *loadStartDate = [[ATAdLoader sharedLoader] loadDateForRequestID:requestID];
            NSMutableDictionary *tkExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraLoadTimeKey:@(loadStartDate != nil ? [@([[NSDate date]timeIntervalSinceDate:loadStartDate] * 1000) integerValue] : 0)}];
            if ([extra[kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey] boolValue]) { tkExtra[kATTrackerExtraSDKNotCalledReasonKey] = @5; }
            [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:requestID trackType:ATNativeAdTrackTypeLoadResult extra:tkExtra];
        }
    }];
    
    [_delegateCallFlagsAccessor writeWithBlock:^{
        if ([requestID isEqualToString:_delegateCallFlags[placementID]]) {
            [self clearRequestIDForPlacementID:placementID];
            [[ATPlacementSettingManager sharedManager] setStatus:YES forPlacementID:placementID];
            if (![[ATAdManager sharedManager] adBeingShownForPlacementID:placementID] && [weakDelegate respondsToSelector:@selector(didFinishLoadingADWithPlacementID:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFinishLoadingADWithPlacementID:placementID]; }); }
            [_delegateCallFlags removeObjectForKey:placementID];
        }
    }];
}

/*
 *request id storage is used as loading flag to allow/disallow loading for a placement
 */
-(void) setRequestID:(NSString*)requestID forPlacementID:(NSString*)placementID {
    [_requestIDStorageAccessor writeWithBlock:^{ _requestIDStorage[placementID] = requestID; }];
}

-(void) clearRequestIDForPlacementID:(NSString*)placementID {
    [_requestIDStorageAccessor writeWithBlock:^{ [_requestIDStorage removeObjectForKey:placementID]; }];
}

-(BOOL) loadingAdForPlacementID:(NSString*)placementID {
    return [[_requestIDStorageAccessor readWithBlock:^id{ return @(_requestIDStorage[placementID] != nil); }] boolValue];
}

/*
 * load date storage
 */
-(void) setLoadDateforRequestID:(NSString*)requestID{
    if (requestID != nil) { [_loadDateStorageAccessor writeWithBlock:^{ _loadDateStorage[requestID] = [NSDate date]; }]; }
}
-(NSDate *)loadDateForRequestID:(NSString*)requestID{
    return [_loadDateStorageAccessor readWithBlock:^id{ return _loadDateStorage[requestID]; }];
}
-(void)clearLoadDateForRequestID:(NSString*)requestID{
    [_loadDateStorageAccessor writeWithBlock:^{ [_loadDateStorage removeObjectForKey:requestID]; }];
}

-(void) configureDefaultAdSourceLoadIfNeededWithPlacementModel:(ATPlacementModel*)placementModel activeUnitGroups:(NSArray<ATUnitGroupModel*>*)activeUnitGroups requestID:(NSString*)requestID extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    NSUInteger defaultAdSourceIndex = [[activeUnitGroups mutableArrayValueForKey:NSStringFromSelector(@selector(networkFirmID))] indexOfObject:@(placementModel.extra.defaultNetworkFirmID)];
    if (defaultAdSourceIndex != NSNotFound && defaultAdSourceIndex > MIN(placementModel.maxConcurrentRequestCount - 1, [activeUnitGroups count] - 1)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.extra.defaultAdSourceLoadingDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[ATAdManager sharedManager] adReadyForPlacementID:placementModel.placementID]) {
                [ATLogger logMessage:@"Ad's been ready for placement, default load's not needed" type:ATLogTypeInternal];
            } else {
                if (defaultAdSourceIndex > [self currentUnitGroupIndexForPlacementID:placementModel.placementID requestID:requestID]) {
                    [ATLogger logMessage:@"ATAdLoader::Will dispatch default ad source load." type:ATLogTypeInternal];
                    NSMutableDictionary *extraPara = extra != nil ? [NSMutableDictionary dictionaryWithDictionary:extra] : [NSMutableDictionary dictionary];
                    extraPara[kAdLoadingExtraDefaultLoadKey] = @YES;
                    [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:activeUnitGroups[defaultAdSourceIndex] extra:extraPara delegate:delegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary *> *assets) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [ATLogger logMessage:@"ATAdLoader::Default ad source load has succeeded; will notify delegate if needed" type:ATLogTypeInternal];
                            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:extra];
                            userInfo[kATADLoadingNotificationUserInfoRequestIDKey] = requestID;
                            [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:userInfo];
                            [self updateStatusAndNotifySuccessIfNeededToDelegate:delegate placementID:placementModel.placementID requestID:requestID extra:nil];
                        });
                    } failure:^(id<ATAdLoadingDelegate> delegate, NSError * error) {
                        //just do nothing
                    }];
                } else {
                    [ATLogger logMessage:@"ATAdLoader::Default adsource load has begun." type:ATLogTypeInternal];
                }
            }
        });
    } else {
        [ATLogger logMessage:@"Default ad source not configured or contained in first round loading" type:ATLogTypeInternal];
    }
}

static NSString *const kATHeaderBiddingResponseListFailedListKey = @"header_bidding_failed_request";
-(void) startLoadingOffersWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    __weak typeof(delegate) weakDelegate = delegate;
    if ([placementModel.unitGroups count] + [placementModel.headerBiddingUnitGroups count] > 0) {
        NSMutableDictionary *startLoadNotiUserInfo = [NSMutableDictionary dictionaryWithObject:placementModel forKey:kATADLoadingNotificationUserInfoPlacementKey];
        if (extra != nil) { startLoadNotiUserInfo[kATADLoadingNotificationUserInfoExtraKey] = extra; }
        [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingStartLoadNotification object:nil userInfo:startLoadNotiUserInfo];
        
        void(^StartLoading)(NSArray<ATUnitGroupModel*>* activeUnitGroups) = ^(NSArray<ATUnitGroupModel*>* activeUnitGroups) {
            BOOL shouldLoad = NO;
            NSString *errorReasonDesc = @"";
            NSMutableDictionary *trackingExtraInfo = [NSMutableDictionary dictionary];
            if ([ATCapsManager validateCapsForPlacementModel:placementModel]) {
                if ([ATCapsManager validatePacingForPlacementModel:placementModel]) {
                    shouldLoad = YES;
                    trackingExtraInfo[kATTrackerExtraSDKCalledFlagKey] = @1;
                } else {//Pacing within limit
                    errorReasonDesc = @"Placement pacing within limit.";
                    
                    trackingExtraInfo[kATTrackerExtraSDKCalledFlagKey] = @0;
                    trackingExtraInfo[kATTrackerExtraSDKNotCalledReasonKey] = @2;
                }
            } else {//Caps exceeded
                errorReasonDesc = @"Placement cap exeeds limit.";
                
                trackingExtraInfo[kATTrackerExtraSDKCalledFlagKey] = @0;
                trackingExtraInfo[kATTrackerExtraSDKNotCalledReasonKey] = @1;
            }
            if ([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]) { trackingExtraInfo[kATTrackerExtraAutoloadOnCloseFlagKey] = @YES; }
            [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:trackingExtraInfo];
            
            if (shouldLoad) {
                [[ATAdLoader sharedLoader] setDelegateCallFlagForPlacementID:placementModel.placementID requestID:requestID];
                [[ATAdLoader sharedLoader] setLoadDateforRequestID:requestID];
                if (placementModel.maxConcurrentRequestCount == 1) {
                    //Serial request
                    [[ATAdLoader sharedLoader] seriallyLoadOfferWithRequestID:requestID placementModel:placementModel activeUnitGroups:activeUnitGroups extra:extra delegate:delegate index:0];
                } else {
                    //Parallel request
                    [[ATAdLoader sharedLoader] concurrentlyLoadOfferWithRequestID:requestID placementModel:placementModel activeUnitGroups:activeUnitGroups extra:extra delegate:delegate round:0];
                }
                
                //Configure default adsource load
                [self configureDefaultAdSourceLoadIfNeededWithPlacementModel:placementModel activeUnitGroups:activeUnitGroups requestID:requestID extra:extra delegate:delegate];
                
                //Configure placement timeout
                [ATLogger logMessage:[NSString stringWithFormat:@"ATAdLoader::Loading has been kicked off, will dispatch long timeout handler with offer_loading_timeout:%.1f", placementModel.offerLoadingTimeout / 1000.0f] type:ATLogTypeInternal];
                __weak typeof(self) weakSelf = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(placementModel.offerLoadingTimeout / 1000.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [ATLogger logMessage:@"ATAdLoader::Dispatched long timeout handler fired(长超时结束，处理Adsource 埋点)" type:ATLogTypeInternal];
                    [_adaptersAccessors writeWithBlock:^{
                        NSMutableArray<NSString*>* keysForPendingGroups = [NSMutableArray<NSString*> array];
                        NSMutableArray<ATUnitGroupModel*>* pendingGroups = [NSMutableArray<ATUnitGroupModel*> array];
                        [placementModel.unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull unitGroup, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSString *adapterKey = [weakSelf adapterKeyWithRequestID:requestID placementModel:placementModel unitGroupModel:unitGroup];
                            if (weakSelf.adapters[adapterKey] != nil) {
                                [pendingGroups addObject:unitGroup];
                                [keysForPendingGroups addObject:adapterKey];
                                NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT SDK has failed to load ad.", NSLocalizedFailureReasonErrorKey:@"Third party SDK has not returned after long timeout."}];
                                NSDate *failedDate = [[ATAdLoader sharedLoader]loadDateForRequestID:requestID];
                                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID], kAgentEventExtraInfoPriorityKey:@(idx), kAgentEventExtraInfoRequestFailReasonKey:@1, kAgentEventExtraInfoRequestFailErrorCodeKey:@(error.code), kAgentEventExtraInfoRequestFailErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@(unitGroup.headerBidding ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:@(unitGroup.headerBidding ? [unitGroup bidPriceWithRequestID:requestID] : unitGroup.price),
                                                                                                                                                            kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)
                                                                                                                                                                                             }];
                            }
                        }];
                        if ([keysForPendingGroups count] > 0) {
                            [ATLogger logMessage:[NSString stringWithFormat:@"ATAdLoader::Short timeout unit group found, will handle agent event & tracking for unitGroups:%@", pendingGroups] type:ATLogTypeInternal];
                            NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AD offer loading has failed.",NSLocalizedFailureReasonErrorKey:@"Third party SDK has not returned after long timeout."}];
                            [weakSelf.delegateCallFlagsAccessor writeWithBlock:^{
                                [ATLogger logMessage:@"ATAdLoader::examine delegate call falgs" type:ATLogTypeInternal];
                                if ([requestID isEqualToString:weakSelf.delegateCallFlags[placementModel.placementID]]) {
                                    [ATLogger logMessage:@"ATAdLoader::Will call delegate" type:ATLogTypeInternal];
                                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey, nil];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
                                    if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; }); }
                                    [weakSelf.delegateCallFlags removeObjectForKey:placementModel.placementID];
                                } else {
                                    [ATLogger logMessage:@"ATAdLoader::No need to call delegate" type:ATLogTypeInternal];
                                }
                            }];
                            [weakSelf.adapters removeObjectsForKeys:keysForPendingGroups];
                        } else {
                            [ATLogger logMessage:@"ATAdLoader::No timeout unit group found, all succeeded/failed without timeouting" type:ATLogTypeInternal];
                        }
                    }];
                });
            } else {
                [ATLogger logMessage:[NSString stringWithFormat:@"ATAdLoader::Placement:%@ will not load because of pacing/cap limit", placementModel.placementID] type:ATLogTypeInternal];
                NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AD offer loading has failed.",NSLocalizedFailureReasonErrorKey:errorReasonDesc}];
                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey,  nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
                if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) { dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; }); }
                [self clearRequestIDForPlacementID:placementModel.placementID];
            }
        };
        void(^SendAgentEvent)(NSArray*infos) = ^(NSArray *infos) {
            if ([infos count] > 0) {
                NSArray *inActiveInfos = [NSArray arrayWithArray:infos];
                [inActiveInfos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDate *failedDate = [[ATAdLoader sharedLoader]loadDateForRequestID:requestID];
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:obj[kATTrackerExtraNetworkFirmIDKey] != nil ? obj[kATTrackerExtraNetworkFirmIDKey] : @(0), kAgentEventExtraInfoUnitGroupUnitIDKey:obj[kATTrackerExtraUnitIDKey] != nil ? obj[kATTrackerExtraUnitIDKey] : @"", kAgentEventExtraInfoPriorityKey:obj[kAgentEventExtraInfoPriorityKey] != nil ? obj[kAgentEventExtraInfoPriorityKey] : @0, kAgentEventExtraInfoRequestFailReasonKey:@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue]), kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@([obj[kAgentEventExtraInfoRequestHeaderBiddingFlagKey] boolValue] ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:@([obj[kAgentEventExtraInfoRequestPriceKey] doubleValue]), kAgentEventExtraInfoRequestFailReasonKey:@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue]),
                                                                                                                                                                           kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)
                                                                                                                                                                           }];
                }];
            }
        };
        
        NSArray *inActiveInfos = nil;
        NSMutableArray<ATUnitGroupModel*>* activeUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.unitGroups inactiveUnitGroupInfos:&inActiveInfos requestID:requestID];
        NSArray *hbInactiveInfos = nil;
        NSMutableArray<ATUnitGroupModel*>* activeHBUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:placementModel.headerBiddingUnitGroups inactiveUnitGroupInfos:&hbInactiveInfos requestID:requestID];
        NSArray<ATUnitGroupModel*>* offerCachedHBUnitGroups = [ATAdLoader offerCachedActiveUnitGroupsInPlacementModel:placementModel hbUnitGroups:activeHBUnitGroups];
        [activeHBUnitGroups removeObjectsInArray:offerCachedHBUnitGroups];//remove hblist
        [activeUnitGroups addObjectsFromArray:offerCachedHBUnitGroups];//add nomarl
        
        if ([activeUnitGroups count] + [activeHBUnitGroups count] > 0) {
            if ([activeHBUnitGroups count] > 0) {//HeaderBidding
                NSArray<NSDictionary*>* inactiveBidResponseListTKInfo = [ATAdLoader bidResponseListWithInactiveUnitGroupInfos:hbInactiveInfos unitGroupInfos:inActiveInfos];
                NSMutableArray<NSDictionary*>* failedHBRequestInfos = [NSMutableArray<NSDictionary*> array];
                if ([inactiveBidResponseListTKInfo count] > 0) { [failedHBRequestInfos addObjectsFromArray:inactiveBidResponseListTKInfo]; }
                
                NSNumber* bidRequestTime = [Utilities normalizedTimeStamp];
                [self runHeaderBiddingWithPlacementModel:placementModel requestID:requestID completion:^(NSDictionary *context) {
                    NSArray *inActiveInfos = nil;
                    NSArray<ATUnitGroupModel*>* sortedUnitGroups = [ATAdLoader activeUnitGroupsInPlacementModel:placementModel unitGroups:[placementModel unitGroupsForRequestID:requestID] inactiveUnitGroupInfos:&inActiveInfos requestID:requestID];
                    if ([sortedUnitGroups count] > 0) {
                        StartLoading(sortedUnitGroups);
                    } else {
                        [self clearRequestIDForPlacementID:placementModel.placementID];
                        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AD offer loading has failed.",NSLocalizedFailureReasonErrorKey:@"HeaderBidding request has failed."}];
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey,  nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
                        if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error];
                            });
                        }
                    }
                    SendAgentEvent(inActiveInfos);
                    NSArray<NSDictionary*> *hbResResponseListTKInfo = [ATAdLoader bidResponseListWithBidResponseExtraInfo:context headerBiddingUnitGroups:activeHBUnitGroups];
                    if ([hbResResponseListTKInfo count] > 0) { [failedHBRequestInfos addObjectsFromArray:hbResResponseListTKInfo]; }
                    [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeBidSort extra:@{kATTrackerExtraHeaderBiddingInfoKey:[ATAdLoader dynamicWaterfallTrackingExtraWithPlacementModel:placementModel unitGroups:sortedUnitGroups offerCachedUnitGroups:offerCachedHBUnitGroups unitGroupsUsingLatestBidInfo:context[kATHeaderBiddingExtraInfoUnitGroupsUsingLatestBidInfoKey] bidRequestTime:bidRequestTime bidResponseTime:[Utilities normalizedTimeStamp] requestID:requestID extraInfo:@{kATHeaderBiddingResponseListFailedListKey:failedHBRequestInfos}],kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])}];
                    [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeRankAndShuffle extra:@{kATTrackerExtraHeaderBiddingInfoKey:[ATAdLoader dynamicWaterfallTrackingExtraWithPlacementModel:placementModel unitGroups:sortedUnitGroups offerCachedUnitGroups:nil unitGroupsUsingLatestBidInfo:nil bidRequestTime:nil bidResponseTime:nil requestID:requestID extraInfo:nil],kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])}];
                }];
            } else {//No Header Bidding UnitGroups
                NSArray<ATUnitGroupModel*>* rankedAndShuffledUnitGroups = [ATAdLoader rankAndShuffleUnitGroups:activeUnitGroups];
                [placementModel updateUnitGroups:rankedAndShuffledUnitGroups forRequestID:requestID];
                //Send tk15
                [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeRankAndShuffle extra:@{kATTrackerExtraHeaderBiddingInfoKey:[ATAdLoader dynamicWaterfallTrackingExtraWithPlacementModel:placementModel unitGroups:rankedAndShuffledUnitGroups offerCachedUnitGroups:nil unitGroupsUsingLatestBidInfo:nil bidRequestTime:nil bidResponseTime:nil requestID:requestID extraInfo:nil],kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])}];
                StartLoading(rankedAndShuffledUnitGroups);
                if ([hbInactiveInfos count] > 0) {
                    NSMutableArray *inactiveInfos = [NSMutableArray arrayWithArray:inActiveInfos];
                    [inactiveInfos addObjectsFromArray:hbInactiveInfos];
                    SendAgentEvent(inactiveInfos);
                } else {
                    SendAgentEvent(inActiveInfos);
                }
            }
        } else {//No active unit groups
            if ([hbInactiveInfos count] > 0) {
                NSMutableArray *inactiveInfos = [NSMutableArray arrayWithArray:inActiveInfos];
                [inactiveInfos addObjectsFromArray:hbInactiveInfos];
                SendAgentEvent(inactiveInfos);
            } else {
                SendAgentEvent(inActiveInfos);
            }
            
            NSError *error = [NSError errorWithDomain:@"com.anythink.ATAdLoading" code:ATADLoadingErrorCodeUnitGroupsFilteredOut userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"Ad sources are filtered, no ad source is currently available."}];
            [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeLoad extra:@{kATTrackerExtraSDKCalledFlagKey:@0,
                                                                                                                                                     kATTrackerExtraSDKNotCalledReasonKey:@6}];
            [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error]}];
            [self clearRequestIDForPlacementID:placementModel.placementID];
            if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{ [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error]; });
            }
        }
    } else {
        [self clearRequestIDForPlacementID:placementModel.placementID];
        //TO DO: error description has to be revisid
        NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeNoUnitGroupsFoundInPlacement userInfo:@{NSLocalizedDescriptionKey:@"AD offer loading has failed.",NSLocalizedFailureReasonErrorKey:@"The placement strategy does not contain any unit group."}];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:placementModel, kATADLoadingNotificationUserInfoPlacementKey, error, kATADLoadingNotificationUserInfoErrorKey, extra[kAdLoadingExtraRefreshFlagKey], kAdLoadingExtraRefreshFlagKey,  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
        if ([weakDelegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakDelegate didFailToLoadADWithPlacementID:placementModel.placementID error:error];
            });
        }
    }
}

-(void) seriallyLoadOfferWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel activeUnitGroups:(NSArray<ATUnitGroupModel*>*)activeUnitGroups extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate index:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    __weak typeof(delegate) weakDelegate = delegate;
    __block NSInteger numberOfTimeoutRequest = 0;
    [[ATAdLoader sharedLoader] setCurrentUnitGroupIndex:index forPlacementID:placementModel.placementID requestID:requestID];
    id<ATAdManagement> adManager = [placementModel.adManagerClass sharedManager];
    NSArray<NSDictionary*>* adSourceStatusInpectionExtraInfo = nil;
    if ([adManager respondsToSelector:@selector(inspectAdSourceStatusWithPlacementModel:activeUnitGroups:unitGroup:requestID:extraInfo:)] && [adManager inspectAdSourceStatusWithPlacementModel:placementModel activeUnitGroups:activeUnitGroups unitGroup:activeUnitGroups[index] requestID:requestID extraInfo:&adSourceStatusInpectionExtraInfo]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:extra];
        });
        [self updateStatusAndNotifySuccessIfNeededToDelegate:delegate placementID:placementModel.placementID requestID:requestID extra:@{kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey:@YES}];
        [adSourceStatusInpectionExtraInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAdSourceStatusFillKey placementID:placementModel.placementID unitGroupModel:nil extraInfo:obj];
        }];
    } else {
        [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:activeUnitGroups[index] extra:extra delegate:weakDelegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary*> *assets) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:extra];
            });
            [self updateStatusAndNotifySuccessIfNeededToDelegate:delegate placementID:placementModel.placementID requestID:requestID extra:nil];
        } failure:^(id<ATAdLoadingDelegate> delegate, NSError *error) {
            if (error.code == ATADLoadingErrorCodeADOfferLoadingTimeout) { numberOfTimeoutRequest++; }
            if (index + 1 < [activeUnitGroups count]) {
                [_delegateCallFlagsAccessor readWithBlock:^id{
                    if ([_delegateCallFlags[placementModel.placementID] isEqualToString:requestID]) { [weakSelf seriallyLoadOfferWithRequestID:requestID placementModel:placementModel activeUnitGroups:activeUnitGroups extra:extra delegate:delegate index:index + 1]; }
                    return nil;
                }];
            } else {
                if (numberOfTimeoutRequest == 0) {
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error != nil ? error : [NSError errorWithDomain:@"com.anythink.OfferLoading" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"All offer loading(s) failed."}]], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:placementModel forKey:kATADLoadingNotificationUserInfoPlacementKey];
                    userInfo[kAdLoadingExtraRefreshFlagKey] = extra[kAdLoadingExtraRefreshFlagKey];
                    if (error != nil) { userInfo[kATADLoadingNotificationUserInfoErrorKey] = error; }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
                    //else if there's no more unit groups, call the failure callback on the loading delegate.
                    
                    if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate didFailToLoadADWithPlacementID:placementModel.placementID error:error];
                        });
                    }
                    [[ATAdLoader sharedLoader] clearDelegateCallFlagForPlacementID:placementModel.placementID];
                }
                [self clearRequestIDForPlacementID:placementModel.placementID];
            }//End of else
        }];
    }
}

-(void) concurrentlyLoadOfferWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel activeUnitGroups:(NSArray<ATUnitGroupModel*>*)activeUnitGroups extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate round:(NSInteger)round {
    [ATLogger logMessage:[NSString stringWithFormat:@"ATAdLoader::Round:%ld of concurrent load", round] type:ATLogTypeInternal];
    __weak typeof(self) weakSelf = self;
    NSInteger concurrentCount = placementModel.maxConcurrentRequestCount;
    if (round * concurrentCount < [activeUnitGroups count]) {
        /**
         * The number of the requests that have failed to load the ad.
         */
        __block NSInteger failedLoadNumber = 0;
        __block NSInteger numberOfTimeoutRequest = 0;
        NSMutableDictionary *adSourceStatusRecords = [NSMutableDictionary dictionary];
        [[ATAdLoader sharedLoader] setCurrentUnitGroupIndex:MIN(round * concurrentCount + concurrentCount, [activeUnitGroups count]) - 1 forPlacementID:placementModel.placementID requestID:requestID];
        for (NSInteger i = round * concurrentCount; i < MIN(round * concurrentCount + concurrentCount, [activeUnitGroups count]); i++) {
            id<ATAdManagement> adManager = [placementModel.adManagerClass sharedManager];
            NSArray<NSDictionary*>* adSourceStatusInpectionExtraInfo = nil;
            if ([adSourceStatusRecords count] == 0 && [adManager respondsToSelector:@selector(inspectAdSourceStatusWithPlacementModel:activeUnitGroups:unitGroup:requestID:extraInfo:)] && [adManager inspectAdSourceStatusWithPlacementModel:placementModel activeUnitGroups:activeUnitGroups unitGroup:activeUnitGroups[i] requestID:requestID extraInfo:&adSourceStatusInpectionExtraInfo]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:extra];
                    userInfo[kATADLoadingNotificationUserInfoRequestIDKey] = requestID;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:userInfo];
                    [self updateStatusAndNotifySuccessIfNeededToDelegate:delegate placementID:placementModel.placementID requestID:requestID extra:@{kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey:@YES}];
                });
                [adSourceStatusInpectionExtraInfo enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    adSourceStatusRecords[obj[kAgentEventExtraInfoPriorityKey]] = @YES;
                    [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAdSourceStatusFillKey placementID:placementModel.placementID unitGroupModel:nil extraInfo:obj];
                }];
            } else {
                if (![adSourceStatusRecords[@(i)] boolValue]) {
                    [self loadOfferWithRequestID:requestID placementModel:placementModel unitGroupModel:activeUnitGroups[i] extra:extra delegate:delegate success:^(id<ATAdLoadingDelegate> delegate, NSArray<NSDictionary*> *assets) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:extra];
                            userInfo[kATADLoadingNotificationUserInfoRequestIDKey] = requestID;
                            [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingOfferSuccessfullyLoadedNotification object:self userInfo:userInfo];
                            [self updateStatusAndNotifySuccessIfNeededToDelegate:delegate placementID:placementModel.placementID requestID:requestID extra:@{kLoaderInternalInfoKeyLoadingUsingAdSourceStatusFlagKey:@YES}];
                        });
                    } failure:^(id<ATAdLoadingDelegate> delegate, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error.code == ATADLoadingErrorCodeADOfferLoadingTimeout) { numberOfTimeoutRequest++; }
                            //Failed to load offer
                            failedLoadNumber++;
                            if (failedLoadNumber == MIN(concurrentCount, [activeUnitGroups count] - round * concurrentCount)) {
                                if ((1 + round) * concurrentCount < [activeUnitGroups count]) {
                                    [_delegateCallFlagsAccessor readWithBlock:^id{
                                        if ([_delegateCallFlags[placementModel.placementID] isEqualToString:requestID]) { [weakSelf concurrentlyLoadOfferWithRequestID:requestID placementModel:placementModel activeUnitGroups:activeUnitGroups extra:extra delegate:delegate round:round + 1]; }
                                        return nil;
                                    }];
                                } else {//All request has timeouted/failed
                                    if (numberOfTimeoutRequest == 0) {
                                        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyLoadFail placementID:placementModel.placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoLoadingFailureReasonKey:[NSString stringWithFormat:@"%@", error != nil ? error : [NSError errorWithDomain:@"com.anythink.OfferLoading" code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load ad", NSLocalizedFailureReasonErrorKey:@"All offer loading(s) failed."}]], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
                                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:placementModel forKey:kATADLoadingNotificationUserInfoPlacementKey];
                                        userInfo[kAdLoadingExtraRefreshFlagKey] = extra[kAdLoadingExtraRefreshFlagKey];
                                        if (error != nil) { userInfo[kATADLoadingNotificationUserInfoErrorKey] = error; }
                                        [[NSNotificationCenter defaultCenter] postNotificationName:kATADLoadingFailedToLoadNotification object:self userInfo:userInfo];
                                        if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
                                            [delegate didFailToLoadADWithPlacementID:placementModel.placementID error:error];
                                        }
                                        [[ATAdLoader sharedLoader] clearDelegateCallFlagForPlacementID:placementModel.placementID];
                                    }
                                    [self clearRequestIDForPlacementID:placementModel.placementID];
                                }
                            }//End of failedLoadNumber
                        });
                    }];
                }//End of ad source inspect records
            }
        }//End of for
    }
}

static NSString *const kAutoloadExtraInfoKey = @"extra_info";
-(void) loadOfferWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroup extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate success:(void(^)(id<ATAdLoadingDelegate>delegate, NSArray<NSDictionary*> *assets))successHandler failure:(void(^)(id<ATAdLoadingDelegate>, NSError*))failureHandler {
    __weak typeof(delegate) weakDelegate = delegate;
    if (unitGroup.adapterClass != nil) {
        NSMutableDictionary *adapterInfo = [NSMutableDictionary dictionaryWithDictionary:unitGroup.content];
        adapterInfo[kADapterCustomInfoStatisticsInfoKey] = [ATAdLoader statisticsInfoWithPlacementModel:placementModel unitGroupModel:unitGroup requestID:requestID bidRequest:NO];
        adapterInfo[@"request_num"] = @(unitGroup.networkRequestNum);
        adapterInfo[kAdapterCustomInfoRequestIDKey] = requestID;
        adapterInfo[kAdapterCustomInfoPlacementModelKey] = placementModel;
        adapterInfo[kAdapterCustomInfoUnitGroupModelKey] = unitGroup;
        if ([extra isKindOfClass:[NSDictionary class]]) { adapterInfo[kAdapterCustomInfoExtraKey] = extra; }
        __block id<ATNativeAdapter> adapter = [[unitGroup.adapterClass alloc] initWithNetworkCustomInfo:adapterInfo];
        ((NSObject*)adapter).delegateToBePassed = weakDelegate;
        [self setAdapter:adapter forKey:[self adapterKeyWithRequestID:requestID placementModel:placementModel unitGroupModel:unitGroup]];
        dispatch_queue_t loading_completion_queue = dispatch_queue_create("completionQueue.com.anythink", DISPATCH_QUEUE_SERIAL);
        __block BOOL requestFinished = NO;//Failed or Succeeded, the request is regarded as having finished.
        __block BOOL requestTimeout = NO;
        
        id<ATAd> phAd = [ATPlacementholderAd placeholderAdWithPlacementModel:placementModel requestID:requestID unitGroup:unitGroup];
        [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:ATGeneralAdAgentEventTypeRequest extra:extra error:nil]] type:ATLogTypeTemporary];
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraHeaderBiddingInfoKey:[ATTracker headerBiddingTrackingExtraWithUnitGroup:unitGroup requestID:requestID], kATTrackerExtraUnitIDKey:unitGroup.unitID, kATTrackerExtraNetworkFirmIDKey:@(unitGroup.networkFirmID), kATTrackerExtraRefreshFlagKey:@([extra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey:@([extra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey:@([extra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue])}];
        [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeADRequest extra:trackingExtra];
        NSDate *requestStartDate = [NSDate date];
        __block NSTimeInterval dataDidLoadedTime;
        __block BOOL ismetaDataDidLoaded = NO;
        if (unitGroup.networkDataTimeout != -1 && [adapter respondsToSelector:@selector(setMetaDataDidLoadedBlock:)]) {
               adapter.metaDataDidLoadedBlock = ^(){
                   ismetaDataDidLoaded = YES;
                   dataDidLoadedTime = [[NSDate date]timeIntervalSinceDate:requestStartDate];
               };
         }
        //Kick off the request
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [adapter loadADWithInfo:adapterInfo completion:^(NSArray<NSDictionary*> *assets, NSError *error) {
                [weakSelf.adaptersAccessors writeWithBlock:^{
                    NSString *adapterKey = [weakSelf adapterKeyWithRequestID:requestID placementModel:placementModel unitGroupModel:unitGroup];
                    if (weakSelf.adapters[adapterKey] != nil) {
                        [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:error != nil ? ATGeneralAdAgentEventTypeRequestFailure : ATGeneralAdAgentEventTypeRequestSuccess extra:extra error:error]] type:ATLogTypeTemporary];
                        if ([assets count] > 0 && error == nil) {
                            if (unitGroup.networkDataTimeout != -1 && ismetaDataDidLoaded) {
                                NSArray<ATUnitGroupModel*>* activeUnitGroups = [placementModel unitGroupsForRequestID:requestID];
                                activeUnitGroups = [activeUnitGroups count] > 0 ? activeUnitGroups : placementModel.unitGroups;
                                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyMetadataAndAdDataLoadingTimeKey placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{
                                                                       kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID),
                                                                       kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID],
                                                                       kAgentEventExtraInfoPriorityKey:@([activeUnitGroups indexOfObject:unitGroup]),
                                                                       kAgentEventExtraInfoMetadataLoadingTimeKey:@([@(dataDidLoadedTime * 1000) integerValue]),
                                                                       kAgentEventExtraInfoAdDataLoadingTimeKey:@([@([[NSDate date] timeIntervalSinceDate:requestStartDate] * 1000.0f) integerValue])
                                                                   }];
                            }
                            [weakSelf.agentEventFlagsAccessor writeWithBlock:^{
                                if (![weakSelf.agentEventFlags[requestID] boolValue]) {
                                    weakSelf.agentEventFlags[requestID] = @YES;
                                    NSDate *loadStartDate = [[ATAdLoader sharedLoader] loadDateForRequestID:requestID];
                                    [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeAdTrackTypeLoadResult extra:@{kATTrackerExtraAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraLoadTimeKey:@(loadStartDate != nil ? [@([[NSDate date]timeIntervalSinceDate:loadStartDate] * 1000) integerValue] : 0)}];
                                }
                            }];
                        }
                        dispatch_async(loading_completion_queue, ^{
                            requestFinished = YES;
                            
                            trackingExtra[kATTrackerExtraFilledWithinNetworkTimeoutFlagKey] = @(requestTimeout ? 1 : 0);
                            NSArray<ATUnitGroupModel*>* activeUnitGroups = [placementModel unitGroupsForRequestID:requestID];
                            activeUnitGroups = [activeUnitGroups count] > 0 ? activeUnitGroups : placementModel.unitGroups;
                            NSInteger unitGroupPri = [activeUnitGroups indexOfObject:unitGroup];
                            if (error == nil) {
                                NSInteger shownPri = [[[placementModel adManagerClass] sharedManager] highestPriorityOfShownAdInPlacementID:placementModel.placementID requestID:requestID];
                                trackingExtra[kATTrackerExtraFillTimeKey] = @([@([[NSDate date] timeIntervalSinceDate:requestStartDate] * 1000.0f) integerValue]);
                                trackingExtra[kATTrackerExtraFillRequestFlagKey] = @(shownPri == NSNotFound ? 0 : shownPri < unitGroupPri ? 1 : 2);
                                
                                if (assets[0][kAdAssetsCustomObjectKey] != nil) { trackingExtra[kATTrackerExtraCustomObjectKey] = assets[0][kAdAssetsCustomObjectKey]; }
                                [[ATTracker sharedTracker] trackWithPlacementID:placementModel.placementID requestID:requestID trackType:ATNativeADTrackTypeADRecalledSuccessfully extra:trackingExtra];
                                [weakSelf handleAssets:assets placementModel:placementModel unitGroupModel:unitGroup requestID:requestID extra:extra];
                                if (successHandler != nil) successHandler(weakDelegate, assets);
                            } else {
                                [self updateRequestFailureForPlacemetModel:placementModel unitGroupModel:unitGroup];
                                [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyRequestFail placementID:placementModel.placementID unitGroupModel:unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:requestID, kAgentEventExtraInfoNetworkFirmIDKey:@(unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:[NSString stringWithFormat:@"%@", unitGroup.unitID], kAgentEventExtraInfoPriorityKey:@(unitGroupPri), kAgentEventExtraInfoRequestFailReasonKey:@0, kAgentEventExtraInfoRequestFailErrorCodeKey:@(error.code), kAgentEventExtraInfoRequestFailErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoRequestHeaderBiddingFlagKey:@(unitGroup.headerBidding ? 1 : 0), kAgentEventExtraInfoRequestPriceKey:@(unitGroup.headerBidding ? [unitGroup bidPriceWithRequestID:requestID] : unitGroup.price),kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0),
                                                                                                                                                                                     kAgentEventExtraInfoRequestFailTimeKey:@([@([[NSDate date] timeIntervalSinceDate:requestStartDate] * 1000.0f) integerValue])
                                }];
                                if (failureHandler != nil) failureHandler(weakDelegate, error);
                            }
                            [weakSelf.adapters removeObjectForKey:adapterKey];
                        });//End dispatch_async
                    }
                }];
            }];
        });
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
        //Configure timeout handler
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(unitGroup.networkTimeout * NSEC_PER_SEC)), loading_completion_queue, ^{
            requestTimeout = YES;
            if (placementModel.format != 4) {
                if (!requestFinished) {
                    NSError *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingFailed userInfo:@{NSLocalizedDescriptionKey:@"AT SDK has failed to load ad.", NSLocalizedFailureReasonErrorKey:@"Third party SDK load timeouts."}];
                    [ATLogger logMessage:[NSString stringWithFormat:@"\nRequest offer with network info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:phAd event:ATGeneralAdAgentEventTypeRequestFailure extra:extra error:error]] type:ATLogTypeTemporary];
                }
                if (!requestFinished && failureHandler != nil) {
                    failureHandler(weakDelegate, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferLoadingTimeout userInfo:@{NSLocalizedDescriptionKey:@"The offer loading timeouts.",NSLocalizedFailureReasonErrorKey:@"Certain error might have occured during the offer loading process."}]);
                }
            }
        });
    } else {
        failureHandler(weakDelegate, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeAdapterClassNotFound userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Adapter(%@) initialization failed", unitGroup.adapterClassString],NSLocalizedFailureReasonErrorKey:@"The adapter has not been implemented or there are some spelling mistakes in the adapter name in the placement settings."}]);
    }
}

-(void) handleAssets:(NSArray<NSDictionary*>*)assets placementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID extra:(NSDictionary*)extra {
    [[ATLoadingScheduler sharedScheduler] scheduleLoadingWithPlacementModel:placementModel unitGroup:unitGroupModel requestID:requestID extra:extra];
    [assets enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[placementModel.adManagerClass sharedManager] addAdWithADAssets:obj withPlacementSetting:placementModel unitGroup:unitGroupModel requestID:requestID];
    }];
}

#pragma mark - adapter storage
/**
 * The structure of the adapters storage is as follows:
 * {
 *       key: adapter
 * }
 * key = md5(request_id + placement_id + unit_group_id).
 */
-(NSString*)adapterKeyWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    return [NSString stringWithFormat:@"%@%@%@", requestID, placementModel.placementID, unitGroupModel.unitGroupID].md5;
}

-(NSArray<NSString*>*) adapterKeysWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel unitGroupModels:(NSArray<ATUnitGroupModel*>*)unitGroupModels {
    NSMutableArray<NSString*>* keys = [NSMutableArray<NSString*> array];
    [unitGroupModels enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [keys addObject:[self adapterKeyWithRequestID:requestID placementModel:placementModel unitGroupModel:obj]];
    }];
    return keys;
}

-(void) setAdapter:(id)adapter forKey:(NSString*)key {
    if (adapter != nil && key != nil) [_adaptersAccessors writeWithBlock:^{ _adapters[key] = adapter; }];
}

-(void) removeAdapterForKey:(NSString*)key {
    if (key != nil) [_adaptersAccessors writeWithBlock:^{ [_adapters removeObjectForKey:key]; }];
}

-(void) removeAdaptersForKeys:(NSArray<NSString*>*)keys {
    [_adaptersAccessors writeWithBlock:^{ [_adapters removeObjectsForKeys:keys]; }];
}

-(void) enumerateUnitGroupsWithRequestID:(NSString*)requestID placementModel:(ATPlacementModel*)placementModel block:(void(^)(ATUnitGroupModel *unitGroup))block {
    [_adaptersAccessors readWithBlock:^id{
        [placementModel.unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (_adapters[[self adapterKeyWithRequestID:requestID placementModel:placementModel unitGroupModel:obj]] != nil) { block(obj); }
        }];
        return nil;
    }];
}

+(NSDictionary*)statisticsInfoWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel requestID:(NSString*)requestID bidRequest:(BOOL)bidRequest {
    return @{@"ads":@([[ATCapsManager sharedManager] capByDayWithAdFormat:placementModel.format]),
             @"ahs":@([[ATCapsManager sharedManager] capByHourWithAdFormat:placementModel.format]),
             @"pds":@([[ATCapsManager sharedManager] capByDayWithPlacementID:placementModel.placementID]),
             @"phs":@([[ATCapsManager sharedManager] capByHourWithPlacementID:placementModel.placementID]),
             @"tpl":placementModel.placementID != nil ? placementModel.placementID : @"",
             @"ap":@(bidRequest ? 0 : [[placementModel unitGroupsForRequestID:requestID] indexOfObject:unitGroupModel] / placementModel.maxConcurrentRequestCount + 1),
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
+(NSArray<NSDictionary*>*) bidResponseListWithInactiveUnitGroupInfos:(NSArray<NSDictionary*>*)hbGroupInfos unitGroupInfos:(NSArray<NSDictionary*>*)groupInfos {
    NSMutableArray<NSDictionary*>* list = [NSMutableArray<NSDictionary*> array];
    if ([hbGroupInfos count] > 0) {
        [hbGroupInfos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                                  kHeaderBiddingResponseListSortTypeKey:@-1,
                                  kHeaderBiddingResponseListAdSourceIDKey:obj[kATTrackerExtraUnitIDKey] != nil ? obj[kATTrackerExtraUnitIDKey] : @"",
                                  kHeaderBiddingResponseListBidResultKey:@0,
                                  kHeaderBiddingResponseListBidPriceKey:@0,
                                  kHeaderBiddingResponseListErrorCodeKey:obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] != nil ? obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] : @0,
                                  kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@ within limit", @{@0:@"Cap/pacing", @2:@"Cap", @3:@"Pacing"}[@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue])]]
                                  }];
            }
        }];
    }
    if ([groupInfos count] > 0) {
        [groupInfos enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                                  kHeaderBiddingResponseListSortTypeKey:@-1,
                                  kHeaderBiddingResponseListAdSourceIDKey:obj[kATTrackerExtraUnitIDKey] != nil ? obj[kATTrackerExtraUnitIDKey] : @"",
                                  kHeaderBiddingResponseListBidResultKey:@0,
                                  kHeaderBiddingResponseListBidPriceKey:@0,
                                  kHeaderBiddingResponseListErrorCodeKey:obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] != nil ? obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] : @0,
                                  kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@ within limit", @{@0:@"Cap/pacing", @2:@"Cap", @3:@"Pacing"}[@([obj[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] integerValue])]]
                                  }];
            }
        }];
    }
    return list;
}

+(NSArray<NSDictionary*>*) bidResponseListWithBidResponseExtraInfo:(NSDictionary*)extraInfo headerBiddingUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups {
    NSMutableArray<NSDictionary*>* list = [NSMutableArray<NSDictionary*> array];
    if ([extraInfo count] > 0) {
        NSMutableDictionary<NSNumber*, ATUnitGroupModel*>* unitGroupMap = [NSMutableDictionary<NSNumber*, ATUnitGroupModel*> dictionary];
        [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { unitGroupMap[@([obj hash])] = obj; }];
        if ([extraInfo[kATHeaderBiddingExtraInfoDetailErrorKey] isKindOfClass:[NSDictionary class]]) {
            NSDictionary<NSNumber*, NSError*> *detailErrors = extraInfo[kATHeaderBiddingExtraInfoDetailErrorKey];//{@([unitGroup hash]):error}
            [detailErrors enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSError * _Nonnull obj, BOOL * _Nonnull stop) {
                ATUnitGroupModel *unitGroupModel = unitGroupMap[key];
                if ([obj isKindOfClass:[NSError class]]) {
                    [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                                      kHeaderBiddingResponseListSortTypeKey:@-1,
                                      kHeaderBiddingResponseListAdSourceIDKey:unitGroupModel.unitID != nil ? unitGroupModel.unitID : @"",
                                      kHeaderBiddingResponseListBidResultKey:@0,
                                      kHeaderBiddingResponseListBidPriceKey:@0,
                                      kHeaderBiddingResponseListErrorCodeKey:@(obj.code),
                                      kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@", obj]
                                      }];
                }
            }];
        } else if ([extraInfo[kATHeaderBiddingExtraInfoTotalErrorKey] isKindOfClass:[NSError class]]) {
            NSError *totalError = extraInfo[kATHeaderBiddingExtraInfoTotalErrorKey];
            [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [list addObject:@{kHeaderBiddingResponseListSortPriorityKey:@-1,
                                  kHeaderBiddingResponseListSortTypeKey:@-1,
                                  kHeaderBiddingResponseListAdSourceIDKey:obj.unitID != nil ? obj.unitID : @"",
                                  kHeaderBiddingResponseListBidResultKey:@0,
                                  kHeaderBiddingResponseListBidPriceKey:@0,
                                  kHeaderBiddingResponseListErrorCodeKey:@(totalError.code),
                                  kHeaderBiddingResponseListErrorMessageKey:[NSString stringWithFormat:@"%@", extraInfo[kATHeaderBiddingExtraInfoTotalErrorKey]]
                                  }];
            }];
        }
    }
    return list;
}

+(NSMutableArray<ATUnitGroupModel*>*) offerCachedActiveUnitGroupsInPlacementModel:(ATPlacementModel*)placementModel hbUnitGroups:(NSArray<ATUnitGroupModel*>*)hbUnitGroups {
    NSMutableArray<ATUnitGroupModel*>* unitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    [hbUnitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[placementModel.adManagerClass sharedManager] adSourceStatusInPlacementModel:placementModel unitGroup:obj]) { [unitGroups addObject:obj]; }
    }];
    return unitGroups;
}

+(NSMutableArray<ATUnitGroupModel*>*)activeUnitGroupsInPlacementModel:(ATPlacementModel*)placementModel unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups inactiveUnitGroupInfos:(NSArray<NSDictionary*>* __autoreleasing*)inactiveActiveUnitGroupInfos requestID:(NSString*)requestID {
    NSMutableArray<ATUnitGroupModel*> *activeUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    NSMutableArray<NSDictionary*>* reasons = [NSMutableArray<NSDictionary*> array];
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *reason = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:placementModel unitGroupModel:obj requestID:requestID]];
        reason[kAgentEventExtraInfoRequestHeaderBiddingFlagKey] = @(obj.headerBidding ? 1 : 0);
        reason[kAgentEventExtraInfoRequestPriceKey] = @(obj.headerBidding ? [obj bidPriceWithRequestID:requestID] : obj.price);
        reason[kAgentEventExtraInfoPriorityKey] = @(idx);
        reason[kInactiveUnitGroupInfoUnitGroupKey] = obj;
        reason[kATTrackerExtraUnitIDKey] = obj.unitID != nil ? obj.unitID : @"";
        reason[kATTrackerExtraNetworkFirmIDKey] = @(obj.networkFirmID);
        if ([ATAdStorageUtility validateCapsForUnitGroup:obj placementID:placementModel.placementID]) {
            if ([ATAdStorageUtility validatePacingForUnitGroup:obj placementID:placementModel.placementID]) {
                if ([[ATAdLoader sharedLoader] shouldSendRequestAfterLastFailureForPlacementModel:placementModel unitGroupModel:obj]) {
                    [activeUnitGroups addObject:obj];
                } else {
                    reason[kGeneralAdAgentEventExtraInfoSDKNotCalledReasonKey] = @4;//loading failure interval
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

+(NSDictionary*)dynamicWaterfallTrackingExtraWithPlacementModel:(ATPlacementModel*)placementModel unitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups offerCachedUnitGroups:(NSArray<ATUnitGroupModel*>*)offerCachedUnitGroups unitGroupsUsingLatestBidInfo:(NSArray<ATUnitGroupModel*>*)unitGroupsUsingLatestBidInfo bidRequestTime:(NSNumber*)requestTime bidResponseTime:(NSNumber*)responseTime requestID:(NSString*)requestID extraInfo:(NSDictionary*)extraInfo {
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionary];
    if (requestTime != nil) { trackingExtra[@"bidrequesttime"] = @([requestTime doubleValue]); }
    if (responseTime != nil) { trackingExtra[@"bidresponsetime"] = @([responseTime doubleValue]); }
    NSMutableArray<NSDictionary*>* biddingEntries = [NSMutableArray<NSDictionary*> array];
    NSArray<ATUnitGroupModel*>* sortedAdSources = [placementModel unitGroupsForRequestID:requestID];
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.headerBidding) {
            NSString *bidInfo = [obj bidTokenWithRequestID:requestID];
            if (bidInfo != nil) {
                [biddingEntries addObject:@{kHeaderBiddingResponseListSortPriorityKey:@([sortedAdSources indexOfObject:obj]),
                                            kHeaderBiddingResponseListSortTypeKey:@([unitGroupsUsingLatestBidInfo containsObject:obj] ? 2 : 0),
                                            kHeaderBiddingResponseListBidResultKey:@1,
                                            kHeaderBiddingResponseListBidPriceKey:@([obj bidPriceWithRequestID:requestID]),
                                            kHeaderBiddingResponseListAdSourceIDKey:obj.unitID != nil ? obj.unitID : @""
                                            }];
            } else {
                if ([offerCachedUnitGroups containsObject:obj]) {
                    [biddingEntries addObject:@{kHeaderBiddingResponseListSortPriorityKey:@([sortedAdSources indexOfObject:obj]),
                    kHeaderBiddingResponseListSortTypeKey:@3,
                    kHeaderBiddingResponseListBidResultKey:@1,
                    kHeaderBiddingResponseListBidPriceKey:@(obj.price),
                    kHeaderBiddingResponseListAdSourceIDKey:obj.unitID != nil ? obj.unitID : @""
                    }];
                }
            }
        } else {
            [biddingEntries addObject:@{kHeaderBiddingResponseListSortPriorityKey:@([sortedAdSources indexOfObject:obj]),
                                        kHeaderBiddingResponseListSortTypeKey:@1,
                                        kHeaderBiddingResponseListBidResultKey:@0,
                                        kHeaderBiddingResponseListBidPriceKey:@(obj.price),
                                        kHeaderBiddingResponseListAdSourceIDKey:obj.unitID != nil ? obj.unitID : @""
                                        }];
        }
    }];
    [biddingEntries sortUsingComparator:^NSComparisonResult(NSDictionary*  _Nonnull obj1, NSDictionary*  _Nonnull obj2) {
        return [obj1[kHeaderBiddingResponseListSortPriorityKey] compare:obj2[kHeaderBiddingResponseListSortPriorityKey]] == NSOrderedSame ? [obj2[kHeaderBiddingResponseListSortTypeKey] compare:obj1[kHeaderBiddingResponseListSortTypeKey]] : [obj1[kHeaderBiddingResponseListSortPriorityKey] compare:obj2[kHeaderBiddingResponseListSortPriorityKey]];
    }];
    if ([extraInfo[kATHeaderBiddingResponseListFailedListKey] isKindOfClass:[NSArray class]]) { [biddingEntries addObjectsFromArray:extraInfo[kATHeaderBiddingResponseListFailedListKey]]; }
    if ([biddingEntries count] > 0) { trackingExtra[@"bidresponselist"] = biddingEntries; }
    return trackingExtra;
}

+(NSDictionary*)logHeaderBiddingInfoWithUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups placementModel:(ATPlacementModel*)placementModel requestID:(NSString*)requestID {
    NSMutableArray *adSources = [NSMutableArray<NSDictionary*> array];
    [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [adSources addObject:@{@"network_firm_id":@(obj.networkFirmID),
                               @"unit_id":obj.unitID != nil ? obj.unitID : @"",
                               @"price":@(obj.headerBidding ? ([obj bidTokenWithRequestID:requestID] != nil ? [obj bidPriceWithRequestID:requestID] : obj.price) : obj.price)
                               }];
    }];
    return @{@"placement_id":placementModel.placementID,
             @"request_id":requestID,
             @"ad_source_list":adSources
             };
}

+(NSArray<ATUnitGroupModel*>*)rankAndShuffleUnitGroups:(NSArray<ATUnitGroupModel*>*)unitGroups {
    NSMutableArray<ATUnitGroupModel*> *rankedAndShuffledUnitGroups = [NSMutableArray<ATUnitGroupModel*> array];
    if ([unitGroups count] > 0) {
        NSMutableArray<ATUnitGroupModel*> *curRank = [NSMutableArray<ATUnitGroupModel*> arrayWithObject:unitGroups[0]];
        [unitGroups enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < [unitGroups  count] - 1) {
                ATUnitGroupModel *nextObj = unitGroups[idx + 1];
                if (obj.price == nextObj.price) {
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
