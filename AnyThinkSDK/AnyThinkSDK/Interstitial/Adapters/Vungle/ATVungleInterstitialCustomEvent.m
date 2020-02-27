//
//  ATVungleInterstitialCustomEvent.m
//  AnyThinkVungleInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATVungleInterstitialCustomEvent.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
@interface ATVungleInterstitialCustomEvent()
@end
@implementation ATVungleInterstitialCustomEvent
-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

-(void) handlerPlayError:(NSError*)error {
    [ATLogger logMessage:[NSString stringWithFormat:@"VungleInterstitial::play error:%@", error] type:ATLogTypeExternal];
    if ([self.delegate respondsToSelector:@selector(interstitialFailedToShowForPlacementID:error:extra:)]) {
        [self.delegate interstitialFailedToShowForPlacementID:self.interstitial.placementModel.placementID error:error extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
    }
}

-(void) handleLoadNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID]) {
        [ATLogger logMessage:@"VungleInterstitial::load" type:ATLogTypeExternal];
        [self handleAssets:@{kInterstitialAssetsCustomEventKey:self, kInterstitialAssetsUnitIDKey:[self.unitID length] > 0 ? self.unitID : @"", kAdAssetsCustomObjectKey:self.unitID}];
    }
}

-(void) handleShowNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [ATLogger logMessage:@"VungleInterstitial::show" type:ATLogTypeExternal];
        [self trackShow];
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
    }
}

-(void) handleCloseNotification:(NSNotification*)notification {
    if ([notification.userInfo[kVungleInterstitialNotificationUserInfoPlacementIDKey] isEqualToString:self.unitID] && self.interstitial != nil) {
        [ATLogger logMessage:@"VungleInterstitial::close" type:ATLogTypeExternal];
        if ([notification.userInfo[kVungleInterstitialNotificationUserInfoClickFlagKey] boolValue]) {
            [self trackClick];
            if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
                [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
            }
        }
        
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
            [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo adapter:(ATVungleInterstitialAdapter*)adapter {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadNotification:) name:kVungleInterstitialLoadNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowNotification:) name:kVungleInterstitialShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCloseNotification:) name:kVungleInterstitialCloseNotification object:nil];
    }
    return self;
}
@end