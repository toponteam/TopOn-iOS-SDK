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
@implementation ATInterstitialCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        self.requestNumber = 1;
        self.priorityIndex = [ATAdCustomEvent calculateAdPriority:self.ad];
        _unitID = unitID;
    }
    return self;
}

-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeUnknown;
}

-(void) handleClose {
    [super handleClose];
    if (self.interstitial != nil) {
        if (self.interstitial.placementModel.autoRefresh) {
            [[ATAdManager sharedManager]loadADWithPlacementID:self.interstitial.placementModel.placementID extra:@{kAdLoadingExtraAutoLoadOnCloseFlagKey:@YES} delegate:nil];
        }
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyClose placementID:self.interstitial.placementModel.placementID unitGroupModel:nil
                                               extraInfo:@{kAgentEventExtraInfoRequestIDKey:self.interstitial.requestID != nil ? self.interstitial.requestID : @"", kAgentEventExtraInfoNetworkFirmIDKey:@(self.interstitial.unitGroup.networkFirmID), kAgentEventExtraInfoUnitGroupUnitIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"", kAgentEventExtraInfoPriorityKey:@(self.interstitial.priority), kAgentEventExtraInfoAutoloadOnCloseFlagKey:@([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue] ? 1 : 0)}];
    }
    
}

-(void) trackVideoStart {
    if (self.interstitial != nil) {
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeAdTrackTypeVideoStart extra:trackingExtra];
    }
}

-(void) trackVideoEnd {
    if (self.interstitial != nil) {
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeAdTrackTypeVideoEnd extra:trackingExtra];
    }
}

-(void) trackShow {
    if (self.interstitial != nil) {
        [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.interstitial.placementModel unitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID];
        [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.interstitial event:ATGeneralAdAgentEventTypeImpression extra:self.customInfo[kAdapterCustomInfoExtraKey] error:nil]] type:ATLogTypeTemporary];
        [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.interstitial.placementModel.placementID unitGroupID:self.interstitial.unitGroup.unitGroupID requestID:self.interstitial.requestID];
        [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.interstitial.placementModel.placementID unitGroupID:self.interstitial.unitGroup.unitGroupID];
        
        NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
        NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
        
        if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
        [[ATTracker sharedTracker] trackWithPlacementID:self.interstitial.placementModel.placementID requestID:self.interstitial.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
    }
}

-(void) trackClick {
    [ATLogger logMessage:[NSString stringWithFormat:@"\nClick with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.interstitial event:ATGeneralAdAgentEventTypeClick extra:self.customInfo[kAdapterCustomInfoExtraKey] error:nil]] type:ATLogTypeTemporary];
    
    NSDictionary *loadExtra = [self.customInfo[kAdapterCustomInfoExtraKey] isKindOfClass:[NSDictionary class]] ? self.customInfo[kAdapterCustomInfoExtraKey] : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithUnitGroup:self.interstitial.unitGroup requestID:self.interstitial.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.interstitial.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.interstitial.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @([loadExtra[kAdLoadingExtraFilledByReadyFlagKey] boolValue]), kATTrackerExtraAdFilledByReadyFlagKey, @([loadExtra[kAdLoadingExtraAutoLoadOnCloseFlagKey] boolValue]), kATTrackerExtraAutoloadOnCloseFlagKey, @(self.interstitial.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, nil];
    if (self.interstitial.scene != nil) { trackingExtra[kATTrackerExtraAdShowSceneKey] = self.interstitial.scene; }
    [[ATTracker sharedTracker] trackClickWithAd:self.ad extra:trackingExtra];
}
@end
