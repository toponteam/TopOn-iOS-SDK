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
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:@{kATSplashDelegateExtraNetworkIDKey:@(self.ad.unitGroup.networkFirmID),kATSplashDelegateExtraAdSourceIDKey:self.ad.unitGroup.unitID != nil ? self.ad.unitGroup.unitID : @"",kATSplashDelegateExtraIsHeaderBidding:@(self.ad.unitGroup.headerBidding),kATSplashDelegateExtraPriority:@(self.ad.priority),kATSplashDelegateExtraPrice:@(self.ad.price), kATADDelegateExtraSegmentIDKey:@(self.ad.placementModel.groupID), kATADDelegateExtraECPMLevelKey:@(self.ad.unitGroup.ecpmLevel)}];
        NSString *channel = [ATAPI sharedInstance].channel;
        if (channel != nil) { extra[kATADDelegateExtraChannelKey] = channel; }
        NSString *subchannel = [ATAPI sharedInstance].subchannel;
        if (subchannel != nil) { extra[kATADDelegateExtraSubChannelKey] = subchannel; }
        if ([self.ad.placementModel.associatedCustomData count] > 0) { extra[kATADDelegateExtraCustomRuleKey] = self.ad.placementModel.associatedCustomData; }
        NSString *extraID = [NSString stringWithFormat:@"%@%@%@",self.ad.requestID,self.ad.unitGroup.unitID,self.sdkTime];
        extra[kATADDelegateExtraIDKey] = [extraID md5];
        extra[kATADDelegateExtraAdunitIDKey] = self.ad.placementModel.placementID;
        extra[kATADDelegateExtraPublisherRevenueKey] = @(self.ad.price / 1000.0f);
        extra[kATADDelegateExtraCurrencyKey] = self.ad.placementModel.callback[@"currency"];
        extra[kATADDelegateExtraCountryKey] = self.ad.placementModel.callback[@"cc"];
        extra[kATADDelegateExtraFormatKey] = @"Splash";
        extra[kATADDelegateExtraPrecisionKey] = self.ad.unitGroup.precision;
        extra[kATADDelegateExtraNetworkTypeKey] = self.ad.unitGroup.networkFirmID == 35 ? @"Cross_promotion":@"Network";
        
        //add adsource unit_id value
        extra[kATADDelegateExtraNetworkPlacementIDKey] = self.networkUnitId != nil ? self.networkUnitId:@"";
        
        return extra;
    } else {
        return @{kATSplashDelegateExtraNetworkIDKey:self.serverInfo[kATSplashExtraNetworkFirmID],
                 kATADDelegateExtraFormatKey:@"Splash"
        };
    }
}


-(void) trackShowWithoutWaterfall {
    [[ATTracker sharedTracker] trackWithPlacementID:self.unitID requestID:self.serverInfo[kATSplashExtraRequestIDKey] trackType:ATNativeADTrackTypeADShow extra:@{kATTrackerExtraUnitIDKey:@([self.serverInfo[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([self.serverInfo[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
}
-(void) trackClickWithoutWaterfall {
    [[ATTracker sharedTracker] trackWithPlacementID:self.unitID requestID:self.serverInfo[kATSplashExtraRequestIDKey] trackType:ATNativeADTrackTypeADClicked extra:@{kATTrackerExtraUnitIDKey:@([self.serverInfo[kATSplashExtraAdSourceIDKey] integerValue]), kATTrackerExtraNetworkFirmIDKey:@([self.serverInfo[kATSplashExtraNetworkFirmID] integerValue]), kATTrackerExtraTrafficGroupIDKey:@"0", kATTrackerExtraASIDKey:@"0", kATTrackerExtraFormatKey:@(ATAdFormatSplash)}];
}

-(NSInteger)priorityIndex {
    return [ATAdCustomEvent calculateAdPriority:self.ad];;
}

-(void) trackShow {
    if (self.ad != nil) {
        [super trackShow];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:self.ad.placementModel.placementID]; });
           if ([_delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) { [_delegate splashDidShowForPlacementID:self.unitID extra:[self delegateExtra]]; }
    }
   
}


-(void) trackSplashAdClosed {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForPlacementID:extra:)]) { [self.delegate splashDidCloseForPlacementID:self.unitID extra:[self delegateExtra]];
    }
}

-(void) trackSplashAdLoaded:(id)splashAd {
    
    [self handleAssets:@{kAdAssetsCustomObjectKey:splashAd, kAdAssetsCustomEventKey:self, kAdAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"" }];
}

-(void) trackSplashAdShow {
    //only for splash without waterfall
    if(self.ad == nil && self.serverInfo[@"tracking_info_placement_model"] == nil){
        [self trackShowWithoutWaterfall];
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [[ATPlacementSettingManager sharedManager] setStatus:NO forPlacementID:self.ad.placementModel.placementID]; });
           if ([_delegate respondsToSelector:@selector(splashDidShowForPlacementID:extra:)]) { [_delegate splashDidShowForPlacementID:self.unitID extra:[self delegateExtra]]; }
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


@end
 
