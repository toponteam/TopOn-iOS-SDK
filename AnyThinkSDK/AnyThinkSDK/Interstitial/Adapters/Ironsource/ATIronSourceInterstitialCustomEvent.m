//
//  ATIronSourceInterstitialCustomEvent.m
//  AnyThinkIronSourceInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATIronSourceInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@implementation ATIronSourceInterstitialCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoaded:) name:kATIronSourceInterstitialNotificationLoaded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShow:) name:kATIronSourceInterstitialNotificationShow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadFailed:) name:kATIronSourceInterstitialNotificationLoadFailed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClose:) name:kATIronSourceInterstitialNotificationClose object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClick:) name:kATIronSourceInterstitialNotificationClick object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) handleLoaded:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID]) {
        [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}];
    }
}

-(void) handleLoadFailed:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID]) {
        NSError *error = notification.userInfo[kATIronSourceInterstitialNotificationUserInfoError];
        [self handleLoadingFailure:error != nil ? error : [NSError errorWithDomain:@"com.anythink.IronSourceInterstitialLoading" code:100001 userInfo:@{NSLocalizedDescriptionKey:@"AnyThinkSDK has failed to load interstitial", NSLocalizedFailureReasonErrorKey:@"IronSource has failed to load interstitial"}]];
    }
}

-(void) handleShow:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackShow];
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
    }
}

-(void) handleClick:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
            [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}

-(void) handleClose:(NSNotification*)notification {
    if ([notification.userInfo[kATIronSourceInterstitialNotificationUserInfoInstanceID] isEqualToString:self.unitID] && self.interstitial != nil) {
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
            [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}
@end
