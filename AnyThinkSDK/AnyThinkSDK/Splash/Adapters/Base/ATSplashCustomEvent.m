//
//  ATSplashCustomEvent.m
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplashCustomEvent.h"
#import "ATSplashDelegate.h"
#import "ATPlacementSettingManager.h"
#import "NSString+KAKit.h"
#import "ATAdManager+Splash.h"
#import "ATSplashManager.h"
#import "Utilities.h"
#import "ATLoadingScheduler.h"
#import "ATCapsManager.h"
#import "ATGeneralAdAgentEvent.h"
#import "ATAdManager+Internal.h"
#import "ATAPI+Internal.h"

NSString *const kATSplashExtraRequestIDKey = @"request_id";
@implementation ATSplashCustomEvent
-(instancetype) initWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    NSString *unitID = serverInfo[kATSplashExtraPlacementIDKey] != nil ? serverInfo[kATSplashExtraPlacementIDKey] : localInfo[kATSplashExtraPlacementIDKey];
    self = [super initWithUnitID:unitID serverInfo:serverInfo localInfo:localInfo];
    if (self != nil) {
        self.requestNumber = 1;
        _unitID = unitID;
    }
    return self;
}

-(NSDictionary*)delegateExtra {
    if (self.ad != nil) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.ad.priority),kATSplashDelegateExtraPrice:@([self.ad.ecpm doubleValue]), kATADDelegateExtraSegmentIDKey:@(self.ad.placementModel.groupID), kATADDelegateExtraECPMLevelKey:@(self.ad.unitGroup.ecpmLevel)}];
        NSString *channel = [ATAPI sharedInstance].channel;
        if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
        NSString *subchannel = [ATAPI sharedInstance].subchannel;
        if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
        if ([self.ad.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.ad.placementModel.associatedCustomData; }
        NSString *extraID = [NSString stringWithFormat:@"%@_%@_%@",self.ad.requestID,self.ad.unitGroup.unitID,self.sdkTime];
        extra[kATADDelegateExtraIDKey] = extraID;
        extra[kATADDelegateExtraAdunitIDKey] = self.ad.placementModel.placementID;
        extra[kATADDelegateExtraPublisherRevenueKey] = @([self.ad.ecpm doubleValue] / 1000.f);
        extra[kATADDelegateExtraCurrencyKey] = self.ad.placementModel.currency;
        extra[kATADDelegateExtraCountryKey] = self.ad.placementModel.callback[@"cc"];
        extra[kATADDelegateExtraFormatKey] = @"Splash";
        extra[kATADDelegateExtraPrecisionKey] = self.ad.unitGroup.precision;
        extra[kATADDelegateExtraNetworkTypeKey] = self.ad.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
        
        //add adsource unit_id value
        extra[kATADDelegateExtraNetworkPlacementIDKey] = self.networkUnitId != nil ? self.networkUnitId:@"";
        if ([self.networkCustomInfo count] > 0) {
            extra[kATADDelegateExtraExtInfoKey] = self.networkCustomInfo;
        }
        return extra;
    } else {
        return @{kATSplashDelegateExtraNetworkIDKey:self.serverInfo[kATSplashExtraNetworkFirmID] != nil ? self.serverInfo[kATSplashExtraNetworkFirmID] : @"",
                 kATADDelegateExtraFormatKey:@"Splash"
        };
    }
}


