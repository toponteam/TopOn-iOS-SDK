//
//  ATRewardedVideoCustomEvent.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATRewardedVideoCustomEvent.h"
#import "ATAgentEvent.h"
#import "ATTracker.h"
#import "ATCapsManager.h"
#import "ATAdAdapter.h"
#import "ATGeneralAdAgentEvent.h"
#import "Utilities.h"
#import "ATLoadingScheduler.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"
#import "ATPlacementModel.h"
#import "ATRewardedVideoManager.h"
#import "ATFBBiddingManager.h"
#import "ATAdManager+RewardedVideo.h"

@interface ATRewardedVideoCustomEvent()

@end
@implementation ATRewardedVideoCustomEvent
-(NSDictionary*)delegateExtra {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@([self.ad.ecpm doubleValue]), kATADDelegateExtraECPMLevelKey:@(self.rewardedVideo.unitGroup.ecpmLevel), kATADDelegateExtraSegmentIDKey:@(self.rewardedVideo.placementModel.groupID)}];
    if (self.rewardedVideo.scene != nil) { extra[kATADDelegateExtraScenarioIDKey] = self.rewardedVideo.scene; }
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([self.rewardedVideo.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.rewardedVideo.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@_%@_%@",self.rewardedVideo.requestID,self.rewardedVideo.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = extraID;
    extra[kATADDelegateExtraAdunitIDKey] = self.rewardedVideo.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @([self.rewardedVideo.ecpm doubleValue] / 1000.f);
    extra[kATADDelegateExtraCurrencyKey] = self.rewardedVideo.placementModel.currency;
    extra[kATADDelegateExtraCountryKey] = self.rewardedVideo.placementModel.callback[@"cc"];
    extra[kATADDelegateExtraFormatKey] = @"RewardedVideo";
    extra[kATADDelegateExtraPrecisionKey] = self.rewardedVideo.unitGroup.precision;
    extra[kATADDelegateExtraNetworkTypeKey] = self.rewardedVideo.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
    if (self.rewardedVideo.placementModel.callback[@"sc_list"][self.rewardedVideo.scene] != nil) {
        NSString *rwName = self.rewardedVideo.placementModel.callback[@"sc_list"][self.rewardedVideo.scene][@"rw_n"];
        NSString *rwNum = self.rewardedVideo.placementModel.callback[@"sc_list"][self.rewardedVideo.scene][@"rw_num"];
        if ([rwName length] > 0 && rwNum != nil) {
            extra[kATADDelegateExtraScenarioRewardNameKey] = rwName;
            extra[kATADDelegateExtraScenarioRewardNumberKey] = rwNum;
        }
    } else {
        if (self.rewardedVideo.placementModel.callback[@"reward"] != nil) {
            NSString *rwName = self.rewardedVideo.placementModel.callback[@"reward"][@"rw_n"];
            NSString *rwNum = self.rewardedVideo.placementModel.callback[@"reward"][@"rw_num"];
            if ([rwName length] > 0 && rwNum != nil) {
                extra[self.rewardedVideo.scene != nil ? kATADDelegateExtraScenarioRewardNameKey : kATADDelegateExtraPlacementRewardNameKey] = rwName;
                extra[self.rewardedVideo.scene != nil ? kATADDelegateExtraScenarioRewardNumberKey : kATADDelegateExtraPlacementRewardNumberKey] = rwNum;
            }
        }
    }
    
    //add adsource unit_id value
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.networkUnitId != nil ? self.networkUnitId:@"";
    if ([self.networkCustomInfo count] > 0) {
        extra[kATADDelegateExtraExtInfoKey] = self.networkCustomInfo;
    }
    [extra AT_setDictValue:self.localInfo[kATAdLoadingExtraMediaExtraKey] key:kATADDelegateExtraRVUserCustomData];
    return extra;
}

-(void) trackRewardedVideoAdPlayEventWithError:(NSError*)error {
    if (self.rewardedVideo != nil) {
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFailToPlay placementID:self.rewardedVideo.placementModel.placementID unitGroupModel:self.rewardedVideo.unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.rewardedVideo.requestID != nil ? self.rewardedVideo.requestID : @"", kAgentEventExtraInfoNetworkFirmIDKey:@(self.rewardedVideo.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.rewardedVideo.priority), kAgentEventExtraInfoNetworkErrorCodeKey:@(error.code), kAgentEventExtraInfoNetworkErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
    }
     if ([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForPlacementID:error:extra:)]) { [self.delegate rewardedVideoDidFailToPlayForPlacementID:self.rewardedVideo.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

-(void) handleClose {
    [super handleClose];
    if (self.rewardedVideo != nil) {
        if (self.rewardedVideo.placementModel.autoRefresh) {
            NSMutableDictionary *loadInfoExtra = [NSMutableDictionary dictionary];
            if ([self.localInfo isKindOfClass:[NSDictionary class]] && [Utilities isEmpty:self.localInfo] == NO) {
                [loadInfoExtra addEntriesFromDictionary:self.localInfo];
            }
            loadInfoExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] = @(YES);
            [[ATAdManager sharedManager]loadADWithPlacementID:self.rewardedVideo.placementModel.placementID extra:loadInfoExtra delegate:nil];
        }
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyClose placementID:self.rewardedVideo.placementModel.placementID unitGroupModel:nil
                                               extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.rewardedVideo.requestID != nil ? self.rewardedVideo.requestID:@"",
                                                   kAgentEventExtraInfoNetworkFirmIDKey:@(self.rewardedVideo.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.rewardedVideo.priority), kAgentEventExtraInfoRewardFlagKey:@(self.rewardGranted ? 1 : 0), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
        NSDate *date = [NSDate date];
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAdShowDurationKey placementID:self.rewardedVideo.placementModel.placementID unitGroupModel:nil
        extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.rewardedVideo.requestID != nil ? self.rewardedVideo.requestID:@"",
                    kAgentEventExtraInfoFormatKey:@(self.rewardedVideo.placementModel.format),
                    kAgentEventExtraInfoShowTimestampKey:@((NSInteger)([self.showDate timeIntervalSince1970] * 1000.0f)),
                    kAgentEventExtraInfoCloseTimestampKey:@((NSInteger)([date timeIntervalSince1970] * 1000.0f)),
                    kAgentEventExtraInfoShowDurationKey:@((NSInteger)([date timeIntervalSinceDate:self.showDate] * 1000.0f)),
                    kAgentEventExtraInfoNetworkFirmIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),
                    kAgentEventExtraInfoAdSourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"",
                    kAgentEventExtraInfoPriorityKey:@(self.rewardedVideo.priority),
                    kAgentEventExtraInfoMyOfferDefaultFlagKey:@(self.rewardedVideo.defaultPlayIfRequired ? 1 : 0),
                    kAgentEventExtraInfoRewardFlagKey:@(self.rewardGranted ? 1 : 0)
        }];
    }
}

