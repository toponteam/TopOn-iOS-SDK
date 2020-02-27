 //
//  ATAdManager.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 04/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdManager.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"
#import "ATPlacementSettingManager.h"
#import "ATAdLoader.h"
#import "ATPlacementModel.h"
#import "ATUnitGroupModel.h"
#import "ATTracker.h"
#import "ATThreadSafeAccessor.h"
#import "ATAPI+Internal.h"
#import "ATAgentEvent.h"
#import "ATAdLoadingDelegate.h"
#import "ATCapsManager.h"
#import "ATAdManagement.h"
#import "ATGeneralAdAgentEvent.h"
#import <objc/runtime.h>
#import "ATAdManager+Internal.h"
#import "ATLoadingScheduler.h"
#import "ATAdStorageUtility.h"
NSString *const kExtraInfoRootViewControllerKey = @"root_view_controller";
NSString *const kAdLoadingExtraAutoloadFlagKey = @"auto_load";
NSString *const kExtraInfoAdSizeKey = @"ad_size";
NSString *const kAdLoadingTrackingExtraStatusKey = @"timeout_status";
NSString *const kAdLoadingTrackingExtraFlagKey = @"hight_priority_shown_flag";
NSString *const kAdLoadingExtraDefaultLoadKey = @"default_ad_source_load";
NSString *const kAdLoadingExtraFilledByReadyFlagKey = @"filled_by_ready";
NSString *const kAdLoadingExtraAutoLoadOnCloseFlagKey = @"auto_load_on_close";

NSString *const kAdAssetsCustomEventKey = @"custom_event";
NSString *const kAdAssetsCustomObjectKey = @"custom_object";
NSString *const kAdAssetsUnitIDKey = @"unit_id";
@protocol ATAdReady<NSObject>
-(BOOL) nativeAdReadyForPlacementID:(NSString*)placementID;
-(BOOL) interstitialReadyForPlacementID:(NSString*)placementID;
-(BOOL) bannerAdReadyForPlacementID:(NSString*)placementID;
-(BOOL) rewardedVideoReadyForPlacementID:(NSString*)placementID;
@end

@interface ATAdManager()<ATAdReady>
@property(nonatomic) NSDate *psIDExpireDate;
@property(nonatomic, readonly) NSString *PSID_impl;
@property(nonatomic, readonly) dispatch_queue_t ps_id_accessing_queue;
@property(nonatomic, readonly) dispatch_queue_t placement_ids_accessing_queue;
@property(nonatomic, readonly) NSMutableSet *placementIDs_impl;
@property(nonatomic, readonly) ATThreadSafeAccessor *extraInfoAccessor;
@property(nonatomic, readonly) NSMutableDictionary *extraInfo;
@property(nonatomic, readonly) dispatch_queue_t show_api_control_queue_impl;
@property(nonatomic, readonly) ATThreadSafeAccessor *adBeingShownFlagsAccessor;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSNumber*> *adBeingShowFlags;
@end
@implementation ATAdManager
+(instancetype) sharedManager {
    static ATAdManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATAdManager alloc] init];
    });
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        [ATLogger logMessage:@"ATAdManager init" type:ATLogTypeInternal];
        _ps_id_accessing_queue = dispatch_queue_create("psIDAccessQueue.com.anythink", DISPATCH_QUEUE_CONCURRENT);
        _placement_ids_accessing_queue = dispatch_queue_create("placementIDsAccessQueue.com.anythink", DISPATCH_QUEUE_CONCURRENT);
        _placementIDs_impl = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[ATAdManager placementIDsFilePathWithAppID:[ATAPI sharedInstance].appID appKey:[ATAPI sharedInstance].appKey]]];
        if (_placementIDs_impl == nil) {
            _placementIDs_impl = [NSMutableSet new];
        }
        _extraInfoAccessor = [ATThreadSafeAccessor new];
        _extraInfo = [NSMutableDictionary new];
        _show_api_control_queue_impl = dispatch_queue_create("com.anythink.ShowAPIControlQueue", DISPATCH_QUEUE_SERIAL);
         [ATLogger logMessage:@"ATAdManager init end" type:ATLogTypeInternal];
        
        _adBeingShowFlags = [NSMutableDictionary<NSString*, NSNumber*> dictionary];
        _adBeingShownFlagsAccessor = [ATThreadSafeAccessor new];
    }
    return self;
}

