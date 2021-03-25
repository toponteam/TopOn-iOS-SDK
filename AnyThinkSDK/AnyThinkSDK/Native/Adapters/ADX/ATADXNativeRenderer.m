//
//  ATADXNativeRenderer.m
//  AnyThinkSDK
//
//  Created by Topon on 10/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATADXNativeRenderer.h"
#import "ATADXNativeCustomEvent.h"
#import "ATADXNativeAdManager.h"
#import "ATADXOfferModel.h"
#import "ATNativeAdView.h"
#import "ATNativeADCache.h"
#import "Utilities.h"

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface ATADXNativeRenderer()

@end

@implementation ATADXNativeRenderer

-(__kindof UIView*)createMediaView {
    return nil;
}

-(void) bindCustomEvent {
    ATADXNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    ATADXOfferModel *offerModel = offer.assets[kAdAssetsCustomObjectKey];
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    ATADXPlacementSetting *setting = [[ATADXPlacementSetting alloc] initWithPlacementDictionary:cache.placementModel.adxSettingDict infoDictionary:cache.customEvent.serverInfo placementID:cache.placementModel.placementID];
    [[ATADXNativeAdManager sharedManager] registerViewForInteraction:self.configuration.rootViewController adView:self.ADView clickableViews:[self.ADView clickableViews] offerModel:offerModel setting:setting delegate:(ATADXNativeCustomEvent*)self.ADView.customEvent];
}

@end
