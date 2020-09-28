//
//  ATInterstitialCustomEvent.m
//  AnyThinkInterstitial
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATTracker.h"
#import "ATCapsManager.h"
#import "ATAdAdapter.h"
#import "ATGeneralAdAgentEvent.h"
#import "Utilities.h"
#import "ATLoadingScheduler.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"
#import "ATInterstitialManager.h"

@implementation ATInterstitialCustomEvent
-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super initWithUnitID:self.networkUnitId serverInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        self.requestNumber = 1;
        _unitID = self.networkUnitId;
    }
    return self;
}

-(NSDictionary*)delegateExtra {
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.price), kATADDelegateExtraECPMLevelKey:@(self.interstitial.unitGroup.ecpmLevel), kATADDelegateExtraSegmentIDKey:@(self.interstitial.placementModel.groupID)}];
    if (self.interstitial.scene != nil) { extra[kATADDelegateExtraScenarioIDKey] = self.interstitial.scene; }
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([self.interstitial.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.interstitial.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@%@%@",self.interstitial.requestID,self.interstitial.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = [extraID md5];
    extra[kATADDelegateExtraAdunitIDKey] = self.interstitial.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @(self.interstitial.price / 1000.0f);
    extra[kATADDelegateExtraCurrencyKey] = self.interstitial.placementModel.callback[@"currency"];
    extra[kATADDelegateExtraCountryKey] = self.interstitial.placementModel.callback[@"cc"];
    extra[kATADDelegateExtraFormatKey] = @"Interstitial";
    extra[kATADDelegateExtraPrecisionKey] = self.interstitial.unitGroup.precision;
    extra[kATADDelegateExtraNetworkTypeKey] = self.interstitial.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
    
    //add adsource unit_id value
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.networkUnitId != nil ? self.networkUnitId:@"";
    return extra;
}

-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeUnknown;
}

-(void) trackInterstitialAdLoaded:(id)interstitialAd adExtra:(NSDictionary *)adExtra {
    NSMutableDictionary *assets;
    if(adExtra != nil){
        assets = [NSMutableDictionary dictionaryWithDictionary:adExtra];
    }else{
        assets = [NSMutableDictionary dictionary];
    }
    if(interstitialAd != nil){
        assets[kAdAssetsCustomObjectKey] = interstitialAd;
    }
    assets[kInterstitialAssetsCustomEventKey] = self;
    if ([self.unitID length] > 0) assets[kInterstitialAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

-(void) trackInterstitialAdLoadFailed:(NSError*)error {
     [self handleLoadingFailure:error];
}

- (void)trackInterstitialAdClose {
    [self handleClose];
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) { [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
}

-(void) handleClose {
    [super handleClose];
    if (self.interstitial != nil) {
        if (self.interstitial.placementModel.autoRefresh) {
            [[ATAdManager sharedManager]loadADWithPlacementID:self.interstitial.placementModel.placementID extra:@{kAdLoadingExtraAutoLoadOnCloseFlagKey:@YES} delegate:nil];
        }
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyClose placementID:self.interstitial.placementModel.placementID unitGroupModel:nil
                                               extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.interstitial.requestID != nil ? self.interstitial.requestID : @"", kAgentEventExtraInfoNetworkFirmIDKey:@(self.interstitial.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.interstitial.priority), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
        NSDate *date = [NSDate date];
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyAdShowDurationKey placementID:self.interstitial.placementModel.placementID unitGroupModel:nil
        extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.interstitial.requestID != nil ? self.interstitial.requestID:@"",
                    kAgentEventExtraInfoFormatKey:@(self.interstitial.placementModel.format),
                    kAgentEventExtraInfoShowTimestampKey:@((NSInteger)([self.showDate timeIntervalSince1970] * 1000.0f)),
                    kAgentEventExtraInfoCloseTimestampKey:@((NSInteger)([date timeIntervalSince1970] * 1000.0f)),
                    kAgentEventExtraInfoShowDurationKey:@((NSInteger)([date timeIntervalSinceDate:self.showDate] * 1000.0f)),
                    kAgentEventExtraInfoNetworkFirmIDKey:@(self.interstitial.unitGroup.networkFirmID),
                    kAgentEventExtraInfoAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",
                    kAgentEventExtraInfoPriorityKey:@(self.interstitial.priority),
                    kAgentEventExtraInfoMyOfferDefaultFlagKey:@(self.interstitial.defaultPlayIfRequired ? 1 : 0),
                    kAgentEventExtraInfoRewardFlagKey:@0
        }];
    }
}

-(void) trackInterstitialAdVideoStart {
    if (self.interstitial != nil) {
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.interstitial requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
        if (self.interstitial.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeAdTrackTypeVideoStart extra:trackingExtra];
        
        if ([self.delegate respondsToSelector:@selector(interstitialDidStartPlayingVideoForPlacementID:extra:)]) { [self.delegate interstitialDidStartPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

-(void) trackInterstitialAdVideoEnd {
    if (self.interstitial != nil) {
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.interstitial requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
        if (self.interstitial.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
        
        if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
            [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(void) trackInterstitialAdDidFailToPlayVideo:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
        [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

-(void) trackInterstitialAdShow {
    if (self.interstitial != nil) {
        [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.interstitial.placementModel unitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID];
        [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.interstitial event:ATGeneralAdAgentEventTypeImpression extra:self.localInfo error:nil]] type:ATLogTypeTemporary];
        [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.interstitial.placementModel.placementID unitGroupID:self.interstitial.unitGroup.unitGroupID requestID:self.interstitial.requestID];
        [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.interstitial.placementModel.placementID unitGroupID:self.interstitial.unitGroup.unitGroupID];
        self.sdkTime = [Utilities normalizedTimeStamp];
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.interstitial requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey,self.sdkTime,kATTrackerExtraAdShowSDKTimeKey, nil];
        
        if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
        if (self.interstitial.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
        
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]]; }
    }
}

- (void)trackInterstitialAdShowFailed:(NSError *)error {
    
}

-(void) trackInterstitialAdClick {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.interstitial event:ATGeneralAdAgentEventTypeClick extra:self.localInfo error:nil]] type:ATLogTypeTemporary];
    
    NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.interstitial requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
    if (self.interstitial.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    [[ATTracker sharedTracker] trackClickWithAd:self.ad extra:trackingExtra];
    
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}
@end
