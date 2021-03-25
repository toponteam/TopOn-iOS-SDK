//
//  ATMyOfferNativeRenderer.m
//  AnyThinkMyOffer
//
//  Created by Topon on 8/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferNativeRenderer.h"
#import "ATMyOfferNativeCustomEvent.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferOfferModel.h"
#import "ATNativeAdView.h"
#import "ATNativeADCache.h"
#import "Utilities.h"

@protocol ATNativeADView<NSObject>
@property(nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface ATMyOfferNativeRenderer()

@end

@implementation ATMyOfferNativeRenderer

-(__kindof UIView*)createMediaView {
    return nil;
}

-(void) bindCustomEvent {
    ATMyOfferNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    [self bindCustomEvent];
    ATMyOfferOfferModel *offerModel = offer.assets[kAdAssetsCustomObjectKey];
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    [[ATMyOfferOfferManager sharedManager] registerViewForInteraction:self.configuration.rootViewController clickableViews:[self.ADView clickableViews] offerModel:offerModel setting:cache.placementModel.myOfferSetting delegate:(ATMyOfferNativeCustomEvent*)self.ADView.customEvent];
}



@end