#pragma mark - ad being shown
//For banner at the moment
-(void) setAdBeingShownFlagForPlacementID:(NSString*)placementID {
    if (placementID != nil) {
        __weak typeof(self) weakSelf = self;
        [_adBeingShownFlagsAccessor writeWithBlock:^{ weakSelf.adBeingShowFlags[placementID] = @YES; }];
    }
}

-(void) clearAdBeingShownFlagForPlacementID:(NSString*)placementID {
    if (placementID != nil) {
        __weak typeof(self) weakSelf = self;
        [_adBeingShownFlagsAccessor writeWithBlock:^{ [weakSelf.adBeingShowFlags removeObjectForKey:placementID]; }];
    }
}


-(BOOL) adBeingShownForPlacementID:(NSString*)placementID {
    __weak typeof(self) weakSelf = self;
    return [[_adBeingShownFlagsAccessor readWithBlock:^id{ return weakSelf.adBeingShowFlags[placementID]; }] boolValue];
}

#pragma mark - ps id accessing
-(dispatch_queue_t) show_api_control_queue {
    return _show_api_control_queue_impl;
}

-(void) clearPSID {
    dispatch_barrier_async(_ps_id_accessing_queue, ^{
        _PSID_impl = nil;
        _psIDExpireDate = [NSDate dateWithTimeIntervalSince1970:0];
    });
}

-(void) setPSID:(NSString*)psID interval:(NSTimeInterval)interval {
    dispatch_barrier_async(_ps_id_accessing_queue, ^{
        _PSID_impl = psID;
        _psIDExpireDate = [NSDate dateWithTimeIntervalSinceNow:interval / 1000.0f];
    });
}

-(NSString*)psID {
    __block NSString *psID = nil;
    dispatch_sync(_ps_id_accessing_queue, ^{
        psID = _PSID_impl;
    });
    return psID;
}

-(BOOL) psIDExpired {
    __block BOOL expired = NO;
    dispatch_sync(_ps_id_accessing_queue, ^{
        expired = !([_PSID_impl length] > 0 && [_psIDExpireDate timeIntervalSinceDate:[NSDate date]] > 0);
    });
    return expired;
}
#pragma mark - api methods
-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra customData:(NSDictionary*)customData delegate:(id<ATAdLoadingDelegate>)delegate {
    [self loadADWithPlacementID:placementID extra:extra delegate:delegate];
}

-(void) loadADWithPlacementID:(NSString*)placementID extra:(NSDictionary*)extra delegate:(id<ATAdLoadingDelegate>)delegate {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nAPI invocation info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent apiLogInfoWithPlacementID:placementID format:NSNotFound api:kATAPILoad]] type:ATLogTypeTemporary];
    if ([placementID length] <= 0 || [[ATAPI sharedInstance].appID length] <= 0 ||  [[ATAPI sharedInstance].appKey length] <= 0) {
        if ([delegate respondsToSelector:@selector(didFailToLoadADWithPlacementID:error:)]) {
            [delegate didFailToLoadADWithPlacementID:placementID error:[NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeInvalidInputEncountered userInfo:@{NSLocalizedDescriptionKey:@"Ad loading has failed.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Invalid input has been encountered: placementID(%@), appID(%@), appKey(%@)", placementID, [ATAPI sharedInstance].appID, [ATAPI sharedInstance].appKey]}]];
        }
    } else {
        [[ATAdLoader sharedLoader] loadADWithPlacementID:placementID extra:extra customData:nil delegate:delegate];
    }
}

-(void) clearCache {
    [ATLogger logMessage:@"This method has been marked as depricated and does nothing." type:ATLogTypeExternal];
}

