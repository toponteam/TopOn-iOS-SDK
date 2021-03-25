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
#import "AppsFlyerLibProtocol.h"
#import "ATFBBiddingManager.h"

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
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@([self.interstitial.ecpm doubleValue]), kATADDelegateExtraECPMLevelKey:@(self.interstitial.unitGroup.ecpmLevel), kATADDelegateExtraSegmentIDKey:@(self.interstitial.placementModel.groupID)}];
    if (self.interstitial.scene != nil) { extra[kATADDelegateExtraScenarioIDKey] = self.interstitial.scene; }
    NSString *channel = [ATAPI sharedInstance].channel;
    if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
    NSString *subchannel = [ATAPI sharedInstance].subchannel;
    if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
    if ([self.interstitial.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.interstitial.placementModel.associatedCustomData; }
    NSString *extraID = [NSString stringWithFormat:@"%@_%@_%@",self.interstitial.requestID,self.interstitial.unitGroup.unitID,self.sdkTime];
    extra[kATADDelegateExtraIDKey] = extraID;
    extra[kATADDelegateExtraAdunitIDKey] = self.interstitial.placementModel.placementID;
    extra[kATADDelegateExtraPublisherRevenueKey] = @([self.interstitial.ecpm doubleValue] / 1000.f);
    extra[kATADDelegateExtraCurrencyKey] = self.interstitial.placementModel.currency;
    extra[kATADDelegateExtraCountryKey] = self.interstitial.placementModel.callback[@"cc"];
    extra[kATADDelegateExtraFormatKey] = @"Interstitial";
    extra[kATADDelegateExtraPrecisionKey] = self.interstitial.unitGroup.precision;
    extra[kATADDelegateExtraNetworkTypeKey] = self.interstitial.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
    
    //add adsource unit_id value
    extra[kATADDelegateExtraNetworkPlacementIDKey] = self.networkUnitId != nil ? self.networkUnitId:@"";
    if ([self.networkCustomInfo count] > 0) {
        extra[kATADDelegateExtraExtInfoKey] = self.networkCustomInfo;
    }
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
            NSMutableDictionary *loadInfoExtra = [NSMutableDictionary dictionary];
            if ([self.localInfo isKindOfClass:[NSDictionary class]] && [Utilities isEmpty:self.localInfo] == NO) {
                [loadInfoExtra addEntriesFromDictionary:self.localInfo];
            }
            loadInfoExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] = @(YES);
            [[ATAdManager sharedManager]loadADWithPlacementID:self.interstitial.placementModel.placementID extra:loadInfoExtra delegate:nil];
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

        if([ATAPI isOfm]){
            trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
            trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
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
        if([ATAPI isOfm]){
            trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
            trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
        }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
        
        if ([self.delegate respondsToSelector:@selector(interstitialDidEndPlayingVideoForPlacementID:extra:)]) {
            [self.delegate interstitialDidEndPlayingVideoForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
        }
    }
}

-(void) trackInterstitialAdDidFailToPlayVideo:(NSError*)error {
    if (self.interstitial != nil) {
        NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyFailToPlay placementID:self.interstitial.placementModel.placementID unitGroupModel:self.interstitial.unitGroup extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.interstitial.requestID != nil ? self.interstitial.requestID : @"", kAgentEventExtraInfoNetworkFirmIDKey:@(self.interstitial.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.interstitial.priority), kAgentEventExtraInfoNetworkErrorCodeKey:@(error.code), kAgentEventExtraInfoNetworkErrorMsgKey:[NSString stringWithFormat:@"%@", error], kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
    }
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToPlayVideoForPlacementID:error:extra:)]) {
        [self.delegate interstitialDidFailToPlayVideoForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]];
    }
}

-(void) trackInterstitialAdShow {
    if (self.interstitial == nil) {
        return;
    }
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.interstitial.placementModel unitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID];
    [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.interstitial event:ATGeneralAdAgentEventTypeImpression extra:self.localInfo error:nil]] type:ATLogTypeTemporary];
    [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.interstitial.placementModel.placementID unitGroupID:self.interstitial.unitGroup.unitGroupID requestID:self.interstitial.requestID];
    [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.interstitial.placementModel.placementID unitGroupID:self.interstitial.unitGroup.unitGroupID];
//        self.sdkTime = [Utilities normalizedTimeStamp];
    NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.interstitial requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey,self.sdkTime,kATTrackerExtraAdShowSDKTimeKey, nil];
    
    if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
    if (self.interstitial.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    if([ATAPI isOfm]){
        trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
        trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
    }
    [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
    
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
    
    [Utilities reportProfit:self.interstitial time:self.sdkTime];
    [[ATFBBiddingManager sharedManager] notifyDisplayWinnerWithID:self.interstitial.unitGroup.unitID placementID:self.interstitial.placementModel.placementID];
//    Class class = NSClassFromString(@"AppsFlyerLib");
//    if (class) {
//        
//        NSString *extraID = [NSString stringWithFormat:@"%@_%@_%@",self.ad.requestID,self.ad.unitGroup.unitID,self.sdkTime];
//        ATPlatfromInfo *platform = [self.ad.placementModel revenueToPlatforms][@(ATRevenueToPlatformAppsflyer).stringValue];
//        id revenue = @([self.ad.price doubleValue] / 1000.f);
//        if (platform.dataType == 2) {
//            revenue = @(self.rewardedVideo.unitGroup.ecpmLevel);
//        }
//        NSDictionary *dic = @{@"af_order_id": extraID,
//                              @"af_content_id":self.ad.placementModel.placementID,
//                              @"af_content":@(self.ad.placementModel.format),
//                              @"af_revenue":revenue,
//                              @"af_currency":self.ad.placementModel.currency,
//        };
//        id<AppsFlyerLibProtocol> appsflyer = (id<AppsFlyerLibProtocol>)[class shared];
//        [appsflyer logEvent:@"af_ad_view" withValues:dic];
//    }
}

- (void)trackInterstitialAdShowFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) { [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:error extra:[self delegateExtra]]; }
}

-(void) trackInterstitialAdClick {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.interstitial event:ATGeneralAdAgentEventTypeClick extra:self.localInfo error:nil]] type:ATLogTypeTemporary];
    
    NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.interstitial requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
    if (self.interstitial.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES; }
    if([ATAPI isOfm]){
        trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey];
        trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
    }
    [[ATTracker sharedTracker] trackClickWithAd:self.ad extra:trackingExtra];
    
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
        [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra]];
    }
}

-(void) trackInterstitialAdDeeplinkOrJumpResult:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(interstitialDeepLinkOrJumpForPlacementID:extra:result:)]) {
        [self.delegate interstitialDeepLinkOrJumpForPlacementID:self.interstitial.placementModel.placementID extra:[self delegateExtra] result:success];
    }
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}
@end
