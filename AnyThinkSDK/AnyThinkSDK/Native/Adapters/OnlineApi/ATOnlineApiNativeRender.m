//
//  ATOnlineApiNativeRender.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/21.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOnlineApiNativeRender.h"
#import "ATNativeAdView.h"
#import "ATNativeADCache.h"
#import "Utilities.h"
#import "ATOnlineApiNativeAdCustomEvent.h"
#import "ATOnlineApiOfferModel.h"
#import "ATOnlineApiPlacementSetting.h"
#import "ATOnlineApiNativeAdManager.h"

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface ATOnlineApiNativeRender ()

@end

@implementation ATOnlineApiNativeRender
- (void)bindCustonEvent {
    ATOnlineApiNativeAdCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

- (void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustonEvent];
    ATOnlineApiOfferModel *offerModel = offer.assets[kAdAssetsCustomObjectKey];
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    ATOnlineApiPlacementSetting *setting = [[ATOnlineApiPlacementSetting alloc]initWithPlacementDictionary:cache.placementModel.olApiSettingDict infoDictionary:cache.customEvent.serverInfo placementID:cache.placementModel.placementID];
    [[ATOnlineApiNativeAdManager sharedManager] registerViewCtrlForInteraction:self.configuration.rootViewController adView:self.ADView clickableViews:[self.ADView clickableViews] offerModel:offerModel setting:setting delegate:(ATOnlineApiNativeAdCustomEvent *)self.ADView.customEvent];
}
@end