-(id<ATAd>) offerWithPlacementID:(NSString*)placementID error:(NSError**)error refresh:(BOOL)refresh {
    [ATLogger logMessage:@"retrieving offer" type:ATLogTypeInternal];
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    //Unit pacing & cap by day&hour
    if (placementModel.unitPacing >= 0 && [[ATCapsManager sharedManager] lastShowTimeOfPlacementID:placementID] != nil && [[NSDate date] timeIntervalSinceDate:[[ATCapsManager sharedManager] lastShowTimeOfPlacementID:placementID]] < placementModel.unitPacing / 1000.0f) {
        if (error != nil) {
            *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeShowIntervalWithinPlacementPacing userInfo:@{NSLocalizedDescriptionKey:@"The AD for the placement is being shown too frequently.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The interval between the moment you're trying to show the AD and the moment you showed it last time(%ld) is less than the pacing you've set in the placement strategy(%ld).", (long)[[NSDate date] timeIntervalSinceDate:[[ATCapsManager sharedManager] lastShowTimeOfPlacementID:placementID]], (NSInteger)(placementModel.unitPacing / 1000)]}];
        }
        return nil;
    }
    if (placementModel.unitCapsByDay <= [[ATCapsManager sharedManager] capByDayWithPlacementID:placementID]) {
        if (error != nil) {
            *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeShowTimesExceedsDayCap userInfo:@{NSLocalizedDescriptionKey:@"The AD for the placement has been shown too many times today.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The times for which this placment has shown it's AD(%ld) has exceeds the limit you set in the placement strategy(%ld)", (long)[[ATCapsManager sharedManager] capByDayWithPlacementID:placementID], placementModel.unitCapsByDay]}];
        }
        return nil;
    }
    if (placementModel.unitCapsByHour <= [[ATCapsManager sharedManager] capByHourWithPlacementID:placementID]) {
        if (error != nil) {
            *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeShowTimesExceedsHourCap userInfo:@{NSLocalizedDescriptionKey:@"The AD for the placement has been shown too many times within the current hour.", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"The times for which this placment has shown it's AD(%ld) has exceeds the limit you set in the placement strategy(%ld)", (long)[[ATCapsManager sharedManager] capByHourWithPlacementID:placementID], placementModel.unitCapsByHour]}];
        }
        return nil;
    }
    [ATLogger logMessage:@"No error occured & will retriev offers from offer manager" type:ATLogTypeInternal];
    NSArray<id<ATAd>>* offers = [[placementModel.adManagerClass sharedManager] adsWithPlacementID:placementID];
    [ATLogger logMessage:[NSString stringWithFormat:@"placement offers:%@", offers] type:ATLogTypeInternal];
    if ([offers count] == 0) {
        if (error != nil) {
            *error = [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeADOfferNotFound userInfo:@{NSLocalizedDescriptionKey:placementModel.format == 0 ? @"Offer can not be found while creating AD view" : @"Offer can not be found", NSLocalizedFailureReasonErrorKey:@"Maybe: The offer load request has not returned or has not been made in the first place."}];
        }
        return nil;
    } else {
        NSArray<id<ATAd>>* sortedOffers = [offers sortedArrayUsingComparator:@[
                                                                                           ^NSComparisonResult(id<ATAd>  _Nonnull obj1, id<ATAd>  _Nonnull obj2) {
            //For priority show type
            [ATLogger logMessage:@"showtype 0" type:ATLogTypeInternal];
            NSComparisonResult result = NSOrderedSame;
            if (obj1.priority != obj2.priority) result = [@(obj1.priority) compare:@(obj2.priority)];
            else if (obj1.showTimes != obj2.showTimes) result = [@(obj1.showTimes) compare:@(obj2.showTimes)];
            else result = [obj1.cacheDate compare:obj2.cacheDate];
            return result;
        },
                                                                                            ^NSComparisonResult(id<ATAd>  _Nonnull obj1, id<ATAd>  _Nonnull obj2) {
            //For serial show type
            [ATLogger logMessage:@"showtype 1" type:ATLogTypeInternal];
            NSComparisonResult result = NSOrderedSame;
            if (obj1.showTimes != obj2.showTimes) result = [@(obj1.showTimes) compare:@(obj2.showTimes)];
            else if (obj1.priority != obj2.priority) result = [@(obj1.priority) compare:@(obj2.priority)];
            else result = [obj1.cacheDate compare:obj2.cacheDate];
            return result;
        }][refresh ? ATADShowTypePriority : placementModel.showType]];
        [ATLogger logMessage:[NSString stringWithFormat:@"sorted offers by show type %ld: %@", (long)placementModel.showType, sortedOffers] type:ATLogTypeInternal];
        return sortedOffers[0];
    }
}
#pragma mark - placement setting accessing
-(NSSet*)placementIDs {
    __block NSSet *IDs = nil;
    dispatch_sync(_placement_ids_accessing_queue, ^{
        IDs = [NSSet setWithSet:_placementIDs_impl];
    });
    return IDs;
}

