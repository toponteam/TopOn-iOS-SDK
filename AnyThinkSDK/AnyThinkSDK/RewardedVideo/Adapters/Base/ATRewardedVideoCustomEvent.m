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
@interface ATRewardedVideoCustomEvent()

@end
@implementation ATRewardedVideoCustomEvent
-(NSDictionary*)delegateExtra {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATRewardedVideoCallbackExtraAdsourceIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kATRewardedVideoCallbackExtraNetworkIDKey:@(self.rewardedVideo.unitGroup.networkFirmID),kATRewardedVideoCallbackExtraIsHeaderBidding:@(self.rewardedVideo.unitGroup.headerBidding),kATRewardedVideoCallbackExtraPriority:@(self.priorityIndex),kATRewardedVideoCallbackExtraPrice:@(self.rewardedVideo.unitGroup.price), kATADDelegateExtraECPMLevelKey:@(self.rewardedVideo.unitGroup.ecpmLevel), kATADDelegateExtraSegmentIDKey:@(self.rewardedVideo.placementModel.groupID)}];
    if (self.rewardedVideo.scene != nil) { extra[kATADDelegateExtraScenarioIDKey] = self.rewardedVideo.scene; }
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([self.rewardedVideo.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.rewardedVideo.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@%@%@",self.rewardedVideo.requestID,self.rewardedVideo.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = [extraID md5];
    extra[kATADDelegateExtraAdunitIDKey] = self.rewardedVideo.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @(self.rewardedVideo.unitGroup.price / 1000.0f);
    extra[kATADDelegateExtraCurrencyKey] = self.rewardedVideo.placementModel.callback[@"currency"];
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
    return extra;
}

-(void) saveVideoPlayEventWithError:(NSError*)error {
    if (self.rewardedVideo != nil) {
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFailToPlay placementID:self.rewardedVideo.placementModel.placementID unitGroupModel:self.rewardedVideo.unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.rewardedVideo.requestID != nil ? self.rewardedVideo.requestID : @"", kAgentEventExtraInfoNetworkFirmIDKey:@(self.rewardedVideo.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.rewardedVideo.unitGroup.unitID != nil ? self.rewardedVideo.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.rewardedVideo.priority), kAgentEventExtraInfoNetworkErrorCodeKey:@(error.code), kAgentEventExtraInfoNetworkErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
    }
}

-(void) handleClose {
    [super handleClose];
    if (self.rewardedVideo != nil) {
        if (self.rewardedVideo.placementModel.autoRefresh) {
            [[ATAdManager sharedManager]loadADWithPlacementID:self.rewardedVideo.placementModel.placementID extra:@{kAdLoadingExtraAutoLoadOnCloseFlagKey:@YES} delegate:nil];
        }
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
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

-(void) saveVideoCloseEventRewarded:(BOOL)rewarded {

}

-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

-(id<ATAd>) ad {
    return self.rewardedVideo;
}

-(void) trackShow {
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.ad.placementModel unitGroup:self.ad.unitGroup requestID:self.ad.requestID];
    self.sdkTime = [Utilities normalizedTimeStamp];
    NSMutableDictionary *generalAdAgentEventExtraInfo = [NSMutableDictionary dictionaryWithDictionary:[ATAgentEvent generalAdAgentInfoWithPlacementModel:self.ad.placementModel unitGroupModel:self.ad.unitGroup requestID:self.ad.requestID]];
    [generalAdAgentEventExtraInfo addEntriesFromDictionary:self.customInfo[kAdapterCustomInfoExtraKey] != nil ? self.customInfo[kAdapterCustomInfoExtraKey] : @{}];
    generalAdAgentEventExtraInfo[kGeneralAdAgentEventExtraInfoAutoRequestFlagKey] = [self.customInfo[kAdapterCustomInfoExtraKey][kAdLoadingExtraAutoloadFlagKey] boolValue] ? @"1" : @"0";
    [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.rewardedVideo event:ATGeneralAdAgentEventTypeImpression extra:nil error:nil]] type:ATLogTypeTemporary];
    [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.rewardedVideo.placementModel.placementID unitGroupID:self.rewardedVideo.unitGroup.unitGroupID requestID:self.rewardedVideo.requestID];
    [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.rewardedVideo.placementModel.placementID unitGroupID:self.rewardedVideo.unitGroup.unitGroupID];
    NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.rewardedVideo.unitGroup requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey,self.sdkTime,kATTrackerExtraAdShowSDKTimeKey, nil];
    if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
    [[ATTracker sharedTracker] trackWithPlacementID:self.rewardedVideo.placementModel.placementID requestID:self.rewardedVideo.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
}

-(void) trackClick {
    if (self.rewardedVideo != nil) {
        [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.rewardedVideo event:ATGeneralAdAgentEventTypeClick extra:nil error:nil]] type:ATLogTypeTemporary];
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.rewardedVideo.unitGroup requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
        [[ATTracker sharedTracker] trackClickWithAd:self.ad extra:trackingExtra];

    }
}

-(void) trackVideoStart {
    if (self.rewardedVideo != nil) {
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.rewardedVideo.unitGroup requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.rewardedVideo.placementModel.placementID requestID:self.rewardedVideo.requestID trackType:ATNativeAdTrackTypeVideoStart extra:trackingExtra];
    }
}

-(void) trackVideoEnd {
    if (self.rewardedVideo != nil) {
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.rewardedVideo.unitGroup requestID:self.rewardedVideo.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.rewardedVideo.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.rewardedVideo.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.rewardedVideo.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.rewardedVideo.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.rewardedVideo.scene; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.rewardedVideo.placementModel.placementID requestID:self.rewardedVideo.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
    }
}

-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        self.requestNumber = 1;
        _unitID = unitID;
        _userID = [[ATAdManager sharedManager] extraInfoForPlacementID:((ATPlacementModel*)customInfo[kAdapterCustomInfoPlacementModelKey]).placementID requestID:customInfo[kAdapterCustomInfoRequestIDKey]][@"userID"];

    }
    return self;
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}
@end