-(void) trackRewardedVideoAdCloseRewarded:(BOOL)rewarded {
    
    [self handleClose];
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForPlacementID:rewarded:extra:)]) {
        [self.delegate rewardedVideoDidCloseForPlacementID:self.rewardedVideo.placementModel.placementID rewarded:self.rewardGranted extra:[self delegateExtra]];
    }
}

-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

-(id<ATAd>) ad {
    return self.rewardedVideo;
}

-(void) trackRewardedVideoAdShow {
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.ad.placementModel unitGroup:self.ad.unitGroup requestID:self.ad.requestID];
//    self.sdkTime = [Utilities normalizedTimeStamp];
    NSMutableDictionary *generalAdAgentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:self.ad.placementModel unitGroupModel:self.ad.unitGroup requestID:self.ad.requestID]];
    [generalAdAgentEventExtraInfo addEntriesFromDictionary:self.localInfo != nil ? self.localInfo : @{}];
    generalAdAgentEventExtraInfo[kGeneralAdAgentEventExtraInfoAutoRequestFlagKey] = [self.localInfo[kAdLoadingExtraAutoloadFlagKey] boolValue] ? @"1" : @"0";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.rewardedVideo event:ATGeneralAdAgentEventTypeImpression extra:nil error:nil]] type:ATLogTypeTemporary];
    [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.rewardedVideo.placementModel.placementID unitGroupID:self.rewardedVideo.unitGroup.unitGroupID requestID:self.rewardedVideo.requestID];
    [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.rewardedVideo.placementModel.placementID unitGroupID:self.rewardedVideo.unitGroup.unitGroupID];
    NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.rewardedVideo requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey,self.sdkTime,kATTrackerExtraAdShowSDKTimeKey, nil];
    if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
    if (self.rewardedVideo.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    if([ATAPI isOfm]){
        trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
        trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
    }
    [[ATTracker sharedTracker] trackWithPlacementID:self.rewardedVideo.placementModel.placementID requestID:self.rewardedVideo.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
    
    [Utilities reportProfit:self.rewardedVideo time:self.sdkTime];
    [[ATFBBiddingManager sharedManager] notifyDisplayWinnerWithID:self.rewardedVideo.unitGroup.unitID placementID:self.rewardedVideo.placementModel.placementID];
}

-(void) trackRewardedVideoAdClick {
    if (self.rewardedVideo != nil) {
        [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.rewardedVideo event:ATGeneralAdAgentEventTypeClick extra:nil error:nil]] type:ATLogTypeTemporary];
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.rewardedVideo requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
        if (self.rewardedVideo.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        if([ATAPI isOfm]){
            trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey];
            trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
        [[ATTracker sharedTracker] trackClickWithAd:self.ad extra:trackingExtra];

    }
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidClickForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(void) trackRewardedVideoAdVideoStart {
    if (self.rewardedVideo != nil) {
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.rewardedVideo requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
        if (self.rewardedVideo.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        if([ATAPI isOfm]){
            trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
            trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
        [[ATTracker sharedTracker] trackWithPlacementID:self.rewardedVideo.placementModel.placementID requestID:self.rewardedVideo.requestID trackType:ATNativeAdTrackTypeVideoStart extra:trackingExtra];
    }
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForPlacementID:extra:)]) {
           [self.delegate rewardedVideoDidStartPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
       }
}

-(void) trackRewardedVideoAdVideoEnd {
    if (self.rewardedVideo != nil) {
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.rewardedVideo requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
        if (self.rewardedVideo.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        if([ATAPI isOfm]){
            trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
            trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
        [[ATTracker sharedTracker] trackWithPlacementID:self.rewardedVideo.placementModel.placementID requestID:self.rewardedVideo.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
    }
    
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForPlacementID:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super initWithUnitID:self.networkUnitId serverInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        self.requestNumber = 1;
        _unitID = self.networkUnitId;
        _userID = [[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)serverInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:serverInfo[kAdapterCustomInfoRequestIDKey]][@"userID"];

    }
    return self;
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}

-(void) trackRewardedVideoAdLoadFailed:(NSError*)error {
    [self handleLoadingFailure:error];
}
-(void) trackRewardedVideoAdLoaded:(id)adObject adExtra:(NSDictionary *)adExtra {
    NSMutableDictionary *assets;
    if(adExtra != nil){
        assets = [NSMutableDictionary dictionaryWithDictionary:adExtra];
    }else{
        assets = [NSMutableDictionary dictionary];
    }
    
    if(adObject != nil){
        assets[kAdAssetsCustomObjectKey] = adObject;
    }
    assets[kRewardedVideoAssetsCustomEventKey] = self;
    if ([self.unitID length] > 0) assets[kRewardedVideoAssetsUnitIDKey] = self.networkUnitId;
    [self handleAssets:assets];
}

-(void) trackRewardedVideoAdRewarded {
    self.rewardGranted = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForPlacemenID:extra:)]){
        [self.delegate rewardedVideoDidRewardSuccessForPlacemenID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra]];
    }
}

- (void)trackRewardedVideoAdDeeplinkOrJumpResult:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidDeepLinkOrJumpForPlacementID:extra:result:)]) {
        [self.delegate rewardedVideoDidDeepLinkOrJumpForPlacementID:self.rewardedVideo.placementModel.placementID extra:[self delegateExtra] result:success];
    }
}
@end
