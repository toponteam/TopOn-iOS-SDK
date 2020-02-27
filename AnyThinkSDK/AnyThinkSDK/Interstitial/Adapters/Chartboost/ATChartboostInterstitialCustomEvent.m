//
//  ATChartboostInterstitialCustomEvent.m
//  AnyThinkChartboostInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATChartboostInterstitialCustomEvent.h"
#import "ATChartboostInterstitialAdapter.h"
#import "Utilities.h"
#import "ATInterstitialManager.h"
#import "ATAPI.h"
@interface ATChartboostInterstitialCustomEvent()
@property (nonatomic, weak) ATChartboostInterstitialAdapter *adapter;
@end
@implementation ATChartboostInterstitialCustomEvent
-(instancetype) initWithUnitID:(NSString *)unitID customInfo:(NSDictionary *)customInfo {
    self = [super initWithUnitID:unitID customInfo:customInfo];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterstitialLoadedNotification:) name:kChartboostInterstitialLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterstitialLoadingFailureNotification:) name:kChartboostInterstitialLoadingFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterstitialImpressionNotification:) name:kChartboostInterstitialImpressionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterstitialClickNotification:) name:kChartboostInterstitialClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterstitialCloseNotification:) name:kChartboostInterstitialCloseNotification object:nil];
    }
    return self;
}

-(ATNativeADSourceType) adSourceType {
    return ATNativeADSourceTypeVideo;
}

-(void) handleInterstitialLoadedNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostInterstitialNotificationUserInfoLocationKey]]) {
        [self handleAssets:@{kInterstitialAssetsUnitIDKey:self.unitID != nil ? self.unitID : @"", kInterstitialAssetsCustomEventKey:self, kAdAssetsCustomObjectKey:self.unitID != nil ? self.unitID : @""}];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChartboostInterstitialLoadedNotification object:nil];
    }
}

-(void) handleInterstitialLoadingFailureNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostInterstitialNotificationUserInfoLocationKey]]) {
        [self handleLoadingFailure:notification.userInfo[kChartboostInterstitialNotificationUserInfoErrorKey]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChartboostInterstitialLoadedNotification object:nil];
    }
}

-(void) handleInterstitialImpressionNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostInterstitialNotificationUserInfoLocationKey]]) {
        [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::impressionDelegate:%@", self.unitID] type:ATLogTypeExternal];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kChartboostInterstitialImpressionNotification object:nil];
        [self trackShow];
        if ([self.delegate respondsToSelector:@selector(interstitialDidShowForPlacementID:extra:)]) { [self.delegate interstitialDidShowForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}]; }
    }
}

-(void) handleInterstitialClickNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostInterstitialNotificationUserInfoLocationKey]]) {
        [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::impressionDelegate:%@", self.unitID] type:ATLogTypeExternal];
        [self trackClick];
        if ([self.delegate respondsToSelector:@selector(interstitialDidClickForPlacementID:extra:)]) {
            [self.delegate interstitialDidClickForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}

-(void) handleInterstitialCloseNotification:(NSNotification*)notification {
    if ([self.unitID isEqualToString:notification.userInfo[kChartboostInterstitialNotificationUserInfoLocationKey]]) {
        [ATLogger logMessage:[NSString stringWithFormat:@"ChartboostInterstitial::closeDelegate:%@", self.unitID] type:ATLogTypeExternal];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self handleClose];
        if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForPlacementID:extra:)]) {
            [self.delegate interstitialDidCloseForPlacementID:self.interstitial.placementModel.placementID extra:@{kATInterstitialDelegateExtraNetworkIDKey:@(self.interstitial.unitGroup.networkFirmID), kATInterstitialDelegateExtraAdSourceIDKey:self.interstitial.unitGroup.unitID != nil ? self.interstitial.unitGroup.unitID : @"",kATInterstitialDelegateExtraIsHeaderBidding:@(self.interstitial.unitGroup.headerBidding),kATInterstitialDelegateExtraPriority:@(self.priorityIndex),kATInterstitialDelegateExtraPrice:@(self.interstitial.unitGroup.price)}];
        }
    }
}
@end