-(void) trackShowWithoutWaterfall {
    NSMutableDictionary* trackingExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraUnitIDKey:@([self.serverInfo[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([self.serverInfo[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
    if([ATAPI isOfm]){
        trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
        trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
    }
    [[ATTracker sharedTracker] trackWithPlacementID:self.unitID requestID:self.serverInfo[kATSplashExtraRequestIDKey] trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
}

-(void) trackClickWithoutWaterfall {
    NSMutableDictionary* trackingExtra = [NSMutableDictionary dictionaryWithDictionary:@{kATTrackerExtraUnitIDKey:@([self.serverInfo[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([self.serverInfo[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
    if([ATAPI isOfm]){
        trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
        trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
    }
    
    [[ATTracker sharedTracker] trackWithPlacementID:self.unitID requestID:self.serverInfo[kATSplashExtraRequestIDKey] trackType:ATNativeADTrackTypeADClicked extra:trackingExtra];
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}

-(void) trackShow {
    if (self.ad != nil) {
        [self trackSplashImpression];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:self.ad.placementModel.placementID];
            
        });
        if ([_delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) { [_delegate splashDidShowForPlacementID:self.unitID extra:[self delegateExtra]]; }
    }
}

- (void)trackSplashImpression {
    [[ATLoadingScheduler sharedScheduler] cancelScheduleLoadingWithPlacementModel:self.ad.placementModel unitGroup:self.ad.unitGroup requestID:self.ad.requestID];
    [ATLogger logMessage:[NSString stringWithFormat:@"\nImpression with ad info:\n*****************************\n%@ \n*****************************", [ATGeneralAdAgentEvent logInfoWithAd:self.ad event:ATGeneralAdAgentEventTypeImpression extra:self.localInfo error:nil]] type:ATLogTypeTemporary];
    [[ATCapsManager sharedManager] increaseCapWithPlacementID:self.ad.placementModel.placementID unitGroupID:self.ad.unitGroup.unitGroupID requestID:self.ad.requestID];
    [[ATCapsManager sharedManager] setLastShowTimeWithPlacementID:self.ad.placementModel.placementID unitGroupID:self.ad.unitGroup.unitGroupID];
    
    NSDictionary *loadExtra = [self.localInfo isKindOfClass:[NSDictionary class]] ? self.localInfo : nil;
    NSMutableDictionary *trackingExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:@([loadExtra[kAdLoadingExtraRefreshFlagKey] boolValue]), kATTrackerExtraRefreshFlagKey, @([loadExtra[kAdLoadingExtraAutoloadFlagKey] boolValue]), kATTrackerExtraAutoloadFlagKey, @([loadExtra[kAdLoadingExtraDefaultLoadKey] boolValue]), kATTrackerExtraDefaultLoadFlagKey, [ATTracker headerBiddingTrackingExtraWithAd:self.ad requestID:self.ad.requestID], kATTrackerExtraHeaderBiddingInfoKey, self.ad.unitGroup.unitID, kATTrackerExtraUnitIDKey, @(self.ad.unitGroup.networkFirmID), kATTrackerExtraNetworkFirmIDKey, @(self.ad.renewed), kATTrackerExtraOfferLoadedByAdSourceStatusFlagKey, self.sdkTime,kATTrackerExtraAdShowSDKTimeKey,nil];
    if (self.ad.autoReqType == 5) { trackingExtra[kATTrackerExtraRequestExpectedOfferNumberFlagKey] = @YES;
    }
    if([ATAPI isOfm]){
        trackingExtra[kATTrackerExtraOFMTrafficIDKey] = self.localInfo[kATTrackerExtraOFMTrafficIDKey]==nil?@(0):self.localInfo[kATTrackerExtraOFMTrafficIDKey];
        trackingExtra[kATTrackerExtraOFMSystemKey] = @(1);
    }
    
    [[ATTracker sharedTracker] trackWithPlacementID:self.ad.placementModel.placementID requestID:self.ad.requestID trackType:ATNativeADTrackTypeADShow extra:trackingExtra];
    [Utilities reportProfit:self.ad time:self.sdkTime];
}

-(void) trackSplashAdClosed {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.unitID extra:[self delegateExtra]];
    }
//    [[ATSplashManager sharedManager] clearCahceForPlacementID:self.unitID];
    [[ATSplashManager sharedManager] ckearDefaultSplash];
}

-(void) trackSplashAdLoaded:(id)splashAd {
    [self handleAssets:@{kAdAssetsCustomObjectKey:splashAd, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
}

-(void) trackSplashAdLoaded:(id)splashAd adExtra:(NSDictionary *)adExtra {
    NSMutableDictionary *assets;
    if(adExtra != nil){
        assets = [NSMutableDictionary dictionaryWithDictionary:adExtra];
    }else{
        assets = [NSMutableDictionary dictionary];
    }
    if(splashAd != nil){
        assets[kAdAssetsCustomObjectKey] = splashAd;
    }
    assets[kAdAssetsCustomEventKey] = self;
    if ([self.unitID length] > 0) assets[kAdAssetsUnitIDKey] = self.unitID;
    [self handleAssets:assets];
}

-(void) trackSplashAdShow {
    //only for splash without waterfall
    if(self.ad == nil && self.serverInfo[@"tracking_info_placement_model"] == nil){
        [self trackShowWithoutWaterfall];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:self.ad.placementModel.placementID];
        });
        if ([_delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) { [_delegate splashDidShowForPlacementID:self.unitID extra:[self delegateExtra]];
        }
    }else {
        [self trackShow];
    }
}

-(void) trackSplashAdClick {
    if (self.ad != nil) {
        [super trackClick];
    } else {
        [self trackClickWithoutWaterfall];
    }
    //delegate callback click
    if ([self.delegate respondsToSelector:@selector(splashDidClickForPlacementID:extra:)]) {
        [self.delegate splashDidClickForPlacementID:self.unitID extra:[self delegateExtra]];
    }
}

-(void) trackSplashAdLoadFailed:(NSError*)error {
    [self handleLoadingFailure:error];
}


- (void)trackSplashAdZoomOutViewClick {
    if (self.ad != nil) {
        [super trackClick];
    } else {
        [self trackClickWithoutWaterfall];
    }
    //delegate callback click
    if ([self.delegate respondsToSelector:@selector(splashZoomOutViewDidClickForPlacementID:extra:)]) {
        [self.delegate splashZoomOutViewDidClickForPlacementID:self.unitID extra:[self delegateExtra]];
    }
}

- (void)trackSplashAdZoomOutViewClosed {
    //delegate callback click
    if ([self.delegate respondsToSelector:@selector(splashZoomOutViewDidCloseForPlacementID:extra:)]) {
        [self.delegate splashZoomOutViewDidCloseForPlacementID:self.unitID extra:[self delegateExtra]];
    }
}

- (void)trackSplashAdDeeplinkOrJumpResult:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(splashDeepLinkOrJumpForPlacementID:extra:result:)]) {
        [self.delegate splashDeepLinkOrJumpForPlacementID:self.unitID extra:[self delegateExtra] result:success];
    }
}
@end
 