-(void) addNewPlacementID:(NSString *)placementID {
    dispatch_barrier_async(_placement_ids_accessing_queue, ^{
        NSInteger previousCount = [_placementIDs_impl count];
        [_placementIDs_impl addObject:placementID];
        if (previousCount != [_placementIDs_impl count]) {
            [[NSKeyedArchiver archivedDataWithRootObject:_placementIDs_impl] writeToFile:[ATAdManager placementIDsFilePathWithAppID:[ATAPI sharedInstance].appID appKey:[ATAPI sharedInstance].appKey] options:NSDataWritingFileProtectionComplete error:nil];
        }
    });
}

#pragma mark - path utilities
+(NSString*) placementIDsFilePathWithAppID:(NSString*)appID appKey:(NSString*)appKey {
    return [[Utilities documentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.placementIDs.com.anythink", [NSString stringWithFormat:@"%@%@", [ATAPI sharedInstance].appID, [ATAPI sharedInstance].appKey].md5]];
}

#pragma mark - extra info management
static NSString *requestIDKey = @"request_id";
static NSString *extraInfoKey = @"extra_info";
-(NSDictionary*)extraInfoForPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    return [_extraInfoAccessor readWithBlock:^id{
        if ([_extraInfo containsObjectForKey:placementID]) {
            if ([_extraInfo[placementID][requestIDKey] isEqualToString:requestID]) {
                return _extraInfo[placementID][extraInfoKey];
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }];
}

/*
 extra info is saved as below:
 {
     placement_id:{
         request_id:requestID,
         extra_info:extraInfo
     }
     //other extra info
 }
 */
-(void) setExtraInfo:(NSDictionary*)extraInfo forPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    if ([extraInfo isKindOfClass:[NSDictionary class]] && [placementID isKindOfClass:[NSString class]] && [requestID isKindOfClass:[NSString class]]) {
        [_extraInfoAccessor writeWithBlock:^{
            _extraInfo[placementID] = @{requestIDKey:requestID, extraInfoKey:extraInfo};
        }];
    }
}

-(void) removeExtraInfoForPlacementID:(NSString*)placementID requestID:(NSString*)requestID {
    if ([placementID isKindOfClass:[NSString class]] && [requestID isKindOfClass:[NSString class]]) {
        [_extraInfoAccessor writeWithBlock:^{
            [_extraInfo removeObjectForKey:placementID];
        }];
    }
}

/*
 *Internal method, invoked by the various storage managers.
 */

-(BOOL) adReadyForPlacementID:(NSString*)placementID caller:(ATAdManagerReadyAPICaller)caller context:(BOOL(^)(NSDictionary *__autoreleasing *extra))context {
    return [[ATAdManager sharedManager] adReadyForPlacementID:placementID scene:nil caller:caller context:context];
}

-(BOOL) adReadyForPlacementID:(NSString*)placementID scene:(NSString*)scene caller:(ATAdManagerReadyAPICaller)caller context:(BOOL(^)(NSDictionary *__autoreleasing *extra))context {
    if ([placementID isKindOfClass:[NSString class]] && [placementID length] > 0) {
        ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
        NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithDictionary:@{kAdStorageExtraPlacementIDKey:placementID,
                                                                                         kAdStorageExtraRequestIDKey:@"",
                                                                                         kAdStorageExtraPSIDKey:[placementModel.psID length] > 0 ? placementModel.psID : @"",
                                                                                         kAdStorageExtraSessionIDKey:[placementModel.sessionID length] > 0 ? placementModel.sessionID : @"",
                                                                                         kAgentEventExtraInfoCallerInfoKey:@(caller)
                                                                                         }];
        NSString *latestRequestID = [[ATPlacementSettingManager sharedManager] latestRequestIDForPlacementID:placementID];
        NSInteger latestRequestIDDifferFlag = 1;
        BOOL ready = NO;
        if (placementModel != nil) {
            if ([ATCapsManager validateCapsForPlacementModel:placementModel]) {
                if ([ATCapsManager validatePacingForPlacementModel:placementModel]) {
                    NSDictionary *extra = nil;
                    ready = context(&extra);
                    if ([extra[kAdStorageExtraRequestIDKey] isKindOfClass:[NSString class]]) { latestRequestIDDifferFlag = ![latestRequestID isEqualToString:extra[kAdStorageExtraRequestIDKey]]; }
                    if (extra[kAdStorageExtraRequestIDKey] != nil) { extraInfo[kAdStorageExtraRequestIDKey] = extra[kAdStorageExtraRequestIDKey]; }
                    if (!ready && extra[kAdStorageExtraNotReadyReasonKey] != nil) { extraInfo[kAgentEventExtraInfoNotReadyReasonKey] = extra[kAdStorageExtraNotReadyReasonKey]; }
                    if (extra[kAdStorageExtraUnitGroupInfosKey] != nil) { extraInfo[kAdStorageExtraUnitGroupInfosKey] = extra[kAdStorageExtraUnitGroupInfosKey]; }
                    if (extra[kAdStorageExtraNetworkFirmIDKey] != nil) { extraInfo[kAdStorageExtraNetworkFirmIDKey] = extra[kAdStorageExtraNetworkFirmIDKey]; }
                    if (extra[kAdStoreageExtraUnitGroupUnitID] != nil) { extraInfo[kAdStoreageExtraUnitGroupUnitID] = extra[kAdStoreageExtraUnitGroupUnitID]; }
                    if (extra[kAdStorageExtraHeaderBiddingInfo] != nil) { extraInfo[kAdStorageExtraHeaderBiddingInfo] = extra[kAdStorageExtraHeaderBiddingInfo]; }
                    if (extra[kAdStorageExtraNetworkSDKVersion] != nil) { extraInfo[kAdStorageExtraNetworkSDKVersion] = extra[kAdStorageExtraNetworkSDKVersion]; }
                    if (extra[kAdStorageExtraPriorityKey] != nil) { extraInfo[kAdStorageExtraPriorityKey] = extra[kAdStorageExtraPriorityKey]; }
                    if (extra[kATTrackerExtraAppIDKey] != nil) { extraInfo[kATTrackerExtraAppIDKey] = extra[kATTrackerExtraAppIDKey]; }
                    if (extra[kAdLoadingExtraFilledByReadyFlagKey] != nil) { extraInfo[kAdLoadingExtraFilledByReadyFlagKey] = extra[kAdLoadingExtraFilledByReadyFlagKey]; }
                    if (extra[kAdLoadingExtraAutoLoadOnCloseFlagKey] != nil) { extraInfo[kAdLoadingExtraAutoLoadOnCloseFlagKey] = extra[kAdLoadingExtraAutoLoadOnCloseFlagKey]; }
                    if (extra[kATTrackerExtraRefreshFlagKey] != nil) { extraInfo[kATTrackerExtraRefreshFlagKey] = extra[kATTrackerExtraRefreshFlagKey]; }
                    if (extra[kAgentEventExtraInfoMyOfferDefaultFlagKey] != nil) { extraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey] = extra[kAgentEventExtraInfoMyOfferDefaultFlagKey]; }
                    if ([extra[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey] boolValue]) { extraInfo[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey] = extra[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey]; }
                    if (extra[kATTrackerExtraAdObjectKey] != nil) { extraInfo[kATTrackerExtraAdObjectKey] = extra[kATTrackerExtraAdObjectKey]; }
                } else {//Logically, control currently will never reach this point
                    extraInfo[kAgentEventExtraInfoNotReadyReasonKey] = @3;
                    ready = NO;
                }
            } else {//Logically, Control currently will never reach this point
                extraInfo[kAgentEventExtraInfoNotReadyReasonKey] = @2;
                ready = NO;
            }
        } else {
            extraInfo[kAgentEventExtraInfoNotReadyReasonKey] = @4;
            ready = NO;
        }
        
        extraInfo[kAdStorageExtraReadyFlagKey] = @(ready ? 1 : 0);
        if (ready && caller == ATAdManagerReadyAPICallerShow) {
            NSMutableDictionary *trackingInfo = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraUnitIDKey:extraInfo[kAdStoreageExtraUnitGroupUnitID] != nil ? extraInfo[kAdStoreageExtraUnitGroupUnitID] : @"",
                                                                                                kATTrackerExtraNetworkFirmIDKey:extraInfo[kAdStorageExtraNetworkFirmIDKey] != nil ? extraInfo[kAdStorageExtraNetworkFirmIDKey] : @(0),
                                                                                                kATTrackerExtraASResultKey:extraInfo[kAdStorageExtraUnitGroupInfosKey] != nil ?
                                                                                                extraInfo[kAdStorageExtraUnitGroupInfosKey] : @[]}];
            if ([extraInfo[kAdStorageExtraHeaderBiddingInfo] isKindOfClass:[NSDictionary class]]) { trackingInfo[kATTrackerExtraHeaderBiddingInfoKey] = extraInfo[kAdStorageExtraHeaderBiddingInfo]; }
            if (extraInfo[kATTrackerExtraAppIDKey] != nil) { trackingInfo[kATTrackerExtraAppIDKey] = extraInfo[kATTrackerExtraAppIDKey]; }
            if (latestRequestID != nil) { trackingInfo[kATTrackerExtraLastestRequestIDKey] = latestRequestID; }
            trackingInfo[kATTrackerExtraLastestRequestIDMatchFlagKey] = @(latestRequestIDDifferFlag);
            if ([extraInfo[kAdLoadingExtraFilledByReadyFlagKey] boolValue]) { trackingInfo[kATTrackerExtraAdFilledByReadyFlagKey] = @YES; }
            if ([extraInfo[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]) { trackingInfo[kATTrackerExtraAutoloadOnCloseFlagKey] = @YES; }
            if ([extraInfo[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey] boolValue]) { trackingInfo[kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey] = @YES; }
            if (extraInfo[kATTrackerExtraRefreshFlagKey] != nil) { trackingInfo[kATTrackerExtraRefreshFlagKey] = extraInfo[kATTrackerExtraRefreshFlagKey]; }
            if (extraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey] != nil) { trackingInfo[kATTrackerExtraMyOfferDefaultFalgKey] = extraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey]; }
            if (extraInfo[kATTrackerExtraAdObjectKey] != nil) { trackingInfo[kATTrackerExtraAdObjectKey] = extraInfo[kATTrackerExtraAdObjectKey]; }
            if (scene != nil) { trackingInfo[kATTrackerExtraAdShowSceneKey] = scene; }
            [[ATTracker sharedTracker] trackWithPlacementID:placementID requestID:extraInfo[kAdStorageExtraRequestIDKey] trackType:ATNativeAdTrackTypeShowAPICall extra:trackingInfo];
        } else {
            //agent event
            NSMutableDictionary *agentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:@{kAgentEventExtraInfoReadyFlagKey:@(ready ? 1 : 0), kAgentEventExtraInfoASResultKey:extraInfo[kAdStorageExtraUnitGroupInfosKey] != nil ? extraInfo[kAdStorageExtraUnitGroupInfosKey] : @[]}];
            if (latestRequestID != nil) { agentEventExtraInfo[kAgentEventExtraInfoLatestRequestIDKey] = latestRequestID; }
            agentEventExtraInfo[kAgentEventExtraInfoLatestRequestIDDifferFlagKey] = @(latestRequestIDDifferFlag);
            if (extraInfo[kAdStorageExtraRequestIDKey] != nil) { agentEventExtraInfo[kAgentEventExtraInfoRequestIDKey] = extraInfo[kAdStorageExtraRequestIDKey]; }
            if (extraInfo[kAgentEventExtraInfoNotReadyReasonKey] != nil) { agentEventExtraInfo[kAgentEventExtraInfoNotReadyReasonKey] = extraInfo[kAgentEventExtraInfoNotReadyReasonKey]; }
            if (extraInfo[kAdStorageExtraNetworkFirmIDKey] != nil) { agentEventExtraInfo[kAgentEventExtraInfoNetworkFirmIDKey] = extraInfo[kAdStorageExtraNetworkFirmIDKey]; }
            if (extraInfo[kAdStoreageExtraUnitGroupUnitID] != nil) { agentEventExtraInfo[kAgentEventExtraInfoUnitGroupUnitIDKey] = extraInfo[kAdStoreageExtraUnitGroupUnitID]; }
            if (extraInfo[kAdStorageExtraNetworkSDKVersion] != nil) { agentEventExtraInfo[kAgentEventExtraInfoNetworkSDKVersionKey] = extraInfo[kAdStorageExtraNetworkSDKVersion]; }
            if (extraInfo[kAdStorageExtraPriorityKey] != nil) { agentEventExtraInfo[kAgentEventExtraInfoPriorityKey] = extraInfo[kAdStorageExtraPriorityKey]; }
            if (extraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey] != nil) { agentEventExtraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey] = extraInfo[kAgentEventExtraInfoMyOfferDefaultFlagKey]; }
            agentEventExtraInfo[kAgentEventExtraInfoAdFilledByReadyFlagKey] = @([extraInfo[kAdLoadingExtraFilledByReadyFlagKey] boolValue] ? 1 : 0);
            agentEventExtraInfo[kAgentEventExtraInfoAutoloadOnCloseFlagKey] = @([extraInfo[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0);
            //Add failed hb adsource
            if (!ready && extraInfo[kAdStorageExtraRequestIDKey] != nil) {
                NSArray<ATUnitGroupModel*>* sortedAdSource = [placementModel unitGroupsForRequestID:extraInfo[kAdStorageExtraRequestIDKey]];
                NSMutableArray<NSDictionary*>* adsourceResults = [NSMutableArray<NSDictionary*> array];
                if ([extraInfo[kAdStorageExtraUnitGroupInfosKey] isKindOfClass:[NSArray class]]) { [adsourceResults addObjectsFromArray:extraInfo[kAdStorageExtraUnitGroupInfosKey]]; }
                
                NSMutableArray<ATUnitGroupModel*>* hbAdSource = [NSMutableArray arrayWithArray:placementModel.headerBiddingUnitGroups];
                [hbAdSource removeObjectsInArray:sortedAdSource];
                [hbAdSource enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSInteger adsourceNotReadyReason = 0;
                    if ([ATAdStorageUtility validateCapsForUnitGroup:obj placementID:placementID]) {
                        if ([ATAdStorageUtility validatePacingForUnitGroup:obj placementID:placementID]) {
                            adsourceNotReadyReason = 5;//bid request failed
                        } else {//pacing
                            adsourceNotReadyReason = 3;
                        }
                    } else {//caps
                        adsourceNotReadyReason = 2;
                    }
                    [adsourceResults addObject:@{kAdStorageExtraUnitGroupInfoPriorityKey:@-1,
                                                 kAdStorageExtraUnitGroupInfoUnitIDKey:obj.unitID != nil ? obj.unitID : @"",
                                                 kAdStorageExtraUnitGroupInfoNetworkFirmIDKey:@(obj.networkFirmID),
                                                 kAdStorageExtraUnitGroupInfoNetworkSDKVersionKey:[[ATAPI sharedInstance] versionForNetworkFirmID:obj.networkFirmID],
                                                 kAdStorageExtraUnitGroupInfoReadyFlagKey:@0,
                                                 kAdStorageExtraNotReadyReasonKey:@(adsourceNotReadyReason)
                                                 }];
                }];
                
                //Add caped/pacinged adsource for header bidding
                if ([placementModel.headerBiddingUnitGroups count] > 0) {
                    NSMutableArray<ATUnitGroupModel*>* adSources = [NSMutableArray<ATUnitGroupModel*> arrayWithArray:placementModel.unitGroups];
                    [adSources removeObjectsInArray:sortedAdSource];
                    [adSources enumerateObjectsUsingBlock:^(ATUnitGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSInteger adsourceNotReadyReason = 0;
                        if ([ATAdStorageUtility validateCapsForUnitGroup:obj placementID:placementID]) {
                            if ([ATAdStorageUtility validatePacingForUnitGroup:obj placementID:placementID]) {
//                                adsourceNotReadyReason = 5;//bid request failed
                            } else {//pacing
                                adsourceNotReadyReason = 3;
                            }
                        } else {//caps
                            adsourceNotReadyReason = 2;
                        }
                        [adsourceResults addObject:@{kAdStorageExtraUnitGroupInfoPriorityKey:@-1,
                                                     kAdStorageExtraUnitGroupInfoUnitIDKey:obj.unitID != nil ? obj.unitID : @"",
                                                     kAdStorageExtraUnitGroupInfoNetworkFirmIDKey:@(obj.networkFirmID),
                                                     kAdStorageExtraUnitGroupInfoNetworkSDKVersionKey:[[ATAPI sharedInstance] versionForNetworkFirmID:obj.networkFirmID],
                                                     kAdStorageExtraUnitGroupInfoReadyFlagKey:@0,
                                                     kAdStorageExtraNotReadyReasonKey:@(adsourceNotReadyReason)
                                                     }];
                    }];
                }
                
                if ([adsourceResults count] > 0) { agentEventExtraInfo[kAgentEventExtraInfoASResultKey] = adsourceResults; }
            }
            
            [[ATAgentEvent sharedAgent] saveEventWithKey:caller == ATAdManagerReadyAPICallerShow ? kATAgentEventKeyShowFail : kATAgentEventKeyReady placementID:placementID unitGroupModel:nil extraInfo:agentEventExtraInfo];
        }
        if (!ready) { [[ATPlacementSettingManager sharedManager] setStatus:ready forPlacementID:placementID]; }
        return ready;
    } else {
        [ATLogger logError:[NSString stringWithFormat:@"Invalid placementID encountered:%@", placementID] type:ATLogTypeExternal];
        return NO;
    }
}

-(BOOL) adReadyForPlacementID:(NSString*)placementID {
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    if (placementModel.format == ATAdFormatNative) {
        return [[ATAdManager sharedManager] respondsToSelector:@selector(nativeAdReadyForPlacementID:)] ? [[ATAdManager sharedManager] nativeAdReadyForPlacementID:placementID] : NO;
    } else if (placementModel.format == ATAdFormatRewardedVideo) {
        return [[ATAdManager sharedManager] respondsToSelector:@selector(rewardedVideoReadyForPlacementID:)] ? [[ATAdManager sharedManager] rewardedVideoReadyForPlacementID:placementID] : NO;
    } else if (placementModel.format == ATAdFormatInterstitial) {
        return [[ATAdManager sharedManager] respondsToSelector:@selector(interstitialReadyForPlacementID:)] ? [[ATAdManager sharedManager] interstitialReadyForPlacementID:placementID] : NO;
    } else if (placementModel.format == ATAdFormatBanner) {
        return [[ATAdManager sharedManager] respondsToSelector:@selector(bannerAdReadyForPlacementID:)] ? [[ATAdManager sharedManager] bannerAdReadyForPlacementID:placementID] : NO;
    } else if (placementModel.format == ATAdFormatSplash) {
        return NO;
    } else {
        return NO;
    }
}

-(void) clearCacheWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel {
    [[NSClassFromString(@{@(ATAdFormatNative):@"ATNativeADOfferManager",
                          @(ATAdFormatRewardedVideo):@"ATRewardedVideoManager",
                          @(ATAdFormatInterstitial):@"ATInterstitialManager",
                          @(ATAdFormatBanner):@"ATBannerManager",
                          @(ATAdFormatSplash):@"ATSplashManager"}
                        [@(placementModel.format)]) sharedManager] removeAdForPlacementID:placementModel.placementID unitGroupID:unitGroupModel.unitGroupID];
}
@end

static NSString *const kDelegateToPassedKey = @"delegate_to_be_passed";
@implementation NSObject(DelegateBinding)
-(void)setDelegateToBePassed:(id)delegateToBePassed {
    objc_setAssociatedObject(self, (__bridge_retained void*)kDelegateToPassedKey, delegateToBePassed, OBJC_ASSOCIATION_ASSIGN);
}

-(id)delegateToBePassed {
    return objc_getAssociatedObject(self, (__bridge_retained void*)kDelegateToPassedKey);
}
@end
